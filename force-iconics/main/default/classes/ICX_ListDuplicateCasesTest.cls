@isTest
public class ICX_ListDuplicateCasesTest {
    @testSetup static void methodName() {
       Account myAccount = new Account(LastName ='Test', PrimaryCountry__pc='France');
       insert myAccount;
    Order__c orderRecord = ICX_TestFactory.createOrder(myAccount) ;
    // orderRecord.OwnerId__c = CAUser.Id;
     insert orderRecord;
     
     OrderShipping__c orderShippingRecord = ICX_TestFactory.createOrderShipping(orderRecord.Id) ;
     insert orderShippingRecord;
     
     OrderLine__c orderLineRecord = ICX_TestFactory.createOrderLine(orderRecord.Id,orderShippingRecord.Id) ;
     insert orderLineRecord;

        id CaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Operation_Exception').getRecordTypeId();
        Case myCase = new Case(Shipping_group__c='123',Order_Shipping__c=orderShippingRecord.Id,Issue_Category__c='Other' ,Status='New',Country__c='FRANCE',RecordTypeId=CaseRecordTypeId,Description='123');
        insert myCase;
       

   }
    @IsTest Static  void myFunction(){
       Case myCase = [ select id, Shipping_group__c,Order_Shipping__r.ShippingNumber__c From Case limit 1 ]  ;
        ICX_ListDuplicateCases_LC.getDuplicateCases(myCase.Shipping_group__c,myCase.Order_Shipping__r.ShippingNumber__c,'',myCase.id);
        ICX_ListDuplicateCases_LC.getCase(myCase.id);

    }
    
}