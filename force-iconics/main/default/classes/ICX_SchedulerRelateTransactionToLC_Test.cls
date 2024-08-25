@isTest
private class ICX_SchedulerRelateTransactionToLC_Test {
	
	@isTest static void test_ScheduleBatchRelateTransactionToLiveChat() {
		Test.startTest();
		String cron = '0 0 23 * * ?';
		ICX_SchedulerRelateTransactionToLiveChat schd = new ICX_SchedulerRelateTransactionToLiveChat();
		String jobId = System.schedule('test schedule relate transaction to live chat', cron, schd);

    // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                     FROM CronTrigger WHERE id = :jobId];

    Test.stopTest();
    System.assertNotEquals(Null, ct.NextFireTime);
	}
}