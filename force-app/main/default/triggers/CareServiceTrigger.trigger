/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-10-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-03-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
trigger CareServiceTrigger on CareService__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    
    if(Trigger.isInsert && Trigger.isBefore) {
    	CareService_TriggerHandler.beforeInsert(Trigger.new, Trigger.newMap);
    } else if(Trigger.isUpdate && Trigger.isBefore) {
      CareService_TriggerHandler.beforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    } else if(Trigger.isInsert && Trigger.isAfter) {
        CareService_TriggerHandler.afterInsert(Trigger.new, Trigger.newMap);
        ICON_Todos_Helper.afterInsertCareService(Trigger.new, Trigger.newMap);
    } else if(Trigger.isUpdate && Trigger.isAfter) {
        CareService_TriggerHandler.afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        ICON_Todos_Helper.afterUpdateCareService(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    }

}