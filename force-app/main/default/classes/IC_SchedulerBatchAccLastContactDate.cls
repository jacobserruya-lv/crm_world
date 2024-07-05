global class IC_SchedulerBatchAccLastContactDate implements Schedulable{

    global void execute(SchedulableContext sc) {

        IC_BatchTaskLastContactDate bat = new IC_BatchTaskLastContactDate();
        ID batchprocessid = Database.executeBatch(bat,1000);           
    }
}