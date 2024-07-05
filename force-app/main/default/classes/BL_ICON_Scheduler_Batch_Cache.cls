global class BL_ICON_Scheduler_Batch_Cache implements Schedulable{

    global void execute(SchedulableContext sc) {

        BL_ICON_Batch_Cache bat = new BL_ICON_Batch_Cache();
        ID batchprocessid = Database.executeBatch(bat,2);
    }
}