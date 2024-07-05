@isTest
private class CampaignHistoryCleanerBatch_SchedulTest {
    
    @isTest 
    static void test_scheduleCampaignHistoryCleanerBatch() {
        
        Test.startTest();
        
        String cronExpression = '0 0 1 * * ?'; 
        CampaignHistoryCleanerBatch_Scheduler scheduler = new CampaignHistoryCleanerBatch_Scheduler();
        String jobId = System.schedule('Test Campaign History Cleaner Batch Scheduler', cronExpression, scheduler);

        // Get the information from the CronTrigger API object
        CronTrigger cronTrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];

        Test.stopTest();

        // Assert that the NextFireTime is not null, indicating a successful scheduling
        System.assertNotEquals(null, cronTrigger.NextFireTime);
    }
}