trigger TracabilityRecordTrigger on Export_Purchases_Tracability__c (after insert, after update) {
    TracabilityRecordTriggerHandler.handleTrigger(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.operationType);
}