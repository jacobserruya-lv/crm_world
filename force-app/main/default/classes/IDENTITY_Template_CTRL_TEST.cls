@isTest
global class IDENTITY_Template_CTRL_TEST {
    
    
    @isTest static void test_controller() {
     	Identity_TestFactory.createSettings();
        Account acc = Identity_TestFactory.createAccount('ya', 'test', 'yaelg@test.com', '+972549876543', '', true);
        IDENTITY_Utils.createMylvClient(acc, 'Balink123*');

        PageReference pageRef = Page.Identity_Registration;
        pageRef.getParameters().put('accountId',acc.Id);
        pageRef.getParameters().put('origin','lvconnect');
        pageRef.getParameters().put('domain','mydomain');
        pageRef.getParameters().put('lang-country','zhs-cn');
        Test.setCurrentPage(pageRef);

        Test.startTest();
            IDENTITY_Template_CTRL ctrl = new IDENTITY_Template_CTRL();
        Test.stopTest();
    }
 }