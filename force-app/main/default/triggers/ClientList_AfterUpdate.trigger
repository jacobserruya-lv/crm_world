trigger ClientList_AfterUpdate on CLI_CliList__c (after update) {
    List<CLI_CliList__c> cLsToNotify = new List<CLI_CliList__c>();
    for(CLI_CliList__c cl: trigger.new) {
        if(cl.OwnerId != UserInfo.getUserId() && cl.Active__c && (cl.Active__c != trigger.oldMap.get(cl.Id).Active__c) && !cl.TECH_PushNotified__c) {
            cLsToNotify.add(cl);
        }
    }
    if(cLsToNotify.size() > 0) {
        IM_SendPushNotifications.ClientListSendPush(cLsToNotify);
    }
}