trigger Task_AfterDelete on Task (after delete) {
    Task_TriggerHandler.afterDelete(trigger.old);
}