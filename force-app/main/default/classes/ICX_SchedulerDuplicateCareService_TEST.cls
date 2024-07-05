/**
* @author Keman WU
* @date Creation 14/12/2021
* @description test class for ICX_SchedulerDuplicateCareService
*/
@isTest
public class ICX_SchedulerDuplicateCareService_TEST {
    @isTest static void testBehavior() {
        Test.startTest();
		String cron = '0 0 23 * * ?';
		ICX_SchedulerDuplicateCareService schd = new ICX_SchedulerDuplicateCareService();
		String jobId = System.schedule('cancelDuplicate CareService', cron, schd);

    // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                     FROM CronTrigger WHERE id = :jobId];

    Test.stopTest();
    System.assertNotEquals(Null, ct.NextFireTime);
    }
}