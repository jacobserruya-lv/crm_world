@isTest
public class BL_WRDB_Notifications_TEST {
   
    @isTest 
    public static void testAPINotifications() {

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/wrdb-notifications' ; //Request URL
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response= res;

        Account acc = new Account(LastName = 'test');
		insert acc;
        String jsonMsg ='{'+
  							'"ownerId": "' + UserInfo.getUserId() +  '",' +
                            '"clientId":"' + acc.id + '",' +
                            '"wardrobingName": "TEST",' +
                            '"sharingId":" JBKBCL"' +
            			'}';
        System.Debug(JsonMsg);
            
        req.requestBody = Blob.valueOf(JsonMsg);

		BL_WRDB_Notifications_TEST.setTestSettings();
       Test.startTest();
        User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
		insert u;
		system.runAs(u) {
            BL_WRDB_Nofifications.post();
        }
       Test.stopTest();

       //System.assertEquals(200, RestContext.response.statusCode,true);

    }
    
    static public void setTestSettings(){
        if(IM_Notifications__c.getInstance('en_US')==null){

            IM_Notifications__c imn =  new IM_Notifications__c(
                Name='en_US',
                WardrobingLike__c = 'A new client {1} intercated With wardrobing : {0}'
            );
            insert imn;
        }
    }

}