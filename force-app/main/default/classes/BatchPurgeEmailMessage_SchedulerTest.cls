@isTest
private class BatchPurgeEmailMessage_SchedulerTest {
    
    @isTest
    static void test_scheduleBatchPurgeEmailMessage(){
        
        Test.startTest();
        String cronExpression = '0 0 1 * * ?'; 
        BatchPurgeEmailMessage_Scheduler scheduler = new BatchPurgeEmailMessage_Scheduler();
        String jobId = System.schedule('Test Email Messages Cleaner Batch Scheduler', cronExpression, scheduler);

        CronTrigger cronTrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        Test.stopTest();
        System.assertNotEquals(null, cronTrigger.NextFireTime);
    }
}