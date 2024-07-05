/**
* @File Name          : TR_SocialMediaIdentifier_Trigger.trigger
* @Description        : 
* @Author             : Imad.alsidchikh.ext@louisvuitton.com
* @Group              : 
* @Last Modified By   : Imad.alsidchikh.ext@louisvuitton.com
* @Last Modified On   : 01-11-2022
* @Modification Log   : 
* Ver       Date            Author      		                     Modification
* 1.0       01-11-2022      Imad.alsidchikh.ext@louisvuitton.com     Initial Version
**/
trigger TR_SocialMediaIdentifier_Trigger on Social_Media_Identifier__c (before insert, before update, after insert , after update) {
    TR_Constants.startTime = System.now();
    TR_SocialMediaIdentifierHandler.handleTrigger(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.operationType);
}