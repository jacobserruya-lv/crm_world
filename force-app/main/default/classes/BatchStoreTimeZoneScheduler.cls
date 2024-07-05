global class BatchStoreTimeZoneScheduler implements Schedulable{

    global void execute(SchedulableContext sc) {
        BatchStoreTimeZone bat = new BatchStoreTimeZone();
        ID batchprocessid = Database.executeBatch(bat,10);           
    }
}