trigger CareServiceLineItemTrigger on CareServiceLineItem__c (before insert, before update) {

    if(Trigger.isInsert && Trigger.isBefore) {
    	CareServiceLineItem_TriggerHandler.beforeInsert(Trigger.new);
    }
     if(Trigger.isUpdate && Trigger.isBefore) {
    	CareServiceLineItem_TriggerHandler.beforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }
}