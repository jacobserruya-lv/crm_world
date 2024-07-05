global class IC_SchedulerBatchClMemberCleanUp implements Schedulable{

    global void execute(SchedulableContext sc) {

        IC_BatchClMemberCleanUp bat = new IC_BatchClMemberCleanUp();
        ID batchprocessid = Database.executeBatch(bat,1000);           
    }
}