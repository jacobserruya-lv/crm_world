/**
 * @description       : Trigger for ShipmentTracking__c
 * @author            : Keman WU
 * @group             : 
 * @last modified on  : 27-05-2022
 * @last modified by  : Keman WU
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   27-05-2022   Keman WU   Initial Version
**/
trigger ShipmentTrackingTrigger on ShipmentTracking__c (before insert, before update, after insert, after update, before delete, after delete, after undelete) {
    if(Trigger.isInsert && Trigger.isBefore) 
    	ShipmentTracking_TriggerHandler.beforeInsert(Trigger.new, Trigger.newMap);
   
}