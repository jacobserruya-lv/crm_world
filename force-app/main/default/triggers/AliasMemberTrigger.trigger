/**
 * @description       : Trigger for Alias_Member__c
 * @author            : Keman WU
 * @group             : 
 * @last modified on  : 15-06-2022
 * @last modified by  : Keman WU
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   15-06-2022   Keman WU   Initial Version
**/
trigger AliasMemberTrigger on Alias_Member__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    if(Trigger.isInsert && Trigger.isBefore) 
    AliasMember_TriggerHandler.beforeInsert(Trigger.new, Trigger.newMap);
}