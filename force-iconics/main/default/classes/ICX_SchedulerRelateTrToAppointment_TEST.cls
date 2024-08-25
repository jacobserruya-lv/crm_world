@isTest
private class ICX_SchedulerRelateTrToAppointment_TEST {
	
	@isTest static void test_ICX_SchedulerRelateTrToAppointment_TEST() {
		
		Test.startTest();
		String cron = '0 0 23 * * ?';
		ICX_SchedulerRelateTrToAppointment schd = new ICX_SchedulerRelateTrToAppointment();
		String jobId = System.schedule('test schedule spam deletion batch', cron, schd);

		// Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
         						FROM CronTrigger WHERE id = :jobId];

		Test.stopTest();
		System.assertNotEquals(Null, ct.NextFireTime);
	}
	

	
}