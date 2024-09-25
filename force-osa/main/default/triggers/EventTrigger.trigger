trigger EventTrigger on Event (before delete) {
    Appointment_TriggerHandler.handleTrigger(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.operationType); 
}