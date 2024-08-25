@isTest
public with sharing class TWIST_Utils_TEST {
    
    @testSetup
    static void initData(){
        Identity_TestFactory.createSettings();
        User user = Identity_TestFactory.createUser('TEST','TEST','get-map-user@test.test','0500000000','972');
        
        Reset_Password_Request__c request = createResetRequest('test@test.com', 'token_1');
        insert request;
        
        TWIST_Settings__c settings = new TWIST_Settings__c();
        settings.Name = 'test';
        settings.Allow_Plus_Symbol_In_Email__c = true;
        settings.Reset_Password_Max_Requests__c = 2;
        settings.Password_Maxlength__c = 20;
        settings.Env_In_Reset_Password_Url__c = 'i1f';
        settings.Reset_Password_Redirection_Host__c = 'https://www-i1f.louisvuitton.com';
        settings.Footer_Links_Base_Url__c = 'https://{0}-i3f.louisvuitton.com';
        settings.SFCC_Feature_Flag_Endpoint__c = '/eco-eu/lvcom-core-conf-eapi/v1/configuration/lang_country';
        settings.Origins_to_replace__c = 'lvapp';
        settings.Target_origin__c = 'mylv';
        insert settings;
        
        Account acc = new Account(LastName = 'test', FirstName = 'test', PersonEmail = 'aaa@test.com');
        insert acc;
        
        Country__c country = new Country__c(Name = 'FRANCE', Iso2Code__c = 'FR', tech_duplicate__c = 'France');
        insert country;
    }
    
    @isTest
    public static void test_buildPageReference() {
        // Given
        String url = '/dummy/url/';
        Map<String,String> currentPageParameters = new Map<String,String> { 'myKey1' => 'myValue1', 'myKey2' => 'myValue2', 'myKey3' => 'myValue3' };
        
        // When
        PageReference page = TWIST_Utils.buildPageReference(url, currentPageParameters);
        
        // Then
        System.assert(String.valueOf(page.getUrl()).startsWith(url), 'ERROR');
        System.assert(currentPageParameters.equals(page.getParameters()), 'ERROR');
    }
    
    @isTest
    static void test_getLoginFormSettings() {
        // When
        Map<String,Object> identitySettings = TWIST_Utils.getLoginFormSettings();
        // Then
        System.assert(!identitySettings.isEmpty(), 'ERROR');
    }
    
    @isTest
    static void test_truncateUsername() {
        // Given
        String username = 'test@test.com';
        String usernameTruncatedMustBe = 'tes***';
        // When
        String usernameTruncated = TWIST_Utils.getUserIdentifier('utm_campaign', username);
        // Then
        System.assertEquals(usernameTruncatedMustBe, usernameTruncated, 'ERROR');
    }
    
    @isTest
    static void test_truncateUsername_emptyString() {
        // Given
        String username;
        String usernameTruncatedMustBe = '';
        // When
        String usernameTruncated = TWIST_Utils.getUserIdentifier('utm_campaign', username);
        // Then
        System.assertEquals(usernameTruncatedMustBe, usernameTruncated, 'ERROR');
    }
    
    @isTest
    static void test_buildResponse() {
        
        Map<String,Object> response = new Map<String,Object> {'str_1' => 'str_2'};
        Test.startTest();
        Map<String,Object> result_failure_1 = TWIST_Utils.buildFailureResponseObject();
        Map<String,Object> result_failure_2 = TWIST_Utils.buildFailureResponseObject('str1', 'str2');
        Map<String,Object> result_success_1 = TWIST_Utils.buildSuccessResponseObject();
        Map<String,Object> result_success_2 = TWIST_Utils.buildSuccessResponseObject('str1', 'str2');
        Map<String,Object> result_success_3 = TWIST_Utils.buildSuccessResponseObject(response);
        Test.stopTest();
        
        Map<String,Object> expected_failure_1 = new Map<String,Object> { 'success' => false };
        Map<String,Object> expected_failure_2 = new Map<String,Object> { 'success' => false, 'str1' => 'str2' };
        Map<String,Object> expected_success_1 = new Map<String,Object> { 'success' => true };
        Map<String,Object> expected_success_2 = new Map<String,Object> { 'success' => true, 'str1' => 'str2' };
        Map<String,Object> expected_success_3 = new Map<String,Object> { 'success' => true, 'str_1' => 'str_2' };
        
        System.assertequals(expected_failure_1, result_failure_1);
        System.assertequals(expected_failure_2, result_failure_2);
        System.assertequals(expected_success_1, result_success_1);
        System.assertequals(expected_success_2, result_success_2);
        System.assertequals(expected_success_3, result_success_3);
    }
    
    @isTest
    static void test_activateUserBeforeLogin() {
        Test.startTest();
        String userId = [SELECT Id FROM User WHERE IsActive = false LIMIT 1][0].Id;
        TWIST_Utils.activateUser(userId);
        Test.stopTest();
        Boolean expected = [SELECT IsActive FROM User WHERE Id =: userId LIMIT 1][0].IsActive;
        System.assertequals(expected, true);
    }
    
    @isTest
    static void test_FindAndValidEmail() {
        String userTechEmail = [SELECT Id, TECH_Email__c FROM User WHERE Is_Identity_User__c = true LIMIT 1][0].TECH_Email__c;
        Test.startTest();
        Boolean success_valid = TWIST_Utils.isValidEmail('test@test.com');
        Boolean failure_valid = TWIST_Utils.isValidEmail('a@');
        
        Boolean success_find = TWIST_Utils.canFindMyLVUserWithEmail(userTechEmail);
        Boolean failure_find = TWIST_Utils.canFindMyLVUserWithEmail('');
        Test.stopTest();
        
        System.assertequals(success_valid, true);
        System.assertequals(failure_valid, false);
        
        System.assertequals(success_find, true);
        System.assertequals(failure_find, false);
    }
    
    @isTest
    static void test_settings() {
        Test.startTest();
        Map<String,Object> settings = TWIST_Utils.getForgotPasswordFormSettings(new Map<String,Object>());
        String path = TWIST_Utils.getLVappUrlScheme();
        Test.stopTest();
        Boolean result = (Boolean)settings.get('AllowPlusSymbolInEmail');
        String expected_path = [SELECT Value__c FROM IDENTITY_Paths__mdt WHERE Name__c = 'LVAPP URL Scheme' LIMIT 1][0].Value__c;
        
        System.assertequals(result, true);
        System.assertequals(path, expected_path);
    }
    
    @isTest
    static void test_password() {
        Test.startTest();
        Boolean result_true_1 = TWIST_Utils.doPasswordsMatch('Password1!', 'Password1!');
        Boolean result_false_1 = TWIST_Utils.doPasswordsMatch('', 'Password1!');
        
        Boolean result_true_2 = TWIST_Utils.doesPasswordMatchStringPattern('Password1!');
        Boolean result_false_2 = TWIST_Utils.doesPasswordMatchStringPattern('aaaaa!');
        
        Boolean result_true_3 = TWIST_Utils.isPasswordTooLong('123456789012345678901234567890');
        Boolean result_false_3 = TWIST_Utils.isPasswordTooLong('1234');
        
        //String password, Map<String,String> user
        Map<String,String> user = new Map<String,String> {'FirstName' => 'first', 'LastName' => 'last'};
        Boolean result_true_4 = TWIST_Utils.doesPasswordContainUserFirstNameOrLastName('first_last', user);
        Boolean result_false_4 = TWIST_Utils.doesPasswordContainUserFirstNameOrLastName('pasword', user);
        Test.stopTest();
        
        System.assertequals(result_true_1, true);
        System.assertequals(result_true_2, true);
        System.assertequals(result_true_3, true);
        System.assertequals(result_true_4, true);
        
        System.assertequals(result_false_1, false);
        System.assertequals(result_false_2, false);
        System.assertequals(result_false_3, false);
        System.assertequals(result_false_4, false);
    }
    
    @isTest
    static void test_buildForgotPasswordFormUrl() {
        // Given
        String langCountry = 'eng-us';
        String origin = 'mylv';
        String dispatchCountry = 'KW';
        String urlExpected = String.format('{0}{1}/{2}/{3}?{4}', new List<String> {
            TWIST_UrlUtils.getCommunityUrl(true),
            langCountry,
            origin,
            TWIST_Utils.getPageKey(TWIST_IdentityPathsMdt_CONST.FORGOT_PASSWORD_FORM),
            'dispatchCountry=' + dispatchCountry
        });
        
        // When
        Test.startTest();
        String urlBuilt = TWIST_Utils.buildForgotPasswordFormUrl(langCountry, origin, dispatchCountry);
        Test.stopTest();
        
        // Then
        System.assertequals(urlExpected, urlBuilt, 'Error');
    }
    
    @isTest
    static void test_buildGetAuthorizationCodeUrl() {
        Test.startTest();
        String result = TWIST_Utils.buildGetAuthorizationCodeUrl('state', 'codeChallenge', 'clientId', 'redirectUri');
        Test.stopTest();
        
        String expected = '/services/oauth2/authorize?response_type=code&state=state&code_challenge=codeChallenge&client_id=clientId&redirect_uri=redirectUri';
        
        System.assertequals(expected, result);
    }
    
    @isTest
    static void test_getAccountSettings() {
        Map<String,Object> result = TWIST_Utils.getAccountSettings();
        System.assertnotequals(null, result.get('passwordMaxlength'));
    }
    
    @isTest
    static void test_findAccountsByEmail() {
        List<Account> resultEmpty = TWIST_Utils.findAccountsByEmail('');
        List<Account> expectedEmpty = new List<Account>();
        System.assertequals(resultEmpty, expectedEmpty);
        
        List<Account> expectedNotEmpty = [SELECT Id, PersonEmail FROM Account WHERE PersonEmail = 'aaa@test.com' LIMIT 1];
        List<Account> resultNotEmpty = TWIST_Utils.findAccountsByEmail(expectedNotEmpty[0].PersonEmail);
        System.assertequals(resultNotEmpty[0].PersonEmail, 'aaa@test.com');
    }
    
    @isTest
    static void test_createExternalMyLVUser() {
        List<Account> acc = [SELECT Id, PersonEmail, PersonMobilePhone, LocalMobilePhone__pc, MobilePhoneCountryCallingCode__pc,
        LoginPhone__pc, LocalLoginPhone__pc, LoginPhoneCallingCode__pc, Salutation, SPO_Country_code__pc,
        PrimaryCountry__pc, HomeAddressCountryCode__pc, LastName, FirstName, PersonContactId
        FROM Account WHERE PersonEmail = 'aaa@test.com' LIMIT 1];
        User result = TWIST_Utils.createExternalMyLVUser(acc[0], '');
        User expected = new User(EmailEncodingKey = 'UTF-8', Username = 'aaa@test.com');
        System.assertequals(result.Username, expected.Username);
    }
    
    @isTest
    static void test_getLoginFormBaseUrl() {
        String result = TWIST_Utils.getLoginFormBaseUrl('eng-us', 'mylv');
        String expected = TWIST_UrlUtils.getCommunityUrl(true) + 'eng-us/mylv/login';
        System.assertequals(result, expected);
    }
    
    @isTest
    static void test_getUserISO2CountryCode() {
        String resultEmpty = TWIST_Utils.getUserISO2CountryCode('');
        String result = TWIST_Utils.getUserISO2CountryCode('FRANCE');
        System.assertequals(resultEmpty, 'US');
        System.assertequals(result, 'FR');
    }
    
    @isTest
    static void test_setContext() {
        Map<String,Object> componentConfig = new Map<String,Object>{ 'defaultLangCountryParameter' => 'fra-fr',  'defaultOriginParameter' => 'mylv-TEST'};
        TWIST_Utils.setContext('mylv', 'fra-fr', 'FR', componentConfig);
        System.assertequals(componentConfig.get('langCountry'), 'fra-fr');
        
        TWIST_Utils.setContext('', '', 'FR', componentConfig);
        System.assertequals(componentConfig.get('langCountry'), 'fra-fr');
        System.assertequals(componentConfig.get('origin'), 'mylv-TEST');
    }
    
    @isTest
    static void test_countVerificationCodes() {
        Integer result = TWIST_Utils.countVerificationCodes('test@test.com', '000');
        Integer resultEmpty = TWIST_Utils.countVerificationCodes('', '');
        System.assertequals(result, 0);
        System.assertequals(resultEmpty, 0);
    }
    
    @isTest
    static void test_countVerificationCodesWithResult() {
        
        Test.startTest();
        Registration_Code_Verification_Request__c requestEmail = createVerificationRequest('test-result@test.com', '784503');
        Registration_Code_Verification_Request__c requestPhone1 = createVerificationRequest('0500000000', '645029');
        Registration_Code_Verification_Request__c requestPhone2 = createVerificationRequest('0500000000', '109304');
        insert requestEmail;
        insert requestPhone1;
        insert requestPhone2;
        Test.stopTest();
        
        Integer resultEmail = TWIST_Utils.countVerificationCodes('test-result@test.com', '');
        Integer resultPhone = TWIST_Utils.countVerificationCodes('', '0500000000');
        Integer resultEmailPhone = TWIST_Utils.countVerificationCodes('test-result@test.com', '0500000000');
        
        System.assertequals(resultEmail, 1);
        System.assertequals(resultPhone, 2);
        System.assertequals(resultEmailPhone, 1);
    }
    
    @isTest
    static void test_activateUser() {
        User inactiveUser = [SELECT Id, IsActive FROM User WHERE IsActive = false LIMIT 1][0];
        TWIST_Utils.activateUser(inactiveUser);
        User activeUser = [SELECT Id, IsActive FROM User WHERE Id =: inactiveUser.Id LIMIT 1][0];
        System.assertequals(activeUser.IsActive, true);
    }
    
    @isTest
    static void test_getUserByAccountId() {
        // Given
        List<Account> accounts;
        accounts = [SELECT Id FROM Account WHERE PersonEmail = 'aaa@test.com' LIMIT 1];
        Account account1 = accounts.isEmpty() ? null : accounts.get(0);
        accounts = [SELECT Id FROM Account WHERE PersonEmail = 'get-map-user@test.test' LIMIT 1];
        Account account2 = accounts.isEmpty() ? null : accounts.get(0);
        
        // When
        User user1 = TWIST_Utils.getUserByAccountId(account1 != null ? account1.Id : null);
        User user2 = TWIST_Utils.getUserByAccountId(account2 != null ? account2.Id : null);
        
        // Then
        System.assertEquals(null, user1, 'ERROR');
        System.assertNotEquals(null, user2, 'ERROR');
    }
    
    @isTest
    static void test_getUserByUsername() {
        User result = TWIST_Utils.getUserByUsername('');
        System.assertequals(result, null);
    }
    
    @isTest
    static void test_convertUserToMap() {
        User user = [SELECT Id, LanguageLocaleKey, HasVerifiedEmail__c, LocaleSidKey, FirstName, LastName, Country__c, Title, MobilePhone, Username FROM User WHERE Email = 'get-map-user@test.test' LIMIT 1][0];
        Map<String,String> result = TWIST_Utils.convertUserToMap(user);
        System.assertequals(result.isEmpty(), false);
    }
    
    @isTest
    static void test_getResetPasswordEmailSettings() {
        Map<String,String> result = TWIST_Utils.getResetPasswordEmailSettings();
        System.assertnotequals(result.get('definitionKey'), null);
    }
    
    @isTest
    static void test_getResetPasswordUrl() {
        String language = 'eng-us';
        String origin = 'mylv';
        String result = TWIST_Utils.getResetPasswordUrl(language, '', origin, '1111');

        String baseUrl = String.format((String) TWIST_Utils.getTwistSetting('Footer_Links_Base_Url__c'), new List<String> { TWIST_UrlUtils.getUrlPrefix(language) });
        String pathValue = [SELECT Value__c FROM TWIST_IDENTITY_Paths__mdt WHERE Name__c = 'Reset Password Form Path' LIMIT 1][0].Value__c;
        String resetPasswordPath = '/' + language + '/' + origin + '/' + pathValue.substring(pathValue.lastIndexOf('/') + 1);

        String expected =  String.format(
            '{0}{1}?token={2}',
            new List<String> {
                baseUrl,
                resetPasswordPath,
                '1111'
            }
        );
        System.assertequals(result, expected);
    }
    
    @isTest
    static void test_getPathFromPattern() {
        String result1 = TWIST_Utils.getPathFromPattern('Forgot Password Form Path', 'eng-us', '', 'mylv');
        String expected1 =  '/eng-us/mylv/forgot-password';
        System.assertequals(result1, expected1);
    }

    @isTest
    public static void test_getSocialProvidersByLangCountry_shouldReturnEmptyMap() {
        // Given
        String langCountry = 'zzz-zz';
        
        // When
        Map<String,String> socialProviders = TWIST_Utils.getSocialProvidersByLangCountry(langCountry, new Map<String,Object>());
        
        // Then
        System.assert(socialProviders.isEmpty(), 'ERROR');
    }

    @isTest
    public static void test_getSocialProvidersByLangCountry_nominalCase() {
        // Given
        String langCountry = 'jpn-jp';

        // When
        Map<String,String> socialProviders = TWIST_Utils.getSocialProvidersByLangCountry(langCountry, new Map<String,Object>());
        
        // Then
        System.assert(!socialProviders.isEmpty(), 'ERROR');
    }

    @isTest
    static void test_getIso2CodeForCallingCode() {
        // When
        String result = TWIST_Utils.getIso2CodeForCallingCode(376);
        // Then
        System.assertEquals(result, 'AD', 'ERROR');
    }
    
    @isTest
    static void test_getSplittedPhoneFromFullPhone() {
        // When
        Map<String, String>  result = TWIST_Utils.getSplittedPhoneFromFullPhone('+82-2-1234- 5678');
        Map<String, String> expected = new Map<String,String>{
            'callingCode'               => '8221234',
            'iso2Code'                  => 'null',
            'internationalMobilePhone'  => '+82212345678',
            'mobilePhone'               => '05678'
        };
        system.debug('result map:'+result);
    }
    
    @isTest
    static void test_genderToSalutation() {
        // When
        String  result = TWIST_Utils.genderToSalutation('Female');
        // Then
        System.assertEquals(result, '04', 'ERROR');
    }
    
    @isTest
    static void test_getblockUser() {
        Map<String,Object> settingMap = new Map<String,Object>{
            'legalAge' => 16,
            'timeBlockValue' => 48,
            'langCountry' => 'eng-us',
            'isMinAge' => Twist_Utils.isMinimumAge('2024-01-31', 16)
        };
        String email = 'mohamed.sacko.ext+0060@louisvuitton.com';
        String langCountry = 'eng-us';
        try {
            TWIST_Utils.blockUser(settingMap, email, '2024-01-31', langCountry);
        } catch(Exception ex) {
            System.assertEquals(ex.getMessage(),TWIST_i18nTranslations.translateSingleLabel('Twist_Account_Creation_Wrong_birthdate', TWIST_login.getLanguage(langCountry)));
        }
    }
    
    @isTest
    static void test_getisUserBlocked() {
        String email = 'mohamed.sacko.ext+0060@louisvuitton.com';
        String langCountry = 'eng-us';
        
        TwistCacheManager__c obj = new TwistCacheManager__c();
        obj.Key__c = email;
        obj.LangCountry__c = langCountry;
        obj.TTL__c = 48;
        obj.Type__c = 'AGE_RESTRICTION';
        obj.Value__c = '2024-01-31';
        insert obj;
        
        List<TwistCacheManager__c> userBlocked = [SELECT Key__c, LangCountry__c, TTL__c, Value__c, Type__c FROM TwistCacheManager__c WHERE Key__c =: email AND LangCountry__c =: langCountry  LIMIT 1];
        TWIST_Utils.isUserBlocked(email, langCountry);
        System.assertEquals(true, TWIST_Utils.isUserBlocked(email, langCountry));
    }

    @isTest
    public static void test_buildAndClauseFromDisabledSocialProviders_whenNoSocialMediaProviderIsDisabled() {
        // Given
        String langCountry = 'jpn-jp';
        Map<String,Object> body = new Map<String,Object> {
            TWIST_FeatureFlagUtils.FEATURE_KEY_LINE_SOCIAL_LOGIN => true,
            TWIST_FeatureFlagUtils.FEATURE_KEY_DUMMY_SOCIAL_MEDIA => true
        };
        Test.startTest();
        HttpResponseMock mock = new HttpResponseMock().setStatusCode(200).setBody(JSON.serialize(body));
        UnitTestsHelper.setSingleHttpMock(mock);
        Test.stopTest();

        // When
        String andClause = TWIST_Utils.buildAndClauseFromDisabledSocialProviders(langCountry);

        // Then
        System.assertEquals('', andClause);
    }

    @isTest
    public static void test_buildAndClauseFromDisabledSocialProviders_whenOneSocialMediaProviderIsDisabled() {
        // Given
        String langCountry = 'jpn-jp';
        String prefix = 'eco-as';

        Test.startTest();
        Country__c country = new Country__c();
        country.tech_duplicate__c = 'Japan';
        insert country;

        Language2__c language = new Language2__c();
        language.Iso2Code__c = 'JA';
        language.Iso3Code__c = 'JPN';
        insert language;

        insert new CountryLanguage__c(
            Country__c = country.Id,
            Language__c = language.Id,
            ATG_Locale__c = langCountry,
            Mulesoft_Local__c = prefix
        );

        Map<String,Object> body = new Map<String,Object> {
            TWIST_FeatureFlagUtils.FEATURE_KEY_LINE_SOCIAL_LOGIN => false,
            TWIST_FeatureFlagUtils.FEATURE_KEY_DUMMY_SOCIAL_MEDIA => true
        };
        HttpResponseMock mock = new HttpResponseMock().setStatusCode(200).setBody(JSON.serialize(body));
        UnitTestsHelper.setSingleHttpMock(mock);
        Test.stopTest();

        // When
        String andClause = TWIST_Utils.buildAndClauseFromDisabledSocialProviders(langCountry);

        // Then
        System.assertEquals('AND Page_Key__c != \'line\'', andClause);
    }

    @isTest
    public static void test_buildAndClauseFromDisabledSocialProviders_whenMultipleSocialMediaProvidersAreDisabled() {
        // Given
        String langCountry = 'jpn-jp';
        String prefix = 'eco-as';

        Test.startTest();
        Country__c country = new Country__c();
        country.tech_duplicate__c = 'Japan';
        insert country;

        Language2__c language = new Language2__c();
        language.Iso2Code__c = 'JA';
        language.Iso3Code__c = 'JPN';
        insert language;

        insert new CountryLanguage__c(
            Country__c = country.Id,
            Language__c = language.Id,
            ATG_Locale__c = langCountry,
            Mulesoft_Local__c = prefix
        );

        Map<String,Object> body = new Map<String,Object> {
            TWIST_FeatureFlagUtils.FEATURE_KEY_LINE_SOCIAL_LOGIN => false,
            TWIST_FeatureFlagUtils.FEATURE_KEY_DUMMY_SOCIAL_MEDIA => false
        };
        HttpResponseMock mock = new HttpResponseMock().setStatusCode(200).setBody(JSON.serialize(body));
        UnitTestsHelper.setSingleHttpMock(mock);
        Test.stopTest();

        // When
        String andClause = TWIST_Utils.buildAndClauseFromDisabledSocialProviders(langCountry);

        // Then
        System.assertEquals('AND Page_Key__c NOT IN [\'dummy-social-media\',\'line\']', andClause);
    }

    @isTest
    public static void test_isFutureDate_shouldReturnFalse() {
        // Given
        String dateEmpty1 = null;
        String dateEmpty2 = '';
        String dateWrongFormat1 = 'undefined';
        String dateWrongFormat2 = '2024';
        String dateWrongFormat3 = '06/06/2024';
        String dateRightFormat1 = '2020-12-01';
        String dateRightFormat2 = '1950-06-26';

        // Then
        System.assert(!TWIST_Utils.isFutureDate(dateEmpty1));
        System.assert(!TWIST_Utils.isFutureDate(dateEmpty2));
        System.assert(!TWIST_Utils.isFutureDate(dateWrongFormat1));
        System.assert(!TWIST_Utils.isFutureDate(dateWrongFormat2));
        System.assert(!TWIST_Utils.isFutureDate(dateWrongFormat3));
        System.assert(!TWIST_Utils.isFutureDate(dateRightFormat1));
        System.assert(!TWIST_Utils.isFutureDate(dateRightFormat2));
    }

    @isTest
    public static void test_isFutureDate_shouldReturnTrue() {
        System.assert(TWIST_Utils.isFutureDate('2032-09-13'));
    }
    
    
    /* PRIVATE METHODS ***************************************************************************************/
    
    private static Reset_Password_Request__c createResetRequest(String email, String token) {
        Reset_Password_Request__c req = new Reset_Password_Request__c();
        req.Email__c = email;
        req.Token__c = token;
        req.Status__c = TWIST_ResetPasswordTokenService.TOKEN_ISSUED;
        return req;
    }
    
    private static Registration_Code_Verification_Request__c createVerificationRequest(String recordId, String code) {
        Registration_Code_Verification_Request__c request = new Registration_Code_Verification_Request__c();
        request.Record_Id__c = recordId;
        request.Code__c = code;
        return request;
    }
    
}