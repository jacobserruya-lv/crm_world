global class IDENTITY_UserManagement_BATCH implements Database.Batchable<sObject>, Database.Stateful{
    
    public Integer records_counter = 0;
    public Integer success_counter = 0; 
    public Integer error_counter = 0;
    String errors_details = '';
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('START');

        IDENTITY_Settings__c identity_settings = IDENTITY_Settings__c.getInstance();       
        
        String query = 'SELECT Id FROM User WHERE Is_Identity_User__c = true AND IsActive = true AND LastLoginDate < LAST_N_DAYS:';
        query += (identity_settings.Deactivate_User_After__c == null ? 365 : Integer.valueOf(identity_settings.Deactivate_User_After__c));

        if(Test.isRunningTest()){
            query = 'SELECT Id FROM User WHERE Is_Identity_User__c = true AND IsActive = true LIMIT 10';
        }
        
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        System.debug('EXECUTE');

        records_counter += scope.size();
        
        for(User usr : (List<User>)scope){                   
            usr.IsActive = false;
        }
        
        Database.SaveResult[] result = Database.update(scope, false);
        
        for(Database.SaveResult res : result) {
            if(res.isSuccess()) {
                success_counter++;                
            } else {
                error_counter++;           
                errors_details += (res.Id + ': \n');
                for(Database.Error error : res.getErrors()){
                    Integer length = errors_details.length() + error.getMessage().length();
                    if(length > 131070){
                        errors_details += (error.getMessage() + '\n');
                    }
                }
            } 
        }

        String details = 'Total records to update: ' + records_counter + '\nBatch successes: ' + success_counter + '\nBatch failures: ' + error_counter + '\n' + errors_details;
        System.debug(details);
    }
    
    global void finish(Database.BatchableContext BC) {
        System.debug('FINISH');

        AsyncApexJob job = [SELECT Id, Status, ExtendedStatus
            FROM AsyncApexJob 
            WHERE Id = :BC.getJobId()
        ];

        String details = (!String.isEmpty(job.ExtendedStatus) ? job.ExtendedStatus : '') + '\n' + errors_details;

        System.debug(details);

        new Logs(new Map<String,Object> {
                'level' => 'INFO', 
                'apexClass' => 'IDENTITY_UserManagement_BATCH', 
                'category' => 'DATABASE',
                'message' => 'Total records to update: ' + records_counter + '\nBatch successes: ' + success_counter + '\nBatch failures: ' + error_counter + '\n',
                'status_code' => job.Status,
                'details' => details,
                'application' => 'SYSTEM'
            });
    }
}