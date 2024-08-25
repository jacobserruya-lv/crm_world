@isTest
private class TWIST_CheckPasswordAPI_TEST {

    static String userEmail = 'testmatch' + StringUtils.generateRandomString(10, '0123456789') + '@test.com';

    @testSetup
    static void setup() {
        insert new TWIST_Settings__c(
            Name = 'test',
            Password_checked_duration__c = 24,
            Pwdless_Email_Verif_Identifier_Validity__c = 15,
            Password_Maxlength__c = 20,
            Email_Token_Size__c = 32,
            Email_Token_Chars__c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz'
        );
    }
    
    @isTest
    static void test_match() {
        Identity_TestFactory.createSimpleUser('check', 'password', userEmail, '0541234567');
        Test.startTest();
        
        Map<String, Object> bodyMap = new Map<String, Object>();
        
        User userTest = [SELECT Id, Email, userName FROM User WHERE username = :userEmail LIMIT 1];
        
        System.setPassword(userTest.Id, 'check1234!');
        
        HttpResponseMock mock = new HttpResponseMock().setStatusCode(200).setBody(new Map<String,String> {
            'access_token' => '1234567891234567890qwertyuwerty'
        });
        UnitTestsHelper.setSingleHttpMock(mock);
        
        // USERNAME & PASSWORD MATCH
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/CheckPassword';
        req.addHeader('Content-Type','application/json');
        RestContext.request = req;
        RestContext.response = res;
        
        bodyMap = new Map<String, Object>{'username' => userTest.username, 'password' => 'check1234!'};
        req.requestBody = Blob.valueOf(JSON.serialize(bodyMap));
        
        TWIST_CheckPasswordAPI.doPost();
        System.assertEquals(200, RestContext.response.statusCode, 'Statuscode should be 200');//in the body match = true
        Test.stopTest();
    }
    
    @isTest
    static void test_match_withcache() {
        insert new TwistCacheManager__c(
            Type__c = 'CHECKED_PASSWORD',
            Key__c = userEmail,
            Value__c = String.valueOf(DateTime.now())
        );
        Identity_TestFactory.createSimpleUser('check', 'password', userEmail, '0541234567');

        Test.startTest();
        User userTest = [SELECT Id, Email, userName FROM User WHERE username = :userEmail LIMIT 1];
        
        System.setPassword(userTest.Id, 'check1234!');
        
        HttpResponseMock mock = new HttpResponseMock().setStatusCode(200).setBody(new Map<String,String> {
            'access_token' => '1234567891234567890qwertyuwerty'
        });
        UnitTestsHelper.setSingleHttpMock(mock);
        
        // USERNAME & PASSWORD MATCH
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/CheckPassword';
        req.addHeader('Content-Type','application/json');
        RestContext.request = req;
        RestContext.response = res;
        
        Map<String, Object> bodyMap = new Map<String, Object>{'username' => userTest.username, 'password' => 'check1234!'};
        req.requestBody = Blob.valueOf(JSON.serialize(bodyMap));
        
        TWIST_CheckPasswordAPI.doPost();
        System.assertEquals(200, RestContext.response.statusCode, 'Statuscode should be 200');//in the body match = true
        Test.stopTest();
    }
    @isTest
    static void test_not_match() {
        Identity_TestFactory.createSimpleUser('check', 'password', userEmail, '0541234567');
        
        Test.startTest();
        User userTest = [SELECT Id, Email, userName FROM User WHERE username = :userEmail LIMIT 1];
        
        HttpResponseMock mock = new HttpResponseMock().setStatusCode(400);
        UnitTestsHelper.setSingleHttpMock(mock);
        
        // USERNAME & PASSWORD MATCH
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/CheckPassword';
        req.addHeader('Content-Type','application/json');
        RestContext.request = req;
        RestContext.response = res;
        
        Map<String, Object> bodyMap = new Map<String, Object>{'username' => userTest.username, 'password' => 'check1234!'};
        req.requestBody = Blob.valueOf(JSON.serialize(bodyMap));
        
        TWIST_CheckPasswordAPI.doPost();
        System.assertEquals(200, RestContext.response.statusCode, 'Statuscode should be 200');//in the body match = false
        Test.stopTest();
    }

    @isTest
    static void test_error() {
        Identity_TestFactory.createSimpleUser('check', 'password', userEmail, '0541234567');

        Test.startTest();
        User userTest = [SELECT Id, Email, userName FROM User WHERE username = :userEmail LIMIT 1];
        
        // USERNAME & PASSWORD MATCH
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/CheckPassword';
        req.addHeader('Content-Type','application/json');
        RestContext.request = req;
        RestContext.response = res;
        
        Map<String, Object> bodyMap = new Map<String, Object>{'username' => userTest.username, 'password' => 'check1234!'};
        req.requestBody = Blob.valueOf(JSON.serialize(bodyMap));
        
        TWIST_CheckPasswordAPI.doPost();
        Test.stopTest();
    }
    
}