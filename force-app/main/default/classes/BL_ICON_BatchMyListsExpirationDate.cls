global with sharing class BL_ICON_BatchMyListsExpirationDate implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public String query;
    

    global BL_ICON_BatchMyListsExpirationDate() {
        String dateToCheck = DateTime.now().addDays(7).format('yyyy-MM-dd');
        query = 'SELECT id, ExpirationDate__c,  Name, IsMasterClientList__c, Type__c, OwnerId, CreatedById FROM CLI_CliList__c WHERE ExpirationDate__c = '+ dateToCheck +' and IsMasterClientList__c = false and Type__c = \'Regular\' and TECH_PushNotified__c = false';
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        Map<String, CLI_CliList__c> listsFound = new Map<String, CLI_CliList__c>();
        List<CLI_CliList__c> listsToCheck = new List<CLI_CliList__c>();
        List<CLI_CliList__c> listsToUpdate = new List<CLI_CliList__c>();
        for(sObject s : scope){
            CLI_CliList__c cli =  (CLI_CliList__c) s;
            listsFound.put(cli.id, cli);
            listsToCheck.add(cli);
        }

        for(CLI_CliList__c cli  : listsToCheck){
            if(cli.OwnerId == cli.CreatedById){
                listsToUpdate.add(cli);
            }
        }
        if(listsToUpdate.size() > 0){
            IM_SendPushNotifications.ClientListExpirationSendPush(listsToUpdate);
        }
    }

    global void finish(Database.BatchableContext CD){}
}