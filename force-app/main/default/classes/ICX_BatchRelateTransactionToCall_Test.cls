@isTest
private class ICX_BatchRelateTransactionToCall_Test {
	
	@testSetup 
	static void TransactionCallsCreation() {
		Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ACC_PersonAccount').getRecordTypeId();
		
        Account client = new Account();
		client.LastName ='Test Client';
		client.RecordTypeId = personAccountRTId;
		insert client;

		//Create products
		List<ProductCatalogue__c> products = new List<ProductCatalogue__c>();

		ProductCatalogue__c product1 = new ProductCatalogue__c(SKU__c='TST123');
		products.add(product1);

		ProductCatalogue__c product2 = new ProductCatalogue__c(SKU__c='TST321');
		products.add(product2);
        
        ProductCatalogue__c product3 = new ProductCatalogue__c(SKU__c='TST626');
		products.add(product3);
        
        ProductCatalogue__c product4 = new ProductCatalogue__c(SKU__c='TST1235');
		products.add(product4);

		insert products;
		Datetime yesterday = Datetime.now().addDays(-1);
		
		//Create  inbound calls
		List<Task> inboundCalls = new List<Task>();

		Task inboundCall1 = createCallInbound(client,product1,'');
		inboundCalls.add(inboundCall1);

		Task inboundCall2 = createCallInbound(client,product2,'Test1234L');
		inboundCalls.add(inboundCall2);
        
        // Task inboundCall3 = createCallInbound(client,product3,'');
        // inboundCalls.add(inboundCall3);
        
        // Task inboundCall4 = createCallInbound(null,product4,'nx12345');
		// inboundCalls.add(inboundCall4);

		insert inboundCalls;

		//Create outbound calls
		List<Task> outboundCalls = new List<Task>();

		// Task outboundCall1 = createCallOutbound(client,product1,'');
		// outboundCalls.add(outboundCall1);

		// Task outboundCall2 = createCallOutbound(client,product2,'Test1234L');
		// outboundCalls.add(outboundCall2);
		
		Task outboundCall3 = createCallOutbound(client,product3,'');
		outboundCalls.add(outboundCall3);
		
		Task outboundCall4 = createCallOutbound(null,product4,'nx12345');
		outboundCalls.add(outboundCall4);

		insert outboundCalls;

		//Create transactions
		List<PPR_PurchProduct__c> transactions = new List<PPR_PurchProduct__c>();

        PPR_PurchProduct__c purchasedProduct1 = createPurchasedProductCSC(client , 'TST123' ,'123456');
		transactions.add(purchasedProduct1);
        
        PPR_PurchProduct__c purchasedProduct2 = createPurchasedProductStore(client , 'TST321' ,'Test1234L');
        purchasedProduct2.OrderATGId__c = 'Test1234L';
		transactions.add(purchasedProduct2);
        
        PPR_PurchProduct__c purchasedProduct3 = createPurchasedProductWEB(client ,'TST888' ,'11123456');
		purchasedProduct3.RMSSKUCode__c = 'TST626';
		transactions.add(purchasedProduct3);
        
        PPR_PurchProduct__c purchasedProduct4 = createPurchasedProductStore(client ,'TST1235' ,'nx12345');
		purchasedProduct4.OrderATGId__c = 'nx12345';
        purchasedProduct4.RMSSKUCode__c = 'TST1235';
		transactions.add(purchasedProduct4);

		insert transactions;
        Test.setCreatedDate(purchasedProduct1.Id, yesterday);
		Test.setCreatedDate(purchasedProduct2.Id, yesterday);
		Test.setCreatedDate(purchasedProduct3.Id, yesterday);
		Test.setCreatedDate(purchasedProduct4.Id, yesterday);
	}
	
	@isTest static void executeBatch() {
		Test.startTest();
		Id batchId = Database.executeBatch(new ICX_BatchRelateTransactionToCall());
		Test.stopTest();

		PPR_PurchProduct__c ppr1 = [SELECT Id FROM PPR_PurchProduct__c WHERE SKU__c='TST123'];
		Task call1 = [SELECT Id,Purchased_Product__c,AccountId FROM Task WHERE Sku_Number__c='TST123' AND CallType = 'Inbound' LIMIT 1];
		System.assertEquals(ppr1.Id, call1.Purchased_Product__c);

		PPR_PurchProduct__c ppr2 = [SELECT Id FROM PPR_PurchProduct__c WHERE SKU__c='TST321'];
		Task call2 = [SELECT Id,Purchased_Product__c,AccountId FROM Task WHERE Sku_Number__c='TST321' AND CallType = 'Inbound' LIMIT 1];
		System.assertEquals(ppr2.Id, call2.Purchased_Product__c);

		PPR_PurchProduct__c ppr3 = [SELECT Id FROM PPR_PurchProduct__c WHERE SKU__c='TST888'];
		Task call3 = [SELECT Id,Purchased_Product__c,AccountId FROM Task WHERE Sku_Number__c='TST626' AND CallType = 'Outbound' LIMIT 1];
		System.assertEquals(ppr3.Id, call3.Purchased_Product__c);

		PPR_PurchProduct__c ppr4 = [SELECT Id FROM PPR_PurchProduct__c WHERE SKU__c='TST1235'];
		Task call4 = [SELECT Id,Purchased_Product__c,AccountId FROM Task WHERE Sku_Number__c='TST1235' AND CallType = 'Outbound' LIMIT 1];
		System.assertEquals(ppr4.Id, call4.Purchased_Product__c);
	}


	private static PPR_PurchProduct__c createPurchasedProductCSC(Account client , String SKU ,String TicketNumber){
        PPR_PurchProduct__c purchasedProduct = new PPR_PurchProduct__c();
		purchasedProduct.Client__c = client.Id;
		purchasedProduct.SKU__c = SKU ;
		purchasedProduct.Store__c = 'T11';
		purchasedProduct.TransactionStoreType__c='CSC';
		purchasedProduct.PurchasedDate__c = Date.today().addDays(1);
		purchasedProduct.TicketNumber__c = TicketNumber;
		purchasedProduct.Quantity__c = 1; 
        
        return purchasedProduct;
    }

	private static PPR_PurchProduct__c createPurchasedProductWEB(Account client , String SKU ,String TicketNumber){
        PPR_PurchProduct__c purchasedProduct = new PPR_PurchProduct__c();
		purchasedProduct.Client__c = client.Id;
		purchasedProduct.SKU__c = SKU ;
		purchasedProduct.Store__c = 'T11';
		purchasedProduct.TransactionStoreType__c='WEB';
		purchasedProduct.PurchasedDate__c = Date.today().addDays(1);
		purchasedProduct.TicketNumber__c = TicketNumber;
		purchasedProduct.Quantity__c = 1; 
        
        return purchasedProduct;
    }

	private static PPR_PurchProduct__c createPurchasedProductStore(Account client , String SKU ,String TicketNumber){
        PPR_PurchProduct__c purchasedProduct = new PPR_PurchProduct__c();
		purchasedProduct.Client__c = client.Id;
		purchasedProduct.SKU__c = SKU ;
		purchasedProduct.Store__c = 'T11';
		purchasedProduct.TransactionStoreType__c='Store';
		purchasedProduct.PurchasedDate__c = Date.today().addDays(1);
		purchasedProduct.TicketNumber__c = TicketNumber;
		purchasedProduct.Quantity__c = 1; 
        
        return purchasedProduct;
    }


    private static Task createCallInbound(Account client , ProductCatalogue__c product ,String TicketNumber){
        Id CallRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSC_Call').getRecordTypeId();
        Task call = new Task();
        call.WhatId  = client ?.Id;
		call.Product_Sku__c = product.Id;
		call.Transaction_Id__c = TicketNumber;
        call.RecordTypeId=CallRecordTypeId;
		call.CallType  = 'Inbound';
        
        return call;
    }

	private static Task createCallOutbound(Account client , ProductCatalogue__c product ,String TicketNumber){
        Id CallRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSC_Call').getRecordTypeId();
        Task call = new Task();
        call.WhatId  = client ?.Id;
		call.Product_Sku__c = product.Id;
		call.Transaction_Id__c = TicketNumber;
        call.RecordTypeId=CallRecordTypeId;
		call.CallType  = 'Outbound';
        
        return call;
    }
}