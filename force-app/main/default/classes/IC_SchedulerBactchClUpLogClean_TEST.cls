@isTest
private class IC_SchedulerBactchClUpLogClean_TEST {

        static testMethod void testBatch() {
        	
        Account Acc = IC_TestFactory.createAccount();
        Acc.DREAMID__c = '123456';
        insert Acc; 
        
        CleanUpLog__c Clu = new CleanUpLog__c();
        Clu.DreamIdClient__c =Acc.DREAMID__c;
        Clu.IdSFDCAccount__c =Acc.Id;
        insert Clu;   
           
        IC_SchedulerBactchClUpLogClean myScheduler = new IC_SchedulerBactchClUpLogClean();
        
        Test.startTest();
        String sch = '0 0 23 L * ?';
        system.schedule('Test check', sch, myScheduler);
        Test.stopTest();

    }

}