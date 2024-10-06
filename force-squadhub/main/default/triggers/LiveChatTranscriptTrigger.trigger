trigger LiveChatTranscriptTrigger on LiveChatTranscript (before insert , after insert , after update) {
    
    if (Trigger.isBefore && Trigger.isInsert) {
        LiveChatTranscriptTriggerHandler.matchClientByPhone(Trigger.new);
    }
    else if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter) {
        
        LiveChatTranscriptTriggerHandler.createTasksForLiveChat(Trigger.new);
    }
}