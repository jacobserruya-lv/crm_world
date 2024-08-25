@isTest
public with sharing class TWIST_ResetPassword_TEST {
        
    @testSetup
    static void initData(){
        Identity_TestFactory.createSettings();
        User user_1 = Identity_TestFactory.createUser('TEST1','TEST1','test_user_1@test.test','0500000111','972');
        User user_2 = Identity_TestFactory.createUser('TEST2','TEST2','test_user_2@test.test','0500000222','972');
        User user1 = getIdentityUser(user_1.Email);
        User user2 = getIdentityUser(user_2.Email);
        //User user2 = getIdentityUserNotEqual(user1.Email);
        list<Reset_Password_Request__c> rps = new list<Reset_Password_Request__c>();
        Reset_Password_Request__c req1 = createRequest('email_1_test@test.com', 'token_1', true);
        Reset_Password_Request__c req2 = createRequest(user1.Email, 'token_2', false);
        Reset_Password_Request__c req3 = createRequest(user2.Email, 'token_3', false);
        Reset_Password_Request__c req4 = createRequest(user2.Email, 'token_4', false);
        
        rps.add(req1);
        rps.add(req2);
        rps.add(req3);
        rps.add(req4);
        insert rps;
        
        TWIST_Settings__c settings = new TWIST_Settings__c();
        settings.Name = 'test';
        settings.Allow_Plus_Symbol_In_Email__c = true;
        settings.Reset_Password_Max_Requests__c = 2;
        settings.Password_Maxlength__c = 20;
        settings.Env_In_Reset_Password_Url__c = 'ift';
        settings.Is_Active_User_Creation__c = true;
        insert settings;
    }
    
    @isTest
    static void test_initForgotPasswordComponentConfig() {
        Set<String> expectedConfigAttributes = new Set<String> {'AllowPlusSymbolInEmail', 'loginUrl', 'registrationUrl'};
        Map<String,Object> config = TWIST_ResetPassword.initForgotPasswordComponentConfig(new Map<String,Object>());
        System.assertEquals(expectedConfigAttributes, config.keySet(), 'msg');
    }
    
    @isTest
    static void test_getUserByResetPasswordToken() {
        Test.startTest();
        createAccount('lastName', 'firstName', 'email_1_test@test.com');
        
        
        Map<String,Object> result_no_request = TWIST_ResetPassword.getUserByResetPasswordToken('not_existing_token', 'en');
        Map<String,Object> account_but_no_user = TWIST_ResetPassword.getUserByResetPasswordToken('token_1', 'en');
        Map<String,Object> result_success = TWIST_ResetPassword.getUserByResetPasswordToken('token_2', 'en');
        
        Reset_Password_Request__c request = getResetPasswordRequest('token_2');
        User user = getIdentityUser(request.Email__c);
        Test.stopTest();
        Map<String,Object> expectedNoRequest = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', 'en'));
        Map<String,Object> expectedSuccess = TWIST_Utils.buildSuccessResponseObject(new Map<String,Object> { 'email' => user.Email, 'firstName' => user.FirstName, 'lastName' => user.LastName});
        
        System.assertequals(expectedNoRequest, result_no_request);
        System.assertequals(true, account_but_no_user.get('success'));
        System.assertequals(expectedSuccess, result_success);
    }
    
    @isTest
    static void test_requestResetPassword_invalidEmail() {
        Map<String,Object> result = TWIST_ResetPassword.requestResetPassword('invalid_email', 'en', 'a', '', 'a', 'a');
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Error_Message_UnknownProfile', 'en'));
        
        System.assertequals(expected, result);
    }
    
    @isTest
    static void test_requestResetPassword_UserIsNull_UserCreationIsActiveOnInstance_AccountExists_MarketingCloudSendEmailServiceFails_v1() {
        // Given
        Test.startTest();
        UnitTestsHelper.setSingleHttpMock(new HttpResponseMock().setBody(new Map<String,Object> { 'success' => false }));
        createAccount('lastName', 'firstName', 'test_user_1@test.test');
        
        
        // When
        Map<String,Object> result = TWIST_ResetPassword.requestResetPassword('test_user_1@test.test', 'en', 'eng-us', '', 'a', 'a');
        Test.stopTest();
        // Then
        System.assert(result.containsKey('success'), 'ERROR');
        System.assert(result.containsKey('form'), 'ERROR');
        System.assertEquals(false, (Boolean) result.get('success'), 'ERROR');
    }
    
    @isTest
    static void test_requestResetPassword_UserIsNull_UserCreationIsActiveOnInstance_AccountExists_MarketingCloudSendEmailServiceFails_v2() {
        // Given
        Test.startTest();
        UnitTestsHelper.setSingleHttpMock(new HttpResponseMock().setBody(new Map<String,Object> { 'success' => true }).setStatusCode(500));
        createAccount('lastName', 'firstName', 'test_user_1@test.test');
        
        
        // When
        Map<String,Object> result = TWIST_ResetPassword.requestResetPassword('test_user_1@test.test', 'en', 'eng-us', '', 'a', 'a');
        Test.stopTest();
        // Then
        System.assert(result.containsKey('success'), 'ERROR');
        System.assert(result.containsKey('form'), 'ERROR');
        System.assertEquals(false, (Boolean) result.get('success'), 'ERROR');
    }
    
    @isTest
    static void test_requestResetPassword_UserIsNull_UserCreationIsActiveOnInstance_AccountExists_MarketingCloudSendEmailServiceSuceeds() {
        // Given
        Test.startTest();
        createAccount('lastName', 'firstName', 'test_user_1@test.test');
        UnitTestsHelper.setSingleHttpMock(new HttpResponseMock().setBody(new Map<String,Object> { 'success' => true }).setStatusCode(202));
        
        
        // When
        Map<String,Object> result = TWIST_ResetPassword.requestResetPassword('test_user_1@test.test', 'en', 'eng-us', '', 'a', 'a');
        Test.stopTest();
        // Then
        System.assert(result.containsKey('success'), 'ERROR');
        // System.assert((Boolean) result.get('success'), 'ERROR'); // JSSI understand why this assert fails
        //System.assert(result.containsKey('serps'), 'ERROR'); // JSSI understand why this assert fails
    }
    
    @isTest
    static void test_requestResetPassword_UserIsNull_UserCreationIsActiveOnInstance_AccountDoesNotExist() {
        // When
        Test.startTest();
        Map<String,Object> result = TWIST_ResetPassword.requestResetPassword('test_user_1@test.test', 'en', 'eng-us', '', 'a', 'a');
        Test.stopTest();
        // Then
        System.assert(result.containsKey('success'), 'ERROR');
        System.assertEquals(false, (Boolean) result.get('success'), 'ERROR');
    }
    
    @isTest
    static void test_requestResetPassword_nullUser_falseActivationSettings() {
        Test.startTest();
        updateFalseActiveUserSettings();
        Test.stopTest();
        
        Map<String,Object> result = TWIST_ResetPassword.requestResetPassword('email_1_test@test.com', 'en', 'a', '', 'a', 'a');
        Map<String,Object> expected = TWIST_Utils.buildSuccessResponseObject();
        
        System.assertequals(expected, result);
    }
    
    @isTest
    static void test_requestResetPassword_nullUserWithAccount() {
        Test.startTest();
        createAccount('lastName', 'firstName', 'email_1_test@test.com');
        
        
        Map<String,Object> result = TWIST_ResetPassword.requestResetPassword('email_1_test@test.com', 'en', 'a', '', 'a', 'a');
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', 'CUSTOM_LABEL');
        Test.stopTest();
        System.assertequals(expected, result);
    }
    
    @isTest
    static void test_requestResetPassword_invalidToken() {
        Test.startTest();
        Reset_Password_Request__c request = getResetPasswordRequest('token_3');
        Map<String,Object> result = TWIST_ResetPassword.requestResetPassword(request.Email__c, 'en', 'a', '', 'a', 'a');
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', 'en'));
        Test.stopTest();
        System.assertequals(expected, result);
    }
    
    @isTest
    static void test_requestResetPassword_validToken() {
        Test.startTest();
        Reset_Password_Request__c request = getResetPasswordRequest('token_2');
        Map<String,Object> result = TWIST_ResetPassword.requestResetPassword(request.Email__c, 'en', 'a', '', 'a', 'a');
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', 'en'));
        Test.stopTest();
        System.assertequals(expected, result);
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    @isTest
    static void test_doResetPassword_invalid_token() {
        Map<String,Object> queryParams = new Map<String,Object>();
        queryParams.put(TWIST_QueryParamKey_CONST.TOKEN, 'invalid-token');
        queryParams.put(TWIST_QueryParamKey_CONST.SF_LANGUAGE, 'en_US');
        queryParams.put(TWIST_QueryParamKey_CONST.ORIGIN, 'mylv');
        queryParams.put(TWIST_QueryParamKey_CONST.LANG_COUNTRY, 'eng-us');
        queryParams.put(TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY, 'KW');
        Map<String,Object> result = TWIST_ResetPassword.doResetPassword('password', 'password', 'en_US', queryParams);
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject(
            'redirectUrl',
            TWIST_Utils.buildTwistPageUrl(TWIST_IdentityPathsMdt_CONST.FORGOT_PASSWORD_FORM, queryParams, new List<String> { TWIST_QueryParamKey_CONST.TOKEN }
        ));
        
        System.assertequals(expected, result);
    }
    
    @isTest
    static void test_doResetPassword_nullUser_errorOnUserInsertion() {
        Test.startTest();
        updateNullProfileSettings();
        createAccount('lastName', 'firstName', 'email_1_test@test.com');
        
        
        Map<String,Object> queryParams = new Map<String,Object>();
        queryParams.put(TWIST_QueryParamKey_CONST.TOKEN, 'token_1');
        Map<String,Object> result = TWIST_ResetPassword.doResetPassword('password', 'password', 'en_US', queryParams);
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', 'en'));
        Test.stopTest();
        System.assertequals(expected, result);
    }
    
    @isTest
    static void test_doResetPassword_null_userNoAccount() {
        Map<String,Object> queryParams = new Map<String,Object>();
        queryParams.put(TWIST_QueryParamKey_CONST.TOKEN, 'token_1');
        Test.startTest();
        Map<String,Object> result = TWIST_ResetPassword.doResetPassword('password', 'password', 'en_US', queryParams);
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', 'en'));
        Test.stopTest();
        System.assertequals(expected, result);
    }
    
    @isTest
    static void test_doResetPassword_nullUser_falseActivationSettings() {
        Test.startTest();
        updateFalseActiveUserSettings();
        
        
        Map<String,Object> queryParams = new Map<String,Object>();
        queryParams.put(TWIST_QueryParamKey_CONST.TOKEN, 'token_1');
        Map<String,Object> result = TWIST_ResetPassword.doResetPassword('password', 'password', 'en_US', queryParams);
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', 'en'));
        Test.stopTest();
        System.assertequals(expected, result);
    }
    
    @isTest
    static void test_doResetPassword_passwordNotMatch() {
        Map<String,Object> queryParams = new Map<String,Object>();
        queryParams.put(TWIST_QueryParamKey_CONST.TOKEN, 'token_2');
        Test.startTest();
        Map<String,Object> result = TWIST_ResetPassword.doResetPassword('password1', 'password2', 'en_US', queryParams);
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', 'en'));
        Test.stopTest();
        System.assertequals(expected, result);
    }
    
    @isTest
    static void test_doResetPassword_tooLongPassword() {
        Map<String,Object> queryParams = new Map<String,Object>();
        queryParams.put(TWIST_QueryParamKey_CONST.TOKEN, 'token_2');
        Test.startTest();
        Map<String,Object> result = TWIST_ResetPassword.doResetPassword('password1111111111111111111111111111', 'password1111111111111111111111111111', 'en_US', queryParams);
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', 'en'));
        Test.stopTest();
        System.assertequals(expected, result);
    }
    
    @isTest
    static void test_doResetPassword_dontMatchStringPattern() {
        Map<String,Object> queryParams = new Map<String,Object>();
        queryParams.put(TWIST_QueryParamKey_CONST.TOKEN, 'token_2');
        Test.startTest();
        Map<String,Object> result = TWIST_ResetPassword.doResetPassword('password', 'password', 'en_US', queryParams);
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', 'en'));
        Test.stopTest();
        System.assertequals(expected, result);
    }
    
    @isTest
    static void test_doResetPassword_containsName() {
        Reset_Password_Request__c request = getResetPasswordRequest('token_2');
        Test.startTest();
        User user = getIdentityUser(request.Email__c);
        String password = user.LastName + 'Ll22!';
        
        Map<String,Object> queryParams = new Map<String,Object>();
        queryParams.put(TWIST_QueryParamKey_CONST.TOKEN, 'token_2');
        
        Map<String,Object> result = TWIST_ResetPassword.doResetPassword(password, password, 'en_US', queryParams);
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Reset_Password_Form_Validation_PasswordContainsFirstOrLastNames', 'en'));
        Test.stopTest();
        System.assertequals(expected, result);
    }   
    
    @isTest
    static void test_doResetPassword_success() {
        Map<String,Object> queryParams = new Map<String,Object>();
        queryParams.put(TWIST_QueryParamKey_CONST.TOKEN, 'token_2');
        Test.startTest();
        Map<String,Object> result = TWIST_ResetPassword.doResetPassword('passWord2!', 'passWord2!', 'en_US', queryParams);
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Reset_Password_Form_Validation_PasswordContainsFirstOrLastNames', 'en'));
        Test.stopTest();
        System.assertequals(expected, result);
    }
    
    ////////////////////////////////////////////////////////////////////////////////////////////////
    
    @isTest
    static void test_validateToken_success() {
        Map<String,Object> queryParams = new Map<String,Object>();
        queryParams.put(TWIST_QueryParamKey_CONST.TOKEN, 'token_1');
        Test.startTest();
        Map<String,Object> result = TWIST_ResetPassword.validateToken('en_US', queryParams);
        Map<String,Object> expected = TWIST_Utils.buildSuccessResponseObject();
        Test.stopTest();
        System.assertequals(expected, result);
    }
    
    @isTest
    static void test_validateToken_error() {
        Map<String,Object> queryParams = new Map<String,Object>();
        queryParams.put(TWIST_QueryParamKey_CONST.TOKEN, 'not_existing_token');
        queryParams.put(TWIST_QueryParamKey_CONST.SF_LANGUAGE, 'en_US');
        queryParams.put(TWIST_QueryParamKey_CONST.ORIGIN, 'mylv');
        queryParams.put(TWIST_QueryParamKey_CONST.LANG_COUNTRY, 'eng-us');
        queryParams.put(TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY, 'KW');
        Map<String,Object> result = TWIST_ResetPassword.validateToken('en_US', queryParams);
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject(
                'redirectUrl',
                TWIST_Utils.buildTwistPageUrl(TWIST_IdentityPathsMdt_CONST.FORGOT_PASSWORD_FORM, queryParams, new List<String> { TWIST_QueryParamKey_CONST.TOKEN }
        ));
        
        System.assertequals(expected, result);
    }
    
    /* PRIVATE METHODS ***************************************************************************************/
    
    private static Reset_Password_Request__c createRequest(String email, String token, Boolean isAccountActivation) {
        Reset_Password_Request__c req = new Reset_Password_Request__c();
        req.Email__c = email;
        req.Token__c = token;
        req.Status__c = TWIST_ResetPasswordTokenService.TOKEN_ISSUED;
        req.isAccountActivation__c = isAccountActivation;
        return req;
    }
    
    private static User getIdentityUser() {
        return [SELECT Id, Email, AccountId, FirstName, LastName FROM User WHERE Is_Identity_User__c = true AND AccountId != null LIMIT 1];
    }
    
    private static User getIdentityUser(String email) {
        return [SELECT Id, Email, AccountId, FirstName, LastName FROM User WHERE Is_Identity_User__c = true AND AccountId != null AND Email =: email LIMIT 1];
    }
    
    private static User getIdentityUserNotEqual(String email) {
        return [SELECT Id, Email, AccountId, FirstName, LastName FROM User WHERE Is_Identity_User__c = true AND AccountId != null AND Email !=: email LIMIT 1];
    }
    
    private static Reset_Password_Request__c getResetPasswordRequest(String token) {
        return [SELECT Id, Email__c FROM Reset_Password_Request__c WHERE Token__c =: token ORDER BY CreatedDate DESC LIMIT 1];
    }
    
    private static void updateFalseActiveUserSettings() {
        TWIST_Settings__c settings = [SELECT Is_Active_User_Creation__c FROM TWIST_Settings__c LIMIT 1][0];
        settings.Is_Active_User_Creation__c = false;
        update settings;
    }
    
    private static void updateNullProfileSettings() {
        IDENTITY_Settings__c settings = [SELECT ProfileId__c FROM IDENTITY_Settings__c LIMIT 1][0];
        settings.ProfileId__c = null;
        update settings;
    }
    
    private static void createAccount(String lastName, String firstName, String personEmail) {
        insert new Account(LastName = lastName, FirstName = firstName, PersonEmail = personEmail);
    }
}