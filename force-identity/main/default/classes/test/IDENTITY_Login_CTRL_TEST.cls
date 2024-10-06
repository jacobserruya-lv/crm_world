@isTest
global class IDENTITY_Login_CTRL_TEST {
    
    
    @isTest static void test_controller() {
        Identity_TestFactory.createSettings();
        Account acc = Identity_TestFactory.createAccount('ya', 'test', 'yaelg@test.com', '+972549876543', '', true);
        IDENTITY_Utils.createMylvClient(acc, 'Balink123*');

        String code = String.valueOf(Math.round(Math.random() * 100000));
        Account acc_mobile = Identity_TestFactory.createAccount('jean', 'jacques', null, code + '17864123456','86', true);
        Identity_Utils.createMylvClient(acc_mobile, 'Balink123*');

        PageReference pageRef = Page.Identity_Registration;
        pageRef.getParameters().put('friendlyUrl','/eng-e1/mylv/registration');
        pageRef.getParameters().put('dev','true');
        pageRef.getParameters().put('step','1');
        pageRef.getParameters().put('accountId',acc_mobile.Id);
        pageRef.getParameters().put('defaultCountryLangLog','true');
        pageRef.getParameters().put('404Log','true');
        pageRef.getParameters().put('social_media','line');
        pageRef.getParameters().put('origin','lvconnect');
        pageRef.getParameters().put('domain','mydomain');
        pageRef.getParameters().put('successUrl','myurl');
        pageRef.getParameters().put('campaign','careService');
        pageRef.getParameters().put('lang-country','zhs-cn');
        Test.setCurrentPage(pageRef);


        Test.startTest();
            IDENTITY_Login_CTRL ctrl = new IDENTITY_Login_CTRL();

            ctrl.username = 'yaelg@test.com';
            ctrl.currentUrl = '/eng-e1/mylv/registration';
            ctrl.origin = 'lvapp';

            //METHODS
            List<SelectOption> s=ctrl.getCallingCodes(); 
            system.assertNotEquals(null, s[0].getValue(), 'ERROR');
            PageReference page=ctrl.loginPasswordMethod();
        	System.assertEquals(null,page);
            PageReference page2=ctrl.forgotPassword();
        	PageReference page3=ctrl.log();
        	System.assertEquals(page3,null);
            PageReference page4=ctrl.onScriptError(); 
        	System.assertEquals(page4,null);
            PageReference page5=ctrl.socialLogin();
            PageReference page6=ctrl.logout();
            Test.setCurrentPage(pageRef);
            ctrl = new IDENTITY_Login_CTRL();
            PageReference page7=ctrl.logout(); 

            IDENTITY_Login_CTRL.onLoginEmailChange(ctrl.username);
            IDENTITY_Login_CTRL.onLoginMobilePhoneChange('17864123456');

        Test.stopTest();
    }
 }