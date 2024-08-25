@isTest
private class ICX_SchedulerRelateTransactionToPod_Test {
	
	@isTest static void test_ScheduleBatchRelateTransactionToPod() {
		Test.startTest();
		String cron = '0 0 23 * * ?';
		ICX_SchedulerRelateTransactionToPod schd = new ICX_SchedulerRelateTransactionToPod();
		String jobId = System.schedule('test schedule relate transaction to product on demand', cron, schd);

    // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                     FROM CronTrigger WHERE id = :jobId];

    Test.stopTest();
    System.assertNotEquals(Null, ct.NextFireTime);
	}
	
}