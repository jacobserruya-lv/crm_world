/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-07-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-06-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/

trigger VO_SurveyAfterInsert on VO_Survey__c (After insert) {

    // update type field after scoring formulas have computed
    Vo_Survey.updateScoring(Trigger.new);
    VO_Survey.updateTypeDate(Trigger.new);
    VO_Survey.sendPushVO(Trigger.new);

 }