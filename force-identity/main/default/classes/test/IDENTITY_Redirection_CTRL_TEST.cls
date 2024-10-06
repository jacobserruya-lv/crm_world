@isTest
private class IDENTITY_Redirection_CTRL_TEST {
    
    @isTest static void test_login_controller() {
        Identity_TestFactory.createSettings();
    
        PageReference pageRef;
        IDENTITY_Redirection_CTRL ctrl;
        
        Test.startTest();

            // FROM COOKIES
            pageRef = Page.IDENTITY_Redirection;
            pageRef.getParameters().put('access_token','test');
            pageRef.getParameters().put('dev','1');
            pageRef.getParameters().put('origin','lvconnect');
            pageRef.getParameters().put('userStartUrl','userStartUrl');
            pageRef.getParameters().put('devStartUrl','login');
            Cookie cook = new Cookie('redirectURL', 'redirectURL', 'https://eu.louisvuitton.com', 1440, false);
            pageRef.setCookies(new Cookie[]{cook});
            Test.setCurrentPage(pageRef);
            ctrl = new IDENTITY_Redirection_CTRL();
            ctrl.redirect();

            // FROM URL
            pageRef = Page.IDENTITY_Redirection;
            pageRef.getParameters().put('access_token','test');
            pageRef.getParameters().put('redirectURL','https://eu.louisvuitton.com');
            Test.setCurrentPage(pageRef);
            ctrl = new IDENTITY_Redirection_CTRL();
            ctrl.redirect();

            // FROM SETTINGS
            pageRef = Page.IDENTITY_Redirection;
            pageRef.getParameters().put('access_token','test');
            Test.setCurrentPage(pageRef);
            ctrl = new IDENTITY_Redirection_CTRL();
            ctrl.redirect();
        Test.stopTest();
    }

    @isTest static void test_sso_controller() {
        Identity_TestFactory.createSettings();
    
        PageReference pageRef;
        IDENTITY_Redirection_CTRL ctrl;
        
        Test.startTest();
            pageRef = Page.IDENTITY_Redirection;
            pageRef.getParameters().put('social_media','WeChat');
            pageRef.getParameters().put('userStartUrl','userStartUrl');
            pageRef.getParameters().put('devStartUrl','registration');
            Test.setCurrentPage(pageRef);
            ctrl = new IDENTITY_Redirection_CTRL();
            ctrl.redirect();
        Test.stopTest();
    }

  

    @isTest static void test_social_registration_controller1() {
        Identity_TestFactory.createSettings();
    
        PageReference pageRef;
        IDENTITY_Redirection_CTRL ctrl;
        
        Test.startTest();

            String payload = '{'
                +  '"social_id":         "123",' 
                +  '"email":             "testjgadjkhakjds@test.test",'
                +  '"firstname":         "test",'
                +  '"lastname":          "test",'
                +  '"nickname":          "test",'
                +  '"social_media_type": "WeChat",'
                +  '"others": "' +        JSON.serialize(new Map<String,String>()) + '"'
                + '}';

            String payload_encoded = EncodingUtil.base64Encode(Blob.valueOf(payload));

            pageRef = Page.IDENTITY_Redirection;
            pageRef.getParameters().put('ErrorDescription', payload_encoded);
            pageRef.getParameters().put('errorCode', 'errorCode');
            pageRef.getParameters().put('userStartUrl','userStartUrl');
            pageRef.getParameters().put('devStartUrl','devStartUrl');
            Test.setCurrentPage(pageRef);
            ctrl = new IDENTITY_Redirection_CTRL();
            ctrl.redirect();
        Test.stopTest();
    }
    
        @isTest static void test_social_registration_controller2() {
        Identity_TestFactory.createSettings();
    
        PageReference pageRef;
        IDENTITY_Redirection_CTRL ctrl;
        
        Test.startTest();

            String payload = 'wrong_payload';

            pageRef = Page.IDENTITY_Redirection;
            pageRef.getParameters().put('ErrorDescription', payload);
            pageRef.getParameters().put('errorCode', 'errorCode');
            pageRef.getParameters().put('userStartUrl','userStartUrl');
            pageRef.getParameters().put('devStartUrl','devStartUrl');
            Test.setCurrentPage(pageRef);
            ctrl = new IDENTITY_Redirection_CTRL();
            ctrl.redirect();
        Test.stopTest();
    }

    @isTest static void test_error_controller() {
        Identity_TestFactory.createSettings();
    
        PageReference pageRef;
        IDENTITY_Redirection_CTRL ctrl;
        
        Test.startTest();
            pageRef = Page.IDENTITY_Redirection;
            pageRef.getParameters().put('userStartUrl','userStartUrl');
            pageRef.getParameters().put('devStartUrl','devStartUrl');
            Test.setCurrentPage(pageRef);
            ctrl = new IDENTITY_Redirection_CTRL();
            ctrl.redirect();
        Test.stopTest();
    }
}