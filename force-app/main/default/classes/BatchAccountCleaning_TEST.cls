@isTest
private class BatchAccountCleaning_TEST {

    static testMethod void testBatch() {

        ID batchprocessid;
        
        Account acc = IC_TestFactory.createAccount();
        acc.PersonEmail = 'a.a@a.com';
        insert acc;             
        
        /**Bernard's version*/ 
        Test.startTest();
        BatchAccountCleaning myBatch = new BatchAccountCleaning( acc.id, '');
        Database.executeBatch(myBatch);
        List<Account> lst = [SELECT PersonHomePhone,PersonMobilePhone,Phone,PersonEmail,lastmodifieddate FROM Account WHERE Id = :acc.Id];
        Test.stopTest();
        
        
        
        /**OLD VERSION
        Test.startTest();
        BatchAccountCleaning myBatch = new BatchAccountCleaning();
        batchprocessid = Database.executeBatch(myBatch,1000);
        Test.stopTest();
        
        List<Account> lst = [SELECT PersonHomePhone,PersonMobilePhone,Phone,PersonEmail FROM Account WHERE Id = :acc.Id];
        
        */
        
        //System.assertequals(lst[0].PersonHomePhone, System.Label.IC_AnonymousPhone);
        //System.assertequals(lst[0].PersonMobilePhone, System.Label.IC_AnonymousPhone);
        //System.assertequals(lst[0].Phone, System.Label.IC_AnonymousPhone);
        //System.assertequals(lst[0].PersonEmail, System.Label.IC_AnonymousEmail);
      
    }
}