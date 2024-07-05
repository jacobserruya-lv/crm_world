@RestResource(urlMapping='/sf-auth-validation/*')
global with sharing class BL_SF_AUTH_Validation_WS {
    /*=================================================================================================================*/
    //HTTP Request POST called 
    
    //Interactive Wardrobing purpose

    @HttpGet
    global static void get(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        try{

            res.addHeader('Content-Type','application/json');
            res.statusCode = 200;

            List<User> userList = [Select Id, AccountId, Is_Identity_User__c FROM User Where Id = : UserInfo.getUserId() LIMIT 1];
            if(userList.size() > 0){
                User u = userList[0];
                if(u.Is_Identity_User__c){
                    Map<String, Object> response = new Map<String,Object>{ 'record' => new Map<String, Object>{  'clientUserId' => u.Id,  'accountId' => u.AccountId }};

                    res.responseBody = Blob.valueOf(JSON.serializePretty(response, true));
                } else { 
                    BL_AppSettings.setAppSettings('Icon');
                    BL_ICON_UserInfo userInfos = new BL_ICON_UserInfo('Me_SFAUTH');
                    res.responseBody = Blob.valueOf(JSON.serializePretty(new BL_WS_Response(userInfos.userDetails), true));
                }
            } else {
                throw new SFAUTH_WS_Exception('USER_NOT_FOUND');
            }

        } catch(Exception ex){
            system.debug(ex.getMessage() + '\n\n' + ex.getLineNumber());
            
            res.responseBody = Blob.valueOf(ex.getMessage() + '\n\n' + ex.getLineNumber());
            res.statusCode = 400;
        }
    }

    public class SFAUTH_WS_Exception extends Exception {}

}