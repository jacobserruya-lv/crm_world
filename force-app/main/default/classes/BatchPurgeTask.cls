/**
    @Author : 	deborah.marciano
    Desc 	:   Batch to purge EmailMessage Object Before 90 days 
    V 1.0 	:   30/04/2024
**/


global class BatchPurgeTask implements Database.Batchable<sObject> {

    global String myQuery = '';
    global Integer createdBefore;
    global Integer taskLimit;
    global String moreCondition = '';
    global Integer highestLimit = 0;

    global Database.QueryLocator start(Database.BatchableContext bc) {
        List<PurgeTask__mdt> purgeSettings = PurgeTask__mdt.getAll().values();
        
        for (PurgeTask__mdt setting : purgeSettings) {
            if (setting.numberOfDayBefore__c != null) {
                createdBefore = setting.numberOfDayBefore__c.intValue();
            }
            else{
                createdBefore = 180;
            } 
            
            if (setting.ClauseWhere__c != null) {
                moreCondition = ' AND ' + setting.ClauseWhere__c;
            }
            else {
                moreCondition = '';
            }
            myQuery += '(RecordType.Name = \''+ setting.RecordTypeName__c + '\' '+ moreCondition+ ' AND CreatedDate < LAST_N_DAYS:' + createdBefore + ') OR ' ;
            
            if (setting.Limit__c != null && setting.Limit__c.intValue() > highestLimit) {
               highestLimit = setting.Limit__c.intValue();
             }
        }
        
        if (highestLimit > 0) {
            taskLimit = highestLimit;
        } else {
            taskLimit = 500000;
		}
        
        if (myQuery.endsWith(' OR ')) {
           myQuery = myQuery.substring(0, myQuery.length() - 4);
        } 
        myQuery = 'SELECT Id, RecordType.Name FROM Task WHERE (' + myQuery + ') LIMIT ' + taskLimit;
        System.debug('myQuery: '+ myQuery);
        return Database.getQueryLocator(myQuery);
    }

    global void execute(Database.BatchableContext bc, List<Task> records) {
        delete records;
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
}