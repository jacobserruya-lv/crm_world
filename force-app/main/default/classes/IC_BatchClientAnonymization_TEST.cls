@isTest
private class IC_BatchClientAnonymization_TEST {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test

        CLI_CliList__c clientList = IC_TestFactory.clientlistMembers();
        insert clientList;
        User u = IC_TestFactory.createUser('D1MIntegration@gmail.com',UserInfo.getProfileId());
        u.lastName='D1M Integration';
        u.firstName='';
        insert u;
        Account compte ;
        system.runAs(u){
          compte = IC_testFactory.createAccount();
          compte.ToDelete__c = '1';
          compte.DreamIdMasterClient__c = null;
          insert compte ;
        }

        ICONSettings__c stt = new ICONSettings__c();
      	stt.ClientAnonymizationLimit__c = 100;
      	stt.ClientAnonymizationDaysLimit__c = 0;
      	insert stt;

      	Test.startTest();
        IC_BatchClientAnonymization myBatch = new IC_BatchClientAnonymization();
        Id batchprocessid = Database.executeBatch(myBatch,10);
        Test.stopTest();

        List<Account> lstCompte = [Select Id From Account Where Id = :compte.Id];
        System.assertequals(lstCompte.size(),0);
    }
}