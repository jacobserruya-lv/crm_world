/**
* @File Name          : TR_Integration_Manager_Trigger.trigger
* @Description        : 
* @Author             : Imad.alsidchikh.ext@louisvuitton.com
* @Group              : 
* @Last Modified By   : Imad.alsidchikh.ext@louisvuitton.com
* @Last Modified On   : 01-04-2022
* @Modification Log   : 
* Ver       Date            Author      		                     Modification
* 1.0       01-04-2022      Imad.alsidchikh.ext@louisvuitton.com     Initial Version
**/
trigger TR_Integration_Manager_Trigger on TECH_IntegrationManager__c (after insert , after update) {
     TR_Integration_TriggerHandler.handleTrigger(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.operationType);
}