trigger Event_AfterInsert on Event (after insert) {
    
    
   

    List<Event> myEvents = new List<Event>();
    if (IC_Utils.canTrigger('EVT_LASTCONTACTDATE')) {
        myEvents = IC_Event_TRG.toFilterEventList(trigger.new);
        if(myEvents != null ){
            IC_Event_TRG.eventSetAccLastContactDate(myEvents);
        }
    }
    Appointment_TriggerHandler.afterInsert(trigger.new, trigger.newMap);
}