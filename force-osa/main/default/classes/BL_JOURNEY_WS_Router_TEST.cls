@isTest
private class BL_JOURNEY_WS_Router_TEST {
    @isTest
    static void testRouter() {  
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/journey/v1'; //Request URL
        RestContext.request = req;
        RestContext.response= res;
        req.requestBody = Blob.valueof('{}');
        
        Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new CLT_CalloutMockInstance());
            BL_JOURNEY_WS_Router.doGET();
            BL_JOURNEY_WS_Router.doPOST();
            BL_JOURNEY_WS_Router.doDELETE();
            BL_JOURNEY_WS_Router.doPUT();
            BL_JOURNEY_WS_Router.doPATCH();
        Test.stopTest();
    }
}