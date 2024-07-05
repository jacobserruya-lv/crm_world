global class IM_SchedulerCareServiceStatusFlow implements Schedulable{

    global void execute(SchedulableContext sc) {
        IM_BatchCareServiceStatusFlow bat = new IM_BatchCareServiceStatusFlow();
        ID batchprocessid = Database.executeBatch(bat);           
    }
}