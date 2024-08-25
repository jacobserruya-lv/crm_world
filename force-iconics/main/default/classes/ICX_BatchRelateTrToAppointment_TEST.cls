@isTest
private class ICX_BatchRelateTrToAppointment_TEST {
	
	@testSetup 
	static void TransactionEventsCreation() {

        //Create Clients
		Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ACC_PersonAccount').getRecordTypeId();
        Account client1 = new Account();
        Account client2 = new Account();
		client1.LastName ='Test Client 1 NI-1023';
		client2.LastName ='Test Client 2 NI-1023';
		client1.RecordTypeId = personAccountRTId;
		client2.RecordTypeId = personAccountRTId;
        insert client1;
        insert client2;
        
        //Create User
        User iconicsUser = new User();
        Profile iconicsProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        iconicsUser.profile = iconicsProfile;
        iconicsUser.ProfileId = iconicsProfile.Id;
        iconicsUser.LastName = 'iconics user';
        iconicsUser.Alias = 'iconicsu';
        iconicsUser.Email = 'iconics.user@louisvuitton.com';
        iconicsUser.TimeZoneSidKey = 'Europe/Paris';
        iconicsUser.LocaleSidKey = 'en_US';
        iconicsUser.Username = 'iconics.user@louisvuitton.com.iconics';
        iconicsUser.EmailEncodingKey = 'ISO-8859-1';
        iconicsUser.LanguageLocaleKey = 'en_US';
        insert iconicsUser;

        
		//Create products
		List<ProductCatalogue__c> products = new List<ProductCatalogue__c>();
		ProductCatalogue__c product1 = new ProductCatalogue__c(SKU__c='TEST');
		products.add(product1);
        insert products;
        
		Datetime yesterday = Datetime.now().addDays(-2);
		Datetime dayBeforeYesterday = Datetime.now().addDays(-3);
        
		//Create events (Appointments)
        List<Event> events = new List<Event>();
        
        Event event1 = createEvent('ev1', client1, iconicsUser);
        Event event2 = createEvent('ev2', client1, iconicsUser);
        Event event3 = createEvent('ev3', client2, iconicsUser);
        events.add(event1);
        events.add(event2);
        events.add(event3);
        System.runAs(iconicsUser) {  
            insert events;
        }
        Test.setCreatedDate(event1.Id, yesterday);


		//Create transactions
        List<PPR_PurchProduct__c> transactions = new List<PPR_PurchProduct__c>();
        PPR_PurchProduct__c purchasedProduct1 = createPurchasedProductCSC(client1, '11111');
        PPR_PurchProduct__c purchasedProduct2 = createPurchasedProductWEB(client2, '22222');
        PPR_PurchProduct__c purchasedProduct3 = createPurchasedProductStore(client2, '33333');
		transactions.add(purchasedProduct1);
		transactions.add(purchasedProduct2);
		transactions.add(purchasedProduct3);
        insert transactions;
        
        Test.setCreatedDate(purchasedProduct1.Id, yesterday);
        Test.setCreatedDate(purchasedProduct2.Id, dayBeforeYesterday);
        Test.setCreatedDate(purchasedProduct3.Id, yesterday); 
	}
	
	@isTest static void executeBatch() {
		Test.startTest();
		Id batchId = Database.executeBatch(new ICX_BatchRelateTransactionToAppointment());
        Test.stopTest();


        Account testClient1 = [SELECT Id FROM Account WHERE LastName = 'Test Client 1 NI-1023' AND CreatedBy.Profile.Name = 'System Administrator' AND CreatedDate = TODAY];
        Account testClient2 = [SELECT Id FROM Account WHERE LastName = 'Test Client 2 NI-1023' AND CreatedBy.Profile.Name = 'System Administrator' AND CreatedDate = TODAY];

        PPR_PurchProduct__c ppr1 = [SELECT Id, Name FROM PPR_PurchProduct__c WHERE Client__c =: testClient1.Id AND TicketNumber__c = '11111'];
        PPR_PurchProduct__c ppr2 = [SELECT Id, Name FROM PPR_PurchProduct__c WHERE Client__c =: testClient2.Id AND TicketNumber__c = '22222'];
        
        Event event1 = [SELECT Id, AccountId, Purchased_Product__c, CreatedDate FROM Event WHERE AccountId =: testClient1.Id AND CreatedDate >= LAST_N_DAYS:10 AND Subject = 'ev1' LIMIT 1];
        Event event2 = [SELECT Id, AccountId, Purchased_Product__c, CreatedDate FROM Event WHERE AccountId =: testClient1.Id AND CreatedDate >= LAST_N_DAYS:10 AND Subject = 'ev2' LIMIT 1];
        Event event3 = [SELECT Id, AccountId, Purchased_Product__c, CreatedDate FROM Event WHERE AccountId =: testClient2.Id AND CreatedDate >= LAST_N_DAYS:10 AND Subject = 'ev3' LIMIT 1];

		System.assertEquals(ppr1.Id, event1.Purchased_Product__c);
		System.assertEquals(null, event2.Purchased_Product__c);
		System.assertEquals(ppr2.Id, event3.Purchased_Product__c);
    }

    
    // private static PPR_PurchProduct__c createPurchasedProduct(Account client, String ticketNumber){
        
    //     PPR_PurchProduct__c purchasedProduct = new PPR_PurchProduct__c();
    //     purchasedProduct.Client__c = client.Id;
	// 	purchasedProduct.Store__c = 'T11';
	// 	purchasedProduct.TransactionStoreType__c='CSC';
	// 	purchasedProduct.PurchasedDate__c = Date.today();
    //     purchasedProduct.Quantity__c = 1;
    //     purchasedProduct.TicketNumber__c = ticketNumber;
        
    //     return purchasedProduct;
    // }

    private static PPR_PurchProduct__c createPurchasedProductCSC(Account client, String TicketNumber){
        PPR_PurchProduct__c purchasedProduct = new PPR_PurchProduct__c();
		purchasedProduct.Client__c = client.Id;
		purchasedProduct.Store__c = 'T11';
		purchasedProduct.TransactionStoreType__c='CSC';
		purchasedProduct.PurchasedDate__c = Date.today();
		purchasedProduct.TicketNumber__c = TicketNumber;
		purchasedProduct.Quantity__c = 1; 
        
        return purchasedProduct;
    }

	private static PPR_PurchProduct__c createPurchasedProductWEB(Account client, String TicketNumber){
        PPR_PurchProduct__c purchasedProduct = new PPR_PurchProduct__c();
		purchasedProduct.Client__c = client.Id;
		purchasedProduct.Store__c = 'T11';
		purchasedProduct.TransactionStoreType__c='WEB';
		purchasedProduct.PurchasedDate__c = Date.today();
		purchasedProduct.TicketNumber__c = TicketNumber;
		purchasedProduct.Quantity__c = 1; 
        
        return purchasedProduct;
    }

	private static PPR_PurchProduct__c createPurchasedProductStore(Account client, String TicketNumber){
        PPR_PurchProduct__c purchasedProduct = new PPR_PurchProduct__c();
		purchasedProduct.Client__c = client.Id;
		purchasedProduct.Store__c = 'T11';
		purchasedProduct.TransactionStoreType__c='Store';
		purchasedProduct.PurchasedDate__c = Date.today();
		purchasedProduct.TicketNumber__c = TicketNumber;
		purchasedProduct.Quantity__c = 1; 
        
        return purchasedProduct;
    }

    private static Event createEvent(String Subject, Account client, User iconicsUser) {
        Event event;
        System.runAs(iconicsUser) {
            event = new Event();
            event.WhatId = client.Id;
            event.Subject = Subject;
            event.ActivityDate = Date.today().addDays(6);
            event.StartDateTime = Date.today().addDays(6);
            event.EndDateTime = Date.today().addDays(9);
        }
        return event;
    }
}