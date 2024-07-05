trigger Attachment_AfterInsert on Attachment (after insert) {
    if (Trigger.isAfter && (Trigger.isInsert)) {
		Attachment_TriggerHandler.afterInsert(Trigger.new);
    }
}