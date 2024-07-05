public with sharing class BadgeCatalogTriggerHandler {
    public static void handleTrigger(List<Badge_Collection__c> newList, Map<Id, Badge_Collection__c> newMap, List<Badge_Collection__c> oldList, Map<Id, Badge_Collection__c> oldMap, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when BEFORE_INSERT {
                handleBeforeInsert(newList);
            }
            when BEFORE_UPDATE {
                handleBeforeUpdate(newList, oldMap);
            }
            when else {
                //do nothing for AFTER_UNDELETE, BEFORE_DELETE, or BEFORE_UPDATE
            }
        }
    }

    public static void handleBeforeInsert(List<Badge_Collection__c> newList) {
        for (Badge_Collection__c badgeCollection : newList) {
            badgeCollection.UniqueKey__c = badgeCollection.member_Id__c + '_' + badgeCollection.badgeId__c;
        }
    }

    public static void handleBeforeUpdate(List<Badge_Collection__c> newList, Map<Id, Badge_Collection__c> oldMap) {
        for (Badge_Collection__c badgeCollection : newList) {
            Badge_Collection__c oldBadge = oldMap.get(badgeCollection.Id);

            if (badgeCollection.badgeFlag__c && !oldBadge.badgeFlag__c) {
                badgeCollection.badgeFlagIsTrueDate__c = System.today();
            }
        }
    }
}