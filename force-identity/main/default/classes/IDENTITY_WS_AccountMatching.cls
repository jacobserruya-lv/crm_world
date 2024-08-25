/*
CreatedDate: July 2020
Company: Balink
Author: Deborah Drai
Description: Interface Web Sevice to match SF Account with ATG prospect
*/

@RestResource(urlMapping='/identity/v1/accountMatching/*')
global without sharing class IDENTITY_WS_AccountMatching {
    
    @HttpPost
    global static void match(){

        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');
        res.statusCode = 200;

        try{
            Account atg_data = (Account)JSON.deserialize(RestContext.request.requestBody.toString(), Account.class);

            // Cause DMLException for test coverage
            if(Test.isRunningTest() && atg_data.Firstname == 'DmlException'){
                insert new Account();
            }
            
            Map<String, String> result = IDENTITY_AccountMatching_Utils.upsertAccountByFieldsValue(atg_data);
            String cid = result.get('cid');
            String action = result.get('action');
            Boolean isTrustOrigin = IDENTITY_Utils.isTrustOriginApp('Checkout');            
            String encryptedCID = IDENTITY_Utils.getEncryptedIdWithTrustOrigin(cid, isTrustOrigin);
            res.responseBody = Blob.valueOf(JSON.serialize(new AccountMatchingResponse('SUCCESS', res.statusCode, null, action, encryptedCID)));                       
        }
        catch(Exception ex){
            
            // ERROR LOG
            new Logs.ERROR('IDENTITY_WS_AccountMatching', 'API', ex);            
            
            res.statusCode = 500;
            if(ex.getTypeName() == 'DmlException' ){
                res.responseBody = Blob.valueOf(JSON.serialize(new AccountMatchingResponse('ERROR', res.statusCode, ex.getMessage() + ' Line: ' + ex.getLineNumber(), 'DML_EXCEPTION', null)));
            } 
            else {
                if(ex.getMessage().contains('MISSING REQUIRED FIELD')){
                    res.responseBody = Blob.valueOf(JSON.serialize(new AccountMatchingResponse('ERROR', res.statusCode, ex.getMessage(), 'MISSING_REQUIRED_FIELD', null)));
                }
                else if(ex.getMessage().contains('INVALID REQUIRED FIELD')){
                    res.responseBody = Blob.valueOf(JSON.serialize(new AccountMatchingResponse('ERROR', res.statusCode, ex.getMessage(), 'INVALID_FORMAT_FIELD', null)));
                }
                else{
                    res.responseBody = Blob.valueOf(JSON.serialize(new AccountMatchingResponse('ERROR', res.statusCode, ex.getMessage(), 'GENERIC_ERROR', null)));
                }
            }
            
        }
    }  
    
    /*
    *** DESCRIPTION Response Wrapper
    */
    public class AccountMatchingResponse {
        String status;
        Integer statusCode;
        String message;
        String action;
        String cid;        

        // success
        public AccountMatchingResponse(String status, Integer statusCode, String message, String action, String cid){
            this.status = status;
            this.statusCode = statusCode;
            this.message = message;
            this.action = action;
            this.cid = cid;
        }
    }
}