@isTest
private class BatchPurgeTask_Scheduler_Test {
    
    @isTest
    static void TestBatchPurgeTask_Scheduler(){
        
        Test.startTest();
        String cronExpression = '0 0 1 * * ?'; 
        BatchPurgeTask_Scheduler scheduler = new BatchPurgeTask_Scheduler();
        String jobId = System.schedule('Test Task Cleaner Batch Scheduler', cronExpression, scheduler);

        CronTrigger cronTrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];
        Test.stopTest();
        System.assertNotEquals(null, cronTrigger.NextFireTime,'test scheduler');
    }
}