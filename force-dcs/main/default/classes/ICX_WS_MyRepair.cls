/*	 * @author Keman WU
* @date creation 23/08/2021
* @description Create repair order to MyRepair/ update status
*/
public with sharing class ICX_WS_MyRepair {
    //Create MyRepair Order
    @AuraEnabled (cacheable=true)
    public static String createRepairOrder(ID careId) {
        CareService__c care =[SELECT id,
                                     CreatedDate,
                                     SKU__c,
                                     Shipping_Address_Line_1__c,
                                     Shipping_Address_Line_2__c,
                                     Shipping_City__c,
                                     Shipping_Zip_Postal_Code__c,
                                     Shipping_State_Province__c,
                                     Shipping_Country__c,
                                     Client_Comments__c,
                                     FollowupBy_Email__c,
                                     FollowupBy_Call__c,
                                     FollowupBy_Video_Call__c,
                                     FollowupBy_Chat__c,
                                     Product_Sku_unknown__c,
                                     Category__c,
                                     Repair_Center_Comments__c,
                                     MyRepairStatus__c,
                                     Delivery_Date__c,
                                     CA_Code__c,
                                     TransactionId__c,
                                     StoreRetailCode__c,
                                     Store__r.Store_CountryCode__c,
                                     ICONiCS_Status_Detail__c,
                                     Client__r.PersonEmail,
                                     Client__r.Salutation,
                                     Client__r.ECO_ClientId__c,
                                     Client__r.LastName,
                                     Client__r.Lastname2__pc,
                                     Client__r.FirstName,
                                     Client__r.Firstname2__pc,
                                     Client__r.PersonHomePhone,
                                     Client__r.HomePhoneCountrycode__pc,
                                     Client__r.Nationality__pc,
                                     Client__r.PersonMobilePhone,
                                     Client__r.MobilePhoneCountryCode__pc,
                                     Client__r.AttachedStore__pc,
                                     Client__r.AttachedStoreCode__pc,
                                     Client__r.RMSId__pc,
                                     Client__r.C360GoldenID__c,
                                     Client__r.Phone,
                                     Client__r.WorkPhoneCountryCode__pc,
                                     Product__r.SKU__c,
                                     Destination__c
                                FROM CareService__c 
                                WHERE id =:careId];   
              String returnString = null;
            //Request
            HttpRequest req = new HttpRequest();      
            if(care.ICONiCS_Status_Detail__c=='Pending Customer information' || care.ICONiCS_Status_Detail__c=='Assigned' ){
                MuleSoft_API_Callout__mdt ApiCallout = MuleSoft_API_Callout__mdt.getInstance('MyRepair_HandleSalesForceOrder');
                req.setHeader('Content-Type', ApiCallout.ContentType__c);         
                req.setHeader('client_id', ApiCallout.ClientId__c);   
                req.setHeader('client_secret', ApiCallout.ClientSecret__c);  
                req.setEndpoint(ApiCallout.Endpoint__c);  
                req.setMethod(ApiCallout.Method__c);
                req.setTimeout(Integer.valueOf(ApiCallout.Timeout__c));
                req.setBody(ICX_XmlRequestGenerator.MyRepairRequestBuilder('handleSalesForceOrder',care));
                       

            System.debug('### Request Endpoint : '+req.getEndpoint());           
            
            //Reponse
            HttpResponse response = new HttpResponse();
            try {
                Http http = new Http();            
                response = http.send(req);
                System.debug('### Reponse Body : '+response.getBody());
                care.MyRepair_Request_Body__c =  req.getBody();
                care.MyRepair_Response_Body__c =  response.getBody();
                
                Dom.Document doc = response.getBodyDocument();
                Dom.XMLNode root = doc.getRootElement();
                Dom.XMLNode body = root.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
                Dom.XMLNode myRepairOrderId;
                Dom.XMLNode resultCode;
                Dom.XMLNode resultMessage;
                Dom.XMLNode myRepairOrderHeadId;
               
                if(body.getChildElement('SalesForceOrderResultImpl','http://www.atg.com/com.vuitton.myrepairs.commerce.order.salesforce.adapter')!= null){
                    //success msg
                    Dom.XMLNode SalesForceOrderResultImpl  = body.getChildElement('SalesForceOrderResultImpl','http://www.atg.com/com.vuitton.myrepairs.commerce.order.salesforce.adapter');
                    myRepairOrderHeadId = SalesForceOrderResultImpl.getChildElement('myRepairOrderHeadId', null);
                    myRepairOrderId  = SalesForceOrderResultImpl.getChildElement('myRepairOrderId',null);
                    resultCode  = SalesForceOrderResultImpl.getChildElement('resultCode',null);
                    resultMessage  = SalesForceOrderResultImpl.getChildElement('resultMessage',null);
                    System.debug('myRepairOrderHeadId Value: ' + myRepairOrderHeadId.getText());
                    System.debug('myRepairOrderId Value: ' + myRepairOrderId.getText());
                    System.debug('resultCode Value: ' + resultCode.getText());
                    System.debug('resultMessage Value: ' + resultMessage.getText());
                    System.debug('IS null myRepairOrderId: ' + String.isBlank(myRepairOrderId.getText()));
                    if(String.isBlank(myRepairOrderId.getText())) {  
                        returnString = 'Order Creation Error : '+ resultCode.getText() + ' ' + resultMessage.getText();  
                    }else{
                        returnString = myRepairOrderId.getText()+';'+myRepairOrderHeadId.getText();                      
                    }   
                }            
                
                if(body.getChildElement('Fault','http://schemas.xmlsoap.org/soap/envelope/') != null){
                    //Erreur msg
                    Dom.XMLNode Fault = body.getChildElement('Fault','http://schemas.xmlsoap.org/soap/envelope/');
                    System.debug('Fault: ' + Fault.getChildElement('faultcode',null).getText());
                    System.debug('Fault: ' + Fault.getChildElement('faultstring',null).getText());
                  
                    returnString = 'Callout Error : '+ Fault.getChildElement('faultstring',null).getText();
                    /* for(Dom.XMLNode child : Fault.getChildElements() ){

                        System.debug('child: ' + child.getName());
                        System.debug('child: ' + child.getNamespace());
                        System.debug('child: ' + child.);
                    } */
                }              
                
            } catch (CalloutException e) {
                throw  new CalloutException(e.getMessage());
            }
        }
       return returnString;
    }

   //Update MyRepair Order
    @future(callout = true)
    public static void updateRepairOrderStatus(set<ID> careIds) {
        
        List<CareService__c> listCare =[SELECT id,
                                               CreatedDate,
                                               SKU__c,
                                               Shipping_Address_Line_1__c,
                                               Shipping_Address_Line_2__c,
                                               Shipping_City__c,
                                               Shipping_Zip_Postal_Code__c,
                                               Shipping_State_Province__c,
                                               Shipping_Country__c,
                                               Client_Comments__c,
                                               FollowupBy_Email__c,
                                               FollowupBy_Call__c,
                                               FollowupBy_Video_Call__c,
                                               FollowupBy_Chat__c,
                                               Product_Sku_unknown__c,
                                               Category__c,
                                               Repair_Center_Comments__c,
                                               MyRepairStatus__c,
                                               Delivery_Date__c,
                                               CA_Code__c,
                                               TransactionId__c,
                                               StoreRetailCode__c,
                                               ICONiCS_Status_Detail__c,
                                               Client__r.PersonEmail,
                                               Client__r.Salutation,
                                               Client__r.ECO_ClientId__c,
                                               Client__r.LastName,
                                               Client__r.Lastname2__pc,
                                               Client__r.FirstName,
                                               Client__r.Firstname2__pc,
                                               Client__r.PersonHomePhone,
                                               Client__r.HomePhoneCountrycode__pc,
                                               Client__r.Nationality__pc,
                                               Client__r.PersonMobilePhone,
                                               Client__r.MobilePhoneCountryCode__pc,
                                               Client__r.AttachedStore__pc,
                                               Client__r.AttachedStoreCode__pc,
                                               Client__r.RMSId__pc,
                                               Client__r.C360GoldenID__c,
                                               Client__r.Phone,
                                               Client__r.WorkPhoneCountryCode__pc,
                                               Product__r.SKU__c,
                                               Price_Update_Reason__c,
                                               TotalAmount_Updated__c
                                        FROM CareService__c 
                                        WHERE id IN:careIds];   
        List<CareService__c> listCareToUpdate = new List<CareService__c>() ;
        for(CareService__c care : listCare){
            //Request
            HttpRequest req = new HttpRequest();    
    
            if(care.MyRepairStatus__c=='shippedToRepairCenter' || care.MyRepairStatus__c=='shippedToLocalPartner' || care.MyRepairStatus__c=='receivedAndAcceptedInStore'|| care.MyRepairStatus__c=='sentToRMS' || care.MyRepairStatus__c=='productDeliveredToClient'|| care.MyRepairStatus__c=='cancelled'){
                MuleSoft_API_Callout__mdt ApiCallout = MuleSoft_API_Callout__mdt.getInstance('MyRepair_HandleSalesForceOrderStatus');
                req.setHeader('Content-Type', ApiCallout.ContentType__c);         
                req.setHeader('client_id', ApiCallout.ClientId__c);   
                req.setHeader('client_secret', ApiCallout.ClientSecret__c);  
                req.setEndpoint(ApiCallout.Endpoint__c);
                req.setMethod(ApiCallout.Method__c);  
                req.setTimeout(Integer.valueOf(ApiCallout.Timeout__c));
                req.setBody(ICX_XmlRequestGenerator.MyRepairRequestBuilder('handleSalesForceOrderStatus',care));
                      

            System.debug('### Request Endpoint : '+req.getEndpoint());           
            
            //Reponse
            HttpResponse response = new HttpResponse();
            try {
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
                    
                    /* for(Dom.XMLNode child : Fault.getChildElements() ){

                        System.debug('child: ' + child.getName());
                        System.debug('child: ' + child.getNamespace());
                        System.debug('child: ' + child.);
                    } */
                }
                listCareToUpdate.add(care);
                
            } catch (CalloutException e) {
                care.MyRepair_Error__c = e.getMessage();
                throw  new CalloutException(e.getMessage());
                
            }
          }
        }
        update listCareToUpdate;
    }
}