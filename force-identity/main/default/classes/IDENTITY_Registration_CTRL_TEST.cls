@isTest
global class IDENTITY_Registration_CTRL_TEST {
    
    @testSetup static void setUp() {
        Identity_TestFactory.createSettings();
    }
  
    @isTest static void test_controller() {
        //Identity_TestFactory.createSettings();

        PageReference pageRef = Page.Identity_Registration;
        pageRef.getParameters().put('lang-country','eng-us'); //pageRef.getParameters().put('lang-country','eng-e1');
        pageRef.getParameters().put('friendlyUrl','/eng-e1/mylv/registration');
        pageRef.getParameters().put('dev','true');
        pageRef.getParameters().put('step','1');
        pageRef.getParameters().put('login_international_mobile_phone','+972549876543');
        pageRef.getParameters().put('isValid','true');
        pageRef.getParameters().put('404Log','true');
        pageRef.getParameters().put('defaultCountryLangLog','eng-e2');
        pageRef.getParameters().put('campaign','careService');
        pageRef.getParameters().put('domain','louisvuitton.fr');
        pageRef.getParameters().put('origin','lvconnect');
        Test.setCurrentPage(pageRef);

        User user = Identity_TestFactory.createUser('TEST','TEST','354896321324@test.com','0541234567','972');

        Test.startTest();
            Identity_Registration_CTRL ctrl = new Identity_Registration_CTRL();

            // CLIENT
            Identity_Registration_CTRL.Client client = new Identity_Registration_CTRL.Client();
            client.lastname = 'TEST';
            client.firstname = 'TEST';
            client.login_email = 'test86532465431@test.con';
            client.login_email_confirmation = 'test86532465431@test.con';
            client.title = '02';
            client.password = '651321jhvfG!';
            client.country = 'FR';
            client.currency_code = 'EUR';
            client.international_mobile_phone = '+33621064456';
            client.privacy_agreement = 'true';
            client.newsletter_agreement = 'true';
            client.login_international_mobile_phone = '21064456';

            // ATTRIBUTES
            ctrl.input_code = '123';
            ctrl.isCreated = true;
            ctrl.user = user;
            ctrl.client = client;
            ctrl.expanded_kisa_details_index = 1;
            ctrl.currentUrl = '/eng-e1/mylv/registration';

            ctrl.username = 'test86532465431@test.com';
            System.debug(ctrl.countries_values);
        
            ctrl.fields.get('Settings').get('ATG createConfirmation').Is_Required__c=true;
            ctrl.fields.get('Settings').get('ATG creation before SF').Is_Required__c=true;
            ctrl.fields.get('Settings').get('Russia creation before SF').Is_Required__c=true;
            
            ctrl.form_settings.Default_To_Mobile_Phone__c='+33621064456,+33621064456';

            //METHODS
            ctrl.getCallingCodes();
            ctrl.getTitles();
            ctrl.getCountries();
            ctrl.register();
            ctrl.loginPasswordMethod();
            ctrl.redirect();
            ctrl.forgotPassword();            
            ctrl.getUserByUsername();
            ctrl.onLoginSubmit();
            ctrl.onPersonalSubmit();
            ctrl.onVerificationSubmit();
            ctrl.cancel();
            ctrl.sendVerificationCode();
            //ctrl.sendByEmail('123');
            ctrl.sendBySMS('1234');
            ctrl.log(); 
            ctrl.onScriptError();  
            ctrl.setSubMode();
            ctrl.updateSubMode();
            
            ctrl.country_local='cn';
            ctrl.forgotPassword();
            
            ctrl.mode='SOCIAL_REGISTRATION';
            ctrl.sub_mode='MATCHING';
            ctrl.onLoginSubmit();
            
            ctrl.fields.get('Settings').get('ATG creation before SF').Is_Required__c=false;
            ctrl.redirect();

        
            // REMOTE
            Identity_Registration_CTRL.onLoginEmailChange('a1b2c3d4e5@a1b2c3d4e5.com');
            Identity_Registration_CTRL.onLoginMobilePhoneChange('0549876543');

        Test.stopTest();
    }

    @isTest static void test_controller_RepairsContext() {
        //Identity_TestFactory.createSettings();
        Account acc = Identity_TestFactory.createAccount('ya', 'test', 'yaelg@test.com', '+972549876543', '', true);
        acc.FirstName2__pc='TEST';
        acc.LastName2__pc='TEST';
        acc.LoginPhone__pc='';
        acc.PersonMobilePhone='+972549876543';
        acc.MobilePhoneCountryCode__pc='972';
        acc.LoginPhoneCountryCode__pc='972';
        acc.AttachedStoreCode__pc='abc';
        acc.AttachedStoreCountry__pc='abc';
        update acc;
   
        PageReference pageRef = Page.Identity_Registration;
        pageRef.getParameters().put('lang-country','eng-e1');
        pageRef.getParameters().put('friendlyUrl','/eng-e1/mylv/registration');
        pageRef.getParameters().put('dev','true');
        pageRef.getParameters().put('step','1');
        pageRef.getParameters().put('login_international_mobile_phone','+972549876543');
        pageRef.getParameters().put('accountId',acc.Id);
        //test origin=checkout
        pageRef.getParameters().put('origin','checkout');
        pageRef.getParameters().put('errorUrl','/checkout/identification');

        Test.setCurrentPage(pageRef);
        User user = Identity_TestFactory.createUser('TEST','TEST','354896321324@test.com','0541234567','972');

        Test.startTest();
            Identity_Registration_CTRL ctrl = new Identity_Registration_CTRL();

            // CLIENT
            Identity_Registration_CTRL.Client client = new Identity_Registration_CTRL.Client();
            client.lastname = 'TEST';
            client.firstname = 'TEST';            
            client.title = '02';
            client.password = '651321jhvfG!';
            client.country = 'FR';
            client.currency_code = 'EUR';
            client.international_mobile_phone = '+33621064456';
            client.privacy_agreement = 'true';
            client.newsletter_agreement = 'true';
            client.login_international_mobile_phone = '21064456';

            // ATTRIBUTES
            ctrl.input_code = '123';
            ctrl.isCreated = true;
            ctrl.user = user;
            ctrl.client = client;
            ctrl.currentUrl = '/eng-e1/mylv/registration';

            //add coverage.. 
            ctrl.username = 'test86532465431@test.com';
            ctrl.getUserByUsername();
            ctrl.input_code = '';
            ctrl.isValidCode();
        
        	ctrl.input_code = '123456';
            ctrl.isValidCode();
        Test.stopTest();
    }

    @isTest static void test_controller_MultiCountry() {
        //Identity_TestFactory.createSettings();
        Account acc = Identity_TestFactory.createAccount('ya', 'test', 'yaelg@test.com', '+972549876543', '', true);

        PageReference pageRef = Page.Identity_Registration;
        pageRef.getParameters().put('lang-country','eng-e1');
        pageRef.getParameters().put('friendlyUrl','/eng-e1/mylv/registration');
        pageRef.getParameters().put('dev','true');
        pageRef.getParameters().put('step','1');
        pageRef.getParameters().put('dispatchCountry','FR');

        Test.setCurrentPage(pageRef);

        Test.startTest();
            Identity_Registration_CTRL ctrl = new Identity_Registration_CTRL();
        Test.stopTest();
    }

    @isTest static void test_locales_controller() {
        //Identity_TestFactory.createSettings();
        Identity_TestFactory.createCountryLanguageSettings();       

        PageReference pageRef = Page.Identity_Registration;
        Identity_Registration_CTRL ctrl;

        User user = Identity_TestFactory.createUser('TEST','TEST','354896321324@test.com','0541234567','972');

        Test.startTest();
            // DEFAULT
            pageRef.getParameters().put('lang-country','eng-e1');
            Test.setCurrentPage(pageRef);
            ctrl = new Identity_Registration_CTRL();

            // CHINA
            pageRef.getParameters().put('lang-country','zhs-cn');
            Test.setCurrentPage(pageRef);
            ctrl = new Identity_Registration_CTRL();
       		ctrl.fields.get('Personal').get('Mx').Is_Hidden__c=false;
            ctrl.getTitles();

            // JAPAN
            pageRef.getParameters().put('lang-country','jpn-jp');
            Test.setCurrentPage(pageRef);
            ctrl = new Identity_Registration_CTRL();
            ctrl.fields.get('Personal').get('Mx').Is_Hidden__c=false;
            ctrl.fields.get('Personal').get('Prefer not to say').Is_Hidden__c=false;
            ctrl.getTitles();

            // KOREA
            pageRef.getParameters().put('lang-country','kor-kr');
            Test.setCurrentPage(pageRef);
            ctrl = new Identity_Registration_CTRL();
            ctrl.getTitles();

            // RUSSIA
            pageRef.getParameters().put('lang-country','rus-ru');
            Test.setCurrentPage(pageRef);
            ctrl = new Identity_Registration_CTRL();
            ctrl.getTitles();
        Test.stopTest();
    }
    
    @isTest static void test_social_controller() {
        //Identity_TestFactory.createSettings();

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

        PageReference pageRef = Page.Identity_Registration;
        //pageRef.getParameters().put('lang-country','eng-e1');
        pageRef.getParameters().put('friendlyUrl','/eng-e1/mylv/registration');
        pageRef.getParameters().put('social_id', payload_encoded);
        pageRef.getParameters().put('isValid','false');
        pageRef.getParameters().put('login_international_mobile_phone','+972549876543');
        pageRef.getParameters().put('userStartUrl','userStartUrl');
        pageRef.getParameters().put('devStartUrl','login');
        pageRef.getParameters().put('lookId','lookId');
        Test.setCurrentPage(pageRef);

        User user = Identity_TestFactory.createUser('TEST','TEST','test86532465431@test.com','0541234567','972');

        Test.startTest();
            Identity_Registration_CTRL ctrl = new Identity_Registration_CTRL();

            // CLIENT
            Identity_Registration_CTRL.Client client = new Identity_Registration_CTRL.Client();
            client.lastname = 'TEST';
            client.firstname = 'TEST';
            client.currency_code = 'EUR';
            client.login_email = 'test86532465431@test.com';
            client.login_email_confirmation = 'test86532465431@test.com';
            client.title = '02';
            client.password = '651321jhvfG!';
            client.country = 'FR';
            client.international_mobile_phone = '+33621064456';
            client.privacy_agreement = 'true';
            client.newsletter_agreement = 'true';
            client.mobile_phone = '+33621064500';
            client.primary_country = 'FR';
            client.attached_store= 'abc';
            client.attached_store_code= 'abc';
            client.attached_store_country= 'abc';
            client.tech_attached_store_country= 'fr';

            // ATTRIBUTES
            ctrl.input_code = '123';
            ctrl.isCreated = true;
            ctrl.user = user;
            ctrl.client = client;
            ctrl.expanded_kisa_details_index = 1;
            ctrl.username = 'test86532465431@test.com';
            ctrl.currentUrl = '/eng-e1/mylv/registration';
        
            ctrl.fields.get('Login').get('mobile_phone').Is_Hidden__c=false;
            ctrl.fields.get('Personal').get('mobile_phone').Is_Hidden__c=false;
            ctrl.fields.get('Personal').get('Mx').Is_Hidden__c=false;
            ctrl.fields.get('Personal').get('Prefer not to say').Is_Hidden__c=false;
            

            //METHODS
            ctrl.getCallingCodes();
            ctrl.getTitles();
            ctrl.getCountries();
            ctrl.setSubMode();
            ctrl.register();
            ctrl.loginPasswordMethod();
            ctrl.redirect();
            ctrl.forgotPassword();
            //ctrl.sendByEmail('123');
            ctrl.username = 'test86532465431@test.com';
            ctrl.getUserByUsername();
            ctrl.onLoginSubmit();
            ctrl.onPersonalSubmit();
            ctrl.onVerificationSubmit();
        
            //add coverage.. 
            ctrl.setMode();
            ctrl.onScriptError();
            ctrl.socialLogin();
            ctrl.counter_message= 100;
            ctrl.sendVerificationCode();
            ctrl.setSocialMediaIdentifier();
        
            ctrl.mode = 'SOCIAL_REGISTRATION';
            ctrl.sub_mode = 'MATCHING';
            ctrl.register();       

			ctrl.getAccountFromForm(); 

            // REMOTE
            Identity_Registration_CTRL.onLoginEmailChange('a1b2c3d4e5@a1b2c3d4e5.com');
        	Identity_Registration_CTRL.onLoginEmailChange('test86532465431@test.com');
            Identity_Registration_CTRL.onLoginMobilePhoneChange('0549876543');

        Test.stopTest();
    }
    
	@isTest static void test_birthdate() {
        //Identity_TestFactory.createSettings();
    
        PageReference pageRef = Page.Identity_Registration;
        pageRef.getParameters().put('lang-country','eng-e1');
        pageRef.getParameters().put('friendlyUrl','/eng-e1/mylv/registration');
        pageRef.getParameters().put('dev','true');
        pageRef.getParameters().put('step','1');
        pageRef.getParameters().put('login_international_mobile_phone','+972549876543');
        pageRef.getParameters().put('isValid','true');
        pageRef.getParameters().put('404Log','true');
        pageRef.getParameters().put('defaultCountryLangLog','eng-e2');
        pageRef.getParameters().put('campaign','careService');
        pageRef.getParameters().put('domain','louisvuitton.fr');
        pageRef.getParameters().put('origin','lvconnect');
        Test.setCurrentPage(pageRef);
        
        User user = Identity_TestFactory.createUser('TEST','TEST','354896321324@test.com','0541234567','972');
    
        Test.startTest();
        Identity_Registration_CTRL ctrl = new Identity_Registration_CTRL();
        
        // CLIENT
        Identity_Registration_CTRL.Client client = new Identity_Registration_CTRL.Client();
        client.lastname = 'TEST';
        client.firstname = 'TEST';
        client.login_email = 'test86532465431@test.con';
        client.login_email_confirmation = 'test86532465431@test.con';
        client.title = '02';
        client.password = '651321jhvfG!';
        client.country = 'FR';
        client.currency_code = 'EUR';
        client.international_mobile_phone = '+33621064456';
        client.privacy_agreement = 'true';
        client.newsletter_agreement = 'true';
        client.login_international_mobile_phone = '21064456';
        
        // ATTRIBUTES
        ctrl.input_code = '123';
        ctrl.isCreated = true;
        ctrl.user = user;
        ctrl.client = client;
        ctrl.expanded_kisa_details_index = 1;
        ctrl.currentUrl = '/eng-e1/mylv/registration';
        client.birthdateDay ='30';
        client.birthdateMonth ='1';
        client.birthdateYear ='2007';

        client.birthdate = '2007. 01. 30';
        client.postal_code = '75009';
        client.state = 'state';
        client.city = 'city';
        client.address1 = 'address1';
        client.address2 = 'address2';
        client.address3 = 'address3';
        client.address1 = 'address1';

        

        ctrl.username = 'test86532465431@test.com';
        System.debug(ctrl.countries_values);
        
        ctrl.fields.get('Settings').get('ATG createConfirmation').Is_Required__c=true;
        ctrl.fields.get('Settings').get('ATG creation before SF').Is_Required__c=true;
        ctrl.fields.get('Settings').get('Russia creation before SF').Is_Required__c=true;
        ctrl.fields.get('Personal').get('birthdate').Is_Hidden__c=false;
        
        ctrl.form_settings.Default_To_Mobile_Phone__c='+33621064456,+33621064456';
        
        //METHODS
        ctrl.getCallingCodes();
        ctrl.getTitles();
        ctrl.getCountries();
        ctrl.register();
        ctrl.loginPasswordMethod();
        ctrl.redirect();
        ctrl.forgotPassword();            
        ctrl.getUserByUsername();
        ctrl.onLoginSubmit();
        ctrl.onPersonalSubmit();
        ctrl.onVerificationSubmit();
        ctrl.cancel();
        ctrl.sendVerificationCode();
        //ctrl.sendByEmail('123');
        ctrl.sendBySMS('1234');
        ctrl.log(); 
        ctrl.onScriptError();  
        ctrl.setSubMode();
        ctrl.updateSubMode();
        
        ctrl.country_local='cn';
        ctrl.forgotPassword();
        
        ctrl.mode='SOCIAL_REGISTRATION';
        ctrl.sub_mode='MATCHING';
        ctrl.onLoginSubmit();
        
        ctrl.fields.get('Settings').get('ATG creation before SF').Is_Required__c=false;
        ctrl.redirect();
        ctrl.getAccountFromForm(); 
        
        
        // REMOTE
        Identity_Registration_CTRL.onLoginEmailChange('a1b2c3d4e5@a1b2c3d4e5.com');
        // Identity_Registration_CTRL.onLoginMobilePhoneChange('0549876543');
        
        Test.stopTest();
    }
    
    //added
    @isTest static void test_logValidationError() {
        
        Test.startTest();
        Identity_Registration_CTRL ctrl = new Identity_Registration_CTRL();
        ctrl.logErrorLoginEmailOrMobileModified();
        
        Logs__c myLog = [SELECT id, Apex_Class__c, Message__c, Category__c 
                       FROM Logs__c 
                       WHERE Category__c = 'VALIDATION' 
                       AND Apex_Class__c = 'Identity_Registration_CTRL'
                       ORDER BY CreatedDate DESC LIMIT 1];
        
        System.assertequals(myLog.Message__c, 'EMAIL OR MOBILE MODIFIED');
        
        ctrl.verifyCaptcha();
        ctrl.origin = 'lvapp';
        ctrl.setPrivacyPolicyLinkForApp();
        Identity_Registration_CTRL.onCheckValidationPasswordWhenActivation('password', 'activation_client_encrypted', 'firstname', 'lastname', 'email', 'mobilephone');
        
        Test.stopTest();
    }
    
}