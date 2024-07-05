global class IM_SchedulerAppointmentSyncBacth implements Schedulable{

    global void execute(SchedulableContext sc) {
        IM_BatchAppointmentTransactionSync bat = new IM_BatchAppointmentTransactionSync();
        ID batchprocessid = Database.executeBatch(bat);           
    }
}