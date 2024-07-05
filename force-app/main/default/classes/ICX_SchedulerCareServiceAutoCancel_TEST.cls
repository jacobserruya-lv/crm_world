/**
* @author Keman WU
* @date Creation 09/12/2021
* @description test class for ICX_SchedulerCareServiceAutoCancellation
*/
@isTest
public class ICX_SchedulerCareServiceAutoCancel_TEST {
    @isTest static void testBehavior() {
        Test.startTest();
		String cron = '0 0 23 * * ?';
		ICX_SchedulerCareServiceAutoCancel schd = new ICX_SchedulerCareServiceAutoCancel();
		String jobId = System.schedule('test auto cancel', cron, schd);

    // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                     FROM CronTrigger WHERE id = :jobId];

    Test.stopTest();
    System.assertNotEquals(Null, ct.NextFireTime);
    }
}