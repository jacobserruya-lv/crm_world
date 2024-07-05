global class LogsCleaner_Batch implements Database.Batchable<sObject> {
    
    String query;

    Global_Settings__mdt gsFrom = Global_Settings__mdt.getInstance('Logs_Cleaner_Date_Support');
    Global_Settings__mdt gsTo = Global_Settings__mdt.getInstance('Logs_Cleaner_Date_End_Support');
    
    DateTime dtFrom, dtTo;

    global LogsCleaner_Batch() {
    
        // Always a default value
        Integer daysFrom = gsFrom != null ? Integer.valueOf(gsFrom.Value__c) * -1 : -7;
        dtFrom = System.now().addDays(daysFrom);
        System.debug('Date From:' + dtFrom);
    
        // If no metadata value, no limit on the end date
        Integer daysTo;        
        if(gsTo != null && gsTo.Value__c != '0'){
            daysTo = Integer.valueOf(gsTo.Value__c) * -1;
            dtTo = System.now().addDays(daysTo);
        }
    
        query = 'SELECT Id FROM Logs__c WHERE CreatedDate < :dtFrom';
        System.debug('Date To:' + dtTo);
        if(dtTo != null){
            query += ' AND CreatedDate > :dtTo';
        }
        
        System.debug('Query:' + query);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if(scope.size() > 0){
           delete scope;
       }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
}