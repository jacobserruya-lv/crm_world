@isTest
public class GiftCatalogTriggerHandler_TEST {
    @isTest
    static void handleBeforeInsertUpdate_TEST(){
        Test.startTest();
            GiftCatalog__c gc = new GiftCatalog__c(
                Name = 'Test',
                SKUGift__c = '12345'
            );

            insert gc;
            gc.SKUGift__c = '123456';
            update gc;
        Test.stopTest();
    }
}