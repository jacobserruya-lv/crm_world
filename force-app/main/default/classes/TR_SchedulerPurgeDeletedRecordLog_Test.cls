@isTest

private class TR_SchedulerPurgeDeletedRecordLog_Test {
@isTest
 static void test_ScheduleBatch() {
        Account a = IC_TestFactory.createAccount();
        insert a;
        Transverse_Batchs_Setup__c setting = new Transverse_Batchs_Setup__c();
        setting.name = 'Batch Deleted record logs';
        setting.Created_Before_Days__c =-2;
        setting.Limit__c = '100000';
        insert setting;
     a.DreamId__c='123232';
     update a;
        Deleted_record_log__c send = new Deleted_record_log__c();
     send.Object_type__c='Account';
     send.ObjectId__c=a.id;

        insert send;
       
        Test.startTest();
        String cron = '0 0 23 * * ?';
        TR_SchedulerPurgeDeletedRecordLog schd = new TR_SchedulerPurgeDeletedRecordLog();
        String jobId = System.schedule('test schedule relate transaction to messaging', cron, schd);
        schd.execute(null);
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];
        
        Test.stopTest();
        System.assertNotEquals(Null, ct.NextFireTime);
    }
}