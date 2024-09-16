trigger ExperienceVariationMember on Brand_Experience_Variation_Member__c (before insert, after insert, before update ,after update) {
    ExperienceVariationMemberTriggerHandler.handleTrigger(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.operationType);
}