@isTest
private class IDENTITY_AuthProvider_TEST {
    
    @isTest static void test_method_one() {
        
        String jsonInput = '{"item": "test", "properties": {"prop1":"test1", "prop2":"test2"}, "kakao_account": {"prop3":"test3", "prop4":"test4"}}';
        IDENTITY_AuthProvider.getTokenValue(jsonInput, 'test');

        String provider = 'kakao';
        String jwt_token = '{"tok1": "t1", "tok2": "t2"}';
        IDENTITY_AuthProvider.getUserData(provider, jsonInput, jwt_token);

        /*Map<String,String> authProviderConfiguration = new Map<String,String>();
        authProviderConfiguration.put('Key__c', 'testKey');
        authProviderConfiguration.put('Auth_Url__c', 'http://www.dummy.com/authurl');
        authProviderConfiguration.put('Secret__c', 'testSecret');
        authProviderConfiguration.put('Access_Token_Url__c', 'http://www.dummyhost.com/accessTokenUri');
        authProviderConfiguration.put('API_User_Url__c','www.google.com/user/api');
        authProviderConfiguration.put('API_User_Version_Url__c','http://www.dummyhost.com/user/20/1');
        authProviderConfiguration.put('Redirect_Url__c','http://google.com');
        authProviderConfiguration.put('Authorize_Endpoint_URL__c','http://google.com');
        authProviderConfiguration.put('Consumer_Key__c','testKey');
        authProviderConfiguration.put('Scope__c','testScope');
        authProviderConfiguration.put('Callback_URL__c','http://google.com');
        authProviderConfiguration.put('Token_Endpoint_URL__c','http://google.com');
        authProviderConfiguration.put('User_Info_Endpoint_URL__c','http://google.com');        
       */        
    }
    
}