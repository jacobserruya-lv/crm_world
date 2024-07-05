@isTest
private class IC_DeleteTransactions_Batch_TEST {
	static testMethod void testBatch() {

		ID batchprocessid;
		
		insert new ICONSettings__c (SetupOwnerId = Userinfo.getOrganizationId(), Param_DeleteTransaction_batch__c = '2013-10-26T00:00:00.000+0000');
		System.debug('####'+ICONSettings__c.getOrgDefaults());
		Account acc = IC_TestFactory.createAccount();
        insert acc;	
        PPR_PurchProduct__c p =  IC_TestFactory.createPurchaseProduct(acc.Id);	
        insert p;		
		
		IC_DeleteTransactions_Batch myBatch = new IC_DeleteTransactions_Batch();
		
		Test.startTest();
		batchprocessid = Database.executeBatch(myBatch,1000);
		Test.stopTest();
		
		List<PPR_PurchProduct__c> lst = [SELECT Id FROM PPR_PurchProduct__c WHERE Id = :p.Id];
		System.assertequals(lst.size(), 0);
	}
}