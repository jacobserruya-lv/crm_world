global class IC_SchedulerBactchClUpLogClean implements Schedulable{

    global void execute(SchedulableContext sc) {

        IC_BatchClUpLogCleanUp bat = new IC_BatchClUpLogCleanUp();
        ID batchprocessid = Database.executeBatch(bat,1000);           
    }
}