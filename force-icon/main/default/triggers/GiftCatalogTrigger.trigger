trigger GiftCatalogTrigger on GiftCatalog__c (before insert, before update) {
    GiftCatalogTriggerHandler.handleTrigger(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.operationType);
}