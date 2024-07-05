global class BatchPurgeTask_Scheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchPurgeTask b = new BatchPurgeTask();
        database.executebatch(b);
    }
}