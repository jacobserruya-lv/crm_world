@isTest
public class TWIST_Registration_TEST {

    @testSetup
    static void initData(){
        insert new IDENTITY_Settings__c(
            Name = 'identity',
            Password_Maxlength__c = 20,
            Default_Language_Country_Parameter__c = 'eng-e1',
            Default_Origin_Parameter__c = 'mylv',
            AES_Key__c = 'TESTTWIST20232024'
        );

        insert new TWIST_Settings__c(
            Password_Maxlength__c = 20,
            Env_In_Reset_Password_Url__c = 'ppf',
            Footer_Links_Base_Url__c = 'https://{0}-ppf.louisvuitton.com',
            Name = 'identity',
            Default_Language_Country_Parameter__c = 'eng-e1'
        );

        TWIST_Registration_Form_Settings__c  registrationSetting = new TWIST_Registration_Form_Settings__c();
        registrationSetting.Tealium_Environment__c = 'prod';
        registrationSetting.Code_Validity_Time__c = 10;
        registrationSetting.Sent_Email_Limit__c = 1;
        registrationSetting.Sent_SMS_Limit__c = 1;
        insert registrationSetting;

        Identity_TestFactory.createCountryLanguageSettings();
    }

    @isTest
    static void test_initComponentConfig() {
        Map<String,Object> queryParams = new Map<String,Object> {
            TWIST_QueryParamKey_CONST.ORIGIN => 'mylv',
            TWIST_QueryParamKey_CONST.LANG_COUNTRY => 'fra-fr',
            TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY => '',
            TWIST_QueryParamKey_CONST.LOOK_ID => '1234'
        };

        Set<String> expectedConfigAttributes = new Set<String> {
            'isTrustOrigin',
            'passwordMaxlength',
            'defaultOriginParameter',
            'defaultLangCountryParameter',
            'AllowPlusSymbolInEmail',
            'tealiumEnv',
            'CodeValidityTime',
            'SentEmailLimit',
            'SentSMSLimit',
            'modeInfo',
            'mode',
            'langCountry',
            'countryLocal',
            'metaLanguage',
            'language',
            'origin',
            'clientServicePhoneNumber',
            'form',
            'client_country',
            'countryList',
            'showCountryList',
            'loginBaseUrl',
            'showKanaFields',
            'calendarDateFormat',
            'titleList',
            'socialMediaProviders',
            'forgotPasswordUrl',
            'legalAge',
            'googleSocialLoginEnabled',
            'lineSocialLoginEnabled',
            'birthdayHelpText'
        };

        // When
        Map<String,Object> config = TWIST_Registration.initComponentConfig(queryParams);

        // Then
        System.assertEquals(expectedConfigAttributes, config.keySet(), 'msg');
    }

    @isTest
    static void test_initComponentConfig_ActivationMode() {
        Account account = Identity_TestFactory.createAccount('test', 'test', 'test@test.com', '123456789', '972', true);
        Map<String,Object> queryParams = new Map<String,Object>{
            TWIST_QueryParamKey_CONST.ORIGIN => 'checkout',
            TWIST_QueryParamKey_CONST.LANG_COUNTRY => 'fra-fr',
            TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY => '',
            TWIST_QueryParamKey_CONST.LOOK_ID => '1234',
            TWIST_QueryParamKey_CONST.ACCOUNT => account.id
        };

        Set<String> expectedConfigAttributes = new Set<String> {
            'isTrustOrigin',
            'passwordMaxlength',
            'defaultOriginParameter',
            'defaultLangCountryParameter',
            'AllowPlusSymbolInEmail',
            'tealiumEnv',
            'CodeValidityTime',
            'SentEmailLimit',
            'SentSMSLimit',
            'modeInfo',
            'mode',
            'langCountry',
            'countryLocal',
            'metaLanguage',
            'language',
            'origin',
            'clientServicePhoneNumber',
            'form',
            'client_country',
            'countryList',
            'showCountryList',
            'titleList',
            'showKanaFields',
            'calendarDateFormat',
            'loginBaseUrl',
            'socialMediaProviders',
            'forgotPasswordUrl',
            'legalAge',
            'googleSocialLoginEnabled',
            'lineSocialLoginEnabled',
            'birthdayHelpText'

        };

        // When
        Map<String,Object> config = TWIST_Registration.initComponentConfig(queryParams);

        // Then
        System.assertEquals(expectedConfigAttributes, config.keySet(), 'msg');
    }

    @isTest
    static void test_initComponentConfig_ActivationModeDispatchCountry() {
        IDENTITY_TestFactory.createCountryLanguageMiddleEastSettings();
        Account account = Identity_TestFactory.createAccount('test', 'test', 'test@test.com', '123456789', '972', true);
        Map<String,Object> queryParams = new Map<String,Object>{
            TWIST_QueryParamKey_CONST.ORIGIN => 'checkout',
            TWIST_QueryParamKey_CONST.LANG_COUNTRY => 'ara-ae',
            TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY => 'SA',
            TWIST_QueryParamKey_CONST.LOOK_ID => '1234',
            TWIST_QueryParamKey_CONST.ACCOUNT => account.id
        };

        Set<String> expectedConfigAttributes = new Set<String> {
            'isTrustOrigin',
            'passwordMaxlength',
            'defaultOriginParameter',
            'defaultLangCountryParameter',
            'AllowPlusSymbolInEmail',
            'tealiumEnv',
            'CodeValidityTime',
            'SentEmailLimit',
            'SentSMSLimit',
            'modeInfo',
            'mode',
            'langCountry',
            'countryLocal',
            'metaLanguage',
            'language',
            'origin',
            'clientServicePhoneNumber',
            'form',
            'client_country',
            'countryList',
            'showCountryList',
            'titleList',
            'showKanaFields',
            'calendarDateFormat',
            'loginBaseUrl',
            'socialMediaProviders',
            'forgotPasswordUrl',
            'legalAge',
            'googleSocialLoginEnabled',
            'lineSocialLoginEnabled',
            'birthdayHelpText'
        };

        // When
        Map<String,Object> config = TWIST_Registration.initComponentConfig(queryParams);

        // Then
        System.assertEquals(expectedConfigAttributes, config.keySet(), 'msg');
    }

    //---------------------------------------------------

    @isTest
    static void test_getTermConditionLink() {
        // Given
        Test.startTest();
        String existingLangCountry = 'eng-us';
        String dummyLangCountry = 'zzz-zz';
        String expectedLinkWithDummyLangCountry = String.format('{0}/{1}/legal-privacy', new List<String> { TWIST_UrlUtils.getLvSiteBaseUrl(dummyLangCountry), dummyLangCountry });
        String expectedLinkWithExistingLangCountry = String.format('{0}/{1}/legal-notices', new List<String> { TWIST_UrlUtils.getLvSiteBaseUrl(existingLangCountry), existingLangCountry });

        // When
        String linkWithExistingLangCountry = TWIST_Registration.getTermConditionLink(existingLangCountry);
        String linkWithDummyLangCountry = TWIST_Registration.getTermConditionLink(dummyLangCountry);

        // Then
        System.assertEquals(expectedLinkWithExistingLangCountry, linkWithExistingLangCountry, 'ERROR');
        System.assertEquals(expectedLinkWithDummyLangCountry, linkWithDummyLangCountry, 'ERROR');
    }

    //---------------------------------------------------

    @isTest
    static void test_submitRegistrationForm_ok() {
        Map<String,Object> result = TWIST_Registration.submitRegistrationForm(new Map<String,String>(), new Map<String,Object>(), new Map<String,String>(), true);
        Map<String,Object> expected = TWIST_Utils.buildSuccessResponseObject();
        System.assertEquals(result, expected);
    }

    //---------------------------------------------------

    @isTest
    static void test_isValidCode_noCode() {
        Boolean result = TWIST_Registration.isValidCode('eng-us', '12345', 'test@test.test', new Map<String,Object>{}, new Map<String,String>{});
        System.assertEquals(result, false);
    }

    @isTest
    static void test_isValidCode_validCode() {
        Test.startTest();
        Registration_Code_Verification_Request__c code = createCodeRequest('12345', 'test@test.test');
        insert code;
        Test.stopTest();

        Boolean result = TWIST_Registration.isValidCode('eng-us', '12345', 'test@test.test', new Map<String,Object>{}, new Map<String,String>{});
        System.assertEquals(result, true);
    }

    //--------------------------------------------------------

    //is it normal to have OK when no email nor phone
    @isTest
    static void test_sendVerificationCode_noEmailNorPhone() {
        Map<String,Object> result = TWIST_Registration.sendVerificationCode(new Map<String,String>(), new Map<String,Object>());
        Map<String,Object> expected = TWIST_Utils.buildSuccessResponseObject();
        System.assertEquals(result, expected);
    }

    @isTest
    static void test_sendVerificationCode_sendEmail() {

        User user = getIdentityUser();
        Map<String,String> registForm = new Map<String,String>{
            'email' => user.Email,
            'mobile_phone' => '0500000000',
            'firstname' => user.firstName,
            'lastname' => user.lastName,
            'login_international_mobile_phone' => '0500000000'
        };
        Map<String,Object> queryParams = new Map<String,Object>{'langCountry' => 'eng-us'};

        Map<String,Object> result = TWIST_Registration.sendVerificationCode(registForm, queryParams);
        Map<String,Object> expected = TWIST_Utils.buildSuccessResponseObject();

        System.assertEquals(result, expected);
    }

    @isTest
    static void test_sendVerificationCode_emailLimit() {

        Test.startTest();
        Registration_Code_Verification_Request__c code = createCodeRequest('12345', 'test@test.test');
        insert code;
        Test.stopTest();

        Map<String,String> registForm = new Map<String,String>{'email' => 'test@test.test', 'mobile_phone' => '0500000000'};
        Map<String,Object> queryParams = new Map<String,Object>{'langCountry' => 'eng-us'};

        try {
            Map<String,Object> result = TWIST_Registration.sendVerificationCode(registForm, queryParams);
        } catch (Exception e) {
            String ex = TWIST_i18nTranslations.translateSingleLabel('TWIST_Registration_Verification_Code_Limit', 'eng_us');
            System.assertEquals(e.getMessage(), ex);
        }
    }

    @isTest
    static void test_sendVerificationCode_sendSms() {
        User user = getIdentityUser();
        Map<String,String> registForm = new Map<String,String>{
            'mobile_phone' => '0500000000',
            'firstName' => user.firstName,
            'lastName' => user.lastName,
            'login_international_mobile_phone' => '0500000000'
        };
        Map<String,Object> queryParams = new Map<String,Object>{'langCountry' => 'eng-us'};

        Map<String,Object> result = TWIST_Registration.sendVerificationCode(registForm, queryParams);
        Map<String,Object> expected = TWIST_Utils.buildSuccessResponseObject();

        System.assertEquals(result, expected);
    }

    @isTest
    static void test_sendVerificationCode_SmsLimit() {

        Test.startTest();
        Registration_Code_Verification_Request__c code = createCodeRequest('12346', '0500012345');
        insert code;
        Test.stopTest();

        Map<String,String> registForm = new Map<String,String>{'mobile_phone' => '0500012345'};
        Map<String,Object> queryParams = new Map<String,Object>{'langCountry' => 'eng-us'};

        try {
            Map<String,Object> result = TWIST_Registration.sendVerificationCode(registForm, queryParams);
        } catch (Exception e) {
            String ex = TWIST_i18nTranslations.translateSingleLabel('TWIST_Registration_Verification_Code_Limit', 'eng_us');
            System.assertEquals(e.getMessage(), ex);
        }
    }
    @isTest
    static void test_ModeActivation() {
        Account acc =  new Account(LastName = 'test', FirstName = 'test', PersonEmail = 'aaa@test.com');
        insert acc;
        String encryptedId = 'I92BzJyLOyjyiWYlMV0ZUTTQDlAinKyt3X4HDUvXl1UuTDQMa1I2BOckm4bxDt782BP';
        Test.startTest();
        Map<String,Object> encResult = TWIST_RegistrationUtils.extractAccountId(encryptedId);
        TWIST_RegistrationUtils.Mode modeResult =TWIST_RegistrationUtils.getRegistrationMode(acc.Id, new Map<String,String>{});
        Map<String ,TWIST_Default_Settings__mdt> defaultSet = TWIST_RegistrationUtils.getDefaultSettings('eng-us');
        Map<String, Object> convetAcc =  TWIST_RegistrationUtils.convertAccountToForm(acc,TWIST_RegistrationUtils.Mode.PARTIAL_ACTIVATION,'eng-us');
        Test.stopTest();
        System.AssertNotEquals(null,encResult);
        System.AssertNotEquals(null,modeResult);
        System.AssertNotEquals(null,defaultSet);
        System.AssertNotEquals(null,convetAcc);
    }


    // ------------------------------ private methods ------------------------------

    private static User getIdentityUser() {
        return [SELECT Id, Email, AccountId, lastName, firstName FROM User WHERE Is_Identity_User__c = true AND AccountId != null LIMIT 1];
    }

    private static Registration_Code_Verification_Request__c createCodeRequest(String code, String recordId) {
        Registration_Code_Verification_Request__c request = new Registration_Code_Verification_Request__c();
        request.code__c = code;
        request.Record_Id__c = recordId;
        return request;
    }
}