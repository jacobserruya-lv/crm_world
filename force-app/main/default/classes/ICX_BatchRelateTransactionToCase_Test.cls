@isTest
private class ICX_BatchRelateTransactionToCase_Test {
	
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


		//Create cases
		List<Case> cases = new List<Case>();

		Case case1 = createCase(client,product1,'');
		cases.add(case1);

		Case case2 = createCase(client,product2,'Test1234');
		cases.add(case2);
        
        Case case3 = createCase(client,product3,'');
        cases.add(case3);
        
        Case case4 = createCase(client,product4,'nx12345');
		cases.add(case4);

		insert cases;

		//Create transactions
		List<PPR_PurchProduct__c> transactions = new List<PPR_PurchProduct__c>();

        PPR_PurchProduct__c purchasedProduct1 = createPurchasedProductCSC(client , 'TST123' ,'123456');
		transactions.add(purchasedProduct1);
        
        PPR_PurchProduct__c purchasedProduct2 = createPurchasedProductStore(client , 'TST321' ,'Test1234');
        purchasedProduct2.OrderATGId__c = 'Test1234';
		transactions.add(purchasedProduct2);
        
        PPR_PurchProduct__c purchasedProduct3 = createPurchasedProductWEB(client ,'TST888' ,'11123456');
		purchasedProduct3.RMSSKUCode__c = 'TST626';
		transactions.add(purchasedProduct3);
        
        PPR_PurchProduct__c purchasedProduct4 = createPurchasedProductStore(client ,'IE1452' ,'nx12345');
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
		Id batchId = Database.executeBatch(new ICX_BatchRelateTransactionToCase());
		Test.stopTest();

		PPR_PurchProduct__c ppr1 = [SELECT Id,ICX_CSCContactDate__c,ICX_CSCUser__c,ICX_ContactChannel__c,ICX_ContactChannel_RecordId__c FROM PPR_PurchProduct__c WHERE SKU__c='TST123'];
		Case case1 = [SELECT Id,PurchasedProduct__c,AccountId FROM Case WHERE Sku_Number__c='TST123'limit 1];
		System.assertEquals(ppr1.Id, case1.PurchasedProduct__c);

		PPR_PurchProduct__c ppr2 = [SELECT Id FROM PPR_PurchProduct__c WHERE SKU__c='TST321'];
		Case case2 = [SELECT Id,PurchasedProduct__c,AccountId FROM Case WHERE Sku_Number__c='TST321'limit 1];
		System.assertEquals(ppr2.Id, case2.PurchasedProduct__c);
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


    private static Case createCase(Account client , ProductCatalogue__c product ,String TicketNumber){
		Id emailRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Web_Email_Case').getRecordTypeId();
        Case cases = new Case();
		cases.RecordTypeId = emailRecordTypeId;
		cases.AccountId = client.Id;
		cases.Product_Sku__c = product.Id;
		cases.Transaction_Id__c =  TicketNumber;
        
		return cases;
    }
}