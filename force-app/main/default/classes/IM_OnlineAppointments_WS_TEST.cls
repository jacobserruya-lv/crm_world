@isTest
private class IM_OnlineAppointments_WS_TEST {


    @testSetup static void setUp(){

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
    }

    @isTest
    static void test1(){

        RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/IM_OnlineAppointment/';
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

        Test.startTest();
        IM_OnlineAppointments_WS.get();
        IM_OnlineAppointments_WS.post();
        Test.stopTest();
    }

        @isTest
    static void test2(){

        RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/IM_OnlineAppointment/Cancel';
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

        Test.startTest();
        IM_OnlineAppointments_WS.get();
        IM_OnlineAppointments_WS.post();
        Test.stopTest();
    }


    @isTest
    static void test3(){

        RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/IM_OnlineAppointment/Availability';
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

        Test.startTest();
        IM_OnlineAppointments_WS.get();
        IM_OnlineAppointments_WS.post();
        Test.stopTest();
    }

        @isTest
    static void test4(){

        RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/IM_OnlineAppointment/AvailableUsers';
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

        Test.startTest();
        IM_OnlineAppointments_WS.get();
        IM_OnlineAppointments_WS.post();
        Test.stopTest();
    }

    @isTest
    static void test5(){

        RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/IM_OnlineAppointment/Assign';
		req.httpMethod = 'POST';
		RestContext.request = req;
		RestContext.response = res;

        Test.startTest();
        IM_OnlineAppointments_WS.get();
        IM_OnlineAppointments_WS.post();
        Test.stopTest();
    }

    @isTest
    static void test6(){

        RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/IM_OnlineAppointment/OnlineAndTeamAppointments';
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

        Test.startTest();
        IM_OnlineAppointments_WS.get();
        IM_OnlineAppointments_WS.post();
        Test.stopTest();
    }
}