/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-14-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   06-14-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
trigger Event_AfterUpdate on Event (after update) {

    List<Event> myEvents = new List<Event>();
    if (IC_Utils.canTrigger('EVT_LASTCONTACTDATE')) {
        myEvents = IC_Event_TRG.toFilterEventList(trigger.new);
        if(myEvents!=null){
            IC_Event_TRG.eventSetAccLastContactDate(myEvents);
        }  
    }

    Appointment_TriggerHandler.afterUpdate(trigger.new, trigger.oldMap);
}