trigger ExperienceVariationGuestTrigger on Brand_Experience_Variation_Member_Guest__c (before insert,after insert, after update, after delete) {
    ExperienceVariationGuestTriggerHandler.handleTrigger(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.operationType);
}