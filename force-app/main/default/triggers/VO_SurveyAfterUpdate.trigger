/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 05-12-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-06-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
trigger VO_SurveyAfterUpdate on VO_Survey__c (after update) {
	VO_Survey.updateTypeDate(Trigger.new);	
	ICON_Todos_Helper.afterUpdateVO_Survey(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap);
}