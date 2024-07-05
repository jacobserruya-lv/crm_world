/**
* @File Name          : TR_C360Integration_TriggerHandler.trigger
* @Description        : 
* @Author             : hamza.bouzid.ext@louisvuitton.com
* @Group              : 
* @Last Modified By   : hamza.bouzid.ext@louisvuitton.com
* @Last Modified On   : 16-09-2022
* @Modification Log   : 
* Ver       Date            Author      		                     Modification
* 1.0       16-09-2022       hamza.bouzid.ext@louisvuitton.com     Initial Version
**/
trigger TR_ActionPlan_Trigger on ActionPlan__c (before insert, before update) {
    System.debug(IC_Utils.canTrigger('BANNEDWORDS'));
    TR_ActionPlan_TriggerHandler.handleTrigger(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.operationType);
}