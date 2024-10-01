@isTest
public with sharing class TWIST_ResetPasswordTokenService_TEST {

    @testSetup  
    static void initData(){
        Reset_Password_Request__c request1 =  TWIST_ResetPasswordTokenService.createResetPasswordRequest('email_test@test.com', 'token_1', 'a', 'a', 'a',false);
        Reset_Password_Request__c request2 =  TWIST_ResetPasswordTokenService.createResetPasswordRequest('email_test@test.com', 'token_2', 'a', 'a', 'a',false);
        Reset_Password_Request__c request3 = createRequest('email_test_known_user@test.com', 'token_3');
        Reset_Password_Request__c request4 =  TWIST_ResetPasswordTokenService.createResetPasswordRequest('email_test_temp@test.com', 'token_4', 'a', 'a', 'a',false);

        request3.CreatedDate = System.now().addDays(-1); 
        insert request3;

        request1.Status__c = TWIST_ResetPasswordTokenService.TOKEN_USED;
        update request1;        

        TWIST_Settings__c settings = new TWIST_Settings__c();
        settings.Name = 'test';
        settings.Reset_Password_Max_Requests__c = 3;
        settings.Password_Maxlength__c = 20;
        settings.Email_Token_Size__c = 32;
        settings.Email_Token_Chars__c = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        insert settings;
    }

    
    @isTest
    public static void test_getToken_MissingFields() {

        Test.startTest();
        Map<String,Object> result_missing_fields = TWIST_ResetPasswordTokenService.getToken('', 'a');
        Test.stopTest();

        Map<String,Object> expected_missing_fields = TWIST_Utils.buildFailureResponseObject('error', 'Missing fields');
        System.assertequals(expected_missing_fields, result_missing_fields);
    }

    @isTest
    public static void test_getToken_tooManyRequests() {
        Reset_Password_Request__c request4 =  TWIST_ResetPasswordTokenService.createResetPasswordRequest('email_test@test.com', 'token_4', 'a', 'a', 'a',false);

        Map<String,Object> expected_tooManyRequests = TWIST_Utils.buildFailureResponseObject('error', 'Twist_Too_many_Reset_Password_Requests');
        Map<String,Object> result_tooManyRequests = TWIST_ResetPasswordTokenService.getToken('email_test@test.com', 'a');
        System.assertequals(expected_tooManyRequests, result_tooManyRequests);
    }

    
    @isTest
    public static void test_getToken_success() {

        Test.startTest();
        Map<String,Object> result_success = TWIST_ResetPasswordTokenService.getToken('email_test@test.com', 'a');
        Test.stopTest();

        System.assertequals(true, result_success.get('success'));
        System.assertnotequals(null, result_success.get('token'));
    }

    @isTest
    public static void test_getResetPasswordRequest() {

        Test.startTest();
        Reset_Password_Request__c res_empty = TWIST_ResetPasswordTokenService.getResetPasswordRequest('temp_token');
        Reset_Password_Request__c res_not_empty = TWIST_ResetPasswordTokenService.getResetPasswordRequest('token_1');
        Test.stopTest();

        System.assertequals(null, res_empty);
        System.assertequals('email_test@test.com', res_not_empty.Email__c);  
    }

    @isTest
    public static void test_isTokenValid() {

        Test.startTest();
        Boolean res_1 = TWIST_ResetPasswordTokenService.isTokenValid('TOKEN_STATUS_UNKNOWN');
        Boolean res_2 = TWIST_ResetPasswordTokenService.isTokenValid('TOKEN_STATUS_USER_UNKNOWN');
        Boolean res_3 = TWIST_ResetPasswordTokenService.isTokenValid('TOKEN_STATUS_EXPIRED');
        Boolean res_4 = TWIST_ResetPasswordTokenService.isTokenValid('TOKEN_STATUS_USED');
        Boolean res_5 = TWIST_ResetPasswordTokenService.isTokenValid('TOKEN_STATUS_VALID');
        Test.stopTest();

        System.assertequals(false, res_1);
        System.assertequals(true, res_2);
        System.assertequals(false, res_3);
        System.assertequals(false, res_4);
        System.assertequals(true, res_5);
    }
    
    @isTest
    public static void test_validate() {

        Test.startTest();
        String res_empty = TWIST_ResetPasswordTokenService.validate('temp_token');
        String res_unknown_user = TWIST_ResetPasswordTokenService.validate('token_2');
        String res_used_token = TWIST_ResetPasswordTokenService.validate('token_1');
        String res_token_expired = TWIST_ResetPasswordTokenService.validate('token_3');
        Test.stopTest();

        System.assertequals('TOKEN_STATUS_UNKNOWN', res_empty);
        System.assertequals('TOKEN_STATUS_USER_UNKNOWN', res_unknown_user);
        System.assertequals('TOKEN_STATUS_USED', res_used_token);
        System.assertequals('TOKEN_STATUS_EXPIRED', res_token_expired);
    }

    @isTest
    public static void test_validateWhenTokenIsNullOrEmpty() {
        Test.startTest();
        String resultWhenTokenIsNull = TWIST_ResetPasswordTokenService.validate(null);
        String resultWhenTokenIsEmpty = TWIST_ResetPasswordTokenService.validate('');
        Test.stopTest();

        System.assertequals('TOKEN_STATUS_UNKNOWN', resultWhenTokenIsEmpty, 'ERROR');
        System.assertequals('TOKEN_STATUS_UNKNOWN', resultWhenTokenIsEmpty, 'ERROR');
    }
    
    @isTest
    public static void test_usedResetPasswordRequest() {
        Test.startTest();
        TWIST_ResetPasswordTokenService.setTokenStatusToUsed('token_4');
        Test.stopTest();
        Reset_Password_Request__c expected = TWIST_ResetPasswordTokenService.getResetPasswordRequest('token_4');
        System.assertequals(expected.get('Status__c'), TWIST_ResetPasswordTokenService.TOKEN_USED);
    }

    /* PRIVATE METHODS ***************************************************************************************/


    private static Reset_Password_Request__c createRequest(String email, String token) {
        Reset_Password_Request__c req = new Reset_Password_Request__c();
        req.Email__c = email;
        req.Token__c = token;
        req.Status__c = TWIST_ResetPasswordTokenService.TOKEN_ISSUED;
        return req;
    }

}