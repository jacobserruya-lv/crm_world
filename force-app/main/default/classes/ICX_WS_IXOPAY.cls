public with sharing class ICX_WS_IXOPAY {
    public ICX_WS_IXOPAY() {
    }
    
    @future (callout=true)
    public static void createLinkPBL(set<ID> careIds) {
        
        List<CareService__c> listCare =[select id,StoreRetailCode__c,TransactionId__c,PBL_Created_Date__c,PBL_Link__c,PBL_Number__c,PBL_Status__c,LanguageLocaleKey__c,TotalAmount_Updated__c,SKU__c,CurrencyCode__c,Product__r.Name,Client__c,Shipping_Country__c from CareService__c where id IN:careIds];
        List<CareService__c> listCareToUpdate = new List<CareService__c>() ;
        List<Logs__c> listLogs = new List<Logs__c> () ;
        List<Ixopay_Transaction__c> lstTransaction = new List<Ixopay_Transaction__c> () ;
        
        
        for(CareService__c care : listCare){     
            MuleSoft_API_Callout__mdt ApiCallout = MuleSoft_API_Callout__mdt.getInstance('PayByLink_Ixopay');
            ICX_Repair_Store__mdt repairCountry = ICX_Repair_Store__mdt.getInstance(String.valueOf(care.StoreRetailCode__c));
            if(care.TotalAmount_Updated__c>0 && ApiCallout != null && repairCountry != null && repairCountry.Integrated_PBL__c == true){
            String endpoint = ApiCallout.Endpoint__c + '/'+ repairCountry.API_Key_Ixopay__c + '/debit';
            //String username = ApiCallout.Username__c;
            //String password = ApiCallout.Password__c;
            String successUrlIxopay = System.Label.ICX_SuccessUrlIxopay; 
            String cancelUrlIxopay = System.Label.ICX_CancelUrlIxopay;
            String errorUrlIxopay =  System.Label.ICX_ErrorUrlIxopay; 
            String callbackUrlIxopay = System.Label.ICX_CallbackUrlIxopay;
            //Request      
            HttpRequest request = new HttpRequest();           
            request.setEndpoint(endpoint);
            request.setMethod('POST');
           // request.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password)));
            request.setHeader('Content-Type', ApiCallout.ContentType__c);
            request.setHeader('client_id', ApiCallout.ClientId__c);
            request.setHeader('client_secret', ApiCallout.ClientSecret__c); 
            request.setHeader('X-Sign', repairCountry.Shared_Secret_Ixopay__c);
            request.setTimeout(Integer.valueOf(ApiCallout.Timeout__c));     
            
            requestDebitIxopay myRequest = new requestDebitIxopay();    
            
            //productCare productC = new productCare();    
            //productC.name = care.Product__r.name == null? 'Unknown Product' : care.Product__r.name;
            
            customerCare customerC = new customerCare();
            customerC.identification = care.Client__c;
            customerC.shippingCountry =  care.Shipping_Country__c;
            //myRequest.items.add(productC);
            myRequest.customer = customerC;
            myRequest.additionalId1 = care.StoreRetailCode__c;
            myRequest.merchantTransactionId = String.valueOf(System.now().getTime());
            myRequest.merchantMetaData = care.TransactionId__c == null ? 'MyRepairs_Id' : care.TransactionId__c;
            myRequest.amount =  String.valueOf(care.TotalAmount_Updated__c) == null ? '0' : String.valueOf(care.TotalAmount_Updated__c);
            myRequest.currency_x = care.CurrencyCode__c == null ? 'EUR' : care.CurrencyCode__c;
            myRequest.successUrl = successUrlIxopay;
            myRequest.cancelUrl = cancelUrlIxopay;
            myRequest.errorUrl = errorUrlIxopay;
            myRequest.callbackUrl = callbackUrlIxopay;
            myRequest.language = care.LanguageLocaleKey__c == null ? 'en' : care.LanguageLocaleKey__c.substring(0,2); //LanguageLocaleKey__c=en_US         
            
            String jsonBody = JSON.serialize(myRequest).replace('"currency_x":', '"currency":');
            
            
            system.debug('JSON BODY IXOPAY To Process ==> '+jsonBody);
            
            request.setBody(jsonBody);
            
            //Reponse
            HttpResponse response = new HttpResponse();
            try {
                
                Http http = new Http();            
                response = http.send(request);
                
                system.debug('### Ixopay Reponse Status : '+response.getStatusCode()+' '+response.getStatus());
                System.debug('### Ixopay Reponse Body : '+response.getBody());
                responseIxopay ixoPayResponse = parse(response.getBody());
                if(ixoPayResponse.success==true){
                    care.PBL_Created_Date__c = system.now();
                    care.PBL_Link__c = ixoPayResponse.redirectUrl;
                    System.debug('Ixopay Response Redirect URL : ' + ixoPayResponse.redirectUrl);                
                    care.PBL_Number__c = ixoPayResponse.uuid;
                    care.PBL_Status__c = 'Initiated';
                    care.ICONiCS_Status_Detail__c = 'Payment Initiated';
                    //care.Last_ICONiCS_Status_Changed_Date__c = system.today();
                    listCareToUpdate.add(care);         
                    
                    Ixopay_Transaction__c payment = new Ixopay_Transaction__c ();
                    payment.uuid__c = ixoPayResponse.uuid;
                    payment.Status__c = 'Initiated';
                    payment.Statut_Date__c = system.now();
                    payment.Transaction_Type__c = 'DEBIT';
                    payment.Care_Service__r = new CareService__c(TransactionId__c=care.TransactionId__c);
                    lstTransaction.add(payment);
                    
                }else{ 
                    Logs__c log = new Logs__c ();
                    log.Application__c = 'Distant Care Service';
                    log.Record_Id__c = care.Id;
                    log.Apex_Class__c = 'ICX_WS_IXOPAY';
                    log.API_Request__c = jsonBody;
                    log.API_Response__c = response.getBody();
                    log.Has_Error__c = true;
                    if(ixoPayResponse.error != null){
                        log.Error__c = ixoPayResponse.error;                    	
                    }else if(ixoPayResponse.errors!=null){
                        log.Error__c = ixoPayResponse.errors[0].errorCode +' '+ixoPayResponse.errors[0].errorMessage;
                    }else{
                        log.Error__c = ixoPayResponse.errorCode +' '+ixoPayResponse.errorMessage;
                    }
                    listLogs.add(log);
                }
                
                
                
            } catch (CalloutException e) {               
                throw  new CalloutException(e.getMessage());
            }
          }
        }
        if(listCareToUpdate.size()>0)
            update listCareToUpdate; 
        if(listLogs.size()>0)  
            insert listLogs; 
        if(lstTransaction.size()>0)
            insert lstTransaction; 
    }
    
    @AuraEnabled (cacheable=true)
    public static String createRefund(ID careId) {
        String returnString = null;
        Ixopay_Transaction__c myTransaction = [select id,uuid__c,Amount__c,Currency__c,Care_Service__r.TransactionId__c,Care_Service__r.StoreRetailCode__c, Care_Service__r.Refund_Amount__c from Ixopay_Transaction__c where Care_Service__c =:careId and Status__c = 'Success' and Transaction_Type__c ='DEBIT' limit 1];
        MuleSoft_API_Callout__mdt ApiCallout = MuleSoft_API_Callout__mdt.getInstance('PayByLink_Ixopay');
        ICX_Repair_Store__mdt repairCountry = ICX_Repair_Store__mdt.getInstance(String.valueOf(myTransaction.Care_Service__r.StoreRetailCode__c));
        if(ApiCallout != null && repairCountry != null){
        String endpoint = ApiCallout.Endpoint__c + '/'+ repairCountry.API_Key_Ixopay__c + '/refund';
        //String username = ApiCallout.Username__c;
        //String password = ApiCallout.Password__c;
        String callbackUrlIxopay = System.Label.ICX_CallbackUrlIxopay;
        //Request      
        HttpRequest request = new HttpRequest();           
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        //request.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password)));
        request.setHeader('Content-Type', ApiCallout.ContentType__c);
        request.setHeader('client_id', ApiCallout.ClientId__c);
        request.setHeader('client_secret', ApiCallout.ClientSecret__c); 
        request.setHeader('X-Sign', repairCountry.Shared_Secret_Ixopay__c);
        request.setTimeout(Integer.valueOf(ApiCallout.Timeout__c));     
        
        requestRefundIxopay myRequest = new requestRefundIxopay();    
        myRequest.referenceUuid = myTransaction.uuid__c;
        myRequest.additionalId1 = myTransaction.Care_Service__r.StoreRetailCode__c;
        myRequest.merchantTransactionId = String.valueOf(System.now().getTime());
        myRequest.merchantMetaData = myTransaction.Care_Service__r.TransactionId__c;
        myRequest.amount =  String.valueOf(myTransaction.Care_Service__r.Refund_Amount__c) == null ? '0' : String.valueOf(myTransaction.Care_Service__r.Refund_Amount__c);
        myRequest.currency_x = myTransaction.Currency__c == null ? 'EUR' : myTransaction.Currency__c;
        myRequest.callbackUrl = callbackUrlIxopay;
        String jsonBody = JSON.serialize(myRequest).replace('"currency_x":', '"currency":');
        
        
        system.debug('JSON BODY IXOPAY To Process ==> '+jsonBody);
        
        request.setBody(jsonBody);
        
        //Reponse
        HttpResponse response = new HttpResponse();
        try {
            
            Http http = new Http();            
            response = http.send(request);
            
            system.debug('### Ixopay Reponse Status : '+response.getStatusCode()+' '+response.getStatus());
            System.debug('### Ixopay Reponse Body : '+response.getBody());
            responseIxopay ixoPayResponse = parse(response.getBody());
            if(ixoPayResponse.success==true){
                /*Ixopay_Transaction__c refund = new Ixopay_Transaction__c ();
                refund.uuid__c = ixoPayResponse.uuid;
                refund.Status__c = 'Initiated';
                refund.Statut_Date__c = system.now();
                refund.Transaction_Type__c = 'REFUND';
                refund.Amount__c = myTransaction.Amount__c;
                refund.Currency__c = myTransaction.Currency__c;
                refund.Care_Service__r = new CareService__c(TransactionId__c=myTransaction.Care_Service__r.TransactionId__c);
                insert refund;*/
               
                returnString = 'Success';
            }else{   
               /* Logs__c log = new Logs__c ();
                log.Application__c = 'Distant Care Service';
                log.Record_Id__c = careId;
                log.Apex_Class__c = 'ICX_WS_IXOPAY';
                log.API_Request__c = jsonBody;
                log.API_Response__c = response.getBody();
                log.Has_Error__c = true;
                if(ixoPayResponse.error != null){
                    log.Error__c = ixoPayResponse.error;
                    returnString = 'Error '+ ixoPayResponse.error;
                }else if(ixoPayResponse.errors!=null){
                    log.Error__c = ixoPayResponse.errors[0].errorCode +' '+ixoPayResponse.errors[0].errorMessage;
                    returnString = 'Error '+ ixoPayResponse.errors[0].errorCode +' '+ixoPayResponse.errors[0].errorMessage;
                }else{
                    log.Error__c = ixoPayResponse.errorCode +' '+ixoPayResponse.errorMessage;
                    returnString = 'Error '+ ixoPayResponse.errorCode +' '+ixoPayResponse.errorMessage;
                }
                insert log;  */
                if(ixoPayResponse.error != null){                   
                    returnString = 'Error '+ ixoPayResponse.error;
                }else if(ixoPayResponse.errors!=null){                  
                    returnString = 'Error '+ ixoPayResponse.errors[0].errorCode +' '+ixoPayResponse.errors[0].errorMessage;
                }else{                   
                    returnString = 'Error '+ ixoPayResponse.errorCode +' '+ixoPayResponse.errorMessage;
                }
            }              
            
            
            
        } catch (CalloutException e) {               
            throw  new CalloutException(e.getMessage());
        }
    } 
        return returnString;
     
    }

    @AuraEnabled (cacheable=true)
    public static String createPaymentReviewPBL(ID careId) {  
        String returnString = null;
        CareService__c care =[select id,StoreRetailCode__c,TransactionId__c,PBL_Created_Date__c,PBL_Link__c,PBL_Number__c,PBL_Status__c,LanguageLocaleKey__c,TotalAmount_Updated__c,SKU__c,CurrencyCode__c,Product__r.Name,Client__c,Shipping_Country__c from CareService__c where id =:careId];
        List<Logs__c> listLogs = new List<Logs__c> () ;
        List<Ixopay_Transaction__c> lstTransaction = new List<Ixopay_Transaction__c> () ;        
           
            MuleSoft_API_Callout__mdt ApiCallout = MuleSoft_API_Callout__mdt.getInstance('PayByLink_Ixopay');
            ICX_Repair_Store__mdt repairCountry = ICX_Repair_Store__mdt.getInstance(String.valueOf(care.StoreRetailCode__c));
            if(care.TotalAmount_Updated__c>0 && ApiCallout != null && repairCountry != null && repairCountry.Integrated_PBL__c == true){
            String endpoint = ApiCallout.Endpoint__c + '/'+ repairCountry.API_Key_Ixopay__c + '/debit';
           
            String callbackUrlIxopay = System.Label.ICX_CallbackUrlIxopay;
            //Request      
            HttpRequest request = new HttpRequest();           
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', ApiCallout.ContentType__c);
            request.setHeader('client_id', ApiCallout.ClientId__c);
            request.setHeader('client_secret', ApiCallout.ClientSecret__c); 
            request.setHeader('X-Sign', repairCountry.Shared_Secret_Ixopay__c);
            request.setTimeout(Integer.valueOf(ApiCallout.Timeout__c));     
            
            requestPBLIxopay myRequest = new requestPBLIxopay();    
         
            customerCare customerC = new customerCare();
            extraDataType myExtraData = new extraDataType();
            payByLinkType myPayByLink =  new payByLinkType();

            customerC.identification = care.Client__c;
            customerC.shippingCountry =  care.Shipping_Country__c;                    
            myExtraData.PBL = '1';
            myPayByLink.sendByEmail = false;

            myRequest.customer = customerC;            
            myRequest.extraData = myExtraData;
            myRequest.payByLink = myPayByLink;
            myRequest.additionalId1 = care.StoreRetailCode__c;
            myRequest.merchantTransactionId = String.valueOf(System.now().getTime());
            myRequest.merchantMetaData = care.TransactionId__c == null ? 'MyRepairs_Id' : care.TransactionId__c;
            myRequest.amount =  String.valueOf(care.TotalAmount_Updated__c) == null ? '0' : String.valueOf(care.TotalAmount_Updated__c);
            myRequest.currency_x = care.CurrencyCode__c == null ? 'EUR' : care.CurrencyCode__c;
            myRequest.callbackUrl = callbackUrlIxopay;
            myRequest.language = care.LanguageLocaleKey__c == null ? 'en' : care.LanguageLocaleKey__c.substring(0,2); //LanguageLocaleKey__c=en_US         
           
            String jsonBody = JSON.serialize(myRequest).replace('"currency_x":', '"currency":');
            
            
            system.debug('JSON BODY IXOPAY To Process ==> '+jsonBody);
            
            request.setBody(jsonBody);
            
            //Reponse
            HttpResponse response = new HttpResponse();
            try {
                
                Http http = new Http();            
                response = http.send(request);
                
                system.debug('### Ixopay Reponse Status : '+response.getStatusCode()+' '+response.getStatus());
                System.debug('### Ixopay Reponse Body : '+response.getBody());
                responseIxopay ixoPayResponse = parse(response.getBody());
                if(ixoPayResponse.success==true){
                    returnString = ixoPayResponse.uuid+';'+ixoPayResponse.redirectUrl;
                    
                }else{ 
                    if(ixoPayResponse.error != null){                   
                        returnString = 'Error '+ ixoPayResponse.error;
                    }else if(ixoPayResponse.errors!=null){                  
                        returnString = 'Error '+ ixoPayResponse.errors[0].errorCode +' '+ixoPayResponse.errors[0].errorMessage;
                    }else{                   
                        returnString = 'Error '+ ixoPayResponse.errorCode +' '+ixoPayResponse.errorMessage;
                    }
                }
                
                
                
            } catch (CalloutException e) {               
                throw  new CalloutException(e.getMessage());
            }
          }
          return returnString;
    }
    
    public class requestDebitIxopay {
        public String merchantTransactionId; //Timestamp       
        public String additionalId1; //F92	
        public String merchantMetaData;	//Blue Bag - ModelM671
        public String amount; // 9.99 
        public String currency_x; // EUR
        public String successUrl; // URL
        public String cancelUrl; // URL
        public String errorUrl; // URL
        public String callbackUrl; // URL
        //public list<productCare> items = new list<productCare>(); //SET VALS!!!
        public customerCare customer; 
        public String language; //Two first Capital of language local key
       
    }

    public class requestPBLIxopay {
        public String merchantTransactionId; //Timestamp       
        public String additionalId1; //F92	
        public String merchantMetaData;	//Blue Bag - ModelM671
        public String amount; // 9.99 
        public String currency_x; // EUR       
        public String callbackUrl; // URL
        //public list<productCare> items = new list<productCare>(); //SET VALS!!!
        public customerCare customer; 
        public String language; //Two first Capital of language local key
        public extraDataType extraData;
        public payByLinkType payByLink;
    }
   /* public class productCare {
        public string name;
    }*/
    
    public class customerCare {
        public String identification; 	//SF accId (00003001)
        public String shippingCountry; // FR
    }

    public class extraDataType {
        public string PBL;
    }

    public class payByLinkType {
        public Boolean sendByEmail;
    }

    public class requestRefundIxopay {
        public String merchantTransactionId; //Timestamp     
        public String referenceUuid;//352532d6962eeb33ec14
        public String additionalId1; //F92	
        public String merchantMetaData;	//Blue Bag - ModelM671
        public String amount; // 9.99 
        public String currency_x; // EUR       
        public String callbackUrl; // URL  
    }
    public class responseIxopay {
        public String   error;
        public boolean	success;		//true
        public String 	uuid;			//6ff0f5eeac3adcd1ea1c
        public String	purchaseId;		//20230512-6ff0f5eeac3adcd1ea1c
        public String	returnType;		//REDIRECT
        public String	redirectUrl;	//https:\/\/louisvuitton.ixopaysandbox.com\/redirect\/6ff0f5eeac3adcd1ea1c\/YzhjMjUxMGYzYTY1NWNhYzhiN2RiMGYyNDg0MWMxNDAyYmE0OTk0OWM5Y2RjMGNkNTk4MTQ3MDY4ZjkzZjVlZDZmNGQyNGI4OWE5ZTk4NGRkNzhhNDFkYWY2Y2YzMGEwMGEwMWMyNWE0NjRmY2RmYTg5MDIwMTM1NDZhZTZhN2U=	
        public String 	paymentMethod;	//Creditcard
        public String   errorMessage;    //Signature invalid
        public Integer  errorCode;      //3004
        public List <responseError> errors = new List <responseError> ();
    }
    public class responseError {
        public String errorMessage;
        public Integer errorCode;
    }
    
    public static responseIxopay parse(String json) {
        return (responseIxopay) System.JSON.deserialize(json, responseIxopay.class);
    }
}