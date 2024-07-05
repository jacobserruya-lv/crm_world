trigger MessagingEndUserTrigger on MessagingEndUser (before insert) {
    MessagingEndUserTriggerHandler.handleTrigger(Trigger.new,Trigger.operationType);

}