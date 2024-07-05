@isTest
private class IC_SchedulerBatchClientCleanUp_TEST {

        static testMethod void testBatch() {
        	
        insert new ICONSettings__c (accountPurgeLimit__c=18);
        
        Account acc = IC_TestFactory.createAccount();
        acc.DREAMID__c = '123456';
        acc.LastTrans__pc = Date.today().addMonths(-20);
        insert acc;  
           
        IC_SchedulerBatchClientCleanUp myScheduler = new IC_SchedulerBatchClientCleanUp();
        
        Test.startTest();
        String sch = '0 0 23 L * ?';
        system.schedule('Test check', sch, myScheduler);
        Test.stopTest();
        

    }

}