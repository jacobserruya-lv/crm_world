@isTest
public with sharing class BL_ICON_BatchCleanToDoAssistant_TEST {
    
    @testsetup static void setupMethod(){
        Account acc =  new Account(LastName = 'test');
        insert acc;
         
        User u = IC_Test_Common.prepareTestUser('System Administrator');
        insert u;
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = 'A06');
        insert store;
        
        CareService__c c = new CareService__c(Client__c = acc.id, store__c = store.id, StoreRetailCode__c = store.RetailStoreId__c,MessageToCA__c='Quotation to validate',IsToDo__c=true,CA__c=u.id);
        insert c;
         
        Case ca = new Case( Country__c ='FRANCE', AccountId = acc.id, store__c = store.id,OwnerId=u.id,status='New',CA_Name__c=u.id,Resolution__c='Request to Store');
        insert ca;  
         
   }

   @isTest static void test_Todo_BatchCleanAssistant() {
		
    Test.startTest();
    String jobId = Database.executeBatch(new BL_ICON_BatchCleanToDoAssistant(), 200);

    Test.stopTest();
   }
}