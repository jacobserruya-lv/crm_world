global class IC_SchedulerClientMerge implements Schedulable{

    global void execute(SchedulableContext sc) {
        IC_BatchClientMerge bat = new IC_BatchClientMerge();
        integer batchSize = Integer.valueOf(Label.IC_ClientMergeBatchSize);
        ID batchprocessid = Database.executeBatch(bat,batchSize);           
    }
}