public class ScheduleUpdateOpportunityBatch implements Schedulable {

    public void execute(SchedulableContext context) {
        UpdateOpportunityBatch batchJob = new UpdateOpportunityBatch();
        Database.executeBatch(batchJob);
    }
}