@isTest
public with sharing class MarketingCloudEmails_API_TEST { //TWIST-4341

    @TestSetup
    public static void initTest() {
        TWIST_Settings__c settings = new TWIST_Settings__c();
        settings.Name = 'test';
        settings.Password_Maxlength__c = 20;
        settings.Env_In_Reset_Password_Url__c = 'i1f';
        settings.Reset_Password_Redirection_Host__c = 'https://me-i3f.louisvuitton.com';
        settings.Footer_Links_Base_Url__c = 'https://{0}-i3f.louisvuitton.com';
        settings.Origins_to_replace__c = 'lvapp';
        settings.Target_origin__c = 'mylv';
        insert settings;
    }

    @isTest
    public static void test_status_202() {
        HTTP_Utils.setUseMockWhenTestIsRunning(true);
        Test.setMock(HttpCalloutMock.class, new MarketingCloudEmails_API_TEST.Mock());
        Test.startTest();
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;

        Map<String,Object> res = MarketingCloudEmails_API.sendEmailMC('eng-us', '', 'mylv', '1111', 'rachela@balink.net', 'LastName', 'FirstName', 'M', '', '');
        Map<String,Object> expRes = new Map<String,Object> {
            'message' => 'status: null, statusCode: 202, responseId: 5ff7aca0-6403-11ed-8bf1-024163823c52',
            'success' => true
        };
        System.assertEquals(expRes, res);

        Test.stopTest();
    }

    @isTest
    public static void test_error_400() {
        HTTP_Utils.setUseMockWhenTestIsRunning(true);
        Test.setMock(HttpCalloutMock.class, new MarketingCloudEmails_API_TEST.MockError());
        Test.startTest();
        
        RestRequest request = new RestRequest();
        RestResponse response = new RestResponse();
        RestContext.request = request;
        RestContext.response = response;

        Map<String,Object> res = MarketingCloudEmails_API.sendEmailMC('eng-us', '', 'mylv', '1111', 'rachela@balink', 'ATLAN', 'Rachel', 'M', '', '');
        Map<String,Object> expRes = new Map<String,Object> {
            'form' => 'errorCode: SAPI-C001, errorDescription: HTTP POST on resource https://mcydkmypx9w3xcb5pdys9dqwpxxy.rest.marketingcloudapis.com:443/messaging/v1/email/messages/failed: bad request (400)., responseId: bc502880-6429-11ed-8bf1-024163823c52, status: 400',
            'success' => false
        };
        System.assertEquals(expRes, res);

        Test.stopTest();
    }

    @isTest
    public static void test_error_empty() {
        Test.startTest();

        Map<String,Object> res = MarketingCloudEmails_API.sendEmailMC('eng-us', '', 'mylv', '1111', '', 'ATLAN', 'Rachel', 'M', '', '');
        Map<String,Object> expRes = new Map<String,Object> {
            'form' => 'errorCode: null, errorDescription: null, responseId: null, status: null',
            'success' => false
        };
        System.assertEquals(expRes, res);

        Test.stopTest();
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

    private class MockError implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse res = new HTTPResponse();
            res.setBody(mockBodyError);
            res.setHeader('Content-Type', 'application/json');
            res.setStatusCode(400);
            return res;
        }
    }

    private static String mockBody = '{"status": 202,"responseId": "5ff7aca0-6403-11ed-8bf1-024163823c52","transactionDate": "2022-11-14T10:01:58.14Z","data": {"requestId": "b48364f8-22a4-4e08-8dfd-3b0305395449","errorcode": 0,"responses": [{"messageKey": "8ff9eba1-a129-4d72-9f68-e8ed7ee6bafc"}]}}';
    private static String mockBodyError = '{"status": 400,"responseId": "bc502880-6429-11ed-8bf1-024163823c52","transactionDate": "2022-11-14T14:36:34.649Z","data": {"errorCode": "SAPI-C001","errorType": "BAD_REQUEST","errorDescription": "HTTP POST on resource '+'https://mcydkmypx9w3xcb5pdys9dqwpxxy.rest.marketingcloudapis.com:443/messaging/v1/email/messages/' + 'failed: bad request (400)."}}';

}