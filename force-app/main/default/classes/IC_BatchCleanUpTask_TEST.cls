@isTest
private class IC_BatchCleanUpTask_TEST {
    
 static testMethod void testBatch() {
    
        insert new ICONSettings__c (accountPurgeLimit__c=18, taskPurgeMaxLimit__c=6, taskPurgeMinLimit__c=1, AccLastContactTimeRange__c=30);
        ID batchprocessid; 
        
        Task t1 = IC_TestFactory.createTask();
        t1.Channel__c = 'Emailing';
        t1.DREAMID__c = 'CRM_XXXX';
        t1.ActivityDate = Date.today().addMonths(-20);
        insert t1;
        
        Task t2 = IC_TestFactory.createTask();
        t2.ActionType__c = 'oki';
        t2.ActivityDate = Date.today().addMonths(-2);
        insert t2;
        
        IC_BatchCleanUpTask myBatch = new IC_BatchCleanUpTask();
        
        Test.startTest();
        batchprocessid = Database.executeBatch(myBatch,1000);
        Test.stopTest();
        
        List<Task> lst = [SELECT Id FROM Task];
        System.assertequals(lst.size(), 1);
        
    }
    
}