trigger FavoriteClubMember on Favorite_Club_Member__c (before insert, after insert, after delete) {
    FavoriteClubMemberTriggerHandler.handleTrigger(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.operationType);
}