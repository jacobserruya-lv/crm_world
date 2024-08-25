/**
* @description: Test class for the schedulable ICX_SchedulerRelateTrToOutboundCall
* @modification history:
*
*/

@isTest
private class ICX_SchedulerRelateTrToOutboundCall_TEST {
	
	@isTest static void test_schedulerRelateTransactionToOutboundCall_TEST() {
		
		Test.startTest();
		String cron = '0 0 23 * * ?';
		ICX_SchedulerRelateTrToOutboundCall schd = new ICX_SchedulerRelateTrToOutboundCall();
		String jobId = System.schedule('test schedule spam deletion batch', cron, schd);

		// Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
         						FROM CronTrigger WHERE id = :jobId];

		Test.stopTest();
		System.assertNotEquals(Null, ct.NextFireTime);
	}
	

	
}