/*
CreatedDate: June 2023
Company: VO2
Author: Keman WU
Description: Interface Web Sevice to receive Ixopay payment status
*/
@RestResource(urlMapping='/IxopayPaymentStatus/*')
global with sharing class WS_PaymentStatusNotification {
    
    @HttpPost
    global static void doPost( ) {
        RestRequest req = RestContext.request;
        system.debug(req.requestURI);
        
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        
        
        try{
            if (req.requestBody != null) {
                String stringBody = req.requestBody.toString();                
                IxopayNotificationJson body =  parse(stringBody.replace('"currency":', '"currency_x":'));       
                system.debug('body : ' + body);
                Ixopay_Transaction__c payment = new Ixopay_Transaction__c ();
                if(body.result=='OK') {				
                    payment.Status__c = 'Success';					
                }else if(body.result=='ERROR') {						
                    payment.Status__c = 'Error';
                    payment.Message__c = (body.adapterMessage != null?body.adapterMessage:'') + ' '+ (body.message != body.adapterMessage?body.message:'');				
                }else if(body.result=='PENDING'){
                    payment.Status__c = 'Pending';
                }
                
                payment.uuid__c = body.uuid;
                payment.Statut_Date__c = system.now();
                payment.Care_Service__r = new CareService__c(TransactionId__c=body.merchantMetaData);
                payment.Transaction_Type__c = body.transactionType;
                payment.Payment_Method__c = body.paymentMethod  +' '+ (body.returnData.type != null?body.returnData.type:'');
                payment.Amount__c = Decimal.valueOf(body.amount);
                payment.Currency__c = body.currency_x;
                
                try{
                    insert payment;
                    res.statusCode = 200; 
                    
                }catch(DmlException ex){
                    system.debug('ERROR ' + ex.getMessage());
                    String jsonResponse = '{"message":"'+ex.getMessage()+'","uuid":"' + body.uuid +'"}';
                    res.responseBody = blob.valueOf(jsonResponse);
                    throw new DmlException(ex.getMessage());
                    
                }
                
                
                
                //String jsonResponse = '{"statusCode": "200","status": "success","uuid":' + body.uuid +'}';
                //res.responseBody = blob.valueOf(jsonResponse);
            }   
            
        }catch(Exception ex){
            res.statusCode = 500;
            system.debug('ERROR POSTBACK '+ex);
            
        }
        
        
    }
    
    
    public static IxopayNotificationJson parse(String json){
        return (IxopayNotificationJson) System.JSON.deserialize(json, IxopayNotificationJson.class);
    }

}