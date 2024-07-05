/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-12-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-04-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
trigger CaseTrigger on Case (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    
    if(Trigger.isInsert && Trigger.isBefore) {
    	CaseTriggerHandler.beforeInsert(Trigger.new, Trigger.newMap);
    } else if(Trigger.isUpdate && Trigger.isBefore) {
      CaseTriggerHandler.beforeUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    } else if(Trigger.isInsert && Trigger.isAfter) {
        CaseTriggerHandler.afterInsert(Trigger.new, Trigger.newMap);
        ICON_Todos_Helper.afterInsertCase(Trigger.new, Trigger.newMap); 
    } else if(Trigger.isUpdate && Trigger.isAfter) {
        CaseTriggerHandler.afterUpdate(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
        ICON_Todos_Helper.afterUpdateCase(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
    } else if(Trigger.isDelete && Trigger.isAfter) {
        CaseTriggerHandler.afterDelete(Trigger.old, Trigger.oldMap);
    }

}