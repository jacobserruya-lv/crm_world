global class BatchStoreInfosScheduler implements Schedulable{

    global void execute(SchedulableContext sc) {
        BatchStoreInfos bat = new BatchStoreInfos();
        ID batchprocessid = Database.executeBatch(bat,5);           
    }
}