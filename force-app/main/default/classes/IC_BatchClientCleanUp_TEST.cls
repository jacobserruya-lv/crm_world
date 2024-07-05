@isTest
private class IC_BatchClientCleanUp_TEST {

 static testMethod void testBatch() {
        
        Event__c evt;
        Program__c prg;
        
        insert new ICONSettings__c (accountPurgeLimit__c=18, ProspectClientPurge__c=1);
        ID batchprocessid;
        
        Account acc = IC_TestFactory.createAccount();
        acc.DREAMID__c = '123456';
        acc.LastTrans__pc = Date.today().addMonths(-20);
        acc.Jacket__pc = 'Jacket';
        insert acc;             
        
        /**
        //Create new STAR Event ('Event__c' Object ). It will be used when STAR Program is created
        evt = new Event__c();
        evt.Name='EventTest';
        evt.Start_Date__c =Date.today();
        evt.End_Date__c =Date.today();      
        evt.Location__c='PariSelecs';
        evt.Theme__c='Art & Culture';
        evt.Type__c='Exhibition';
        
        insert evt;
        
        //Create new Program
        prg = New Program__c();
        prg.name='ProgramTest';
        prg.AccountId__c = acc.Id;
        prg.EventId__c = evt.id;
        //prgView.IdProgram= prg.id; 
        insert prg;
        
        **/
        IC_BatchClientCleanUp myBatch = new IC_BatchClientCleanUp();
        
        Test.startTest();
        batchprocessid = Database.executeBatch(myBatch,1000);
        Test.stopTest();
        
        List<CleanUpLog__c> lst = [SELECT Id,IdSFDCAccount__c FROM CleanUpLog__c WHERE IdSFDCAccount__c = :acc.Id];
        
        System.debug('#### lst.size()' + lst.size());

        
    }

}