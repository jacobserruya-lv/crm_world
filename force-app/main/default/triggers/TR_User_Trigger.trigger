/**
* @File Name          : TR_User_Trigger.trigger
* @Description        : 
* @Author             : hamza.bouzid.ext@louisvuitton.com
* @Group              : 
* @Last Modified By   : hamza.bouzid.ext@louisvuitton.com
* @Last Modified On   : 13-01-2023
* @Modification Log   : 
* Ver       Date            Author      		                     Modification
* 1.0       13-01-2023       hamza.bouzid.ext@louisvuitton.com     Initial Version
**/
trigger TR_User_Trigger on User (before insert, before update, after update, after insert) {
    TR_User_TriggerHandler.handleTrigger(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.operationType);
}