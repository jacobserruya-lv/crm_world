trigger TaskAssistant on TaskAssistant__c (after insert) {
    TaskAssistantTriggerHandler.handleTrigger(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.operationType);
}