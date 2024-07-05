global class IM_DeactivateExpiredClientListsBatch implements Database.Batchable<sObject> {

    global database.querylocator start(Database.BatchableContext CD){
        string query  = 'SELECT Id, Active__c FROM CLI_CliList__c WHERE Active__c = TRUE AND ExpirationDate__c < YESTERDAY';
        return Database.getQueryLocator(query);   
    } 

    global void execute(Database.BatchableContext CD, List<CLI_CliList__c> cliLists){
        for(CLI_CliList__c cli: cliLists) {
            cli.Active__c = false;
        }
        update cliLists;
    }

    global void finish(Database.BatchableContext CD){}

}