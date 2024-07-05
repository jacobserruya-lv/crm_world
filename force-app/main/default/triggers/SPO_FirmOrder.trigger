trigger SPO_FirmOrder on SPO_FirmOrder__c (before insert, after insert, before update, after update) {
	if (Trigger.isInsert) {
		if (Trigger.isBefore) {
			FirmOrderTriggerHandler.handleBeforeInsert(Trigger.new, Trigger.newMap);
		}
		if (Trigger.isAfter) {
			FirmOrderTriggerHandler.handleAfterInsert(Trigger.new, Trigger.newMap);
		}
	}

	if (Trigger.isUpdate) {
		if (Trigger.isBefore) {
			FirmOrderTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.oldMap);
		}
		if (Trigger.isAfter) {
			FirmOrderTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);

		}
	}

	if (Trigger.isDelete) {
		if (Trigger.isBefore) {

		}
		if (Trigger.isAfter) {

		}
	}

	if (Trigger.isUndelete) {

	}
}