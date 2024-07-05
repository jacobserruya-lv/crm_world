@isTest
public with sharing class TWIST_RecaptchaUtils_TEST {

    private static String customLabelValueWhenRunningTests = 'CUSTOM_LABEL';
    private static Boolean useGoogleRecaptcha = Boolean.valueOf(TWIST_AppSettings_UTIL.getSetting('IsRecaptchaActivated'));

    @isTest
    public static void test_isRunningTest() {
        System.assert(Test.isRunningTest(), 'err');
    }

    @isTest
    static void test_getRecaptchaKeyId() {
     //   if (useGoogleRecaptcha) {
            System.assertNotEquals('', TWIST_RecaptchaUtils.getRecaptchaKeyId(), 'ERROR');
     //   }
    }

    @isTest
    static void test_verifyRecaptchaToken_IfTokenIsEmptyShouldReturnError() {
      //  if (useGoogleRecaptcha) {
            // Given
            String email = 'test@test.com';
            String token1 = null;
            String token2 = '';
            String language = 'en';
            String expectedErrorMessage = customLabelValueWhenRunningTests + ' "token"';
            Map<String,Object> expectedResult = new Map<String,Object> {
                'success' => false,
                'error' => expectedErrorMessage
            };
    
            // When
            Map<String,Object> result1 = TWIST_RecaptchaUtils.verifyRecaptchaToken(token1, language, email);
            Map<String,Object> result2 = TWIST_RecaptchaUtils.verifyRecaptchaToken(token2, language, email);
    
            // Then
            System.assertEquals(expectedResult, result1, 'ERROR');
            System.assertEquals(expectedResult, result2, 'ERROR');
       // }
    }

    @isTest
    static void test_verifyRecaptchaToken_NominalCase_WhenGoogleVerifyApiReturnsSuccessFalseAndSomeErrorCodes() {
      //  if (useGoogleRecaptcha) {
            // Given
            Test.startTest();
                HttpResponseMock mock = new HttpResponseMock().setBody(new Map<String,Object> {
                    'success' => false,
                    'error' => customLabelValueWhenRunningTests
                });
                UnitTestsHelper.setSingleHttpMock(mock);
            Test.stopTest();
    
            // When
            Map<String,Object> result = TWIST_RecaptchaUtils.verifyRecaptchaToken('token', 'en', 'dummy@email.com');
    
            // Then
            System.assert(result.containsKey('success'), 'ERROR');
            System.assert(result.containsKey('error'), 'ERROR');
            System.assertEquals(false, (Boolean) result.get('success'), 'ERROR');
            System.assertEquals(customLabelValueWhenRunningTests, result.get('error'), 'ERROR');
      //  }
    }

    @isTest
    static void test_verifyRecaptchaToken_NominalCase_WhenGoogleVerifyApiReturnsSuccessFalseAndNoErrorCode() {
       // if (useGoogleRecaptcha) {
            // Given
            Test.startTest();
                HttpResponseMock mock = new HttpResponseMock().setBody(new Map<String,Object> { 'success' => false });
                UnitTestsHelper.setSingleHttpMock(mock);
            Test.stopTest();
    
            // When
            Map<String,Object> result = TWIST_RecaptchaUtils.verifyRecaptchaToken('token', 'en', 'dummy@email.com');
    
            // Then
            System.assert(result.containsKey('success'), 'ERROR');
            System.assert(result.containsKey('error'), 'ERROR');
            System.assertEquals(false, (Boolean) result.get('success'), 'ERROR');
            System.assertEquals(customLabelValueWhenRunningTests, result.get('error'), 'ERROR');
     //   }
    }

    @isTest
    static void test_verifyRecaptchaToken_NominalCase_WhenGoogleApiReturnsSuccessTrueAndScoreBelowThreshhold() {
      //  if (useGoogleRecaptcha) {
            Test.startTest();
                HttpResponseMock mock = new HttpResponseMock().setBody(new Map<String,Object> { 'success' => true, 'score' => 0.2 });
                UnitTestsHelper.setSingleHttpMock(mock);
            Test.stopTest();
    
            // When
            Map<String,Object> result = TWIST_RecaptchaUtils.verifyRecaptchaToken('token', 'en', 'dummy@email.com');
            List<Logs__c> logs = [SELECT Id FROM Logs__c WHERE Level__c = 'ERROR' AND Apex_Class__c = 'TWIST_RecaptchaUtils'];
            
            // Then
            System.assert(result.containsKey('success'), 'ERROR');
            System.assert(result.containsKey('error'), 'ERROR');
            System.assertEquals(false, (Boolean) result.get('success'), 'ERROR');
            System.assertEquals(customLabelValueWhenRunningTests, result.get('error'), 'ERROR');
            //System.assertEquals(1, logs.size(), 'ERROR');
     //   }
    }

    @isTest
    static void test_verifyRecaptchaToken_NominalCase_WhenGoogleApiReturnsSuccessTrueAndScoreBeyondThreshhold() {
      //  if (useGoogleRecaptcha) {
            Test.startTest();
                HttpResponseMock mock = new HttpResponseMock().setBody(new Map<String,Object> { 'success' => true, 'score' => 1.0 });
                UnitTestsHelper.setSingleHttpMock(mock);
            Test.stopTest();
    
            // When
            Map<String,Object> result = TWIST_RecaptchaUtils.verifyRecaptchaToken('token', 'en', 'dummy@email.com');
    
            // Then
            System.assert(result.containsKey('success'), 'ERROR');
            System.assertEquals(false, result.containsKey('error'), 'ERROR');
            System.assert((Boolean) result.get('success'), 'ERROR');
     //   }
    }

}