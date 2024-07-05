trigger Ca_ConsentTrigger on Ca_Consent__c (before insert , before update) {

    Ca_ConsentTriggerHandler.handleTrigger(Trigger.new, Trigger.oldMap, Trigger.operationType);
}