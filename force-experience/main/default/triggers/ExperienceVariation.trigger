trigger ExperienceVariation on Brand_Experience_Variation__c (before insert, after update, before update) {
    ExperienceVariationTriggerHandler.handleTrigger(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.operationType);
}