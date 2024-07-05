trigger Opportunity on Opportunity (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

		if (Trigger.isBefore) {
			if (Trigger.isUpdate) {
				OpportunityTriggerHandler.handleBeforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
			}
			if (Trigger.isInsert){
				OpportunityTriggerHandler.handleBeforeInsert(Trigger.new, Trigger.newMap);
			}
	    
		} else if (Trigger.isAfter) {
	    	if (Trigger.isUpdate) {
	           OpportunityTriggerHandler.handleAfterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
	        }

	        if (Trigger.isInsert){
	            OpportunityTriggerHandler.handleAfterInsert(Trigger.new, Trigger.newMap);
	        }
		}
}