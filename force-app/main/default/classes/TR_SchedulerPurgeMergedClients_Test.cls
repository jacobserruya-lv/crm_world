@isTest

private class TR_SchedulerPurgeMergedClients_Test {
    
@isTest
 static void test_ScheduleBatch() {
        Account a = IC_TestFactory.createAccount();
        insert a;
        Transverse_Batchs_Setup__c setting = new Transverse_Batchs_Setup__c();
        setting.name = 'Batch Merge Clients';
        setting.Created_Before_Days__c =-2;
        setting.Limit__c = '100000';
        insert setting;
     a.DreamId__c='123232';
     update a;
        MergedClients__c send = new MergedClients__c();
    send.Absorbed_DreamId__c='123232';
        insert send;
       
        Test.startTest();
        String cron = '0 0 23 * * ?';
        TR_SchedulerPurgeMergedClients schd = new TR_SchedulerPurgeMergedClients();
        String jobId = System.schedule('test schedule relate transaction to messaging', cron, schd);
        schd.execute(null);
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        Test.stopTest();
        System.assertNotEquals(Null, ct.NextFireTime);
    }
}