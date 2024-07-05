global class CT_CreateClientMembersBatch implements Database.Batchable<sObject>, Database.Stateful {
    List<CLM_CliListMember__c> membersList = new List<CLM_CliListMember__c>();
    List<String> membersForNotifications = new List<String>();
    List<String> alreadyNotifiedIds = new List<String>();
    String type;

    public CT_CreateClientMembersBatch(List<CLM_CliListMember__c> cmList, List<String> alreadyNotified, String clType) {
        membersList = cmList;
        alreadyNotifiedIds = alreadyNotified;
        type = clType;
    }

    global List<CLM_CliListMember__c> start(Database.BatchableContext BC) {
        return membersList;
    }
    
    global void execute(Database.BatchableContext BC, List<CLM_CliListMember__c> cmList) {
        System.debug('cmList before insert: ' + cmlist.size());
        List<Database.SaveResult> srList = Database.Insert(cmList, false);
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {               
                membersForNotifications.add(sr.getId());
            }
        }
    }   
     
    global void finish(Database.BatchableContext BC) {
        System.debug('membersForNotifications: ' + membersForNotifications.size() + ': ' + membersForNotifications);
        if (membersForNotifications.size() > 0 && type == 'exclusive') {
            CT_CreateNotificationsForCLMBatch notificationsBatch = new CT_CreateNotificationsForCLMBatch(membersForNotifications, alreadyNotifiedIds);
            Database.executeBatch(notificationsBatch, 200);
        }
    }
}