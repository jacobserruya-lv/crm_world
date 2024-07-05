@isTest
public with sharing class TWIST_AlternativeLogin_TEST {
    
    @testSetup
    static void initData(){
        Identity_TestFactory.createSettings();
        User user_1 = Identity_TestFactory.createUser('TEST1','TEST1','test_user_1@test.test','0500000111','972');
        User user_2 = Identity_TestFactory.createUser('TEST2','TEST2','test_user_2@test.test','0500000222','972');
        updateUserVerified(user_2.Email);
    }
    
    @isTest
    static void test_requestAlternativeLogin_emptyEmail() {
        Test.startTest();
        Map<String,Object> result = TWIST_AlternativeLogin.requestAlternativeLogin('', 'en', 'a', 'NL', 'a');
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Error_Send_Email_Empty_Address', 'en'));
        Test.stopTest();
        System.assertequals(expected, result);
    }
    
    @isTest
    static void test_requestAlternativeLogin_invalidEmail() {
        Test.startTest();
        Map<String,Object> result = TWIST_AlternativeLogin.requestAlternativeLogin('invalid_email', 'en', 'a', '', 'a');
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Error_Message_UnknownProfile', 'en'));
        Test.stopTest();
        System.assertequals(expected, result);
    }
    
    @isTest
    static void test_requestResetPassword_noUser() {
        Test.startTest();
        Map<String,Object> result = TWIST_AlternativeLogin.requestAlternativeLogin('email_nouser@test.com', 'en', 'a', '', 'a');
        Map<String,Object> expected = TWIST_Utils.buildSuccessResponseObject('seenf', '');
        Test.stopTest();
        System.assertequals(expected, result);
    }
    
    @isTest
    static void test_requestAlternativeLogin_NotHasVerifiedEmail() {
        Test.startTest();
        Map<String,Object> result = TWIST_AlternativeLogin.requestAlternativeLogin('test_user_1@test.test', 'en', 'a', '', 'a');
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Error_Message_UnknownProfile', 'en'));
        Test.stopTest();
        System.assertequals(expected, result);
    }
    
    @isTest
    static void test_requestAlternativeLogin_HasVerifiedEmail() {
        Test.startTest();
        Map<String,Object> result = TWIST_AlternativeLogin.requestAlternativeLogin('test_user_2@test.test', 'en', 'a', '', 'a');
        Map<String,Object> expected = TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Error_Message_UnknownProfile', 'en'));
        Test.stopTest();
        System.assertequals(expected, result);
    }
  
    @isTest
    static void test_requestAlternativeLogin_callMulesoftPassworlessApi_success() {
        // Given
        Test.startTest();
        UnitTestsHelper.setSingleHttpMock(new HttpResponseMock().setBody(new Map<String,Object> { 'success' => true }));
        
        // When
        Map<String,Object> result = TWIST_AlternativeLogin.requestAlternativeLogin('test_user_1@test.test', 'en', 'eng-us', '', 'a');
        Map<String,Object> expected = TWIST_Utils.buildSuccessResponseObject('seals', '');
        Test.stopTest();
        
        // Then
        System.assertequals(expected, result);
    }

    /* PRIVATE METHODS ***************************************************************************************/
    
    @future
    private static void updateUserVerified(String username){
        User myuser = [SELECT Id FROM User WHERE Username =: username];
        myuser.HasVerifiedEmail__c = true;
        update myuser;
    }
    
}