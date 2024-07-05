@isTest
private class IC_BatchClUpLogCleanUp_TEST {

 static testMethod void testBatch() {

        ID batchprocessid; 
              
        Account Acc = IC_TestFactory.createAccount();
        Acc.DREAMID__c = '123456';
        insert Acc; 
        
        CleanUpLog__c Clu = new CleanUpLog__c();
        Clu.DreamIdClient__c =Acc.DREAMID__c;
        Clu.IdSFDCAccount__c =Acc.Id;
        insert Clu;             
        

        IC_BatchClUpLogCleanUp myBatch = new IC_BatchClUpLogCleanUp();
        
        Test.startTest();
        batchprocessid = Database.executeBatch(myBatch,1000);
        Test.stopTest();
        
        List<CleanUpLog__c> lst = [SELECT Id FROM CleanUpLog__c WHERE Id = :Clu.Id];
        System.assertequals(lst.size(), 0);
        
    }

}