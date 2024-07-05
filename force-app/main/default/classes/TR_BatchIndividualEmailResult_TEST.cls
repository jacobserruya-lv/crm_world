@isTest
private class TR_BatchIndividualEmailResult_TEST{
    
    @isTest static void test_ScheduleBatch() {
        Account a = IC_TestFactory.createAccount();
        insert a;
        Transverse_Batchs_Setup__c setting = new Transverse_Batchs_Setup__c();
        setting.name = 'Batch Indiv Email Result Purge Setup';
        setting.Created_Before_Days__c = -2;
        setting.Limit__c = '100000';
        insert setting;
        et4ae5__SendDefinition__c send = new et4ae5__SendDefinition__c();
        insert send;
        et4ae5__IndividualEmailResult__c emailResult = new et4ae5__IndividualEmailResult__c();  
        emailResult.et4ae5__SendDefinition__c = send.id;
        insert emailResult;
        Test.startTest();
        String cron = '0 0 23 * * ?';
        TR_SchedulerIndividualEmailResultPurge schd = new TR_SchedulerIndividualEmailResultPurge();
        String jobId = System.schedule('test schedule relate transaction to messaging', cron, schd);
        schd.execute(null);
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        Test.stopTest();
        System.assertNotEquals(Null, ct.NextFireTime);
    }
    
}