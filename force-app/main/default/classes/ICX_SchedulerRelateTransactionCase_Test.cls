@isTest
private class ICX_SchedulerRelateTransactionCase_Test {
	
	@isTest static void test_ScheduleBatchRelateTransactionToCase() {
		Test.startTest();
		String cron = '0 0 23 * * ?';
		ICX_SchedulerRelateTransactionToCase schd = new ICX_SchedulerRelateTransactionToCase();
		String jobId = System.schedule('test schedule relate transaction to case', cron, schd);

    // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                     FROM CronTrigger WHERE id = :jobId];

    Test.stopTest();
    System.assertNotEquals(Null, ct.NextFireTime);
	}
}