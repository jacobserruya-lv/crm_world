@isTest
private class ICX_RelateTransactionToOutboundCall_TEST {
	
	@testSetup 
	static void TransactionCallsCreation() {
		Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ACC_PersonAccount').getRecordTypeId();
		
        Account client = new Account();
		client.LastName ='Test Client';
		client.RecordTypeId = personAccountRTId;
		insert client;
        
		//Create products
		List<ProductCatalogue__c> products = new List<ProductCatalogue__c>();

		ProductCatalogue__c product1 = new ProductCatalogue__c(SKU__c='TEST');
		products.add(product1);
        

		insert products;
		Datetime yesterday = Datetime.now().addDays(-2);
		
		//Create calls
		List<Task> calls = new List<Task>();

        Task call1 = createCall();
        call1.WhatId  = client.Id;
        call1.Transaction_Id__c = '1000';
		calls.add(call1);

        Task call2 = createCall();
        call2.Product_Sku__c = product1.Id;
        call2.Transaction_Id__c = '111';
		calls.add(call2);
        

		insert calls;

		//Create transactions
		List<PPR_PurchProduct__c> transactions = new List<PPR_PurchProduct__c>();

        PPR_PurchProduct__c purchasedProduct1 = createPurchasedProduct();
        purchasedProduct1.Client__c = client.Id;
        purchasedProduct1.TicketNumber__c = '888888888';
		transactions.add(purchasedProduct1);
        
        PPR_PurchProduct__c purchasedProduct2 = createPurchasedProduct();
        purchasedProduct2.TransactionRMSId__c = '111';
        purchasedProduct2.SKU__c = 'TEST';
        purchasedProduct2.Client__c = client.Id;
        purchasedProduct2.TicketNumber__c = '999999999';
		transactions.add(purchasedProduct2);


		insert transactions;
        Test.setCreatedDate(purchasedProduct1.Id, yesterday);
		Test.setCreatedDate(purchasedProduct2.Id, yesterday);
	}
	
	@isTest static void executeBatch() {
		Test.startTest();
		Id batchId = Database.executeBatch(new ICX_RelateTransactionToOutboundCall());
        Test.stopTest();
        Account testClient = [SELECT Id FROM Account WHERE LastName = 'Test Client'];

        PPR_PurchProduct__c ppr1 = [SELECT Id FROM PPR_PurchProduct__c WHERE Client__c =: testClient.Id and TicketNumber__c = '888888888'];
        Task call1 = [SELECT Id,Purchased_Product__c,AccountId, Transaction_Id__c FROM Task WHERE WhatId =: testClient.Id and Transaction_Id__c = '1000' limit 1];
		System.assertEquals(ppr1.Id, call1.Purchased_Product__c);

		PPR_PurchProduct__c ppr2 = [SELECT Id FROM PPR_PurchProduct__c WHERE SKU__c='TEST'];
		Task call2 = [SELECT Id,Purchased_Product__c,AccountId FROM Task WHERE Sku_Number__c='TEST' limit 1];
		System.assertEquals(ppr2.Id, call2.Purchased_Product__c);
	}
    private static PPR_PurchProduct__c createPurchasedProduct(){
        
        PPR_PurchProduct__c purchasedProduct = new PPR_PurchProduct__c();
		purchasedProduct.Store__c = 'T11';
		purchasedProduct.TransactionStoreType__c='CSC';
		purchasedProduct.PurchasedDate__c = Date.today().addDays(2);
        purchasedProduct.Quantity__c = 1;
        
        return purchasedProduct;
    }

    //Create TASK
    private static Task createCall(){
        Id CallRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSC_Call').getRecordTypeId();
        Task call = new Task();
        call.RecordTypeId=CallRecordTypeId;
        call.CallType = 'Outbound';
        
        return call;
    }
	
}