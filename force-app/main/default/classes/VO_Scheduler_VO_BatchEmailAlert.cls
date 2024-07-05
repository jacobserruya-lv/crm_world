global class VO_Scheduler_VO_BatchEmailAlert implements Schedulable{

    global void execute(SchedulableContext sc) {

        VO_BatchEmailAlert bat = new VO_BatchEmailAlert();
        ID batchprocessid = Database.executeBatch(bat,60);           
    }
}