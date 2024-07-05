@isTest
private class ICX_BAtchCleanInternalCallTasks_TEST {
    
 static testMethod void testBatch() {
      ID batchprocessid; 
        
        Task t1 = IC_TestFactory.createTask();
        t1.Channel__c = 'Emailing';
        t1.DREAMID__c = 'CRM_XXXX';
        t1.ActivityDate = Date.today().addMonths(-20);
        insert t1;
        
        Task t2 = IC_TestFactory.createTask();
        t2.ActionType__c = 'Phone';
        t2.Phone_Calling_Number__c='Internal';
        t2.Genesys_IsInternal__c='True';
        t2.ActivityDate = Date.today().addMonths(-2);
         Date v_today = Date.today();
         Date v_lastDate= v_today.addDays(-1);
         t2.CreatedDate = v_lastDate;
        insert t2;
        
        ICX_BatchCleanInternalCallTasks myBatch = new ICX_BatchCleanInternalCallTasks();
        
        Test.startTest();
        batchprocessid = Database.executeBatch(myBatch,1000);
        Test.stopTest();
        
        List<Task> lst = [SELECT Id FROM Task];
        System.assertequals(1, lst.size());
     
    
        
    }
    
        @isTest static void test_ICX_BatchCleanInternalCallTasksSchedule() {
        Test.startTest();
        String cron = '0 0 23 * * ?';
         ICX_BatchCleanInternalCallTasksSchedule schedule = new ICX_BatchCleanInternalCallTasksSchedule();
        String jobId = System.schedule('test schedule relate transaction to live chat', cron, schedule);

        // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                         FROM CronTrigger WHERE id = :jobId];
    
        Test.stopTest();
        System.assertNotEquals(Null, ct.NextFireTime);
    }
    
}