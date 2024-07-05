@isTest
public class BatchAccountSelectForPurge_TEST {
    static testMethod void myUnitTest() {
        // TO DO: implement unit test

        CLI_CliList__c clientList = IC_TestFactory.clientlistMembers();
        insert clientList;
        User u = IC_TestFactory.createUser('D1MIntegration@gmail.com',UserInfo.getProfileId());
        u.lastName='D1MIntegration1234';
        u.userName = 'd1mIntegration1234@lv.com';
        u.firstName='';
        insert u;
        Account compte ;
        system.runAs(u){
            compte = IC_testFactory.createAccount();
            compte.ToDelete__c = '';
            compte.DreamIdMasterClient__c = null;
            insert compte ;
        }

        Id idmin = compte.Id;
        Id idmax = compte.Id;

        Test.startTest();
        BatchAccountSelectForPurge myBatch = new BatchAccountSelectForPurge(idmin, idmax, 0);
        Id batchprocessid = Database.executeBatch(myBatch,1);
        Test.stopTest();

        //List<Account> lstCompte = [Select Id, ToDelete__c From Account Where Id = :compte.Id];
        //System.assertequals(lstCompte[0].ToDelete__c,'1');
    }
}