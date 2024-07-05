@isTest
private class BL_EMAIL_WS_RouterMapping_TEST {

    @isTest
    static void testRoute(){    
        
        Test.setMock(HttpCalloutMock.class, new CLT_CalloutMockInstance());
        String json= '{}';

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestBody = Blob.valueof(json);

        RestContext.request = req;
        RestContext.response = res;
        
        BL_AppSettings.setAppSettings('email');
        BL_AppSettings.currentAppSettings.isLogActive = true;
        BL_AppSettings.currentAppSettings.isImmediateLog = true;
        
        Test.startTest();
            BL_EMAIL_WS_Router.doPOST();
            BL_EMAIL_WS_Router.doPUT();
            BL_EMAIL_WS_Router.doGET();
            BL_EMAIL_WS_Router.doPATCH();
            BL_EMAIL_WS_Router.doDELETE();
        Test.stopTest();
    }
    
    @isTest
    public static void testRouteMapping(){

        BL_EMAIL_WS_RouterMapping router = new BL_EMAIL_WS_RouterMapping();
        Map<String,String> mapRouting = router.routesMapping();
        if(!mapRouting.keySet().isEmpty()){
            String firstelement = new list<string>(mapRouting.keySet())[0];   
            router.getCurrentRoute(firstelement);
            router.getCurrentRoute('');
            
            System.assertEquals(false, maprouting.isEmpty());
        }
        
        BL_WS_RouteMapping routerInterface = new BL_WS_RouteMapping();
        Map<String,String> mapRouting1 = routerInterface.routesMapping();
    }

}