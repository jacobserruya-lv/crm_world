@isTest
private class BatchClientListsCreation_TEST {

	static testMethod void testBatch() {

		ID batchprocessid;
		
		User usr = IC_TestFactory.createUser('TestLVBacthCLCreation@lvtest.com');
		usr.profileId = IC_UTILS.getSAProfile();
		insert usr;
		User usr2 = IC_TestFactory.createUser('Test2LVBacthCLCreation@lvtest.com');
		usr2.profileId = IC_UTILS.getSAProfile();
		insert usr2;
		
		List<Id> lstUsersId = new List<Id>();
		lstUsersId.add(usr.Id);
		lstUsersId.add(usr2.Id);
		List<String> lstCLName = new List<String>();
		lstCLName.add('List1');
		lstCLName.add('List2');
		
		BatchClientListsCreation myBatch = new BatchClientListsCreation(lstUsersId, lstCLName);
		
		Test.startTest();
		batchprocessid = Database.executeBatch(myBatch,50);
		Test.stopTest();
		
		List<CLI_CliList__c> lst = [SELECT Id FROM CLI_CliList__c WHERE OwnerId = :usr.Id OR OwnerId = :usr2.Id];
		System.assertequals(4, lst.size());
	}
	
}