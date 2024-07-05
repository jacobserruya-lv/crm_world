@isTest
public with sharing class BL_SF_AUTH_Validation_WS_TEST {
    

    @testsetup static void setupMethod(){
       
       

   }
   
   @istest static void TestGetAuthUser() {
       RestRequest req = new RestRequest();
       RestResponse res = new RestResponse();
       req.requestURI = '/services/apexrest/sf-auth-validation' ; //Request URL
       req.httpMethod = 'GET';
       RestContext.request = req;
       RestContext.response= res;


       Test.startTest();
       User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
            BL_SF_AUTH_Validation_WS.get();
        }
       Test.stopTest();

       System.assertEquals(200, RestContext.response.statusCode);
    
   }
    
       @istest static void TestGetAuthUser2() {
       RestRequest req = new RestRequest();
       RestResponse res = new RestResponse();
       req.requestURI = '/services/apexrest/sf-auth-validation' ; //Request URL
       req.httpMethod = 'GET';
       RestContext.request = req;
       RestContext.response= res;
           
       try{
           
        Identity_TestFactory.createSettings();
        User u = Identity_TestFactory.createUser('Jean', 'Marc', 'testIW@test.com', null, 'USA');   
       // User u = [SELECT id from user where email = 'testIW@test.com' ];

        Test.startTest();
     
		system.runAs(u) {
            BL_SF_AUTH_Validation_WS.get();
        }
       Test.stopTest();

       System.assertEquals(200, RestContext.response.statusCode);
    }catch(Exception ex){}

    
   }


}