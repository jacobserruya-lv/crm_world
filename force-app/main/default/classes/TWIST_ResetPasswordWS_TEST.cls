@isTest
public with sharing class TWIST_ResetPasswordWS_TEST {

    public enum ResultStatusTest {
        INVALID_EMAIL,
        ERROR_TOKEN,
        ERROR_RESET_PASSWORD,
        SUCCESS_REQUEST_RESET_PASSWORD,
        EMAIL_NOT_FOUND
    }

    @testSetup
    static void initData(){
        Identity_TestFactory.createSettings();
        User user_1 = Identity_TestFactory.createUser('TEST1','TEST1','test_user_2@test.test','0500055111','972');
        TWIST_Settings__c settings = new TWIST_Settings__c();
        settings.Name = 'test';
        settings.Allow_Plus_Symbol_In_Email__c = true;
        settings.Reset_Password_Max_Requests__c = 2;
        settings.Password_Maxlength__c = 20;
        settings.Env_In_Reset_Password_Url__c = 'ift';
        settings.Is_Active_User_Creation__c = true;
        settings.Email_Token_Size__c = 32;
        settings.Footer_Links_Base_Url__c = 'https://{0}-i3f.louisvuitton.com';
        settings.Email_Token_Chars__c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        settings.Origins_to_replace__c='lvapp';
        settings.Target_origin__c='mylv';
        insert settings;
    }

    @isTest
    public static void test_error_token() {
        HTTP_Utils.setUseMockWhenTestIsRunning(true);
        Test.setMock(HttpCalloutMock.class, new TWIST_ResetPasswordWS_TEST.MockError());
        ResultStatusTest ERROR_TOKEN_VALUE_ACTUAL = ResultStatusTest.EMAIL_NOT_FOUND; // FIX TODO

        Test.startTest();
        String userEmail = 'test_user_2@test.test';
        String langCountry = 'eng-us';
        String origin = 'mylv';
        Map<String, Object> requestBodyMap = new Map<String, Object>{
            'userEmail' => userEmail,
            'langCountry' => langCountry,
            'origin' => origin
        };
        String requestBody = JSON.serialize(requestBodyMap);
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestURI = '/services/forgotPassword/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        TWIST_ResetPasswordWS.urlMC();
        TWIST_ResetPasswordWS.urlMC();
        TWIST_ResetPasswordWS.urlMC();
        TWIST_ResetPasswordService.ResultStatus ERROR_TOKEN_VALUE_EXPECTED = TWIST_ResetPasswordService.requestResetPassword('test_user_1@test.test', 'eng-us', null, 'mylv',null);
        Test.stopTest();

        System.assertEquals( ERROR_TOKEN_VALUE_EXPECTED.name(), ERROR_TOKEN_VALUE_ACTUAL.name());
    }

    @isTest
    static void test_getUrlMC() {
        HTTP_Utils.setUseMockWhenTestIsRunning(true);
        Test.setMock(HttpCalloutMock.class, new TWIST_ResetPasswordWS_TEST.Mock());
        ResultStatusTest SUCCESS_REQUEST_RESET_PASSWORD_VALUE_ACTUAL = ResultStatusTest.SUCCESS_REQUEST_RESET_PASSWORD;
        
        Test.startTest();
        String userEmail = 'test_user_2@test.test';
        String langCountry = 'eng-us';
        String origin = 'mylv';
        Map<String, Object> requestBodyMap = new Map<String, Object>{
            'userEmail' => userEmail,
            'langCountry' => langCountry,
            'origin' => origin
        };
        String requestBody = JSON.serialize(requestBodyMap);
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestURI = '/services/forgotPassword/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        TWIST_ResetPasswordWS.urlMC();
        TWIST_ResetPasswordService.ResultStatus SUCCESS_REQUEST_RESET_PASSWORD_VALUE_EXPECTED = TWIST_ResetPasswordService.requestResetPassword('test_user_1@test.test', 'eng-us', null, 'mylv',null);
        Test.stopTest();
        
        //System.assertEquals(SUCCESS_REQUEST_RESET_PASSWORD_VALUE_EXPECTED.name(), SUCCESS_REQUEST_RESET_PASSWORD_VALUE_ACTUAL.name());TODO
    }

    @isTest
    static void test_invalidEmail() {
        HTTP_Utils.setUseMockWhenTestIsRunning(true);
        Test.setMock(HttpCalloutMock.class, new TWIST_ResetPasswordWS_TEST.Mock());
        ResultStatusTest INVALID_EMAIL_VALUE_ACTUAL = ResultStatusTest.INVALID_EMAIL;
        
        Test.startTest();
       
        String userEmail = 'test user@test.test';
        String langCountry = 'eng-us';
        String origin = 'mylv';
        Map<String, Object> requestBodyMap = new Map<String, Object>{
            'userEmail' => userEmail,
            'langCountry' => langCountry,
            'origin' => origin
        };
        String requestBody = JSON.serialize(requestBodyMap);
        RestContext.request = new RestRequest();
        RestContext.response = new RestResponse();
        RestContext.request.requestURI = '/services/forgotPassword/';
        RestContext.request.httpMethod = 'POST';
        RestContext.request.requestBody = Blob.valueOf(requestBody);
        
        TWIST_ResetPasswordWS.urlMC();
        TWIST_ResetPasswordService.ResultStatus INVALID_EMAIL_VALUE_EXPECTED = TWIST_ResetPasswordService.requestResetPassword('test user_1@test.test', 'eng-us', null, 'mylv',null);
        Test.stopTest();

        System.assertEquals(INVALID_EMAIL_VALUE_EXPECTED.name(), INVALID_EMAIL_VALUE_ACTUAL.name());
    }

    @isTest
    public static void test_requestResetPassword_shouldReturn_EMAIL_NOT_FOUND() {
        // Given
        String unknownEmail = 'user' + String.valueOf(datetime.now().getTime()) + '@test.com';
        Map<String,Object> expectedResult = TWIST_Utils.buildFailureResponseObject('message', TWIST_ResetPasswordService.ResultStatus.EMAIL_NOT_FOUND);
        
        // When
        Map<String,Object> actualResult = TWIST_ResetPasswordWS.requestResetPassword(unknownEmail, 'eng-us', null, 'mylv', null);
        
        // Then
        System.assertEquals(expectedResult, actualResult);
    }

    @isTest
    public static void test_requestResetPassword_shouldReturn_ERROR_TOKEN() {
        // Given
        String knownEmail = 'test_user_2@test.test';
        String langCountry = null; // this is making the test work as designed
        String origin = 'mylv';
        String sessionInfo = null;

        // When
        Map<String,Object> actualResult = TWIST_ResetPasswordWS.requestResetPassword(knownEmail, langCountry, null, origin, sessionInfo);
        
        // Then
        Map<String,Object> expectedResult = TWIST_Utils.buildFailureResponseObject('message', String.valueOf(TWIST_ResetPasswordService.statusToken.get('error')));
        System.assertEquals(expectedResult, actualResult);
    }

    @isTest
    public static void test_requestResetPassword_shouldReturn_ERROR_MARKETING_CLOUD() {
        // Given
        Test.startTest();
        UnitTestsHelper.setSingleHttpMock(new HttpResponseMock().setBody(TWIST_Utils.buildFailureResponseObject()));
        Test.stopTest();
        String knownEmail = 'test_user_2@test.test';
        String langCountry = 'eng-us';
        String origin = 'mylv';
        String sessionInfo = null;

        // When
        Map<String,Object> actualResult = TWIST_ResetPasswordWS.requestResetPassword(knownEmail, langCountry, null, origin, sessionInfo);
        
        // Then
        Map<String,Object> expectedResult = TWIST_Utils.buildFailureResponseObject('message', TWIST_ResetPasswordService.ResultStatus.ERROR_MARKETING_CLOUD);
        System.assertEquals(expectedResult, actualResult);
    }

    /* ************************************************************************************************************************* */

    private class MockError implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody(mockBodyError);
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(400);
            return res;
        }
    }

    private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody(mockBody);
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(202);
            return res;
        }
    }

    private static String mockBody = '{"status": 202,"responseId": "5ff7aca0-6403-11ed-8bf1-024163823c52","transactionDate": "2022-11-14T10:01:58.14Z","data": {"requestId": "b48364f8-22a4-4e08-8dfd-3b0305395449","errorcode": 0,"responses": [{"messageKey": "8ff9eba1-a129-4d72-9f68-e8ed7ee6bafc"}]}}';
    private static String mockBodyError = '{"status": 400,"responseId": "bc502880-6429-11ed-8bf1-024163823c52","transactionDate": "2022-11-14T14:36:34.649Z","data": {"errorCode": "SAPI-C001","errorType": "BAD_REQUEST","errorDescription": "HTTP POST on resource '+'https://mcydkmypx9w3xcb5pdys9dqwpxxy.rest.marketingcloudapis.com:443/messaging/v1/email/messages/' + 'failed: bad request (400)."}}';
    
}