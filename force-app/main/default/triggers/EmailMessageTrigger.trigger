trigger EmailMessageTrigger on EmailMessage (before insert, before update, after insert, after update) {

    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            EmailMessageTriggerHandler.handleBeforeInsert(Trigger.new);
        }
    }

    if(Trigger.isAfter){
    	if(Trigger.isInsert){
    		EmailMessageTriggerHandler.handleAfterInsert(Trigger.new);
    	}
    }
}