@isTest
private class IC_RefreshYTD_Batch_TEST {

	static testMethod void testBatch() {

		ID batchprocessid;
		
		User testUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_SYSTEM_ADMINNISTRATOR);
        testUser.BypassVR__c = true;
        testUser.Country__c = 'FRANCE';
        insert testUser;

		Account acc = IC_TestFactory.createAccount();
		acc.YTDJewelryNbrProducts__pc = 100;
		insert acc;

		PPR_PurchProduct__c pp=new PPR_PurchProduct__c();
		pp.PurchasedDate__c =Date.valueof('2021-11-01');
		pp.Client__c = acc.ID;
		pp.TicketNumber__c='1234';
		insert pp;
		
		 System.runAs(testUser) {
			acc.YTDJewelryNbrProducts__pc = 100;
			update acc;
		 }
		
		IC_RefreshYTD_Batch myBatch = new IC_RefreshYTD_Batch();
		
		Test.startTest();
		batchprocessid = Database.executeBatch(myBatch,1000);
		Test.stopTest();
		
		List<Account> lst = [SELECT YTDShoesSpendEUR__pc,YTDJewelryNbrProducts__pc,YTDSpendEUR__pc,YTDWatchSpendYEN__pc FROM Account WHERE Id = :acc.Id];
		System.assertequals(lst[0].YTDShoesSpendEUR__pc, 0);
		System.assertequals(lst[0].YTDJewelryNbrProducts__pc, 0);
		System.assertequals(lst[0].YTDSpendEUR__pc, 0);
		System.assertequals(lst[0].YTDWatchSpendYEN__pc, 0);
	}
}