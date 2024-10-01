@isTest
public with sharing class TWIST_Login_TEST {

    private static String userEmail = 'logintest@test.test';

    @testSetup
    static void initData(){
        Identity_TestFactory.createSettings();
        TWIST_Settings__c settings = new TWIST_Settings__c();
        settings.Name = 'test';
        settings.Password_Maxlength__c = 20;
        settings.Default_Language_Country_Parameter__c = 'eng-e1';
        insert settings;
    }

    private class Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            String userName;
            String password;
            HTTPResponse res = new HTTPResponse();
            System.assertEquals('GET', req.getMethod());
            if(req.getBody().contains('lang_country')){ 
                res.setStatusCode(200);
            }else{
                res.setStatusCode(400);
                res.setBody('');  
            }
            return res;
        }
    }
    
    @isTest
    static void test_initComponentConfig() {
        // Given
        Map<String,Object> queryParams = new Map<String,Object>();
        queryParams.put(TWIST_QueryParamKey_CONST.ORIGIN, 'mylv');
        queryParams.put(TWIST_QueryParamKey_CONST.LANG_COUNTRY, 'eng-us');

        Set<String> expectedConfigAttributes = new Set<String> {
            'AllowPlusSymbolInEmail',
            'alternativeLoginUrl',
            'callingCode',
            'clientServicePhoneNumber',
            'countryLocal',
            'defaultLangCountryParameter',
            'defaultOriginParameter',
            'emailFieldVisibilityStyle',
            'fields',
            'passwordMaxlength',
            'tealiumEnv',
            'googleAnalyticsConfig',
            'langCountry',
            'metaLanguage',
            'language',
            'origin',
            'showUsernameField',
            'isEmailFieldVisible',
            'mobileFieldVisibilityStyle',
            'registrationBaseUrl',
            'forgotPasswordUrl',
            'isRedirectToRegistration',
            'socialMediaProviders',
            'googleSocialLoginEnabled',
            'lineSocialLoginEnabled',
            'oneTimeConnectionEnabled'
        };

        // When
        Map<String,Object> config = TWIST_Login.initComponentConfig(queryParams);
        // Then
        System.assertEquals(expectedConfigAttributes, config.keySet(), 'msg');
    }

    /*
    @isTest
    static void test_initComponentConfig_WhenPageModeIsKnownMode() {
        // Given
        User user = getIdentityUser();
        Map<String,Object> queryParams = new Map<String,Object>();
        queryParams.put(TWIST_QueryParamKey_CONST.ORIGIN, 'mylv');
        queryParams.put(TWIST_QueryParamKey_CONST.LANG_COUNTRY, 'eng-us');
        queryParams.put(TWIST_QueryParamKey_CONST.ORIGIN, 'mylv');
        queryParams.put(TWIST_QueryParamKey_CONST.LANG_COUNTRY, 'eng-us');
        String cid = IDENTITY_Utils.getEncryptedIdWithTrustOrigin(user.AccountId ,false);
        queryParams.put(TWIST_QueryParamKey_CONST.CID, cid);
        queryParams.put(TWIST_QueryParamKey_CONST.CID, cid);

        // When
        Map<String,Object> config = TWIST_Login.initComponentConfig(queryParams);

        // Then
       // System.assert(config.containsKey('usernameTruncated'), 'ERROR');
        //System.assert(config.containsKey('showUsernameField'), 'ERROR');
       // System.assert(config.containsKey('mobile'), 'ERROR');
    }
    */

    @isTest
    static void test_writeLogs_ViaDefaultCountryLangLogParameter() {
        // Given
        Map<String,Object> queryParams = new Map<String,Object>();
        queryParams.put(TWIST_QueryParamKey_CONST.UPDATED_TO_DEFAULT_LANG_COUNTRY, 'true');
        queryParams.put(TWIST_QueryParamKey_CONST.UPDATED_TO_DEFAULT_LANG_COUNTRY, 'true');

        // When
        TWIST_Login.writeLogs(queryParams);
        List<Logs__c> logs = [SELECT Id FROM Logs__c WHERE Level__c = 'ERROR' AND Apex_Class__c = 'TWIST_Login'];

        // Then
        System.assertEquals(1, logs.size(), 'ERROR');
    }

    @isTest
    static void test_writeLogs_ViaLog404Parameter() {
        // Given
        Map<String,Object> queryParams = new Map<String,Object>();
        queryParams.put(TWIST_QueryParamKey_CONST.ERROR_404, 'true');
        queryParams.put(TWIST_QueryParamKey_CONST.ERROR_404, 'true');

        // When
        TWIST_Login.writeLogs(queryParams);
        List<Logs__c> logs = [SELECT Id FROM Logs__c WHERE Level__c = 'ERROR' AND Apex_Class__c = 'TWIST_Login'];

        // Then
        System.assertEquals(1, logs.size(), 'ERROR');
    }

    @isTest
    static void test_writeLogs_ViaDefaultCountryLangLogAndLog404Parameters() {
        // Given
        Map<String,Object> queryParams = new Map<String,Object>();
        queryParams.put(TWIST_QueryParamKey_CONST.UPDATED_TO_DEFAULT_LANG_COUNTRY, 'true');
        queryParams.put(TWIST_QueryParamKey_CONST.ERROR_404, 'true');
        queryParams.put(TWIST_QueryParamKey_CONST.UPDATED_TO_DEFAULT_LANG_COUNTRY, 'true');
        queryParams.put(TWIST_QueryParamKey_CONST.ERROR_404, 'true');

        // When
        TWIST_Login.writeLogs(queryParams);
        List<Logs__c> logs = [SELECT Id FROM Logs__c WHERE Level__c = 'ERROR' AND Apex_Class__c = 'TWIST_Login'];

        // Then
        System.assertEquals(2, logs.size(), 'ERROR');
    }

    @isTest
    static void test_validateFormData_ShouldReturnTrue() {
        // Given
        Integer maxLength = Integer.valueOf(IDENTITY_Settings__c.getInstance().Password_Maxlength__c);
        String email = 'dummy-string';
        String password = 'a'.repeat(maxLength - 1);

        // When
        Boolean result1 = TWIST_Login.validateFormDataWithEmail(email, password, 'en');
        Boolean result2 = TWIST_Login.validateFormDataWithoutEmail(password, 'en');

        // Then
        System.assert(result1, 'ERROR');
        System.assert(result2, 'ERROR');
    }

    @isTest
    static void test_validateFormData_ShouldReturnFalseAndUpdateFormErrors() {
        // Given
        Integer maxLength = Integer.valueOf(IDENTITY_Settings__c.getInstance().Password_Maxlength__c);
        String regularEmail = 'dummy-string';
        String emptyEmail = '';
        String regularPassword = 'dummy-string';
        String emptyPassword = '';
        String longPassword = 'a'.repeat(maxLength + 1);

        // When
        Boolean result1 = TWIST_Login.validateFormDataWithEmail(emptyEmail, regularPassword, 'en');
        Boolean result2 = TWIST_Login.validateFormDataWithEmail(emptyEmail, emptyPassword, 'en');
        Boolean result3 = TWIST_Login.validateFormDataWithEmail(emptyEmail, longPassword, 'en');
        Boolean result4 = TWIST_Login.validateFormDataWithEmail(regularEmail, emptyPassword, 'en');
        Boolean result5 = TWIST_Login.validateFormDataWithEmail(regularEmail, longPassword, 'en');
        Boolean result6 = TWIST_Login.validateFormDataWithoutEmail(emptyPassword, 'en');
        Boolean result7 = TWIST_Login.validateFormDataWithoutEmail(longPassword, 'en');

        // Then
        System.assert(!result1, 'ERROR');
        System.assert(!result2, 'ERROR');
        System.assert(!result3, 'ERROR');
        System.assert(!result4, 'ERROR');
        System.assert(!result5, 'ERROR');
        System.assert(!result6, 'ERROR');
        System.assert(!result7, 'ERROR');
    }

    @isTest
    static void test_login_invalidForm() {
        Map<String,Object> result = TWIST_Login.login('', '', new Map<String,Object> {}, 'en');
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nCustomLabels.translateSingleLabel('Twist_Error_Message_CheckEmailAndPassword', 'en'));
        System.assertequals(result, expected);
    }

    @isTest
    static void test_login_nullUser() {
        Map<String,Object> queryParams = new Map<String,Object> {'cid' => 'dummy-client-id'};
        Map<String,Object> result = TWIST_Login.login('', 'password', queryParams, 'en');
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nCustomLabels.translateSingleLabel('Twist_Error_Message_CheckEmailAndPassword', 'en'));

        System.assertequals(result, expected);
    }

    @isTest
    static void test_login_nullPage() {
        //User user = getIdentityUser();
        User user = Identity_TestFactory.createUser('TEST','TEST',userEmail,'0500000000','972');
        system.debug('user test factory: ' + user.AccountId);
        Map<String,Object> queryParams = new Map<String,Object> {'accountId' => user.AccountId};
        Map<String,Object> result = TWIST_Login.login(user.Email, 'password', queryParams, 'en');
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nCustomLabels.translateSingleLabel('Twist_Login_Form_LoginProcessError', 'en'));

        System.assertequals(result, expected);
    }

    @isTest
    static void test_login_throwsAnException() {
        // User user = getIdentityUser();
        User user = Identity_TestFactory.createUser('TEST','TEST',userEmail,'0500000000','972');
        Map<String,Object> queryParams = new Map<String,Object>();
        queryParams.put(TWIST_QueryParamKey_CONST.CID, null);
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nCustomLabels.translateSingleLabel('Twist_Login_Form_LoginProcessError', 'en'));
        Map<String,Object> result = TWIST_Login.login(user.Email, 'password', queryParams, 'en');
        System.assertequals(expected, result);
    }

    @isTest
    static void test_getLanguage() {
        // Given
        String langCountry = 'fra-fr';

         // When
         Test.startTest();
         String result = TWIST_Login.getLanguage(langCountry);
         String resultNull = TWIST_Login.getLanguage('');
         Test.stopTest();
 
         // Then
         System.assertEquals('fr', result, 'ERROR');
         System.assertEquals('default', resultNull, 'ERROR');
    }
 
    private static User getIdentityUser(String email) {
        return [SELECT Id, Email, AccountId, FirstName, LastName FROM User WHERE Is_Identity_User__c = true AND AccountId != null AND Email =: email LIMIT 1];
    }

    @isTest
    static void test_getCallingCode() {
        User user = Identity_TestFactory.createUser('TEST','TEST','test1@gmail.com','0500000000','972');
        User userWithAccount = getIdentityUser(user.Email);
        Account acc = [SELECT MobilePhoneCountryCode__pc FROM Account WHERE Id = :userWithAccount.AccountId];
        System.assertEquals(null, TWIST_Login.getCallingCode(user));
        System.assertEquals(acc.MobilePhoneCountryCode__pc, TWIST_Login.getCallingCode(userWithAccount));
    }

    @isTest
    static void test_getAccountId() {
        System.assertEquals(null, TWIST_Utils.getAccountId('testcid'));
    }

    @isTest
    static void test_getForm() {
        User user = Identity_TestFactory.createUser('TEST','TEST',userEmail,'0500000000','972');
        system.debug('user test factory set from: ' + user.AccountId);
        system.debug('user test factory set from: ' +  getIdentityUser().AccountId);
        TWIST_Login.setForm('eng-us','','mylv', getIdentityUser().AccountId, 'utm_campaign');
    }

    private static User getIdentityUser() {
        return [SELECT Id, Email, AccountId FROM User WHERE Email = :userEmail  AND AccountId != null  LIMIT 1];
    }

    @isTest
    static void test_getLanguageSettings() {
        // Given
        String langCountry = 'fra-fr';

        // When
        Test.startTest();
        Map<String,String> result = TWIST_Login.getLanguageSettings(langCountry);
        Test.stopTest();
 
        Map<String,String> languageSettingsExpected = new Map<String,String>{
            'salesforceLanguage' => 'fr',
            'metaLanguage' => 'fr-FR'
        };
        // Then
        System.assertEquals(languageSettingsExpected, result, 'ERROR');
    }
    @isTest
    static void test_getLanguageSettingsNullLangCountry() {
       
        // When
        Test.startTest();
        Map<String,String> resultNull = TWIST_Login.getLanguageSettings('');
        Test.stopTest();
 
        Map<String,String> languageSettingsExpected = new Map<String,String>{
            'salesforceLanguage' => 'default',
            'metaLanguage' => 'en-E1'
        };
        // Then
        System.assertEquals(languageSettingsExpected, resultNull, 'ERROR');
    }
}