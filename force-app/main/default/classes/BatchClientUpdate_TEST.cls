@isTest
private class BatchClientUpdate_TEST {

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
		List<String> lstSADreamId = new List<String>();
		
		Account acc = IC_TestFactory.createAccount();
		acc.TECH_DreamIdSA__pc = '123456';
        insert acc;				
		
		User usr = IC_TestFactory.createUser('TestLVBacthCLCreation@lvtest.com');
		usr.profileId = IC_UTILS.getSAProfile();
		usr.DREAMID__C='123456';
		insert usr;
		
		lstSADreamId.add('123456');
		lstSADreamId.add('654321');
		
		BatchClientUpdate myBatch = new BatchClientUpdate(lstSADreamId);
		
		Test.startTest();
		batchprocessid = Database.executeBatch(myBatch,1000);
		Test.stopTest();
		
		List<Account> lst = [SELECT OwnerId FROM Account WHERE Id = :acc.Id];
		//System.assertequals(lst[0].OwnerId, usr.Id);
	}

}