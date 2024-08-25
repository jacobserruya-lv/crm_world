@isTest 
private class ICX_RevisedETABatch_TEST {

    @testSetup  
    static void makeData(){
    Account acc = createAccount('test', 'test', null, null);
    insert acc;
    
    Order__c orderRecord = createOrder(acc) ;
    insert orderRecord;
    
    OrderShipping__c orderShippingRecord = createOrderShipping(orderRecord) ;
    insert orderShippingRecord;
    
    OrderLine__c orderLineRecord = createOrderLine(orderRecord,orderShippingRecord) ;
    insert orderLineRecord;
    }

    @isTest static void revisedETACalloutBatch() {

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();

        Test.startTest();
        mock.setStaticResource('OrderDetailsAPI');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;charset=UTF-8');
        Test.setMock(HttpCalloutMock.class, mock);

        try{
        ICX_RevisedETABatch b = new ICX_RevisedETABatch();
        database.executebatch(b,100);   
        }
        catch(Exception e)
        {
            System.debug('ICX_RevisedETABatch_TEST ERROR ' + e);
        } 
        Test.stopTest();

    }

    static final string EXISTING_ORDER_NUMBER = '1234567898000000';
    static final string EXISTING_SHIPPING_NUMBER = '0123456789-1';

    //help func
    private static Order__c createOrder(Account acc) {
        Order__c orderRecord = new Order__c();
        orderRecord.OrderNumber__c = '1234567898000000';
        orderRecord.Account__c = acc.id;
        return orderRecord;
    }
    private static OrderShipping__c createOrderShipping(Order__c orderId) {
        OrderShipping__c orderShippingRecord = new OrderShipping__c();
        orderShippingRecord.ShippingNumber__c = '0123456789-1';
        orderShippingRecord.Order__c = orderId.id;
        return orderShippingRecord;
    }
    private static OrderLine__c createOrderLine(Order__c orderId,OrderShipping__c orderShippingId) {
        OrderLine__c orderLineRecord = new OrderLine__c();
        orderLineRecord.Name = '1234567898000000-1';
        orderLineRecord.Order__c = orderId.id;
        orderLineRecord.OrderShipping__c= orderShippingId.Id;
        orderLineRecord.Initial_Eta_Max__c=Date.today().addDays(10);
        return orderLineRecord;
    }

    private static Account createAccount(String firstname, String lastname, String phone, String email) {
        Account acc = new Account();
        acc.Firstname = firstname;
        acc.LastName = lastname;
        acc.PersonMobilePhone = phone;
        acc.PersonEmail = email;
        return acc;
    }
}