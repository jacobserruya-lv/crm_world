@isTest
private class CampaignHistoryCleanerBatch_Test {
    private static final Integer BATCH_SIZE = 20;
    
    @testSetup
    static void setup() {
         Date oneMonthAgo = System.today().addMonths(-1);
        
        Account account = ICX_TestFactory.createAccount();
        insert account;
        
        List<Campaign_History__c> campaignHistoryList = new List<Campaign_History__c>();
        for (Integer i = 0; i < 20; i++) {
            campaignHistoryList.add(new Campaign_History__c(
                CreatedDate = oneMonthAgo.addDays(-1), Client__c=account.Id
            ));
        }
        
        insert campaignHistoryList;
    }
  
    @isTest
    static void testBatchExecutionWithRecords() {
        Date oneMonthAgo = System.today().addMonths(-1);
        Test.startTest();
        CampaignHistoryCleanerBatch batch = new CampaignHistoryCleanerBatch(0); 
        Test.stopTest();

        Integer campaignHistoryCount = [SELECT COUNT() FROM Campaign_History__c WHERE CreatedDate < :oneMonthAgo];
        System.assertEquals(20, campaignHistoryCount, 'Tous les enregistrements ont été supprimés.');
    }
    
    
    @isTest
    static void testBatchExecutionWithRemainingRecords() {
        Date oneMonthAgo = System.today().addMonths(-1);
        Test.startTest();
        CampaignHistoryCleanerBatch batch = new CampaignHistoryCleanerBatch(BATCH_SIZE - 1); 
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
        Integer campaignHistoryCount = [SELECT COUNT() FROM Campaign_History__c WHERE CreatedDate < :oneMonthAgo];
        System.assertEquals(0, campaignHistoryCount, 'Des enregistrements restants n\'ont pas été supprimés.');
    }
 /*   
    @isTest
    static void testBatchExecutionWithRecursiveCall() {
        Date oneMonthAgo = System.today().addMonths(-1);
      
        Test.startTest();
        CampaignHistoryCleanerBatch batch = new CampaignHistoryCleanerBatch(0); 
        Id batchId = Database.executeBatch(batch, 10);
        Test.stopTest();
    
        Integer campaignHistoryCountAfterFirstRun = [SELECT COUNT() FROM Campaign_History__c WHERE CreatedDate < :oneMonthAgo];
        System.assertEquals(10, campaignHistoryCountAfterFirstRun, 'Il devrait rester des enregistrements après un traitement partiel.');
       
     }
*/   
}