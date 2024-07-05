@isTest
private class IM_TeamManagment_TEST {

    @testSetup static void setUp() {
        User user1 = new User(
            username = 'johntest112@acme.com',
            alias = 'johnTest',
            emailEncodingKey = 'UTF-8',
            firstName = 'John',
            lastName = 'test',
            localeSIDKey = 'en_US',
            languageLocaleKey = 'en_US',
            timezoneSIDKey = 'America/Los_Angeles');
        user1.email =   'johntest1@acme.com';
        user1.profileId = IC_UTILS.getSAProfile();
        insert user1;


        User user2 = new User(
            username = 'testtest2@acme.com',
            alias = 'testtest',
            emailEncodingKey = 'UTF-8',
            firstName = 'Jotesttes',
            lastName = 'test',
            localeSIDKey = 'en_US',
            languageLocaleKey = 'en_US',
            timezoneSIDKey = 'America/Los_Angeles');
        user2.email =   'testtest123@acme.com';
        user2.profileId = IC_UTILS.getSAProfile();
        insert user2;

        Map<String, Object> body = new Map<String, Object>();
        body.put('teamIds', user2.Id);
        IM_TeamManagment.setTeamMembers(body);

        List<String> inList = new List<String>();
        IM_TeamManagment.indexOf(inList, user1.Id);
    }

    @isTest
    static void test1(){

        RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/TeamManagment/';
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

        Test.startTest();
        IM_TeamManagment.get();
        IM_TeamManagment.post();
        Test.stopTest();
    }

     @isTest
    static void test2() {

        RestRequest req2 = new RestRequest();
		RestResponse res2 = new RestResponse();

        req2.requestURI = '/services/apexrest/TeamManagment/ ';
		req2.httpMethod = 'POST';
        RestContext.request = req2;
		RestContext.response = res2;

        Test.startTest();
        IM_TeamManagment.post();
        Test.stopTest();
    }

    @isTest
    static void test3() {
        RestRequest req3 = new RestRequest();
		RestResponse res3 = new RestResponse();

        req3.requestURI = '/services/apexrest/TeamManagment/ ';
		req3.httpMethod = 'GET';
        RestContext.request = req3;
		RestContext.response = res3;

        Test.startTest();
        IM_TeamManagment.get();
        Test.stopTest();
    }

}