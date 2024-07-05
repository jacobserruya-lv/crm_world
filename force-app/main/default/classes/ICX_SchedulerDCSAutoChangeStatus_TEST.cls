/**
* @author Keman WU
* @date Creation 27/09/2022
* @description test class for ICX_SchedulerCareServiceAutoChangeStatus
*/
@isTest
public class ICX_SchedulerDCSAutoChangeStatus_TEST {
    @isTest static void testBehavior() {
        Test.startTest();
		String cron = '0 0 23 * * ?';
		ICX_SchedulerDCSAutoChangeStatus schd = new ICX_SchedulerDCSAutoChangeStatus();
		String jobId = System.schedule('test auto cancel', cron, schd);

    // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                     FROM CronTrigger WHERE id = :jobId];

    Test.stopTest();
    System.assertNotEquals(Null, ct.NextFireTime);
    }
}