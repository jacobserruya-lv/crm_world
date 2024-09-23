global class ICX_RevisedETABatch implements  Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts { 
   
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date tenWeeksFromNow = (Date.Today()).addDays(70);
        Date today = Date.Today();
        List<String> orderStatusFinished = new List<String> {'Cancelled','Finalized'};
        return Database.getQueryLocator([SELECT Id,OrderShipping__c, OrderShipping__r.ShippingNumber__c,  OrderShipping__r.ShippingNumberV2__c  ,Order__c,Order__r.OrderNumber__c,Revised_Eta_Max__c,Revised_Eta_Min__c FROM OrderLine__c WHERE ((Initial_Eta_Max__c<=:tenWeeksFromNow AND Initial_Eta_Max__c>=:today) OR Revised_Eta_Max__c >=:today) AND Order__r.StatusIconics__c  NOT IN: orderStatusFinished ORDER BY Initial_Eta_Max__c ASC  ]);
    }


    global void execute(Database.BatchableContext BC, list<OrderLine__c> scope){
        List<OrderLine__c> orderLineToUpdate = new List<OrderLine__c>();

        for( OrderLine__c currentOrderLine : scope) {
            
            try {   
            Date initialRevisedEtaMax = currentOrderLine.Revised_Eta_Max__c;
            Date initialRevisedEtaMin = currentOrderLine.Revised_Eta_Min__c;

            String endPoint = '/spl-eu/cust-orders-oms/v1/api/orders/v2/'+ currentOrderLine.Order__r.OrderNumber__c;
            HTTP_Utils request = new HTTP_Utils()
            .get('callout:MULESOFT_KBRW' + endpoint)
            .header('Encoding', 'UTF-8')
            .header('Content-Type', 'application/json')
            .header('Accept', 'application/json')
            .header('client_id', '{!$Credential.UserName}')
            .header('client_secret', '{!$Credential.Password}')
            .timeout(120000)
            .call();
    
            Map<String, Object> response = request.getBodyResponse();
            system.debug('ICX_RevisedETABatch response : ' + response);
            
            if (request.statusCode() == 200 ) {
                    // Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    List<Object> shipping_groups = (List<Object>) response.get('shipping_groups');

                    //oblige to do for in for if there is multiple shippingGroup/orderLine in one order
                    for(Object currentShippingGroup : shipping_groups) {

                        Map<String, Object> shippingGroupMap = (Map<String, Object>)currentShippingGroup;

                        String shippingNumber = (String) shippingGroupMap.get('request_id');

                        system.debug('ICX_RevisedETABatch shippingGroupMap shippingNumber : ' + currentOrderLine.OrderShipping__r.ShippingNumberV2__c);
                        system.debug('ICX_RevisedETABatch shippingNumber API : ' + shippingNumber);

                        if(shippingNumber == currentOrderLine.OrderShipping__r.ShippingNumberV2__c) {
                            
                            system.debug('ICX_RevisedETABatch shippingGroupMap : ' + shippingGroupMap);
                            Map<String, Object> revisedEta = (Map<String, Object>) shippingGroupMap.get('revised_eta');
                            system.debug('ICX_RevisedETABatch shippingGroupMap revised_eta : ' +revisedEta);
                            String revisedEtaMin = (String) revisedEta.get('min');
                            String revisedEtaMax = (String) revisedEta.get('max');
                            
                            currentOrderLine.Revised_Eta_Max__c=revisedEtaMax!=null? date.newInstance(Integer.ValueOF(revisedEtaMax.replaceAll('\\s+', '').split('-')[0]),Integer.ValueOF(revisedEtaMax.replaceAll('\\s+', '').split('-')[1]),Integer.ValueOF(revisedEtaMax.replaceAll('\\s+', '').split('-')[2])):initialRevisedEtaMax;
                            currentOrderLine.Revised_Eta_Min__c=revisedEtaMin!=null? date.newInstance(Integer.ValueOF(revisedEtaMin.replaceAll('\\s+', '').split('-')[0]),Integer.ValueOF(revisedEtaMin.replaceAll('\\s+', '').split('-')[1]),Integer.ValueOF(revisedEtaMax.replaceAll('\\s+', '').split('-')[2])):initialRevisedEtaMin;
                            
                            
                            if(initialRevisedEtaMax!=currentOrderLine.Revised_Eta_Max__c || initialRevisedEtaMin!=currentOrderLine.Revised_Eta_Min__c) {
                            System.debug('ICX_RevisedETABatch currentOrderLine : ' + currentOrderLine);
                            orderLineToUpdate.add(currentOrderLine);
                            }
                            break;
                        }
                    }
                } else {
                    System.debug('ICX_RevisedETABatch error with get order details : ' + response);
                }
                
            } catch(Exception e) {
                System.debug('ICX_RevisedETABatch got an error in the revised ETA update Batch: ' + e);
            }
        }

        System.debug('ICX_RevisedETABatch orderLineToUpdate : ' + orderLineToUpdate);
        
        update orderLineToUpdate;

    }


    global void finish(Database.BatchableContext BC){}

    global void execute(SchedulableContext sc) {
        ICX_RevisedETABatch b = new ICX_RevisedETABatch(); 
        database.executebatch(b,100);
    }

}