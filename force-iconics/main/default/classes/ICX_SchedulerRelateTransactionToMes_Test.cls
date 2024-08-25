@isTest
private class ICX_SchedulerRelateTransactionToMes_Test{
	
	@isTest static void test_ScheduleBatchRelateTransactionToMessaging() {
		Test.startTest();
		String cron = '0 0 23 * * ?';
		ICX_SchedulerRelateTransactionToMess schd = new ICX_SchedulerRelateTransactionToMess();
		String jobId = System.schedule('test schedule relate transaction to messaging', cron, schd);

    // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                     FROM CronTrigger WHERE id = :jobId];

    Test.stopTest();
    System.assertNotEquals(Null, ct.NextFireTime);
	}
	
}