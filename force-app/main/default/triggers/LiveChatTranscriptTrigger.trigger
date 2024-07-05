trigger LiveChatTranscriptTrigger on LiveChatTranscript (before insert) {
    if (Trigger.isBefore && Trigger.isInsert) {
        LiveChatTranscriptTriggerHandler.matchClientByPhone(Trigger.new);
    }
}