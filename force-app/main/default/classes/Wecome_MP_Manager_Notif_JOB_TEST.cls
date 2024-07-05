@isTest
public class Wecome_MP_Manager_Notif_JOB_TEST {
    @isTest
    static void Manager_Notif_JOB_TEST() {
        Test.startTest();
		String cron = '0 0 23 ? * MON';
		Wecome_MP_Manager_Notification_JOB schd = new Wecome_MP_Manager_Notification_JOB();
		String jobId = System.schedule('test schedule user management batch', cron, schd);

		// Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
         						FROM CronTrigger WHERE id = :jobId];

		Test.stopTest();
		System.assertNotEquals(Null, ct.NextFireTime);
    }
}