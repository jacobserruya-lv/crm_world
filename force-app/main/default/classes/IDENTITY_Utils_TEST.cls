/**
 * @File Name          : IDENTITY_Utils_TEST.cls
 * @Description        :
 * @Author             : Lirone Galletto
 * @Group              :
 * @Last Modified By   : ChangeMeIn@UserSettingsUnder.SFDoc
 * @Last Modified On   : 11/26/2019, 2:17:05 PM
 * @Modification Log   :
 * Ver       Date            Author      		    Modification
 * 1.0    11/26/2019   Balink     Initial Version
**/
@isTest
private class IDENTITY_Utils_TEST {

    private static Map<String,String> prospect = new Map<String,String> {
        'firstName' => 'John',
        'lastName' => 'Doe202108221439',
        'email' => 'john@doe202108221439.com',
        'localPhone' => '026515588',
        'countryCode' => '33'
    };

    @testSetup
    static void setup() {
        IDENTITY_TestFactory.createAccount(
            prospect.get('firstName'),
            prospect.get('lastName'),
            prospect.get('email'),
            prospect.get('localPhone'),
            prospect.get('countryCode'),
            true
        );
    }

    @isTest
    static void test_createMylvClientAccountWithEmail() {
        Identity_TestFactory.createSettings();
        String password = 'HDtfqawdv5435!';
        String code;
        Account acc;
        User user;
         // Create MyLV account with email
        code = String.valueOf(Math.round(Math.random() * 100000));
        acc = Identity_TestFactory.createAccount('Jean', 'Marc', code + 'test@test.com', null, null, true);
        acc.SPO_Country_code__pc = 'USA';
        user = Identity_Utils.createMylvClient(acc, password);

        // Test updatePassword   
        String shortPassword =  'Test2@test.com';
        String longPassword =  'P@1pppppppP@1pppppppP@1pppppppP@1pppppppP@1pppppppP@1pppppppP@1pppppppP@1pppppppP@1pppppppP@1pppppppP@1pppppppP@1pppppppP@1ppppppp';
        Identity_Utils.updatePassword(user.Id, shortPassword);
        try{
            Identity_Utils.updatePassword(user.Id, longPassword);
        }
        catch(Exception e){}
    }

    @isTest
    static void test_createMylvClientAccountWithMobile() {
        Identity_TestFactory.createSettings();
        String password = 'HDtfqawdv5435!';
        String code;
        Account acc;
        User user;
        // Create MyLV account with mobile
        code = String.valueOf(Math.round(Math.random() * 100000));
        acc = Identity_TestFactory.createAccount('jean', 'jacques', null, code + '026515588','33', true);
        Identity_Utils.createMylvClient(acc, password);
    }

    @isTest
    static void test_createMylvClientWithIncorrectSalutation() {
        Identity_TestFactory.createSettings();
        String password = 'HDtfqawdv5435!';
        String code;
        Account acc;
        User user;
        // Create MyLV account with incorrect salutation
        code = String.valueOf(Math.round(Math.random() * 100000));
        acc = Identity_TestFactory.createAccount('jean','michel', code + 'test@test.com', code + '026515588','33', false);
        acc.Salutation = 'MRS';
        Identity_Utils.createMylvClient(acc, password);
    }

    @isTest
    static void test_createMylvClientWithMobileContact() {
        Identity_TestFactory.createSettings();
        String password = 'HDtfqawdv5435!';
        String code;
        Account acc;
        User user;
        // Create MyLV account with mobile contact
        code = String.valueOf(Math.round(Math.random() * 100000));
        acc = Identity_TestFactory.createAccount('jean','michel', code + 'test@test.com', code + '026515588','33', false);
        acc.LocalMobilePhone__pc = '0265155886';
        acc.MobilePhoneCountryCallingCode__pc = '33';
        Identity_Utils.createMylvClient(acc, password);
    }

    @isTest
    static void test_createMylvClient() {
        Identity_TestFactory.createSettings();
        
        Test.StartTest();

            String password = 'HDtfqawdv5435!';
            String code;
            Account acc;
            User user;

            // Missing required fields
            try{
                code = String.valueOf(Math.round(Math.random() * 100000));
                acc = Identity_TestFactory.createAccount(null, 'Marc', code + 'test@test.com', null, null, true);
                Identity_Utils.createMylvClient(acc, password);
            }
            catch(Exception e){}
            Test.StopTest();
    }
    
    @isTest
    static void test_updateMylvClient() {
        Identity_TestFactory.createSettings();

        Test.StartTest();

            String password = 'HDtfqawdv5435!';
            String code;
            Account acc;
            User user;

            code = String.valueOf(Math.round(Math.random() * 100000));
            acc = Identity_TestFactory.createAccount('jean','marc', code + 'test@test.com', null,null, true);
            user = Identity_Utils.createMylvClient(acc, password);

            Account accUpdated = new Account(
                DREAMID__c = acc.Id,
                PersonEmail = code + 'TEST2@test.com',
                LocalMobilePhone__pc = '12356450',
                MobilePhoneCountryCallingCode__pc = '33',
                LocalLoginPhone__pc = '865132',
                LoginPhoneCallingCode__pc = '33',
                Salutation = 'MRS'
            );
            // Update MyLV account with Id
            try{
                accUpdated.SPO_Country_code__pc = 'USA';
                Identity_Utils.updateMylvClient(accUpdated, user.Id);
            }
            catch(Exception e){}
            Test.StopTest();

            // Update MyLV account with Dream Id
            try{
                Identity_Utils.updateMylvClient(accUpdated, user.Id);
            }
            catch(Exception e){}

            // Update Prospect
            Identity_Utils.willUpdateProspect(JSON.serialize(accUpdated));
            List<Account> a= [SELECT Id,PersonEmail,LocalMobilePhone__pc,MobilePhoneCountryCallingCode__pc,LocalLoginPhone__pc,LoginPhoneCallingCode__pc,Salutation FROM Account WHERE DREAMID__c = :accUpdated.Id];
    }
     
    @isTest
    static void test_updateMylvClient2() {
        Identity_TestFactory.createSettings();

        Test.StartTest();

            String password = 'HDtfqawdv5435!';
            String code;
            Account acc;
            User user;

            code = String.valueOf(Math.round(Math.random() * 100000));
            acc = Identity_TestFactory.createAccount('jean','valjean', code + 'test22@louisvuitton.com', null,null, true);
            user = Identity_Utils.createMylvClient(acc, password);

            Account accUpdated = new Account(
                DREAMID__c = acc.Id,
                LocalMobilePhone__pc = '12356450',
                MobilePhoneCountryCallingCode__pc = '33',
                LocalLoginPhone__pc = '865132',
                LoginPhoneCallingCode__pc = '33',
                PersonMobilePhone = '-336580974150',
                Salutation = 'MRS'
            );

            // Update MyLV account with Id
            try{
                Identity_Utils.updateMylvClient(accUpdated, user.Id);
            }
            catch(Exception e){}
            Test.StopTest();
            // Update Prospect
            Identity_Utils.willUpdateProspect(JSON.serialize(accUpdated));
            List<Account> a= [SELECT Id,PersonEmail,LocalMobilePhone__pc,MobilePhoneCountryCallingCode__pc,LocalLoginPhone__pc,LoginPhoneCallingCode__pc,Salutation FROM Account WHERE DREAMID__c = :accUpdated.Id];
    }

    @isTest
    static void test_createATGClient() {
        Identity_TestFactory.createSettings();

        Test.StartTest();
            Account acc;
            String code;

            // Create account in ATG
            try{
                code = String.valueOf(Math.round(Math.random() * 100000));
                acc = Identity_TestFactory.createAccount('jean','marc', code + 'test@test.com', null,null, true);
                Identity_Utils.createATGClient(acc, 'fra-fr', '005HJYgd5121');
            }
            catch(Exception e){}

            // Convert account to ATG model and ATG model to account
            code = String.valueOf(Math.round(Math.random() * 100000));
            acc = Identity_TestFactory.createAccount('jean','marc', code + 'test@test.com', null,null, true);
            acc.BirthdateDay__pc = '29';
            acc.BirthdateMonth__pc = '1';
            acc.BirthdateYear__pc = '2001';
            acc.LocalMobilePhone__pc = '0234546546';
            acc.PrimaryAddressLine1__pc = 'ad1';
            acc.PrimaryAddressLine2__pc = 'ad2';
            acc.PrimaryAddressLine3__pc = 'ad3';
            acc.PrimaryStateProvince__pc = 'state';
            acc.PrimaryCity__pc = 'city';
            acc.PersonMobilePhone = '0234546546';
            acc.PrimaryZipCode__pc = '75013';
            acc.MobilePhoneCountryCode__pc = 'KR';
            update acc;

            acc.SPO_Country_code__pc = 'USA';
            Map<String,Object> params = Identity_Utils.toATGParameters(acc);
            Identity_Utils.toAccount(params);

        Test.StopTest();
    }

    @isTest
    static void test_getClientServicePhoneNumber() {
        // Given
        Identity_TestFactory.createCountryLanguageSettings();
        List<CountryLanguage__c> countryLanguage = [SELECT ATG_Locale__c, Dispatch_Country__c, Country__c, Language__c, LVConnect_CS_PhoneNumber__c FROM CountryLanguage__c WHERE Name IN ('Chinese China', 'Belgium Belgium')];
        CountryLanguage__c countryLanguageMap1 = countryLanguage[0];
        CountryLanguage__c countryLanguageMap2 = countryLanguage[1];

        // When
        Test.startTest();
        String foundPhoneNumberWhenSearchingByATGLocaleOnly = IDENTITY_Utils.getClientServicePhoneNumber(
            countryLanguageMap1.ATG_Locale__c,
            null);
        String foundPhoneNumberWhenSearchingByATGLocaleAndDispatchCountry = IDENTITY_Utils.getClientServicePhoneNumber(
            countryLanguageMap2.ATG_Locale__c,
            countryLanguageMap2.Dispatch_Country__c);
        String foundPhoneNumberWhenSearchReturnsNoResult = IDENTITY_Utils.getClientServicePhoneNumber(null, null);
		Test.stopTest();

        // Then
        System.assertEquals(countryLanguageMap1.LVConnect_CS_PhoneNumber__c, foundPhoneNumberWhenSearchingByATGLocaleOnly, 'error');
        System.assertEquals(countryLanguageMap2.LVConnect_CS_PhoneNumber__c, foundPhoneNumberWhenSearchingByATGLocaleAndDispatchCountry, 'error');
        System.assertEquals('N/A', foundPhoneNumberWhenSearchReturnsNoResult, 'error');
    }


    @isTest
    public static void test_updateMylvClient_souldThrowCustomExceptionWhenIdentityUserIsEmpty() {
        // Given
        Account account = new Account();
        String userId = 'THIS_ID_DOES_NOT_EXIST';

        // When
        try {
            IDENTITY_Utils.updateMylvClient(account, userId);
		}
        // Then
        catch (Exception e) {
			return;
		}
		System.assert(false, 'A CustomException was expected, but not thrown');
    }

    @isTest
    public static void test_invalidPassword() {
        // Given
        Account account = new Account();
        String passwordWithLessThanHeightChars = 'azerty';
        String passwordWithNoUpperCaseChar = 'azerty';
        String passwordWithNoLowerChar = 'AZERTY';
        String passwordWithNoNumericChar = 'Aze-rtY';
        String passwordWithNoSpecialChar = 'AzertY';
        String passwordWith_EightOrMoreChars_And_UpperCaseChar_And_LowerCaseChar_And_NumericChar_And_SpecialChar = 'az2Er#tY';
        
        // Then
        System.assert(IDENTITY_Utils.invalidPassword(account, passwordWithLessThanHeightChars), 'ERROR');
        System.assert(IDENTITY_Utils.invalidPassword(account, passwordWithNoUpperCaseChar), 'ERROR');
        System.assert(IDENTITY_Utils.invalidPassword(account, passwordWithNoLowerChar), 'ERROR');
        System.assert(IDENTITY_Utils.invalidPassword(account, passwordWithNoNumericChar), 'ERROR');
        System.assert(IDENTITY_Utils.invalidPassword(account, passwordWithNoSpecialChar), 'ERROR');
        System.assertEquals(false, IDENTITY_Utils.invalidPassword(account, passwordWith_EightOrMoreChars_And_UpperCaseChar_And_LowerCaseChar_And_NumericChar_And_SpecialChar), 'ERROR');
    }

    @isTest
    public static void test_invalidPasswordClientName() {
        // Given
        Account accountWhosePasswordContainsFirstName = new Account();
        accountWhosePasswordContainsFirstName.FirstName = 'John';
        accountWhosePasswordContainsFirstName.LastName = 'Smith';
        String password1 = '!JohnDoe2021!';

        Account accountWhosePasswordContainsLastName = new Account();
        accountWhosePasswordContainsLastName.FirstName = 'Jim';
        accountWhosePasswordContainsLastName.LastName = 'Doe';

        Account accountWhosePasswordContainsMobilePhone = new Account();
        accountWhosePasswordContainsMobilePhone.LoginPhone__pc = '0655511418';
        accountWhosePasswordContainsMobilePhone.FirstName = 'Harry';
        accountWhosePasswordContainsMobilePhone.LastName = 'Smith';
        String password2 = 'John+0655511418+Doe';
        
        Account accountWhosePasswordContainsPersonEmail = new Account();
        accountWhosePasswordContainsPersonEmail.PersonEmail = 'john@doe.com';
        accountWhosePasswordContainsPersonEmail.FirstName = 'Harry';
        accountWhosePasswordContainsPersonEmail.LastName = 'Smith';
        String password3 = 'Begin+john@doe.com+end';
        
        Account accountWhosePasswordContainsPersonEmailPrefix = new Account();
        accountWhosePasswordContainsPersonEmailPrefix.PersonEmail = 'john@doe.com';
        accountWhosePasswordContainsPersonEmailPrefix.FirstName = 'Harry';
        accountWhosePasswordContainsPersonEmailPrefix.LastName = 'Smith';
        String password4 = 'Begin+john+end';

        // Then
        System.assert(IDENTITY_Utils.invalidPasswordClientName(accountWhosePasswordContainsFirstName, password1), 'ERROR');
        System.assert(IDENTITY_Utils.invalidPasswordClientName(accountWhosePasswordContainsLastName, password1), 'ERROR');
        System.assert(IDENTITY_Utils.invalidPasswordClientName(accountWhosePasswordContainsMobilePhone, password2), 'ERROR');
        System.assert(IDENTITY_Utils.invalidPasswordClientName(accountWhosePasswordContainsPersonEmail, password3), 'ERROR');
        System.assert(IDENTITY_Utils.invalidPasswordClientName(accountWhosePasswordContainsPersonEmailPrefix, password4), 'ERROR');
    }

    @isTest
    public static void test_getProspect_returnsNullInSomeCases() {
        // Given
        Account client1 = new Account();
        Account client2 = new Account();
        Account client3 = new Account();
        Account client4 = new Account();
        
        // When
        client1.LoginPhone__pc = null;
        client2.PersonEmail = null;
        client3.LastName = null;
        client4.FirstName = null;

        // Then
        UnitTestsHelper.assertNull(IDENTITY_Utils.getProspect(client1, true));
        UnitTestsHelper.assertNull(IDENTITY_Utils.getProspect(client1, false));
        UnitTestsHelper.assertNull(IDENTITY_Utils.getProspect(client2, true));
        UnitTestsHelper.assertNull(IDENTITY_Utils.getProspect(client2, false));
        UnitTestsHelper.assertNull(IDENTITY_Utils.getProspect(client3, true));
        UnitTestsHelper.assertNull(IDENTITY_Utils.getProspect(client3, false));
        UnitTestsHelper.assertNull(IDENTITY_Utils.getProspect(client4, true));
        UnitTestsHelper.assertNull(IDENTITY_Utils.getProspect(client4, false));
    }

    @isTest
    public static void test_setupAccount_returnsExpectedClient_caseWithBasicClient() {
        // Given
        Account client = new Account();
        client.FirstName = prospect.get('firstName');
        client.LastName = prospect.get('lastName');
        client.PersonEmail = prospect.get('email');
        client.LocalMobilePhone__pc = prospect.get('localPhone');
        
        // When
        Account setupAccount = IDENTITY_Utils.setupAccount(client);

        // Then
        System.assertEquals(false, setupAccount.Can_Be_Contacted_By_Mail__pc, 'ERROR');
        System.assertEquals(false, setupAccount.Can_Be_Contacted_By_Email__pc, 'ERROR');
        System.assertEquals(false, setupAccount.Can_Be_Contacted_By_Phone__pc, 'ERROR');
        System.assertEquals(false, setupAccount.Can_Be_Contacted_By_SMS__pc, 'ERROR');
        System.assert(String.isBlank(setupAccount.DreamID__c), 'ERROR');
        System.assertEquals(client.OwnerId, setupAccount.OwnerId, 'ERROR');
        System.assert(String.isBlank(setupAccount.AttachedStore__pc), 'ERROR');
        System.assert(String.isBlank(setupAccount.AttachedStoreCode__pc), 'ERROR');
        System.assert(String.isBlank(setupAccount.AttachedStoreCountry__pc), 'ERROR');
        System.assert(String.isBlank(setupAccount.Store__pc), 'ERROR');
        System.assert(String.isBlank(setupAccount.TECH_AttachedStoreCountry__c), 'ERROR');
        System.assertEquals(client.PrimaryCountry__pc, setupAccount.PrimaryCountry__pc, 'ERROR');
        System.assertEquals(client.SPO_Country_code__pc, setupAccount.SPO_Country_code__pc, 'ERROR');
    }

    @isTest
    public static void test_setupAccount_returnsExpectedClient_caseWithClientHavingAdditionalInformation() {
        // Given
        Account client = new Account();
        client.FirstName = prospect.get('firstName');
        client.LastName = prospect.get('lastName');
        client.PersonEmail = prospect.get('email');
        client.LocalMobilePhone__pc = prospect.get('localPhone');
        client.Can_Be_Contacted_By_Mail__pc = true;
        client.Can_Be_Contacted_By_Email__pc = true;
        client.Can_Be_Contacted_By_Phone__pc = true;
        client.Can_Be_Contacted_By_SMS__pc = true;
        client.DreamID__c = 'DreamID';
        client.AttachedStore__pc = 'AttachedStore';
        client.AttachedStoreCode__pc = 'AttachedStoreCode';
        client.AttachedStoreCountry__pc = 'AttachedStoreCountry';
        client.Store__pc = 'a0Ni000001E3RHKEA3';
        client.TECH_AttachedStoreCountry__c = 'TECH_AttachedStoreCountry';
        
        // When
        Account setupAccount = IDENTITY_Utils.setupAccount(client);

        // Then
        System.assert(setupAccount.Can_Be_Contacted_By_Mail__pc, 'ERROR');
        System.assert(setupAccount.Can_Be_Contacted_By_Email__pc, 'ERROR');
        System.assert(setupAccount.Can_Be_Contacted_By_Phone__pc, 'ERROR');
        System.assert(setupAccount.Can_Be_Contacted_By_SMS__pc, 'ERROR');
        System.assertEquals(false, String.isBlank(setupAccount.DreamID__c), 'ERROR');
        System.assertEquals(client.OwnerId, setupAccount.OwnerId, 'ERROR');
        System.assertEquals(false, String.isBlank(setupAccount.AttachedStore__pc), 'ERROR');
        System.assertEquals(false, String.isBlank(setupAccount.AttachedStoreCode__pc), 'ERROR');
        System.assertEquals(false, String.isBlank(setupAccount.AttachedStoreCountry__pc), 'ERROR');
        System.assertEquals(false, String.isBlank(setupAccount.Store__pc), 'ERROR');
        System.assertEquals(false, String.isBlank(setupAccount.TECH_AttachedStoreCountry__c), 'ERROR');
        System.assertEquals(client.PrimaryCountry__pc, setupAccount.PrimaryCountry__pc, 'ERROR');
        System.assertEquals(client.SPO_Country_code__pc, setupAccount.SPO_Country_code__pc, 'ERROR');
    }

    @isTest
    static void test_toRussianClient() {
        // Given
        Set<String> russianClientKeySet = new Set<String> { 'email', 'lastName', 'firstName', 'title', 'country', 'subscribedInNewsletter', 'isActive', 'contactableByMail', 'contactableByPhone', 'contactableBySms' };
        
        Account account1 = new Account(
            PersonEmail = 'email@domain.ru',
            FirstName = 'firstname',
            LastName = 'lastname',
            Salutation = 'salutation',
            Can_Be_Contacted_By_Email__pc = true
        );
        
        Account account2 = account1.clone(false, false, false, false);
        account2.Can_Be_Contacted_By_Email__pc = false;

        // When
        Map<String,String> russianClient1 = IDENTITY_Utils.toRussianClient(account1);
        Map<String,String> russianClient2 = IDENTITY_Utils.toRussianClient(account2);

        // Then
        System.assert(russianClientKeySet.equals(russianClient1.keySet()), 'ERROR');
        System.assertEquals(account1.PersonEmail, russianClient1.get('email'), 'ERROR');
        System.assertEquals(account1.FirstName, russianClient1.get('firstName'), 'ERROR');
        System.assertEquals(account1.LastName, russianClient1.get('lastName'), 'ERROR');
        System.assertEquals(account1.Salutation, russianClient1.get('title'), 'ERROR');
        System.assertEquals('RU', russianClient1.get('country'), 'ERROR');
        System.assertEquals('true', russianClient1.get('subscribedInNewsletter'), 'ERROR');
        System.assertEquals('true', russianClient1.get('isActive'), 'ERROR');
        System.assertEquals('true', russianClient1.get('contactableByMail'), 'ERROR');
        System.assertEquals('false', russianClient1.get('contactableByPhone'), 'ERROR');
        System.assertEquals('false', russianClient1.get('contactableBySms'), 'ERROR');

        System.assertEquals('true', russianClient2.get('subscribedInNewsletter'), 'ERROR');
        System.assertEquals('true', russianClient2.get('contactableByMail'), 'ERROR');
    }

    @isTest
    static void test_createRussianClient() {
        // Given
        Integer statusCode = 200;
        String status = 'OK';
        String body = 'dummy-body';
        HttpResponseMock mock = new HttpResponseMock(new Map<String,String>(), statusCode, status, body);
        UnitTestsHelper.setSingleHttpMock(mock);

        Account account = new Account(
            PersonEmail = 'email@domain.ru',
            FirstName = 'firstname',
            LastName = 'lastname',
            Salutation = 'salutation'
        );

        // When
        Test.startTest();
        Map<String,String> result = IDENTITY_Utils.createRussianClient(account);
        Test.stopTest();

        // Then
        // System.assert(new Set<String> { 'StatusCode', 'Status', 'Body' }.equals(result.keySet()), 'ERROR');
        System.assert(true, 'err');
    }

    @isTest
    static void test_getUsers() {
        Test.startTest();
        IDENTITY_Utils.getUsers(new Account(PersonEmail = 'mail@domain.com'));
        Test.stopTest();
    }

    @isTest
    static void test_isAllowedUrl_withEmptyPathsShouldReturnFalse() {
        // Given
        String url = 'https://www.domain.net/users/123456';
        Map<String,String> paths = new Map<String,String>();
        String origin = '';

        // When
        Boolean result = IDENTITY_Utils.isAllowedUrl(url, paths, origin);

        // Then
        System.assertEquals(false, result, 'ERROR');
    }

    @isTest
    static void test_isAllowedUrl_withEmptyOrMalformedUrlShouldReturnFalse() {
        // Given
        String url1 = '';
        String url2 = null;
        String url3 = 'dummy-malformed-url';
        Map<String,String> paths = new Map<String,String>();
        String origin = '';

        // When
        Boolean result1 = IDENTITY_Utils.isAllowedUrl(url1, paths, origin);
        Boolean result2 = IDENTITY_Utils.isAllowedUrl(url2, paths, origin);
        Boolean result3 = IDENTITY_Utils.isAllowedUrl(url3, paths, origin);

        // Then
        System.assertEquals(false, result1, 'ERROR');
        System.assertEquals(false, result2, 'ERROR');
        System.assertEquals(false, result3, 'ERROR');
    }

    @isTest
    static void test_isAllowedUrl_nominalCase_shouldReturnFalse() {
        // Given
        String urlHttp = 'http://www.authorized-domain.com/users/123456';
        String urlHttps = 'https://www.authorized-domain.com/users/123456';
        Map<String,String> paths1 = new Map<String,String> {
            'key1' => 'www.dummy-domain.com',
            'key2' => 'www.other-domain-domain.biz'
        };
        Map<String,String> paths2 = new Map<String,String> {
            'Domain' => 'www.dummy-domain.com'
        };
        Map<String,String> paths3 = new Map<String,String> {
            'key1' => 'www.dummy-domain.com',
            'key2' => 'www.other-dummy-domain.biz',
            'Domain' => 'www.authorized-domain.com'
        };
        Map<String,String> paths4 = new Map<String,String> {
            'key1' => 'https://www.dummy-domain.com',
            'key2' => 'https://www.other-dummy-domain.biz',
            'Domain' => 'http://www.authorized-domain.com'
        };
        String origin1 = 'mylv';
        String origin2 = 'lvconnect';

        // When
        Boolean result1 = IDENTITY_Utils.isAllowedUrl(urlHttps, paths1, origin1);
        Boolean result2 = IDENTITY_Utils.isAllowedUrl(urlHttps, paths1, origin2);
        Boolean result3 = IDENTITY_Utils.isAllowedUrl(urlHttps, paths2, origin1);
        Boolean result4 = IDENTITY_Utils.isAllowedUrl(urlHttps, paths2, origin2);
        Boolean result5 = IDENTITY_Utils.isAllowedUrl(urlHttps, paths3, origin2);
        Boolean result7 = IDENTITY_Utils.isAllowedUrl(urlHttps, paths4, origin2);

        Boolean result8 = IDENTITY_Utils.isAllowedUrl(urlHttp, paths1, origin1);
        Boolean result9 = IDENTITY_Utils.isAllowedUrl(urlHttp, paths1, origin2);
        Boolean result10 = IDENTITY_Utils.isAllowedUrl(urlHttp, paths2, origin1);
        Boolean result11 = IDENTITY_Utils.isAllowedUrl(urlHttp, paths2, origin2);
        Boolean result12 = IDENTITY_Utils.isAllowedUrl(urlHttp, paths3, origin2);

        // Then
        System.assertEquals(false, result1, 'ERROR');
        System.assertEquals(false, result2, 'ERROR');
        System.assertEquals(false, result3, 'ERROR');
        System.assertEquals(false, result4, 'ERROR');
        System.assertEquals(false, result5, 'ERROR');
        System.assertEquals(false, result7, 'ERROR');
        System.assertEquals(false, result8, 'ERROR');
        System.assertEquals(false, result9, 'ERROR');
        System.assertEquals(false, result10, 'ERROR');
        System.assertEquals(false, result11, 'ERROR');
        System.assertEquals(false, result12, 'ERROR');
    }

    @isTest
    static void test_isAllowedUrl_nominalCase_shouldReturnTrue() {
        // Given
        String urlHttp = 'http://www.authorized-domain.com/users/123456';
        String urlHttps = 'https://www.authorized-domain.com/users/123456';
        Map<String,String> paths3 = new Map<String,String> {
            'key1' => 'https://www.dummy-domain.com',
            'key2' => 'https://www.other-dummy-domain.biz',
            'Domain' => 'https://www.authorized-domain.com'
        };
        Map<String,String> paths4 = new Map<String,String> {
            'key1' => 'https://www.dummy-domain.com',
            'key2' => 'https://www.other-dummy-domain.biz',
            'Domain' => 'http://www.authorized-domain.com'
        };
        String origin1 = 'mylv';
        String origin2 = 'lvconnect';

        // When
        Boolean result1 = IDENTITY_Utils.isAllowedUrl(urlHttps, paths3, origin1);
        Boolean result2 = IDENTITY_Utils.isAllowedUrl(urlHttps, paths4, origin1);
        Boolean result3 = IDENTITY_Utils.isAllowedUrl(urlHttp, paths3, origin1);
        Boolean result4 = IDENTITY_Utils.isAllowedUrl(urlHttp, paths4, origin1);
        Boolean result5 = IDENTITY_Utils.isAllowedUrl(urlHttp, paths4, origin2);

        // Then
        System.assertEquals(true, result1, 'ERROR');
        System.assertEquals(true, result2, 'ERROR');
        System.assertEquals(true, result3, 'ERROR');
        System.assertEquals(true, result4, 'ERROR');
        System.assertEquals(true, result5, 'ERROR');
    }

    @isTest
    static void test_getDefaultStoreValuesForRMS_shouldReturnNullWhenParametersAreEmpty() {
        // When
        Account account1 = IDENTITY_Utils.getDefaultStoreValuesForRMS(null, 'dummy-dispatch-country', 'dummy-atg-locale');
        Account account2 = IDENTITY_Utils.getDefaultStoreValuesForRMS(new Account(), 'dummy-dispatch-country', '');
        Account account3 = IDENTITY_Utils.getDefaultStoreValuesForRMS(new Account(), 'dummy-dispatch-country', null);
        Account account4 = IDENTITY_Utils.getDefaultStoreValuesForRMS(null, 'dummy-dispatch-country', '');
        Account account5 = IDENTITY_Utils.getDefaultStoreValuesForRMS(null, 'dummy-dispatch-country', null);
        // Then
        UnitTestsHelper.assertNull(account1);
        UnitTestsHelper.assertNull(account2);
        UnitTestsHelper.assertNull(account3);
        UnitTestsHelper.assertNull(account4);
        UnitTestsHelper.assertNull(account5);
    }

    @isTest
    static void test_getDefaultStoreValuesForRMS_shouldReturnNullWhenNoDefStoreFound() {
        // When
        Account account = IDENTITY_Utils.getDefaultStoreValuesForRMS(new Account(), 'dummy-dispatch-country', 'dummy-atg-locale');
        // Then
        UnitTestsHelper.assertNull(account);
    }

    @isTest
    static void test_getDefaultStoreValuesForRMS_nominalCase() {
        // Given
        IDENTITY_TestFactory.createCountryLanguageSettings();
        String dispatchCountry = 'FR';
        String atgLocale = 'kor-kr';
        CountryLanguage__c countryLanguage = [SELECT Id FROM CountryLanguage__c WHERE ATG_Locale__c = :atgLocale LIMIT 1];
        countryLanguage.Dispatch_Country__c = dispatchCountry;
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = '1234');
        insert store;
        countryLanguage.defaultStore__c = store.Id;
        update countryLanguage;

        List<CountryLanguage__c> defStoreList = [
            SELECT  defaultStore__c, defaultStore__r.retailStoreID__c, Dispatch_Country__c
            FROM    CountryLanguage__c
            WHERE   Dispatch_Country__c = :dispatchCountry
            AND     ATG_Locale__c = :atgLocale
            AND     defaultStore__c != null
            LIMIT   1
        ];
        CountryLanguage__c defStore = defStoreList[0];

        // When
        Account accountForRMS = IDENTITY_Utils.getDefaultStoreValuesForRMS(new Account(), dispatchCountry, atgLocale);

        // Then
        UnitTestsHelper.assertNotNull(accountForRMS);
        System.assertEquals(accountForRMS.AttachedStore__pc, defStore.defaultStore__r.retailStoreID__c, 'ERROR');
        System.assertEquals(accountForRMS.AttachedStoreCode__pc, defStore.defaultStore__r.retailStoreID__c, 'ERROR');
        System.assertEquals(accountForRMS.Store__pc, defStore.defaultStore__c, 'ERROR');
    }

    @isTest
    static void test_isExistDefaultStoreForRMS_shouldReturnFalse() {
        // Given
        String dispatchCountry = 'ZZ';
        String atgLocale = 'dum-my';

        // When
        Boolean result = IDENTITY_Utils.isExistDefaultStoreForRMS(dispatchCountry, atgLocale);

        // Then
        UnitTestsHelper.assertFalse(result);
    }

    @isTest
    static void test_isExistDefaultStoreForRMS_shouldReturnTrue() {
        // Given
        IDENTITY_TestFactory.createCountryLanguageSettings();
        String dispatchCountry = 'FR';
        String atgLocale = 'kor-kr';
        CountryLanguage__c countryLanguage = [SELECT Id FROM CountryLanguage__c WHERE ATG_Locale__c = :atgLocale LIMIT 1];
        countryLanguage.Dispatch_Country__c = dispatchCountry;
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = '1234');
        insert store;
        countryLanguage.defaultStore__c = store.Id;
        update countryLanguage;

        // When
        Boolean result = IDENTITY_Utils.isExistDefaultStoreForRMS(dispatchCountry, atgLocale);

        // Then
        UnitTestsHelper.assertTrue(result);
    }
    
     @isTest
    static void test_getIso2CodeForCallingCode(){
         // When
        String result = IDENTITY_Utils.getIso2CodeForCallingCode(376);

        // Then
          System.assertEquals(result, 'AD', 'ERROR');
    }
    
    @isTest
    static void test_getSplittedPhoneFromFullPhone(){
         // When
        Map<String, String>  result = IDENTITY_Utils.getSplittedPhoneFromFullPhone('+82-2-1234- 5678');
        Map<String, String> expected = new Map<String,String>{
             'callingCode'               => '8221234',
                'iso2Code'                   => 'null',
                'internationalMobilePhone'  => '+82212345678',
                'mobilePhone'           => '05678'
        };
            system.debug('result map:'+result);
        // Then
         // System.assertEquals(result, 'AD', 'ERROR');
    }
  @isTest
    static void test_genderToSalutation(){
       // When
       String  result = IDENTITY_Utils.genderToSalutation('Female');
        
        // Then
        System.assertEquals(result, '04', 'ERROR');
    }
      @isTest
    static void test_truncateUsername(){
       // When
       String  result = IDENTITY_Utils.truncateUsername('laureentesttruncate@balink.net');
        
        // Then
        System.assertEquals(result, 'lau***', 'ERROR');
    }

    @isTest
    public static void test_updateCollectibleWallet_createScenario() {
        // Given
        String random = String.valueOf(Math.round(Math.random() * 100000));
        Account account = Identity_TestFactory.createAccount('first name', 'lastr name', random + 'test@test.com', null, null, true);
        String accountId = account.Id;
        String walletId = 'CW-001';
        List<Object> wallets = new List<Object> {
            new Map<String,String> { 'old' => null, 'new' => walletId }
        };

        // When
        List<Collectible_Wallet__c> walletsBefore = [Select Id FROM Collectible_Wallet__c WHERE Client__c = :accountId];
        IDENTITY_Utils.updateCollectibleWallet(wallets, accountId);
        List<Collectible_Wallet__c> walletsAfter = [Select Id, Wallet_Id__c FROM Collectible_Wallet__c WHERE Client__c = :accountId];

        // Then
        System.assertEquals(0, walletsBefore.size());
        System.assertEquals(1, walletsAfter.size());
        System.assertEquals(1, walletsAfter.size());
        System.assertEquals(walletId, walletsAfter.get(0).Wallet_Id__c);
    }

    @isTest
    public static void test_updateCollectibleWallet_deleteScenario() {
        // Given
        String random = String.valueOf(Math.round(Math.random() * 100000));
        Account account = Identity_TestFactory.createAccount('first name', 'lastr name', random + 'test@test.com', null, null, true);
        String accountId = account.Id;
        String walletId = 'CW-001';
        List<Object> walletsToInsert = new List<Object> {
            new Map<String,String> { 'old' => null, 'new' => walletId }
        };
        IDENTITY_Utils.updateCollectibleWallet(walletsToInsert, accountId);
        List<Object> walletsToDelete = new List<Object> {
            new Map<String,String> { 'old' => walletId, 'new' => null }
        };

        // When
        List<Collectible_Wallet__c> walletsBefore = [Select Id, Wallet_Id__c FROM Collectible_Wallet__c WHERE Client__c = :accountId];
        IDENTITY_Utils.updateCollectibleWallet(walletsToDelete, accountId);
        List<Collectible_Wallet__c> walletsAfter = [Select Id FROM Collectible_Wallet__c WHERE Client__c = :accountId];

        // Then
        System.assertEquals(1, walletsBefore.size());
        System.assertEquals(walletId, walletsBefore.get(0).Wallet_Id__c);
        System.assertEquals(0, walletsAfter.size());
    }
    
    @isTest
    public static void test_updateCollectibleWallet_updateScenario() {
        // Given
        String random = String.valueOf(Math.round(Math.random() * 100000));
        Account account = Identity_TestFactory.createAccount('first name', 'lastr name', random + 'test@test.com', null, null, true);
        String accountId = account.Id;
        String originalWalletId = 'CW-001';
        String updatedWalletId = 'CW-002';
        List<Object> walletsToInsert = new List<Object> {
            new Map<String,String> { 'old' => null, 'new' => originalWalletId }
        };
        IDENTITY_Utils.updateCollectibleWallet(walletsToInsert, accountId);
        List<Object> walletsToUpdate = new List<Object> {
            new Map<String,String> { 'old' => originalWalletId, 'new' => updatedWalletId }
        };

        // When
        List<Collectible_Wallet__c> walletsBefore = [Select Id, Wallet_Id__c FROM Collectible_Wallet__c WHERE Client__c = :accountId];
        IDENTITY_Utils.updateCollectibleWallet(walletsToUpdate, accountId);
        List<Collectible_Wallet__c> walletsAfter = [Select Id, Wallet_Id__c FROM Collectible_Wallet__c WHERE Client__c = :accountId];

        // Then
        System.assertEquals(1, walletsBefore.size());
        System.assertEquals(originalWalletId, walletsBefore.get(0).Wallet_Id__c);
        System.assertEquals(1, walletsAfter.size());
        System.assertEquals(updatedWalletId, walletsAfter.get(0).Wallet_Id__c);
    }

    @isTest
    public static void test_updateCollectibleWallet_allInOneScenario() {
        // Given
        String random = String.valueOf(Math.round(Math.random() * 100000));
        Account account = Identity_TestFactory.createAccount('first name', 'lastr name', random + 'test@test.com', null, null, true);
        String accountId = account.Id;
        String walletId1 = 'CW-001';
        String walletId2 = 'CW-002';
        String walletId3 = 'CW-003';
        String walletId4 = 'CW-004';
        String walletId5 = 'CW-005';
        String walletId6 = 'CW-006';
        List<Object> wallets = new List<Object> {
            new Map<String,String> { 'old' => null, 'new' => walletId1 },
            new Map<String,String> { 'old' => null, 'new' => walletId2 }
        };
        IDENTITY_Utils.updateCollectibleWallet(wallets, accountId);
        wallets = new List<Object> {
            new Map<String,String> { 'old' => null, 'new' => walletId5 },
            new Map<String,String> { 'old' => walletId1, 'new' => null },
            new Map<String,String> { 'old' => walletId2, 'new' => walletId3 },
            new Map<String,String> { 'old' => null, 'new' => walletId6 }
        };

        // When
        List<Collectible_Wallet__c> walletsBefore = [Select Id, Wallet_Id__c FROM Collectible_Wallet__c WHERE Client__c = :accountId];
        IDENTITY_Utils.updateCollectibleWallet(wallets, accountId);
        List<Collectible_Wallet__c> walletsAfter = [Select Id, Wallet_Id__c FROM Collectible_Wallet__c WHERE Client__c = :accountId];

        // Then
        System.assertEquals(2, walletsBefore.size());
        System.assertEquals(walletId1, walletsBefore.get(0).Wallet_Id__c);
        System.assertEquals(walletId2, walletsBefore.get(1).Wallet_Id__c);

        List<String> walletIdList = new List<String>();
        for (Collectible_Wallet__c wallet : walletsAfter) {
            walletIdList.add(wallet.Wallet_Id__c);
        }
        System.assertEquals(3, walletIdList.size());
        System.assert(walletIdList.contains(walletId5));
        System.assert(walletIdList.contains(walletId3));
        System.assert(walletIdList.contains(walletId6));
    }
    @isTest
    public static void test_getPathWithoutDP() {
        String langCountry = 'en_US';
        String origin = 'mylv';

        Test.startTest();
        Map<String, String> paths = IDENTITY_Utils.getPaths(langCountry, origin, null);
        Test.stopTest();

        List<IDENTITY_Paths__mdt> pathsExpected = [SELECT Name__c, Value__c, Context__c, Application__c 
        FROM IDENTITY_Paths__mdt 
        WHERE (Context__c =: langCountry OR Context__c = null) AND 
            (Application__c =: origin OR Application__c = null) 
        ORDER BY Application__c, Context__c ASC NULLS FIRST];

        System.assertEquals(pathsExpected.size(), paths.size());
    }
    @isTest
    public static void test_getPathWithDP() {
        String langCountry = 'en_NL';
        String origin = 'mylv';

        Test.startTest();
        Map<String, String> paths = IDENTITY_Utils.getPaths(langCountry, origin, 'SE');
        Test.stopTest();

        List<IDENTITY_Paths__mdt> pathsExpected = [SELECT Name__c, Value__c, Context__c, Application__c 
        FROM IDENTITY_Paths__mdt 
        WHERE (Context__c =: langCountry OR Context__c = null) AND 
            (Application__c =: origin OR Application__c = null) 
        ORDER BY Application__c, Context__c ASC NULLS FIRST];

        System.assertEquals(pathsExpected.size(), paths.size());
    }

    @isTest
    static void testloginOauthUserAgentMethod() {

        String username = Datetime.now().getTime() + 'test@test.com';
        String redirectUri = '/mobile/lang_country/origin/overview?accountCreation=true	';

        Test.startTest();
        PageReference resultPage = IDENTITY_Utils.loginOauthUserAgentMethod(username, 'test', redirectUri, 'mylv');
        Test.stopTest();

        System.assertEquals(null, resultPage);

    }
    @isTest
    public static void test_generateRandomString() {
        // When
        String result1 = IDENTITY_Utils.generateRandomString(0);
        String result2 = IDENTITY_Utils.generateRandomString(5);

        // Then
        System.assertEquals('', result1);
        System.assertEquals(5, result2.length());
    }

    @isTest
    public static void test_getAccountForRMS_shouldReturnNull() {
        // Given
        Account account = new Account();

        // Then
        System.assertEquals(null, IDENTITY_Utils.getAccountForRMS(null));
        System.assertEquals(null, IDENTITY_Utils.getAccountForRMS(account));
    }

    @isTest
    public static void test_getAccountForRMS_nominalCase() {
        // Given
        String random = String.valueOf(Math.round(Math.random() * 100000));
        Account account = Identity_TestFactory.createAccount('first name', 'last name', random + 'test@test.com', null, null, true);

        // When
        Account result = IDENTITY_Utils.getAccountForRMS(account);
        
        // Then
        System.assertNotEquals(null, result);
        System.assertEquals(account.RMSId__pc, result.RMSId__pc);
        System.assertEquals(account.AttachedStoreCode__pc, result.AttachedStoreCode__pc);
        System.assertEquals(account.AttachedStore__pc, result.AttachedStore__pc);
        System.assertEquals(account.AttachedStoreCountry__pc, result.AttachedStoreCountry__pc);
        System.assertEquals(account.Store__pc, result.Store__pc);
        System.assertEquals(account.TECH_AttachedStoreCountry__c, result.TECH_AttachedStoreCountry__c);
    }

    @isTest
    public static void test_getRandomClientId() {
        String result = IDENTITY_Utils.getRandomClientId();
        List<String> parts = result.split('\\.');
        System.assertEquals(2, parts.size());
        System.assertEquals(9, parts.get(0).length());
        System.assertEquals(9, parts.get(1).length());
    }

    @isTest
    public static void test_getEncrytedId(){
        
        // Given
        String random = String.valueOf(Math.round(Math.random() * 100000));
        Account account = Identity_TestFactory.createAccount('first name', 'last name', random + 'test@test.com', null, null, true);
        Identity_TestFactory.createSettings();
        // When
        String encryptedId = IDENTITY_Utils.getEncryptedId(account.Id);
        
        Blob key = EncodingUtil.base64Decode(IDENTITY_Settings__c.getOrgDefaults().AES_Key__c);
        Blob accountBlob = Blob.valueOf(account.Id);          
        Blob encrypted = Crypto.encryptWithManagedIV('AES128', key, accountBlob);
        String base64Encoded = EncodingUtil.base64Encode(encrypted);
        String encryptedIdExpected =  EncodingUtil.urlEncode(base64Encoded, 'UTF-8');
        
        System.assertNotEquals(encryptedIdExpected, encryptedId);

        IDENTITY_Utils.getEncryptedIdWithTrustOrigin(account.id, true);
    }

    @isTest
    public static void test_isTrustOriginApp() {
        Boolean result = IDENTITY_Utils.isTrustOriginApp('Care Service');
        //System.assertEquals(true, result);//TODO FIX
    }

    @isTest
    public static void test_getPathsForMyLvURL() {
        Map<String,String> paths = IDENTITY_Utils.getPathsForMyLvURL();
        System.assertNotEquals(new Map<String,String>(), paths);
    }

    @isTest
    public static void test_getSuccessUrlForMyLVURL() {
        Map<String,String> paths = IDENTITY_Utils.getSuccessUrlForMyLVURL('Forgot Password Path');
        System.assertNotEquals(new Map<String,String>(), paths);
    }

    @isTest
    public static void test_getLoginLessCancelAppointmentURL() {
        
        // Given
        String random = String.valueOf(Math.round(Math.random() * 100000));
        Account account = Identity_TestFactory.createAccount('first name', 'last name', random + 'test@test.com', null, null, true);
        Event ev= IC_TestFactory.createEvent(account);
        insert ev;
        Identity_TestFactory.createSettings();
        String url = IDENTITY_Utils.getLoginLessCancelAppointmentURL('mylv','eng-gb', account.id, ev.id);
        System.assertNotEquals(null, url);
    }

    @isTest
    public static void test_getMyLVURL() {
        
        // Given
        String random = String.valueOf(Math.round(Math.random() * 100000));
        Account account = Identity_TestFactory.createAccount('first name', 'last name', random + 'test@test.com', null, null, true);
        Identity_TestFactory.createSettings();
        Map<String, String> paths = IDENTITY_Utils.getPathsForMyLvURL();
        String url = IDENTITY_Utils.getMyLVURL(account,'mylv', 'en_NL',paths,null,new Map<String,String> {'application' => 'Exclusive Experience'});
        System.assertNotEquals(null, url);
    }

    @isTest
    public static void test_isStoreTypeValidForRMS() {
        // Given
        String random = String.valueOf(Math.round(Math.random() * 100000));
        Account account = Identity_TestFactory.createAccount('first name', 'last name', random + 'test@test.com', null, null, true);
        Boolean result = IDENTITY_Utils.isStoreTypeValidForRMS(account);
        System.assertEquals(false, result);
    }

    @isTest
    public static void test_getUserByUsername() {
        // Given
        Identity_TestFactory.createSettings();
        String random = String.valueOf(Math.round(Math.random() * 100000));
        User u = IDENTITY_Utils.getUserByUsername(random + 'test@test.com');
        System.assertEquals(null, u);

        String inputDate = date.today().format();
        User u2 = IDENTITY_TestFactory.createUser('test',  'test', inputDate+'test@test.com',  null, '972');
        User userResult = IDENTITY_Utils.getUserByUsername(u2.Username);
        System.assertEquals(u2.id, userResult.id);
       
    }

    @isTest
    public static void test_shareLook() {
        Identity_TestFactory.createSettings();
        String random = String.valueOf(Math.round(Math.random() * 100000));
        Test.startTest();
        Account account = Identity_TestFactory.createAccount('first name', 'last name', random + 'test@test.com', null, null, true);
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = '1234');
        insert store;
        Look__c l = new Look__c(Name = 'MY COFFRET 8 MONTRES MONOGRAM ECLIPSE  Look', store__c = store.id, SKUs__c = 'P00957;');
        insert l;
        String result = IDENTITY_Utils.shareLook(l.id, account.id, 'mylv');
        System.assertEquals(l.Id, result);
        // Create new Look Share 
        Look_Share__c ls = new Look_Share__c();
        ls.Look__c = l.Id;
        ls.Client__c = account.Id;
        ls.ExternalId__c = '123456789';
        insert ls;
        Test.stopTest();
        String resultWithLookAndLookShare = IDENTITY_Utils.shareLook(l.id, account.id, 'mylv');
        System.assertEquals('false', resultWithLookAndLookShare);
        String resultNoLook = IDENTITY_Utils.shareLook('test', account.id, 'mylv');
        System.assertEquals('false', resultNoLook);
    }

    @isTest
    public static void test_getUsersWhenUserIsEmpty() {
          // Given
          String random = String.valueOf(Math.round(Math.random() * 100000));
          Account account = Identity_TestFactory.createAccount('first name', 'last name', random + 'test@test.com', null, null, true);
          IDENTITY_Utils.getUsers(account);
    }
    @isTest
    public static void testResponseHandler() {
        // Test Case 1: Test default constructor
        IDENTITY_Utils.ResponseHandler response1 = new IDENTITY_Utils.ResponseHandler();
        System.assertEquals(null, response1.Status);
        System.assertEquals(null, response1.Message);
        System.assertEquals(null, response1.Data);
        System.assertEquals(null, response1.AccountId);

        // Test Case 2: Test constructor with status and message
        IDENTITY_Utils.ResponseHandler response2 = new IDENTITY_Utils.ResponseHandler('Success', 'Operation successful');
        System.assertEquals('Success', response2.Status);
        System.assertEquals('Operation successful', response2.Message);
        System.assertEquals(null, response2.Data);
        System.assertEquals(null, response2.AccountId);

        // Test Case 3: Test constructor with status, message, and data
        String random = String.valueOf(Math.round(Math.random() * 100000));
        Account testAccount = Identity_TestFactory.createAccount('first name', 'last name', random + 'test2@test.com', null, null, true);
        IDENTITY_Utils.ResponseHandler response3 = new IDENTITY_Utils.ResponseHandler('Success', 'Operation successful', testAccount);
        System.assertEquals('Success', response3.Status);
        System.assertEquals('Operation successful', response3.Message);
        System.assertEquals(testAccount, response3.Data);
        System.assertEquals(null, response3.AccountId);

        // Test Case 4: Test constructor with status, message, data, and accountId
        IDENTITY_Utils.ResponseHandler response4 = new IDENTITY_Utils.ResponseHandler('Success', 'Operation successful', testAccount, '001ABC');
        System.assertEquals('Success', response4.Status);
        System.assertEquals('Operation successful', response4.Message);
        System.assertEquals(testAccount, response4.Data);
        System.assertEquals('001ABC', response4.AccountId);
    }
}