trigger ProductReferentialTrigger on ProductReferential__c (before insert, after insert, before update, after update, before delete, after delete, after undelete) {
        if (Trigger.isInsert) {
            if (Trigger.isBefore) {
                ProductReferentialTriggerHandler.handleBeforeInsert(Trigger.new);
            } else if (Trigger.isAfter) {
                ProductReferentialTriggerHandler.handleAfterInsert(Trigger.new);
            }            
        } else if (Trigger.isUpdate) {
            if (Trigger.isBefore) {
                ProductReferentialTriggerHandler.handleBeforeUpdate(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
            } else if (Trigger.isAfter) {
                ProductReferentialTriggerHandler.handleAfterUpdate(Trigger.old, Trigger.oldMap, Trigger.new, Trigger.newMap);
            }            
        }
}