@IsTest 
global with sharing class BatchUserUtilization_Sched_Test {

    @isTest
    static void testBatchUserSchedUtilization() {
        User testUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_SYSTEM_ADMINNISTRATOR);
        testUser.BypassVR__c = true;
        testUser.Country__c = '';
        insert testUser;

        System.runAs(testUser) {
			BatchUserUtilization_Sched cl = new BatchUserUtilization_Sched();

            Test.startTest();
            String sch = '0 0 23 L * ?';
            System.schedule('test check', sch, cl);
            Test.stopTest();
        }
    }
}