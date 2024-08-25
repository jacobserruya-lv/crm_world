@isTest 
private class IDENTITY_Social_Login_Dashboard_TEST {
    @isTest 
    static void test1() {
		
        Test.StartTest();            
            IDENTITY_Social_Login_Dashboard_CTRL.getLoginHistoryByOrigin('current_month'); 
            IDENTITY_Social_Login_Dashboard_CTRL.getLoginHistoryByOrigin('last_six_months');
        Test.StopTest();
    }

    @isTest
    static void test2() {
		
        Identity_TestFactory.createCustomEmailLogs();
        
        Test.StartTest();
            IDENTITY_Social_Login_Dashboard_CTRL.getVerificationCodeEmailsAmount();            
            IDENTITY_Social_Login_Dashboard_CTRL.getEmailMobileUsers();
            IDENTITY_Social_Login_Dashboard_CTRL.getResetPasswordAmount();
        Test.StopTest();
    }
}