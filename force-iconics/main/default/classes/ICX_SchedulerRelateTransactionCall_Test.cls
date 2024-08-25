@isTest
private class ICX_SchedulerRelateTransactionCall_Test {
	
	@isTest static void test_ScheduleBatchRelateTransactionToCall() {
		Test.startTest();
		String cron = '0 0 23 * * ?';
		ICX_SchedulerRelateTransactionToCall schd = new ICX_SchedulerRelateTransactionToCall();
		String jobId = System.schedule('test schedule relate transaction to call', cron, schd);

    // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                     FROM CronTrigger WHERE id = :jobId];

    Test.stopTest();
    System.assertNotEquals(Null, ct.NextFireTime);
	}
	
}