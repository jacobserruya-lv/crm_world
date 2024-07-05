@isTest
public class Wecome_MP_Assistant_Notif_Job_TEST {
    @isTest
    static void Assitant_Notification_JOB_Test() {
        Test.startTest();
		String cron = '0 0 23 * * ?';
		Wecome_MP_Assistant_Notification_JOB schd = new Wecome_MP_Assistant_Notification_JOB();
		String jobId = System.schedule('test schedule user management batch', cron, schd);

		// Get the information from the CronTrigger API object
      	CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
         						FROM CronTrigger WHERE id = :jobId];

		Test.stopTest();
		System.assertNotEquals(Null, ct.NextFireTime);
    }

}