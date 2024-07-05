/*
*** CREATED DATE December 2018
*** COMPANY      Balink
*** AUTHOR       Elchanan Rottman
*** DESCRIPTION  Test for Web Service MyCC (MYCC_WS_Client)
*/
@isTest
public class MYCC_WS_Client_Test {
   
    @isTest static void testPostAPI(){
        Account testAcc = IDENTITY_TestFactory.createAccount('firstName', 'lastName', 'email@test.com', '541234567', '972', false);
        testAcc.DREAMID__c = 'a1b2c3_test';
        insert testAcc;

        Account testAcc2 = IDENTITY_TestFactory.createAccount('firstName', 'lastName', 'email@test.com', '541234567', '972', false);
        Account testAcc3 = IDENTITY_TestFactory.createAccount('firstName2', 'lastName2', 'email2@test.com', '5412345672', '972', false);
        Account testAcc4 = IDENTITY_TestFactory.createAccount('firstName2', 'lastName2', null, null, null, false);
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse(); 
        req.httpMethod = 'POST';
        req.requestURI = '/services/apexrest/MyCC/Client';
        req.addHeader('Content-Type','application/json');
        
        List<String> fieldsToSend = new List<String>{'LocalMobilePhone__pc','MobilePhoneCountryCallingCode__pc','DREAMID__c','LastName','LastName','FirstName','PersonEmail'};
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
            // EMPTY BODY
            req.requestBody = Blob.valueOf('');
            MYCC_WS_Client.post();
        	System.assertEquals(RestContext.response.statusCode,400);

            // MISSING REQUIRED FIELDS
            req.requestBody = Blob.valueOf(JSON.serialize(RestResource_Utils.prettyJSON(testAcc4, fieldsToSend)));
            MYCC_WS_Client.post();
        	System.assertEquals(RestContext.response.statusCode,200);

            // BY DREAM ID
            req.requestBody = Blob.valueOf(JSON.serialize(RestResource_Utils.prettyJSON(testAcc, fieldsToSend)));
            MYCC_WS_Client.post();
        	System.assertEquals(RestContext.response.statusCode,200);
        	

            // BY IDENTIFIER FIELDS
            req.requestBody = Blob.valueOf(JSON.serialize(RestResource_Utils.prettyJSON(testAcc2, fieldsToSend)));
            MYCC_WS_Client.post();
        	System.assertEquals(RestContext.response.statusCode,200);

            // NEW CLIENT
            req.requestBody = Blob.valueOf(JSON.serialize(RestResource_Utils.prettyJSON(testAcc3, fieldsToSend)));
            MYCC_WS_Client.post();
        	System.assertEquals(RestContext.response.statusCode,200);
         // NEW CLIENT whith new Update 22/02/2021
            req.requestBody = Blob.valueOf(RestResource_Utils.getMyccBody());
            MYCC_WS_Client.post();
        	System.assertEquals(RestContext.response.statusCode,200);
        Test.stopTest();
    }
}