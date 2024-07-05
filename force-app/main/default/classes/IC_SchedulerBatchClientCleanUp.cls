global class IC_SchedulerBatchClientCleanUp implements Schedulable{

    global void execute(SchedulableContext sc) {

        IC_BatchClientCleanUp bat = new IC_BatchClientCleanUp();
        ID batchprocessid = Database.executeBatch(bat,1000);           
    }
}