@isTest
public class BL_ICON_BatchEngagedClientTask_TEST {
    @testsetup static void setupMethod(){
        
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = 'A06');
        insert store;
        
        User u = IC_Test_Common.prepareTestUser('ICON_SA');
        u.DefaultStore__c = store.RetailStoreId__c;
        U.Country = 'HONG KONG';
        insert u;
        
        Account acc =  new Account(LastName = 'test', BoundToLVLine__c = false, PrimaryCountry__pc = 'JAPAN');
        acc.CA_Engaged__c = u.Id;
        acc.End_Engagement_date__c = System.today().addDays(10);
        insert acc;
   
    }
    
     @isTest static void test_batchUpdateLineClients() {
        
         User u = [SELECT id, Name,Country, DefaultStore__c FROM user  limit 1];
         system.runAs(u){ 
             Test.startTest();
        String jobId = Database.executeBatch(new BL_ICON_BatchEngagedClientTask(), 200);
         

    Test.stopTest();
         }
        
   }
}