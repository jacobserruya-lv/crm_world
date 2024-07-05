@RestResource(urlMapping='/Opportunity/*')  //MIY-2079 
global with sharing class Xstore_API {
    
    @HttpPatch
    global static void updateOpportunityAmount() {  
        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response ;
        
        res.addHeader('Content-Type', 'application/json');
        Boolean canCancel=true;
        String jsonString ;  
        String OrderNumber = request.requestURI.substring(
            request.requestURI.lastIndexOf('/')+1); 
            Opportunity opp = new Opportunity() ;
            try {
                opp = [SELECT Id ,SPO_DepositAmount__c ,SPO_XstoreDeposit__c ,StageName , Checkdeposit__c  FROM Opportunity WHERE OrderNumber__c = :OrderNumber];//MIY-2109 
                
                List<SPO_FirmOrder__c> firmOrderToCheck = [
                    SELECT Id, Name, SPO_BriefName__c, SPO_BriefNumber__c, SPO_TechETLStatus__c, SPO_FirmOrderStatus__c,
                            SPO_OrderNumber__c, SPO_FirmOrderNumber__c
                    FROM SPO_FirmOrder__c
                    WHERE SPO_BriefName__c =:opp.Id
            ];
        // Deserialize the JSON string into name-value pairs
        Map<String, Object> params = (Map<String, Object>)JSON.deserializeUntyped(request.requestbody.tostring());
        for (SPO_FirmOrder__c firmOrder : firmOrderToCheck) {
                       
            if (firmOrder.SPO_FirmOrderStatus__c != 'Creation in progress' ||
            (firmOrder.SPO_TechETLStatus__c != null && firmOrder.SPO_TechETLStatus__c != 'V')) {
                canCancel = false ;
            }
          
        }
        // Iterate through each parameter field and value
        for(String fieldName : params.keySet()) {  // MIY-1929
                if (fieldName =='depositAmount' && (params.get(fieldName)==0) && opp.SPO_DepositAmount__c != 0 ) { //MIY-2109
                if ((opp.StageName == 'Creation in progress' || opp.StageName == 'Brief in progress') && canCancel && opp.Checkdeposit__c){
                    SPO_FirmOrderControllerLC.cancelFirmOrderDB(opp.Id,'Xstore','Production - Other','Cancelled by Xstore') ;
                    opp.put('SPO_XstoreDeposit__c', params.get(fieldName));
                    res.statusCode = 200;
                    jsonString ='{ "message": "Order Sucessful cancelled on Salesforce" }';
                    res.responseBody = Blob.valueOf(jsonString);   
                }  else if ((opp.StageName == 'Cancelled by Store') || (opp.StageName == 'Cancelled by production')) {      
                    res.statusCode = 409;
                    jsonString ='{ "message": "This order have alredy been cancelled" }';
                    res.responseBody = Blob.valueOf(jsonString);   
                }  else {      
                    res.statusCode = 409;
                    jsonString ='{ "message": "This order cannot be cancel from here at this stage,please open an ContactIS ticket to cancel it" }';
                    res.responseBody = Blob.valueOf(jsonString);   
                }
                          
                }
    
               else  if (opp.SPO_XstoreDeposit__c == null) {  //first deposit(after order placement)
                if (fieldName =='depositAmount' && (params.get(fieldName)==opp.SPO_DepositAmount__c) ) {
                
                    opp.put('SPO_XstoreDeposit__c', params.get(fieldName));
                    opp.StageName = 'Creation in progress';
                    res.statusCode = 200;
                    jsonString ='{ "message": "Deposit Amount from Xstore Sucessful created on Salesforce" }';
                    res.responseBody = Blob.valueOf(jsonString);
                  //  update opp; Avoid DML statements inside loops // MIY-2179
                }
                else if(fieldName =='depositAmount' && (params.get(fieldName)!=opp.SPO_DepositAmount__c) ) {                       
                        res.statusCode = 409;
                        jsonString ='{ "message": "Inicial Deposit Amount is diferent from Salesforce,please check the value on Salesforce first" }';
                        res.responseBody = Blob.valueOf(jsonString);
                       
                }
            } 
            else { //not first deposit (can be completed on pickup if is not 100% at order placement)
                if (fieldName =='depositAmount'){
                    opp.put('SPO_XstoreDeposit__c', params.get(fieldName));
                    res.statusCode = 200;
                    jsonString ='{ "message" :"Deposit Amount from Xstore Sucessful updated on Salesforce" }';

                    res.responseBody = Blob.valueOf(jsonString);
                    //update opp; Avoid DML statements inside loops // MIY-2179
                }

            }
               
            }
            update opp;  // MIY-2179
        } catch (QueryException e ) {

            res.statusCode = 404;
            jsonString ='{"message":"Order not found in Salesforce"}';
            res.responseBody = Blob.valueOf(jsonString);
           
        }
       
    }   
    
}