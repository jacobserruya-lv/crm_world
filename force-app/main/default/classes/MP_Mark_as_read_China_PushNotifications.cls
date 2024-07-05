public with sharing class MP_Mark_as_read_China_PushNotifications implements Database.Batchable<sObject>{

    String query;

    public MP_Mark_as_read_China_PushNotifications() {
        //TO REMOVE 'System Administrator'
        Map<String,Profile> SAprofiles = new Map<String, Profile> ([SELECT id FROM profile WHERE name in ('ICON_SA', 'ICON_SA Manager', 'ICON_SAManager_EVERYWHERE','System Administrator')]);
        Set<String> SAprofilesIds = SAprofiles.keySet();
        query = 'SELECT id, IsRead__c from Push_Notification_Recipient__c WHERE IsRead__c = False AND CreatedDate < LAST_N_DAYS:7 AND UserId__c IN (SELECT Id FROM User WHERE MGMT_ZONE_SUB_LEVEL1__c = \'1071\' AND DefaultStore__c <> NULL  AND IsActive = true AND ProfileId IN (' + listToString(SAprofilesIds) +'))';
    }

    public Database.QueryLocator start(Database.BatchableContext BC){

        return Database.getQueryLocator(query);

    }
  
    public void execute(Database.BatchableContext BC, List<sObject> notifications){
        List<Push_Notification_Recipient__c> notificationToUpdate = new List<Push_Notification_Recipient__c>();
        for(sObject notif : notifications){
            Push_Notification_Recipient__c pushNotification = (Push_Notification_Recipient__c) notif;
            pushNotification.IsRead__c = true;
            notificationToUpdate.add(pushNotification);
        }
        update notificationToUpdate;
    }

    public void finish(Database.BatchableContext BC){

    }

    public static String listToString (Set<String> stringSet){
        List<String> stringList = new List<String>();
        stringList.addAll(stringSet);
        return '\''+ String.join(stringList, '\',\'') + '\'';
    }

}