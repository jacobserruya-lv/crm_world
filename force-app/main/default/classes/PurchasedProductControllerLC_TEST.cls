@isTest
public class PurchasedProductControllerLC_TEST {

    @isTest
    public static void getPurchasedProductListTest() {
        Account acc = IC_TestFactory.createAccount();
        insert acc;

		PPR_PurchProduct__c pp = IC_TestFactory.createPurchaseProduct(acc.Id);
		PPR_PurchProduct__c pp2 = IC_TestFactory.createPurchaseProduct(acc.Id);
		PPR_PurchProduct__c pp3 = IC_TestFactory.createPurchaseProduct(acc.Id);
		PPR_PurchProduct__c pp4 = IC_TestFactory.createPurchaseProduct(acc.Id);
		PPR_PurchProduct__c pp5 = IC_TestFactory.createPurchaseProduct(acc.Id);
        insert new List<PPR_PurchProduct__c>{pp, pp2, pp3, pp4, pp5};

		// Test (limit: 2, offset: 2)
        PurchasedProductControllerLC.PagedResult result = PurchasedProductControllerLC.getPurchasedProductList(acc.Id, 4, 2);
        
        // Result
        System.assert(result != null);
        System.assertEquals(4, result.pageSize);
        System.assertEquals(2, result.page);
        System.assertEquals(5, result.total);
    }
}