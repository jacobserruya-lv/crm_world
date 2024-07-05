@isTest
private class BatchScheduledClientLists_TEST {
	
	@isTest
	static void testBatch() {		

		ICON_Default_ClientList__c dcl = new ICON_Default_ClientList__c (Name='USA', DefautClientList__c = 'List1,List2,andsoon3');
		insert dcl;
		
		User usr = IC_TestFactory.createUser('TestLVBacthCLCreation@lvtest.com');
		usr.profileId = IC_UTILS.getSAProfile();
		usr.Country__c = 'USA';
		usr.Primary_App__c = 'Icon';
		usr.isActive = true;
		usr.IsTechnicalUser__c = false;
		insert usr;
		User usr2 = IC_TestFactory.createUser('Test2LVBacthCLCreation@lvtest.com');
		usr2.profileId = IC_UTILS.getSAManagerProfile();
		usr2.Country__c = 'USA';
		usr2.Primary_App__c = 'Icon';
		usr2.isActive = true;
		usr2.IsTechnicalUser__c = false;
		insert usr2;
		
		BatchScheduledClientLists myBatch = new BatchScheduledClientLists();
		
		Test.startTest();
		Database.executeBatch(myBatch,200);
		Test.stopTest();
		
		Integer nbListsToCreate = [SELECT DefautClientList__c FROM ICON_Default_ClientList__c WHERE Name = 'USA'].DefautClientList__c.split(',').size() * 2;
		Integer nbListsCreated = [SELECT Id FROM CLI_CliList__c WHERE OwnerId = :usr.Id OR OwnerId = :usr2.Id].size();
		System.assertequals(nbListsToCreate, nbListsCreated);
	}
	
}