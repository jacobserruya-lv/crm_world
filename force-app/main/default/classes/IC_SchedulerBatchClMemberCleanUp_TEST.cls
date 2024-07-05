@isTest
private class IC_SchedulerBatchClMemberCleanUp_TEST {

        static testMethod void testBatch() {
        	
        CLI_CliList__c cl = IC_TestFactory.clientlistMembers();
        insert cl;
        CLM_CliListMember__c Clm = new CLM_CliListMember__c();
        Clm.Client__c = null;
        Clm.ClientList__c = Cl.Id;
        insert Clm;             
         
           
        IC_SchedulerBatchClMemberCleanUp myScheduler = new IC_SchedulerBatchClMemberCleanUp();
        
        Test.startTest();
        String sch = '0 0 23 L * ?';
        system.schedule('Test check', sch, myScheduler);
        Test.stopTest();


    }

}