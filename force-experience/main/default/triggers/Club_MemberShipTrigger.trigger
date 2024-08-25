trigger Club_MemberShipTrigger on Club_MemberShip__c (before insert, after insert) {
    if (Trigger.isBefore) {
        if (Trigger.isInsert) {
            Club_MemberShipTriggerHandler.handleBeforeInsert(Trigger.New);
        }
    }
    else if (Trigger.isAfter) {
        if (Trigger.isInsert) {
            Club_MemberShipTriggerHandler.handleAfterInsert(Trigger.New);
        }
    }
}