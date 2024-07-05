trigger  KnowledgeTrigger on Knowledge__kav (before insert, before update, after insert, after update){
    KnowledgeTriggerHandler.handleTrigger(Trigger.new,Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.operationType);
}