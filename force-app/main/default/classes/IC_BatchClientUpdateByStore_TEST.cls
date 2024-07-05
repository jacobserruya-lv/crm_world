@isTest
private class IC_BatchClientUpdateByStore_TEST {

    @TestSetup
    public static void setup() {
        String identityProfile = [SELECT Id FROM Profile WHERE Name = 'Identity User'][0].Id;
        insert new IC_Config__c(
            Name = 'Identity User',
            Value__c = identityProfile
        );
    }

    static testMethod void testBatch() {

        ID batchprocessid;
        List<String> lstStore = new List<String>();
        
        Account acc = IC_TestFactory.createAccount();
        acc.AttachedStore__pc = 'LV Paris';
        acc.TECH_DreamIdSA__pc = '123456';
        insert acc;             
        
        
        User usr = IC_TestFactory.createUser('TestLVBacth@lvtest.com');
        usr.profileId = IC_UTILS.getSAProfile();
        usr.DefaultStore__c = 'LV Paris';
        usr.DREAMID__C='123456';
        insert usr;
        
        lstStore.add('LV Paris');
        lstStore.add('LV Other Country');
        
        IC_BatchClientUpdateByStore myBatch = new IC_BatchClientUpdateByStore(lstStore);
        
        Test.startTest();
        batchprocessid = Database.executeBatch(myBatch,1000);
        Test.stopTest();
        
        List<Account> lst = [SELECT OwnerId, AttachedStore__pc FROM Account WHERE Id = :acc.Id];
        //System.assertequals(lst[0].OwnerId, usr.Id);
    }
}