trigger Look_Trigger on Look__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    
    if(Trigger.isInsert && Trigger.isBefore) {
    	LookTriggerHandler.beforeInsert(Trigger.new, Trigger.newMap);
    } else if(Trigger.isUpdate && Trigger.isBefore) {
        LookTriggerHandler.beforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    } else if(Trigger.isInsert && Trigger.isAfter) {
        LookTriggerHandler.afterInsert(Trigger.new, Trigger.newMap);
    } else if(Trigger.isUpdate && Trigger.isAfter) {
        LookTriggerHandler.afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }

}