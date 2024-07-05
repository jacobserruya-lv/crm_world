global class TR_PurgeMergedClients implements Database.Batchable<sObject>, Database.Stateful {
String query;
    DateTime dt;
    Integer limitBatch;
    Transverse_Batchs_Setup__c setting;
    
    global TR_PurgeMergedClients() {
        setting = Transverse_Batchs_Setup__c.getAll().get('Batch Merge Clients');
        dt = DateTime.now().addDays(-(integer.valueOf(setting.Created_Before_Days__c)));
        query = 'SELECT Id FROM MergedClients__c  WHERE CreatedDate < :dt';
        limitBatch = integer.valueOf(setting.Limit__c);
        if(limitBatch != null){
            query = query + ' Limit :limitBatch';
        }
    }
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if(scope.size() > 0){
            System.debug(scope.Size());
            delete scope;
            Database.emptyRecycleBin(scope);
            
            setting.job_id__c = BC.getJobId();
            update setting;
        }
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
}