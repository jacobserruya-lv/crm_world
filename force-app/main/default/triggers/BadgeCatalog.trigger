trigger BadgeCatalog on Badge_Collection__c (before insert, before update) {
    BadgeCatalogTriggerHandler.handleTrigger(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.operationType);
}