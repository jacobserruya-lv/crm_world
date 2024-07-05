global without sharing class CampaignHistoryCleanerBatch implements Database.Batchable<sObject>, Database.Stateful {    
    private static final Integer BATCH_SIZE = 3000000;
    integer totalRecordsProcessed;

    global CampaignHistoryCleanerBatch(integer AllTotalRecordsProcessed) {
        System.debug('totalRecordsProcessed:' + AllTotalRecordsProcessed);
        totalRecordsProcessed = AllTotalRecordsProcessed;
        
    }
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date oneMonthAgo = System.today().addMonths(-1);
        String query = 'SELECT Id FROM Campaign_History__c where CreatedDate < :oneMonthAgo LIMIT 500000';
        return Database.getQueryLocator(query);

    }

     global void execute(Database.BatchableContext bc, List<sObject> records) {
            if(records.size() > 0) {
                try { 
                    Database.DeleteResult[] deleteResults = Database.delete(records, false);
                    totalRecordsProcessed += records.size();
                    System.debug('totalRecordsProcessed2 ' + totalRecordsProcessed);
                    
                }
                catch (Exception e) {
                    System.debug('Erreur de suppression : ' + e.getMessage());
                    
                }
            }
             else {
                 
                 totalRecordsProcessed = BATCH_SIZE;
             }
      }
    
	global void finish(Database.BatchableContext bc) {
        if(totalRecordsProcessed < BATCH_SIZE && !Test.isRunningTest()) {
            system.debug('FINISH ');
            CampaignHistoryCleanerBatch batch = new CampaignHistoryCleanerBatch(totalRecordsProcessed);
            Database.executeBatch(batch,200);    
             
        }
    }
}