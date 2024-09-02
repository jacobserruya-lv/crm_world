@isTest
private class BL_Experience_WS_Router_TEST {
    @isTest
    static void BL_Experience_WS_RouterMapping() {  
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
    
        req.requestURI = '/services/apexrest/experience/v1'; //Request URL
        RestContext.request = req;
        RestContext.response= res;
        req.requestBody = Blob.valueof('{}');
        
        Test.startTest(); 
            Test.setMock(HttpCalloutMock.class, new CLT_CalloutMockInstance());
            BL_Experience_WS_Router.doGET();
            BL_Experience_WS_Router.doPOST();
            BL_Experience_WS_Router.doDELETE();
            BL_Experience_WS_Router.doPUT();
            BL_Experience_WS_Router.doPATCH();
        Test.stopTest();
    }
}