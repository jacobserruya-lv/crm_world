@isTest
public class ICX_CreationWardrobingLook_Test {
    
     @testSetup static void setup() {
        Id personAccountRTId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('ACC_PersonAccount').getRecordTypeId();
        Account testAccts = new Account();
        testAccts.LastName='TestAcct0' ;
        testAccts.DREAMID__c='12345'; 
        testAccts.Gender__pc='Female';
        testAccts.RecordTypeId=personAccountRTId;
        insert testAccts;   
         
        PPR_PurchProduct__c testPurchProduct = new PPR_PurchProduct__c();
        testPurchProduct.Name='testPurchProduct';
        testPurchProduct.Client__c = testAccts.id;
		testPurchProduct.SKU__c = 'TST123';
		testPurchProduct.Store__c = 'T11';
		testPurchProduct.PurchasedDate__c = Date.today().addDays(1);
		testPurchProduct.TicketNumber__c = '123456';
        testPurchProduct.RMSSKUCode__c = 'TST123';

        insert testPurchProduct;   
 
    }
    
    @isTest static void testMethod1() {
        test.startTest();
        Account acct = [SELECT Id FROM Account WHERE Name='TestAcct0' LIMIT 1];
        string str= ICX_CreationWardrobingLook_LC.getRecords(acct.id);
        test.stopTest();
        
        System.assertNotEquals(null, str);

    }
    @isTest static void testMethod2() {
        test.startTest();
        PPR_PurchProduct__c ppr = [SELECT Id FROM PPR_PurchProduct__c WHERE Name='testPurchProduct' LIMIT 1];
        string str = ICX_CreationWardrobingLook_LC.getRecords(ppr.id);
        test.stopTest();
        System.assertNotEquals(null, str);
    }


}