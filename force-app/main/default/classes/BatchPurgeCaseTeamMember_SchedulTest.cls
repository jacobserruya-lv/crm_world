@isTest
private class BatchPurgeCaseTeamMember_SchedulTest {
    
    @isTest 
    static void test_scheduleBatchPurgeCaseTeamMember() {
        
        Test.startTest();
        
        String cronExpression = '0 0 1 * * ?'; 
        BatchPurgeCaseTeamMember_Scheduler scheduler = new BatchPurgeCaseTeamMember_Scheduler();
        String jobId = System.schedule('Test Case Team Member Cleaner Batch Scheduler', cronExpression, scheduler);

        
        CronTrigger cronTrigger = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobId];

        Test.stopTest();
        System.assertNotEquals(null, cronTrigger.NextFireTime);
    }
}