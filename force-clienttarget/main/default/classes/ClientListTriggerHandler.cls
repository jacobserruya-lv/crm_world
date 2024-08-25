public without sharing class ClientListTriggerHandler {
    public static void handleBeforeDelete(List<CLI_CliList__c> clList) {
        List<Id> masterListsIds = new List<Id>();
    
        for (CLI_CliList__c cl : clList) {
            if (cl.IsMasterClientList__c) {
                masterListsIds.add(cl.Id);
            }
        }
    
        List<CLI_CliList__c> childrenClientList = [
          SELECT Id
          FROM CLI_CliList__c
          WHERE Master_Client_List__c IN :masterListsIds
        ];
    
        if (!childrenClientList.IsEmpty()) {
            delete childrenClientList;
        }
    }
    
    public static void handleAfterUpdate(List<CLI_CliList__c> clList) {
        Map<Id, CLI_CliList__c> masterClById = new Map<Id, CLI_CliList__c>();

        for (CLI_CliList__c cl : clList) {
            if (cl.IsMasterClientList__c) {
                masterClById.put(cl.Id, cl);
            }
        }

        List<CLI_CliList__c> childrenClientList = [
            SELECT Name,
                Description__c,
                ExpirationDate__c,
                Active__c,
                Master_Client_List__c
            FROM CLI_CliList__c
            WHERE Master_Client_List__c IN :masterClById.keySet()
        ];

        for (CLI_CliList__c cl : childrenClientList) {
            cl.Name = masterClById.get(cl.Master_Client_List__c).Name;
            cl.Description__c = masterClById.get(cl.Master_Client_List__c).Description__c;
            cl.ExpirationDate__c = masterClById.get(cl.Master_Client_List__c).ExpirationDate__c;
            cl.Active__c = masterClById.get(cl.Master_Client_List__c).Active__c;
        }

        if (!childrenClientList.IsEmpty()) {
            update childrenClientList;
        }
    }
}