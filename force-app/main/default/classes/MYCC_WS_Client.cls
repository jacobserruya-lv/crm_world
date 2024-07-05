/*
*** CREATED DATE December 2018
*** COMPANY      Balink
*** AUTHOR       Elchanan Rottman
*** DESCRIPTION  Web Service for upserting a Prospect Account from MyCC
*/
@RestResource(urlMapping='/MyCC/Client')
global with sharing class MYCC_WS_Client {
    
    @HttpPost
    global static void post() {

        // REST RESPONSE
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        res.statusCode = 200;

        // REST REQUEST
        RestRequest req = RestContext.request;
        String service = RestResource_Utils.getRequestType(req);
        String body = req.requestBody.toString();
        
        try{
            if(service == '' || service == 'Client'){
                String accountId  = MYCC_WS_Client_Utils.upsertAccount(body);
                res.responseBody = Blob.valueOf( MYCC_WS_Client_Utils.getResponseData(accountId));
            }
        }
        catch(Exception ex){

            // Missing Required Field is not allowed but the status code will be still 200. 
            if(ex.getMessage() != Label.MyCC_Required_Fields){
                new Logs.ERROR('MYCC_WS_Client', 'API', ex);
                        
                res.statusCode = 400;
                res.responseBody = Blob.valueOf(JSON.serialize(new Map<String,String> { 'errorMessage' => ex.getMessage()}));
            }
        }
    }
}