@isTest
public with sharing class PersonNames_WS_TEST {
    

    @testsetup static void setupMethod(){
       
    }
   
   @istest static void TestGetAuthUser() {
       RestRequest req = new RestRequest();
       RestResponse res = new RestResponse();
       req.requestURI = '/services/apexrest/person-names' ; //Request URL
       req.httpMethod = 'POST';
       RestContext.request = req;
       RestContext.response= res;

        Account acc = new Account(LastName = 'test');
		insert acc;
        String JsonMsg ='['+
  							'"' + UserInfo.getUserId() +  '",' +
                            '"' + acc.id + '"' +
            			']';
        System.Debug(JsonMsg);
            
        req.requestBody = Blob.valueOf(JsonMsg);


       Test.startTest();
        User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
            PersonNames_WS.post();
        }
       Test.stopTest();

       System.assertEquals(200, RestContext.response.statusCode);
    
   }
    

}