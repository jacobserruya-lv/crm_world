@isTest
global class IDENTITY_UserManagement_JOB_TEST {
    @isTest static void testJOB() {     
        Test.startTest();
		String cron = '0 0 23 * * ?';
		IDENTITY_UserManagement_JOB schd = new IDENTITY_UserManagement_JOB();
		String jobId = System.schedule('test schedule user management batch', cron, schd);

		// Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
         						FROM CronTrigger WHERE id = :jobId];

		Test.stopTest();
		System.assertNotEquals(null, ct.NextFireTime, '');
    }
}