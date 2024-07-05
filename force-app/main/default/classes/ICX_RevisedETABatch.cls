global class ICX_RevisedETABatch implements  Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts { 
   
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date tenWeeksFromNow = (Date.Today()).addDays(70);
        Date today = Date.Today();
        List<String> orderStatusFinished = new List<String> {'Cancelled','Finalized'};
        return Database.getQueryLocator([SELECT Id,OrderShipping__c, OrderShipping__r.ShippingNumber__c ,Order__c,Order__r.OrderNumber__c,Revised_Eta_Max__c,Revised_Eta_Min__c FROM OrderLine__c WHERE ((Initial_Eta_Max__c<=:tenWeeksFromNow AND Initial_Eta_Max__c>=:today) OR Revised_Eta_Max__c >=:today) AND Order__r.StatusIconics__c  NOT IN: orderStatusFinished ORDER BY Initial_Eta_Max__c ASC  ]);
    }
    global void execute(Database.BatchableContext BC, list<OrderLine__c> scope){
        List<OrderLine__c> orderLineToUpdate = new List<OrderLine__c>();
        for( OrderLine__c currentOrderLine : scope)
        {
            try{   
            Date initialRevisedEtaMax = currentOrderLine.Revised_Eta_Max__c;
            Date initialRevisedEtaMin = currentOrderLine.Revised_Eta_Min__c;
            
            Http http = new Http();    
            HttpRequest request = new HttpRequest();
            
            string endPoint = '/customer-orders/api/orders/v1/'+ currentOrderLine.Order__r.OrderNumber__c;
            request.setEndpoint('callout:MULESOFT_KBRW' + endPoint);
            request.setMethod('GET');
            request.setTimeout(120000);
            request.setHeader('Encoding', 'UTF-8');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Content-Type', 'application/json');            
            request.setHeader('client_id', '{!$Credential.UserName}');
            request.setHeader('client_secret', '{!$Credential.Password}');
                HttpResponse response = http.send(request);
                if (response.getStatusCode() == 200 ) {
                        Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                        system.debug('results ' + results);
                        List<Object> order_lines = (List<Object>) results.get('order_lines');

                        //oblige to do for in for if there is multiple shippingGroup/orderLine in one order
                        for(Object currentOrderLineAPI : order_lines)
                        {

                            Map<String, Object> orderLine = (Map<String, Object>)currentOrderLineAPI;

                            String shippingNumber = (String) orderLine.get('request_id');

                            system.debug('orderLine shippingNumber  ' + currentOrderLine.OrderShipping__r.ShippingNumber__c.split('-')[0]);
                            system.debug('shippingNumber API  ' + shippingNumber);

                            if(shippingNumber==currentOrderLine.OrderShipping__r.ShippingNumber__c.split('-')[0])
                            {

                                
                                system.debug('orderLine  ' + orderLine);
                                Map<String, Object> revisedEta = (Map<String, Object>) orderLine.get('revised_eta');
                                system.debug('orderLine revised_eta ' +revisedEta);
                                String revisedEtaMin = (String) revisedEta.get('min');
                                String revisedEtaMax = (String) revisedEta.get('max');
                                
                                
                                
                                
                                currentOrderLine.Revised_Eta_Max__c=revisedEtaMax!=null? date.newInstance(Integer.ValueOF(revisedEtaMax.replaceAll('\\s+', '').split('-')[0]),Integer.ValueOF(revisedEtaMax.replaceAll('\\s+', '').split('-')[1]),Integer.ValueOF(revisedEtaMax.replaceAll('\\s+', '').split('-')[2])):initialRevisedEtaMax;
                                currentOrderLine.Revised_Eta_Min__c=revisedEtaMin!=null? date.newInstance(Integer.ValueOF(revisedEtaMin.replaceAll('\\s+', '').split('-')[0]),Integer.ValueOF(revisedEtaMin.replaceAll('\\s+', '').split('-')[1]),Integer.ValueOF(revisedEtaMax.replaceAll('\\s+', '').split('-')[2])):initialRevisedEtaMin;
                                
                                
                                if(initialRevisedEtaMax!=currentOrderLine.Revised_Eta_Max__c || initialRevisedEtaMin!=currentOrderLine.Revised_Eta_Min__c)
                                {
                                System.debug('currentOrderLine ' + currentOrderLine);
                                orderLineToUpdate.add(currentOrderLine);
                            }
                            break;
                        }
                        }

                    }
                    else{
                        System.debug('error with get order details ' + response.getBody());

                    }
                
            }
            catch(Exception e)
            {
                System.debug('got an error in the revised ETA update Batch: ' + e);

            }
        }
        System.debug('orderLineToUpdate : ' + orderLineToUpdate);
        update orderLineToUpdate;

    }
    global void finish(Database.BatchableContext BC){}

    global void execute(SchedulableContext sc) {
        ICX_RevisedETABatch b = new ICX_RevisedETABatch(); 
        database.executebatch(b,100);
    }

}