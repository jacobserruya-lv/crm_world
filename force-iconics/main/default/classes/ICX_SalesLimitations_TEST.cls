@istest
public class ICX_SalesLimitations_TEST {

    @testSetup 
	static void TransactionCreation() {
		ProductReferential__c product = createProductReferential('M6868');
        insert product;
        
        Alias__c alias = new Alias__c(Name='test');
        insert alias;    

        Account acc = createAccount('test', 'test', '+33180111111','test@gmail.com' );        
        insert acc;

        Alias_Member__c am = new Alias_Member__c(Client__c = acc.Id, Alias__c = alias.Id);
        insert am;

        Store__c store = new Store__c(Name='test store2', RetailStoreId__c='T12');
		insert new list<Store__c>{store};
       
        PPR_PurchProduct__c purchasedProduct = createPurchased('M6868' ,acc);
        insert new list<PPR_PurchProduct__c>{purchasedProduct};
            
            
        Order__c orderRecord = createOrder(acc) ;
        insert orderRecord;
        
        OrderShipping__c orderShippingRecord = createOrderShipping(orderRecord) ;
        insert orderShippingRecord;
        
        OrderLine__c orderLineRecord = createOrderLine(orderRecord,orderShippingRecord,product) ;
        insert orderLineRecord;
	}
    
    @isTest static void testMethod1() {
        
        Test.startTest();
        Alias__c  alias = [SELECT id FROM Alias__c limit 1];
        List<ICX_SalesLimitations.Sales> response = ICX_SalesLimitations.getRelatedAccounts(alias.id);
        Test.stopTest();
        system.assertnotequals(null,response);
    }
    
    private static Order__c createOrder(Account acc) {
        Order__c orderRecord = new Order__c();
        orderRecord.OrderNumber__c = '123456789';
        orderRecord.Account__c = acc.id;
        orderRecord.OrderDate__c = Date.today().addDays(-3);
        return orderRecord;
    }
    private static OrderShipping__c createOrderShipping(Order__c orderId) {
        OrderShipping__c orderShippingRecord = new OrderShipping__c();
        orderShippingRecord.ShippingNumber__c = '0123456789';
        orderShippingRecord.Order__c = orderId.id;
        orderShippingRecord.StatusDate__c = Date.today().addDays(-3);
        orderShippingRecord.status__c = 'New';

        
        return orderShippingRecord;
    }
    private static OrderLine__c createOrderLine(Order__c orderId,OrderShipping__c ordsh,ProductReferential__c prd) {
        OrderLine__c orderLineRecord = new OrderLine__c();
        orderLineRecord.Name = '1123456789';
        orderLineRecord.Order__c = orderId.id;
        orderLineRecord.OrderShipping__c = ordsh.id;
        orderLineRecord.SKU__c = 'M6868';
        orderLineRecord.ProductReferential__c =prd.id;
        orderLineRecord.Quantity__c = 1;
    
        return orderLineRecord;
    }
    private static ProductReferential__c createProductReferential(String sku) {
        ProductReferential__c prod = new ProductReferential__c();
        prod.SKUCode__c = sku;
        prod.Name = 'DEMO PRODUCT';
        return prod;
    }
    private static Account createAccount(String firstname, String lastname, String phone, String email) {
        Account acc = new Account();
        acc.Firstname = firstname;
        acc.LastName = lastname;
        acc.PersonMobilePhone = phone;
        acc.PersonEmail = email;
        return acc;
    }
    private static PPR_PurchProduct__c createPurchased(String sku ,Account client) {
        PPR_PurchProduct__c purchasedProduct2 = new PPR_PurchProduct__c();
		purchasedProduct2.Client__c = client.Id;
        purchasedProduct2.RMSSKUCode__c = 'AT0123';
		purchasedProduct2.SKU__c = 'abc12345681';
		purchasedProduct2.Store__c = 'T12';
		purchasedProduct2.PurchasedDate__c = Date.today().addDays(-3);
		purchasedProduct2.TicketNumber__c = '123';
        purchasedProduct2.TransactionRMSId__c='123';
        purchasedProduct2.OrderATGId__c='123';
		purchasedProduct2.Quantity__c = 1;
        purchasedProduct2.ProductLine__c = 'Leather Good';
        purchasedProduct2.Amount__c = 500;

        
        
        return purchasedProduct2;
    }
    
}