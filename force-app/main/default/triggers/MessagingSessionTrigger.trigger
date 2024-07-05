trigger MessagingSessionTrigger on MessagingSession (before insert,after update,after insert) {
    MessagingSessionTriggerHandler.handleTrigger(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.operationType);
}