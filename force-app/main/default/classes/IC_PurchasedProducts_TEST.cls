@isTest
private class IC_PurchasedProducts_TEST {
    
   
    @isTest static void Test_FindPurchasedProductDB() {

        /* NORMAL TEST */

        // Create an account
        Account acc             = IC_TestFactory.createAccount();
        insert acc;
        
        Case cas = ICX_TestFactory.createCase(acc.Id);
        cas.AccountID = acc.Id;
        insert cas;

        // Create an event 
        Event evt               = IC_TestFactory.createEvent(acc);
        evt.WhatId = cas.Id;
        insert evt;

        // Create purchsed product linked to above account
        PPR_PurchProduct__c pp  = IC_TestFactory.createPurchaseProduct(acc.Id);
        pp.PurchasedDate__c = system.today();
        pp.TransactionStoreType__c ='Web';
        insert pp;

        Event eve               =  [Select Id From Event Where Id =:evt.Id Limit 1];
        String eventId          = String.valueOf(eve.Id);
        System.debug('This is eventId in Normal Test Scenario :' + eventId);
        
        // Check if the method return the correct purchsed product, the purchased product should be 1
        Test.startTest();
        List<IC_PurchasedProducts.TransactionWrapper> products = IC_PurchasedProducts.FindPurchasedProductDB(eventId);
        Test.stopTest();
        System.assertEquals(1,products.size());

    }

    @isTest static void Test_Negative_FindPurchasedProductDB(){
        /* NEGATIVE TEST CREATE EVENT AND LINKED TO ACCOUNT WITHOUT PURCHASED PRODUCT*/

        // Create an account
        Account acc2            = IC_TestFactory.createAccount();
        insert acc2;
        System.debug(' This is account 2 in negative test: ' + acc2);

        // Create an event 
        Event evt2              = IC_TestFactory.createEvent(acc2);
        insert evt2;
        System.debug(' This is event 2 in negative test: ' + evt2);

        // Queryt Event and pass to method to do assertion
        Event eve2              =  [Select Id,Purchased_Product__c From Event Where Id =:evt2.Id Limit 1];
        System.debug('This is even2 in negative test :' + eve2);
        String eventId2         = String.valueOf(eve2.Id);
        System.debug('This is eventId after String Method in Negative test scenario :' + eventId2);
        
        // Check if the method return the correct purchsed product, this negative test should return nothing
        Test.startTest();
        List<IC_PurchasedProducts.TransactionWrapper> products2 = IC_PurchasedProducts.FindPurchasedProductDB(eventId2);
        Test.stopTest();
        System.debug('This is products 2 in negative test :' + products2);
        System.assertEquals(0,products2.size());
    }
    
    @isTest 
    static void Test_FindPurchasedProduct_Case() {
		// Init
        Account acc             = IC_TestFactory.createAccount();
        insert acc;

        Case cas = ICX_TestFactory.createCase(acc.Id);
        insert cas;

        PPR_PurchProduct__c pp  = IC_TestFactory.createPurchaseProduct(acc.Id);
           pp.PurchasedDate__c = system.today();
         pp.TransactionStoreType__c ='Web';
        insert pp;
        
        // Test
        Test.startTest();
        List<IC_PurchasedProducts.TransactionWrapper> products = IC_PurchasedProducts.FindPurchasedProductDB(cas.Id);
        Test.stopTest();

        // Check
        System.assertEquals(1,products.size());

    }

    @isTest static void Test_updatePurchasedProductOnEvent() {
        /* NORMAL TEST */

        // Create an account
        Account acc                 = IC_TestFactory.createAccount();
        insert acc;

        // Create an event 
        Event evt                   = IC_TestFactory.createEvent(acc);
        insert evt;

        // Create purchased product linked to above account
        PPR_PurchProduct__c pp      = IC_TestFactory.createPurchaseProduct(acc.Id);
        insert pp;

        // Create second purchased product 
        PPR_PurchProduct__c pp2     = IC_TestFactory.createPurchaseProduct(acc.Id);
        insert pp2;

        // Create third purchased product 
        PPR_PurchProduct__c pp3     = IC_TestFactory.createPurchaseProduct(acc.Id);
        insert pp3;

        // Query event to pass its id to method
        Event eve                   =  [SELECT Id, Purchased_Product__c FROM Event Where Id =:evt.Id Limit 1];
        System.assertEquals(null,eve.Purchased_Product__c);
        String eventId              = String.valueOf(eve.Id);
        System.debug('This is eventId from IC_PurchsedProducts_Test :' + eventId);

        // Query purchased product to pass to method
        PPR_PurchProduct__c product = [Select Id From PPR_PurchProduct__c Where Id = :pp.Id Limit 1];
        String      productId       = String.valueOf(product.Id);
        System.debug('This is purchased product Id in second test method :' + product.Id); 

        // Check if the method return the correct purchsed product, the purchased product should be 1
        Test.startTest();
        IC_PurchasedProducts.updatePurchasedProductOnEvent(eventId,productId);
        Test.stopTest();
        Event eve2                  =  [SELECT Id, Purchased_Product__c FROM Event Where Id =:evt.Id Limit 1];
        System.assertEquals(pp.Id,eve2.Purchased_Product__c);
    }


    @isTest static void Test_updatePurchasedProductOnCase() {
        // Init
        Account acc = IC_TestFactory.createAccount();
        insert acc;

        Case cas = ICX_TestFactory.createCase(acc.Id);
        insert cas;

        PPR_PurchProduct__c pp = IC_TestFactory.createPurchaseProduct(acc.Id);
        insert pp;

        // Create a second purchased product to verify the case won't be linked to this record 
        PPR_PurchProduct__c pp2 = IC_TestFactory.createPurchaseProduct(acc.Id);
        insert pp2;

        // Test
        Test.startTest();
        IC_PurchasedProducts.updatePurchasedProductOnEvent(cas.Id,pp.Id);
        Test.stopTest();

        // Check
        List<Case> resultList =  [SELECT Id, PurchasedProduct__c FROM Case];
        System.assertEquals(1, resultList.size());
        System.assertEquals(pp.Id,resultList.get(0).PurchasedProduct__c);
    }
}