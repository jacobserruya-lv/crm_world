/**
* @author Keman WU
* @date Creation 22/09/2022
* @Batch Apex
* @description auto change status for distant care service
*/
global class ICX_BatchChangeMyRepairOrder implements Database.Batchable<sObject>,Database.AllowsCallouts {
    global Set<ID> setIdCare;
    String query;
    global ICX_BatchChangeMyRepairOrder(Set<ID> setIdCare) {
        system.debug('setIdCare ' +setIdCare.size());
        this.setIdCare = setIdCare;
        query = 'select id,CreatedDate,SKU__c,Shipping_Address_Line_1__c,Shipping_Address_Line_2__c,Shipping_City__c,Shipping_Zip_Postal_Code__c,Shipping_State_Province__c,Shipping_Country__c,Client_Comments__c,FollowupBy_Email__c,FollowupBy_Call__c,FollowupBy_Video_Call__c,FollowupBy_Chat__c,Product_Sku_unknown__c,Category__c,Repair_Center_Comments__c,MyRepairStatus__c,Delivery_Date__c,CA_Code__c,TransactionId__c,StoreRetailCode__c,ICONiCS_Status_Detail__c,Client__r.PersonEmail,Client__r.Salutation,Client__r.ECO_ClientId__c,Client__r.LastName,Client__r.Lastname2__pc,Client__r.FirstName,Client__r.Firstname2__pc,Client__r.PersonHomePhone,Client__r.HomePhoneCountrycode__pc,Client__r.Nationality__pc,Client__r.PersonMobilePhone,Client__r.MobilePhoneCountryCode__pc,Client__r.AttachedStore__pc,Client__r.AttachedStoreCode__pc,Client__r.RMSId__pc,Client__r.Phone,Client__r.WorkPhoneCountryCode__pc,Product__r.SKU__c,Price_Update_Reason__c,TotalAmount_Updated__c from CareService__c '+
        'where id in : setIdCare';
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
    
        return Database.getQueryLocator(query) ;
}

global void execute(Database.BatchableContext bc, List<CareService__c> scope){
    if(scope.size()>0) {      
   try{  
    List<CareService__c> listCareToUpdate = new List<CareService__c>() ;  
    MuleSoft_API_Callout__mdt ApiCallout = MuleSoft_API_Callout__mdt.getInstance('MyRepair_HandleSalesForceOrderStatus');
            
        for(CareService__c care : scope){
                HttpRequest req = new HttpRequest();          
                req.setHeader('Content-Type', ApiCallout.ContentType__c);         
                req.setHeader('client_id', ApiCallout.ClientId__c);   
                req.setHeader('client_secret', ApiCallout.ClientSecret__c);  
                req.setEndpoint(ApiCallout.Endpoint__c);
                req.setMethod(ApiCallout.Method__c);  
                req.setTimeout(Integer.valueOf(ApiCallout.Timeout__c));
                req.setBody(ICX_XmlRequestGenerator.MyRepairRequestBuilder('handleSalesForceOrderStatus',care));
                System.debug('### Request Endpoint : '+req.getEndpoint()); 
                HttpResponse response = new HttpResponse();               
                Http http = new Http();            
                response = http.send(req);
                System.debug('### Reponse Body : '+response.getBody());
                care.MyRepair_Request_Body__c =  req.getBody();
                care.MyRepair_Response_Body__c =  response.getBody();
                care.MyRepair_Error__c = ''; 
                Dom.Document doc = response.getBodyDocument();
                Dom.XMLNode root = doc.getRootElement();
                Dom.XMLNode body = root.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
                Dom.XMLNode myRepairOrderId;
                Dom.XMLNode resultCode;
                Dom.XMLNode resultMessage;
                Dom.XMLNode salesForceOrderId;
                    
                    if(body.getChildElement('SalesForceOrderStatusResultImpl','http://www.atg.com/com.vuitton.myrepairs.commerce.order.salesforce.status')!=null){
                        Dom.XMLNode SalesForceOrderStatusResultImpl = body.getChildElement('SalesForceOrderStatusResultImpl','http://www.atg.com/com.vuitton.myrepairs.commerce.order.salesforce.status');
                        
                        myRepairOrderId  = SalesForceOrderStatusResultImpl.getChildElement('myRepairOrderId',null);
                        resultCode  = SalesForceOrderStatusResultImpl.getChildElement('resultCode',null);
                        resultMessage  = SalesForceOrderStatusResultImpl.getChildElement('resultMessage',null);
                        salesForceOrderId  = SalesForceOrderStatusResultImpl.getChildElement('salesForceOrderId',null);
                        System.debug('myRepairOrderId Value: ' + myRepairOrderId.getText());
                        System.debug('resultCode Value: ' + resultCode.getText());
                        System.debug('resultMessage Value: ' + resultMessage.getText());
                        System.debug('salesForceOrderId Value: ' + salesForceOrderId.getText());
                        if(String.isBlank(myRepairOrderId.getText()))
                            care.MyRepair_Error__c = 'Order Status Error : '+ resultCode.getText() + ' ' + resultMessage.getText();      
                    }
                    
                    if(body.getChildElement('Fault','http://schemas.xmlsoap.org/soap/envelope/') != null){
                        //Erreur msg
                        Dom.XMLNode Fault = body.getChildElement('Fault','http://schemas.xmlsoap.org/soap/envelope/');
                        System.debug('Fault: ' + Fault.getChildElement('faultcode',null).getText());
                        System.debug('Fault: ' + Fault.getChildElement('faultstring',null).getText());
                        care.MyRepair_Error__c = 'Callout Error : '+ Fault.getChildElement('faultstring',null).getText();
                        }
                     
                      listCareToUpdate.add(care);  
                    }  
                    update listCareToUpdate;     
   }catch (DmlException e){
    System.debug('#### Auto Change Status Careservice '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
   }
   
}
}
public void finish(Database.BatchableContext bc){
   
}


}