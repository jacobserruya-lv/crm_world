global without sharing class BatchPurgeCaseTeamMember implements Database.Batchable<sObject>, Database.Stateful {
    // private static final Integer BATCH_SIZE_LIMIT = 1000000;
    integer totalRecordsProcessed;

    global BatchPurgeCaseTeamMember(integer allTotalRecordsProcessed) {
        totalRecordsProcessed = allTotalRecordsProcessed;
        System.debug('totalRecordsProcessed constructor' + totalRecordsProcessed );
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        Integer recordCount = [SELECT COUNT() FROM CaseTeamMember WHERE Parent.Status = 'Closed' AND Parent.ClosedDate < LAST_N_MONTHS:24];
        if (recordCount == 0) {
            return Database.getQueryLocator([SELECT Id FROM CaseTeamMember WHERE Id = null]);
        }

        String query = 'SELECT Id FROM CaseTeamMember WHERE Parent.Status = \'Closed\' AND Parent.ClosedDate < LAST_N_MONTHS:24 LIMIT 200000' ;
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext bc, List<sObject> records) {
        if (records.size() > 0) {
            try {
                Database.DeleteResult[] deleteResults = Database.delete(records, false);
                totalRecordsProcessed += records.size();
                system.debug('totalRecordsProcessed ' + totalRecordsProcessed);
            } catch (Exception e) {
                System.debug('Erreur de suppression : ' + e.getMessage());
            }
        }
    }

    global void finish(Database.BatchableContext bc) {
        System.debug('Total records processed: ' + totalRecordsProcessed);
      //  if (totalRecordsProcessed < BATCH_SIZE_LIMIT && !Test.isRunningTest()) {
            Integer remainingRecordCount = [SELECT COUNT() FROM CaseTeamMember WHERE Parent.Status = 'Closed' AND Parent.ClosedDate < LAST_N_MONTHS:24];
            if (remainingRecordCount > 0) {
                System.debug('totalRecordsProcessed du finish' + totalRecordsProcessed);
                BatchPurgeCaseTeamMember batch = new BatchPurgeCaseTeamMember(totalRecordsProcessed);
                Database.executeBatch(batch);
            }
       // }
    }
}