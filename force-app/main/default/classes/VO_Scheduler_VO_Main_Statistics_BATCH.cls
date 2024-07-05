global class VO_Scheduler_VO_Main_Statistics_BATCH implements Schedulable{

    global void execute(SchedulableContext sc) {

        VO_Main_Statistics_BATCH bat = new VO_Main_Statistics_BATCH();
        ID batchprocessid = Database.executeBatch(bat,60);           
    }
}