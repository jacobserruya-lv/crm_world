@isTest
private class IC_SchedulerClientAnonymization_TEST {

    static testMethod void myUnitTest() {
        
        ID batchprocessid;
        
        CLI_CliList__c clientList = IC_TestFactory.clientlistMembers();
        insert clientList;
        
        Account compte = IC_testFactory.createAccount();
        compte.ToDelete__c = '1';
        compte.DreamIdMasterClient__c = null;
        insert compte;
        
        Contact contact = [Select Id From Contact WHERE accountId = :compte.Id limit 1];
        
        CLM_CliListMember__c clm = new CLM_CliListMember__c(ClientList__c = clientList.Id, Client__c = contact.Id);
        insert clm;
        
        ICONSettings__c stt = new ICONSettings__c();
        stt.clientAnonymizationLimit__c = 100;
        stt.batchAnonymizationScope__c = 100;
        insert stt;
        
        IC_SchedulerClientAnonymization myScheduler = new IC_SchedulerClientAnonymization();
        
        Test.startTest();
        String sch = '0 0 23 L * ?';
        system.schedule('Test check', sch, myScheduler);
        Test.stopTest();
        
        
        
    }
}