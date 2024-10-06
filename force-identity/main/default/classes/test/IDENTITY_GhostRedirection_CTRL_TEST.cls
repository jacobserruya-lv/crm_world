@isTest
private class IDENTITY_GhostRedirection_CTRL_TEST {
    
    @isTest static void test_login_controller() {
        Identity_TestFactory.createSettings();
    
        PageReference pageRef;
        IDENTITY_GhostRedirection_CTRL ctrl;
        
        Test.startTest();
            // FROM URL
            pageRef = Page.IDENTITY_GhostRedirection;
            Test.setCurrentPage(pageRef);
            ctrl = new IDENTITY_GhostRedirection_CTRL();
            ctrl.redirect();


        Test.stopTest();
    }
}