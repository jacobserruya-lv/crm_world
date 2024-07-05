trigger ClientList_AfterInsert on CLI_CliList__c (after insert) {
    List<CLI_CliList__c> cLsToNotify = new List<CLI_CliList__c>();
    for(CLI_CliList__c cl: trigger.new) {
        if(cl.OwnerId != UserInfo.getUserId() && cl.Active__c) {
            cLsToNotify.add(cl);
        }
    }
    if(cLsToNotify.size() > 0) {
        IM_SendPushNotifications.ClientListSendPush(cLsToNotify);
    }

}