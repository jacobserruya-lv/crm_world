global class BatchPurgeEmailMessage_Scheduler implements Schedulable {
     global void execute(SchedulableContext sc) {
            BatchPurgeEmailMessage b = new BatchPurgeEmailMessage();
            database.executebatch(b);
     }
}