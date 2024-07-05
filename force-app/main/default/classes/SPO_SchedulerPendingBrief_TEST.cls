/**
* @description: Test class for the schedulable ICX_SchedulerSpamDeletion
* @modification history:
*
*/
@isTest
private class SPO_SchedulerPendingBrief_TEST {
    
    @isTest static void test_scheduleBatchPendingBrief()
    {
       	Test.startTest();
		String cron = '0 0 23 * * ?';
		SPO_SchedulerPendingBriefNotification schd = new SPO_SchedulerPendingBriefNotification();
		String jobId = System.schedule('test schedule pending brief notifications', cron, schd);

		// Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
         						FROM CronTrigger WHERE id = :jobId];

		Test.stopTest();
		System.assertNotEquals(Null, ct.NextFireTime);
    }

}