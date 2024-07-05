@istest public with sharing class OrderNoteServiceTest {
    static final string EXISTING_ORDER_NUMBER = '1234567898000000';
    static final string EXISTING_SHIPPING_NUMBER = '0123456789-1';

    @testSetup  
    static void makeData(){
        CaseTeamRole caseTeam = [SELECT Id FROM CaseTeamRole WHERE Name='Back Office'];

        IconicsSettings__c setting = new IconicsSettings__c();
        setting.BackOfficeId__c = caseTeam.Id;        
        insert setting;

        CaseTeamTemplate myCaseTeam =  [SELECT Id FROM CaseTeamTemplate limit 1];
        system.debug(myCaseTeam);

        ProductReferential__c product = createProductReferential('M6868');
        insert product;

        store__c store = createStore('I03');
        insert store;

        Account acc = createAccount('test', 'test', null, null);
        insert acc;
        
        Id profileId = [SELECT Id FROM Profile WHERE Name='ICONiCS_SA' LIMIT 1].Id;

        User CAUser = ICX_TestFactory.createUser(profileId);
        CAUser.Country__c='SAUDI ARABIA';
        insert CAUser;
        
        Order__c orderRecord = createOrder(acc) ;
        orderRecord.OwnerId__c = CAUser.Id;
        insert orderRecord;
        
        
        
        OrderShipping__c orderShippingRecord = createOrderShipping(orderRecord) ;
        insert orderShippingRecord;
        
        OrderLine__c orderLineRecord = createOrderLine(orderRecord) ;
        insert orderLineRecord;
    }

    private static Order__c createOrder(Account acc) {
        Order__c orderRecord = new Order__c();
        orderRecord.OrderNumber__c = EXISTING_ORDER_NUMBER;
        orderRecord.Account__c = acc.id;
        return orderRecord;
    }
    private static OrderShipping__c createOrderShipping(Order__c orderId) {
        OrderShipping__c orderShippingRecord = new OrderShipping__c();
        orderShippingRecord.ShippingNumber__c = EXISTING_SHIPPING_NUMBER;
        orderShippingRecord.Status__c = 'fulfilled';
        orderShippingRecord.Order__c = orderId.id;
        return orderShippingRecord;
    }
    private static OrderLine__c createOrderLine(Order__c orderId) {
        OrderLine__c orderLineRecord = new OrderLine__c();
        orderLineRecord.Name = EXISTING_ORDER_NUMBER+'-1';
        orderLineRecord.Order__c = orderId.id;
        return orderLineRecord;
    }
    private static ProductReferential__c createProductReferential(String sku) {
        ProductReferential__c prod = new ProductReferential__c();
        prod.SKUCode__c = sku;
        prod.Name = 'DEMO PRODUCT';
        return prod;
    }
    private static store__c createStore(String retailStoreId) {
        store__c storeRecord = new store__c();
        storeRecord.RetailStoreId__c = retailStoreId;
        storeRecord.Name = 'Louis Vuitton';
        return storeRecord;
    }
    private static Account createAccount(String firstname, String lastname, String phone, String email) {
        Account acc = new Account();
        acc.Firstname = firstname;
        acc.LastName = lastname;
        acc.PersonMobilePhone = phone;
        acc.PersonEmail = email;
        return acc;
    }

    @istest static void updateOrderNote() {
        // Create OrderNote records...
        Order_Note__c orderNoteNew = new Order_Note__c();
        // ATTACHED_NOTE
        orderNoteNew.Type__c = 'ATTACHED_NOTE';
        orderNoteNew.Description__c = 'This is the first comment';
        orderNoteNew.Tech_OrderNumber__c = EXISTING_ORDER_NUMBER;

        insert orderNoteNew;
        
        orderNoteNew = new Order_Note__c();
        // CLIENTELING EXCEPTION
        orderNoteNew.Type__c = 'CLIENTELING_EXCEPTION';
        orderNoteNew.Description__c = 'This is the clienteling exception';
        orderNoteNew.Reason__c = 'None of above';
        orderNoteNew.Tech_OrderNumber__c = EXISTING_ORDER_NUMBER;
        orderNoteNew.Tech_ShippingNumber__c = EXISTING_SHIPPING_NUMBER;
        insert orderNoteNew;
        
        orderNoteNew = new Order_Note__c();
        // PRICE ADJUSTMENT
        orderNoteNew.Type__c = 'PRICE_ADJUSTMENT';
        orderNoteNew.Description__c = 'This is the price adjustment';
        orderNoteNew.Reason__c = 'None of above';
        orderNoteNew.Tech_OrderNumber__c = EXISTING_ORDER_NUMBER;
        orderNoteNew.Tech_ShippingNumber__c = EXISTING_SHIPPING_NUMBER;

        insert orderNoteNew;

        test.startTest();
            OrderNoteService.syncWithOrder(new List<String>{EXISTING_ORDER_NUMBER}, new List<String>{EXISTING_SHIPPING_NUMBER});
        test.stopTest();

        List<Order_Note__c> orderNotes = [Select id, order__c, Order_Shipping__c, Tech_OrderNumber__c, Tech_ShippingNumber__c FROM order_Note__c];

System.debug('JGU - '+orderNotes);

        for (Order_Note__c orderNote: orderNotes) {
            if (orderNote.Tech_OrderNumber__c == EXISTING_ORDER_NUMBER && orderNote.Tech_ShippingNumber__c == null) {
                System.assertEquals(orderNote.Order_Shipping__c, null, 'OrderShipping should be null');
                System.assertNotEquals(orderNote.Order__c, null, 'Order should not be null');
            }
            else {
                System.assertNotEquals(orderNote.Order__c, null, 'Order should not be null');
                System.assertNotEquals(orderNote.Order_Shipping__c, null, 'OrderShipping should not be null');
            }
        }
    }
}