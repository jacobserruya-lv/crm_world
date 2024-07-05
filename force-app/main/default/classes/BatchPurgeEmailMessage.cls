/**
    @Author : 	deborah.marciano
    Desc 	:   Batch to purge EmailMessage Object Before 90 days 
    V 1.0 	:   21/02/2024
**/

global class BatchPurgeEmailMessage implements Database.Batchable<sObject> {
    
    global String myQuery = '';
    global Integer createdBefore;
    global Integer EmailMessagesLimit;
        
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
     	List<PurgeEmailMessages__mdt> purgeSettings = PurgeEmailMessages__mdt.getAll().values();
        
        system.debug('purgeSettings' + purgeSettings);
        for (PurgeEmailMessages__mdt setting : purgeSettings) {
           system.debug('setting.ClauseWhere__c : '  + setting.ClauseWhere__c);
           
		   myQuery += '(' + setting.ClauseWhere__c + ') OR '; 
          	
            if (setting.numberOfDayBefore__c != null) {
                createdBefore = setting.numberOfDayBefore__c.intValue();
                
            }
			
            if (setting.Limit__c != null) {
                EmailMessagesLimit = setting.Limit__c.intValue();
                
            }
        } 
        
        if (createdBefore == null) {
            createdBefore = 0; 
        }
        
        if (EmailMessagesLimit == null) {
            EmailMessagesLimit = 10000; 
        }
     
        
        system.debug('createdBefore :' + createdBefore);
        system.debug('EmailMessagesLimit :' + EmailMessagesLimit);
        
        if (myQuery.endsWith(' OR ')) {
           myQuery = myQuery.substring(0, myQuery.length() - 4);
        }
        
        system.debug('myQueryBefore: ' + myQuery);
        myQuery = 'SELECT Id, CreatedDate FROM EmailMessage WHERE (' + myQuery + ') AND CreatedDate < LAST_N_DAYS:' + createdBefore + ' LIMIT ' + EmailMessagesLimit; 
        system.debug('myQueryAfter: ' + myQuery);
        return Database.getQueryLocator(myQuery);
    }

    global void execute(Database.BatchableContext bc, List<EmailMessage> records) {
		delete records;
    }
    
    global void finish(Database.BatchableContext bc) {
        
    }
}