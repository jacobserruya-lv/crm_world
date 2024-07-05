@isTest
private class IC_FixProspectOwnerCheckboxBatch_Test {
	static testMethod void testBatch() {
		ID batchprocessid;

		User user = IC_TestFactory.createUser('AmiramTest12@test.com');
		user.IsTechnicalUser__c = false;
		user.profileId = IC_UTILS.getSAProfile();
		insert user;

		Account a = IC_TestFactory.createAccount();
		a.IsProspect__pc = true;
		a.OwnerId = user.Id;
		a.CreatedDate = System.now().addDays(-500);
	  	insert a;

		//Test.startTest();
		IC_FixProspectOwnerCheckboxBatch bat = new IC_FixProspectOwnerCheckboxBatch();	
        batchprocessid=Database.executeBatch(bat);
		//Database.executeBatch(new IC_FixProspectOwnerCheckboxBatch(),200);
		//Test.stopTest();
	}
}