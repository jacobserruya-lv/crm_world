@isTest
global class IDENTITY_UserManagement_BATCH_TEST {

    @isTest static void testBatch() {

        ID batchprocessid;  
        
        Identity_TestFactory.createSettings();
        Account acc = Identity_TestFactory.createAccount('ya', 'test', 'yaelg@test.com', '+972549876543', '', true);
        User user = IDENTITY_Utils.createMylvClient(acc, 'Balink123*');
        
        IDENTITY_UserManagement_BATCH myBatch = new IDENTITY_UserManagement_BATCH();
        
        Test.startTest();
        batchprocessid = Database.executeBatch(myBatch,1000);
        Test.stopTest();
        
        //LastLoginDate can't be updated manually so this condition is left out of the test
    }




}