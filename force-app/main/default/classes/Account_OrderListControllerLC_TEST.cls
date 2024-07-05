@isTest
public class Account_OrderListControllerLC_TEST {

    @isTest
    public static void getOrderLineList_TEST() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        Store__c store = ICX_TestFactory.createStore('storeName', 'TESTCODE');
        insert store;

        Order__c order = createOrder(store.Id, '123456', acc.Id);
        insert order;

        ProductReferential__c prod = createProductReferential('SKUTEST');
        insert prod;

        OrderShipping__c shipping = createOrderShipping(order.Id, 'SN-01');
        insert shipping;

        OrderLine__c line = createOrderLine(order.Id, shipping.Id, prod);
        insert line;

        ProductReferential__c prod2 = createProductReferential('SKUTEST2');
        insert prod2;
        OrderLine__c line2 = createOrderLine(order.Id, shipping.Id, prod2);
        insert line2;

        Test.startTest();
        Account_OrderListControllerLC.PagedResult result = Account_OrderListControllerLC.getOrderLineList(acc.Id, 5, 1);
        Test.stopTest();

        List<OrderLine__c> orderLineList = result.orderLineList;
        System.assertEquals(2, orderLineList.size());
    }

    private static Order__c createOrder(Id storeId, String orderNumber, Id accountId) {
        Order__c order = new Order__c();
		order.Store__c = storeId;
        order.OrderNumber__c = orderNumber;
        order.OrderDate__c = Datetime.now();
        order.Account__c = accountId;

        return order;
    }

    private static ProductReferential__c createProductReferential(String sku) {
        ProductReferential__c prod = new ProductReferential__c();
        prod.SKUCode__c = sku;
        prod.Name = 'DEMO PRODUCT';
        return prod;
    }
    
    private static OrderShipping__c createOrderShipping(Id orderId, String shippingNumber) {
        OrderShipping__c ship = new OrderShipping__c();
        ship.Order__c = orderId;
        ship.ShippingNumber__c = shippingNumber;
        ship.Status__c = 'New';
        ship.StatusDate__c = DateTime.now();
        ship.DeliveryType__c = 'standard';
        return ship;
    }

    private static OrderLine__c createOrderLine(Id orderId, Id shippingId, ProductReferential__c prod) {
        OrderLine__c line = new OrderLine__c();
        line.Order__c = orderId;
        line.OrderShipping__c = shippingId;
        line.ProductReferential__c = prod.Id;
        line.SKU__c = prod.SKUCode__c;
        return line;
    }
}