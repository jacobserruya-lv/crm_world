global class BatchPurgeCaseTeamMember_Scheduler implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        BatchPurgeCaseTeamMember b = new BatchPurgeCaseTeamMember(0);
        database.executebatch(b,200);
    }
}