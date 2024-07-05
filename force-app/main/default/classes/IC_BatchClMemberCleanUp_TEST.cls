@isTest
private class IC_BatchClMemberCleanUp_TEST {

 static testMethod void testBatch() {

        ID batchprocessid;
        CLI_CliList__c cl = IC_TestFactory.clientlistMembers();
        insert cl;
        CLM_CliListMember__c Clm = new CLM_CliListMember__c();
        Clm.Client__c = null;
        Clm.ClientList__c = Cl.Id;
        insert Clm;             
        

        IC_BatchClMemberCleanUp myBatch = new IC_BatchClMemberCleanUp();
        
        Test.startTest();
        batchprocessid = Database.executeBatch(myBatch,1000);
        Test.stopTest();
        
        List<CLM_CliListMember__c> lst = [SELECT Id FROM CLM_CliListMember__c WHERE Id = :Clm.Id];
        System.assertequals(lst.size(), 0);
        
    }

}