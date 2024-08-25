@isTest
private class ICX_RelatedOrderShipping_TEST {
    
    @isTest
    static void getOrderShipping_TEST() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        Order__c orderRecord = ICX_TestFactory.createOrder(acc) ;
        insert orderRecord;
         
         OrderShipping__c orderShippingRecord = ICX_TestFactory.createOrderShipping(orderRecord.Id) ;
         insert orderShippingRecord;
         
         OrderLine__c orderLineRecord = ICX_TestFactory.createOrderLine(orderRecord.Id,orderShippingRecord.Id) ;
         insert orderLineRecord;

        Id oeRTId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Operation_Exception').getRecordTypeId();
        Case newOE = new Case(AccountId=acc.Id,RecordTypeId=oeRTId,Order_Shipping__c=orderShippingRecord.Id, country__c='France');
        insert newOE;

        Test.startTest(); 
        OrderShipping__c currentOrderShipping = ICX_RelatedOrderShipping.getOrderShipping(newOE.Id,'Case','Order_Shipping__c','ShippingNumber__c,Status__c,Order__r.Name');
        Test.stopTest();
        System.assertEquals(currentOrderShipping.Order__c,orderRecord.Id);

    }

}