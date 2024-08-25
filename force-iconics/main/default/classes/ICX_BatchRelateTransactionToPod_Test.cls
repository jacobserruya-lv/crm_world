@isTest
private class ICX_BatchRelateTransactionToPod_Test {

	@testSetup 
	static void TransactionCasesCreation() {
		Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ACC_PersonAccount').getRecordTypeId();
		Id podRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Product_On_Demand_with_sku').getRecordTypeId();

		Store__c store = new Store__c(Name='test store', RetailStoreId__c='T11');
        Store__c store2 = new Store__c(Name='test store2', RetailStoreId__c='T12');
		insert new list<Store__c>{store,store2};

		ProductCatalogue__c product = new ProductCatalogue__c(SKU__c='TST123');
        ProductCatalogue__c product2 = new ProductCatalogue__c(SKU__c='AT0123');
      	insert new list<ProductCatalogue__c>{product,product2};

		Account client = new Account();
		client.LastName ='Test Client';
		client.RecordTypeId = personAccountRTId;
       
        Account client2 = new Account();
		client2.LastName ='Test Client2';
		client2.RecordTypeId = personAccountRTId;
		insert new list<Account>{client,client2};

		Case pod = new Case();
		pod.RecordTypeId = podRecordTypeId;
		pod.AccountId = client.Id;
		pod.Product_Sku__c = product.Id;
		pod.Store__c = store.Id;
        
        Case pod2 = new Case();
		pod2.RecordTypeId = podRecordTypeId;
		pod2.AccountId = client2.Id;
		pod2.Product_Sku__c = product2.Id;
		pod2.Store__c = store2.Id;
        pod2.Transaction_Id__c='123';        
        pod2.Status='New';
        insert new list<Case>{pod,pod2};

		PPR_PurchProduct__c purchasedProduct = new PPR_PurchProduct__c();
		purchasedProduct.Client__c = client.Id;
        purchasedProduct.SKU__c = 'TST123';
		purchasedProduct.Store__c = 'T11';
		purchasedProduct.PurchasedDate__c = Date.today().addDays(1);
		purchasedProduct.TicketNumber__c = '123456';
		purchasedProduct.Quantity__c = 1;
       
        PPR_PurchProduct__c purchasedProduct2 = new PPR_PurchProduct__c();
		purchasedProduct2.Client__c = client2.Id;
        purchasedProduct2.RMSSKUCode__c = 'AT0123';
		purchasedProduct2.SKU__c = 'abc12345681';
		purchasedProduct2.Store__c = 'T12';
		purchasedProduct2.PurchasedDate__c = Date.today().addDays(1);
		purchasedProduct2.TicketNumber__c = '123';
        purchasedProduct2.TransactionRMSId__c='123';
        purchasedProduct2.OrderATGId__c='123';
		purchasedProduct2.Quantity__c = 1;
        insert new list<PPR_PurchProduct__c>{purchasedProduct,purchasedProduct2};
	}
	
	@isTest 
	static void TransactionMatchingTest() {
		Test.startTest();
		Id batchId = Database.executeBatch(new ICX_BatchRelateTransactionToPod(),2);
		Test.stopTest();

		Case pod = [SELECT Id,PurchasedProduct__c,AccountId,Store__c FROM Case limit 1];
		System.assertNotEquals(null, pod.PurchasedProduct__c);
	}
    

}