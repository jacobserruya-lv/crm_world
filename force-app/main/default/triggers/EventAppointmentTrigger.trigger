trigger EventAppointmentTrigger on Event (after insert, after update, before delete) {
    EventAppointmentTriggerHandler.handleTrigger(Trigger.new, Trigger.newMap, Trigger.old, Trigger.oldMap, Trigger.operationType);
}