/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-29-2023
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/

@isTest
public class ICX_WS_Manual_Merge_TEST {

    @TestSetup
    static void setupTestData() {
        // Create a ManualMerge_Setting__c custom setting record
        ManualMerge_Setting__c setting = new ManualMerge_Setting__c(
            SetupOwnerId = UserInfo.getOrganizationId(),  // This sets the custom setting at the org level
            // Set any other fields you need for your tests
            Retry__c = 1,
            codeErrorToRetry__c = '502;504'
        );
        insert setting;

        // // Create a TECH_IntegrationManager__c record
        // TECH_IntegrationManager__c record = new TECH_IntegrationManager__c();
        // record.ApexMethod__c = 'ManualMergeAPI';
        // record.Object_Name__c = 'Manual_Merge';
        // record.Other_Details__c = 'testClient';
        // record.Retry__c = 0;
        // record.Trigger_Event__c = 'CREATION';
        // record.OwnerId = UserInfo.getUserId();
        // record.Done__c = false;
        // record.Error__c = false;
        // record.Error_Status__c = '';
        
        // insert record;
    }
    
    // Create a mock callout class
    public class HttpCalloutMockImpl implements HttpCalloutMock {
        private Integer code; // The status code to return for the callout
        private String status; // The status message to return for the callout
        private String body; // The response body to return for the callout

        // Constructor
        public HttpCalloutMockImpl(Integer code, String status, String body){
            this.code = code;
            this.status = status;
            this.body = body;
        }

        // Implement this interface method
        public HTTPResponse respond(HTTPRequest req) {
            // Create a fake response
            HttpResponse res = new HttpResponse();
            res.setHeader('Content-Type', 'application/json');
            res.setBody(this.body);
            res.setStatusCode(this.code);
            res.setStatus(this.status);
            return res;
        }
    }
    
   @isTest
    static void testManualMerge_API_200(){
        // Initialize mock
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(201, 'OK', '{}'));

        Test.startTest();
            ICX_WS_Manual_Merge.Merge_TECH_IntegrationManager_Creation('[{"dreamId": "A789", "salesforceId": "A123", "userIdentitySalesforceId": "A345"}]');
        Test.stopTest();
        
         // Check the status of the record after the method execution
        TECH_IntegrationManager__c record = [SELECT Done__c, Error__c, Error_Status__c FROM TECH_IntegrationManager__c LIMIT 1];
        System.assertEquals(true, record.Done__c, 'The record should be marked as Done');
        System.assertEquals(false, record.Error__c, 'The record should not have any errors');
        System.assertEquals(null, record.Error_Status__c, 'The error status should be blank');
    }
    
    
       @isTest
    static void testManualMerge_API_502(){
        // Initialize mock
        Test.setMock(HttpCalloutMock.class, new HttpCalloutMockImpl(502, 'Bad Gateway', '{}'));

        Test.startTest();
            ICX_WS_Manual_Merge.Merge_TECH_IntegrationManager_Creation('[{"dreamId": "A789", "salesforceId": "A123", "userIdentitySalesforceId": "A345"}]');
        Test.stopTest();
        
         // Check the status of the record after the method execution
        TECH_IntegrationManager__c record = [SELECT Done__c, Error__c, Error_Status__c,Retry__c FROM TECH_IntegrationManager__c LIMIT 1];
        System.assertEquals(false, record.Done__c, 'The record should not be marked as Done');
        System.assertEquals(true, record.Error__c, 'The record should have an error');
        System.assertEquals('502', record.Error_Status__c, 'The error status should be 502');
        System.assertEquals(1, record.Retry__c, 'The retry should be 1');

    }
}