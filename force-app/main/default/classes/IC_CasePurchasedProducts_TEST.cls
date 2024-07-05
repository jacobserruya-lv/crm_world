@isTest
public class IC_CasePurchasedProducts_TEST {
    
    @isTest static void Test_FindPurchasedProductDB() {

		/* NORMAL TEST */

		// Create an account
        
		Account acc 			= IC_TestFactory.createAccount();
		insert acc;
        
        // Create purchsed product linked to above account
		PPR_PurchProduct__c pp 	= IC_TestFactory.createPurchaseProduct(acc.Id);
		insert pp;

		// Create a Case 
		Case cse 				= IC_TestFactory.createCase(acc, pp);
		insert cse;

		Case c 				=  [Select Id From Case Where Id =:cse.Id Limit 1];
		String caseId 			= String.valueOf(c.Id);
		System.debug('This is eventId in Normal Test Scenario :' + caseId);
		
		// Check if the method return the correct purchsed product, the purchased product should be 1
		Test.startTest();
		List<IC_CasePurchasedProducts.TransactionWrapper> products = IC_CasePurchasedProducts.FindPurchasedProductDB(caseId);
		Test.stopTest();
		System.assertEquals(1,products.size());

	}

	@isTest static void Test_Negative_FindPurchasedProductDB(){
		/* NEGATIVE TEST CREATE EVENT AND LINKED TO ACCOUNT WITHOUT PURCHASED PRODUCT*/

		// Create an account
		Account acc2 			= IC_TestFactory.createAccount();
		insert acc2;
		System.debug(' This is account 2 in negative test: ' + acc2);

		// Create a case 
		Case cse2 				= IC_TestFactory.createCase(acc2);
		insert cse2;
		System.debug(' This is event 2 in negative test: ' + cse2);

		// Queryt Event and pass to method to do assertion
		Case c2 				=  [Select Id,PprLinked__c From Case Where Id =:cse2.Id Limit 1];
		System.debug('This is even2 in negative test :' + c2);
		String caseId2 		= String.valueOf(c2.Id);
		System.debug('This is eventId after String Method in Negative test scenario :' + caseId2);
		
		// Check if the method return the correct purchsed product, this negative test should return nothing
		Test.startTest();
		List<IC_CasePurchasedProducts.TransactionWrapper> products2 = IC_CasePurchasedProducts.FindPurchasedProductDB(caseId2);
		Test.stopTest();
		System.debug('This is products 2 in negative test :' + products2);
		System.assertEquals(0,products2.size());
	}
	
	@isTest static void Test_updatePurchasedProductOnEvent() {
		/* NORMAL TEST */

		// Create an account
		Account acc 				= IC_TestFactory.createAccount();
		insert acc;
        
        // Create purchased product linked to above account
		PPR_PurchProduct__c pp 		= IC_TestFactory.createPurchaseProduct(acc.Id);
		insert pp;

		// Create a Case 
		Case cse 					= IC_TestFactory.createCase(acc);
		insert cse;

		// Query case to pass its id to method
		Case c 					=  [SELECT Id, PprLinked__c, Transaction_Id__c  FROM Case Where Id =:cse.Id Limit 1];
        String caseId 				= String.valueOf(c.Id);
        String ppId					= String.valueOf(c.PprLinked__c);
		System.assertEquals(null,c.PprLinked__c);
        System.assertEquals(null,c.Transaction_Id__c);
		System.debug('This is caseId from IC_CasePurchasedProducts_Test :' + caseId);

		// Query purchased product to pass to method
		PPR_PurchProduct__c product = [Select Id, OrderATGId__c From PPR_PurchProduct__c Where Id = :pp.Id Limit 1];
		String 		productId		= String.valueOf(product.Id);
        String		tId				= String.valueOf(product.OrderATGId__c);
        System.assertNotEquals(null,product.OrderATGId__c);
		System.debug('This is purchased product Id in second test method :' + product.Id); 

		// Check if the method return the correct purchsed product, the purchased product should be 1
		Test.startTest();
		IC_CasePurchasedProducts.updatePurchasedProductOnEvent(caseId, tId, productId);
		Test.stopTest();
		Case c2 					=  [SELECT Id, PprLinked__c, Transaction_Id__c FROM Case Where Id =:cse.Id Limit 1];
		System.assertEquals(pp.Id,c2.PprLinked__c);
        System.assertEquals(pp.OrderATGId__c,c2.Transaction_Id__c);
        
        
       // PPR_PurchProduct__c pp2 		= IC_TestFactory.createPurchaseProduct(acc.Id);
       // pp2.TransactionTotalAmount__c = null;
		//insert pp2;
        
        //PPR_PurchProduct__c product2 = [Select Id, TransactionTotalAmount__c From PPR_PurchProduct__c Where Id = :pp2.Id Limit 1];
        //String totalAmount = pp2.TransactionTotalAmount__c.format();
			
        //System.assertEquals('Missing Values',pp2.TransactionTotalAmount__c.format());
        
	}
	

}