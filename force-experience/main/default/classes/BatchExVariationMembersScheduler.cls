global class BatchExVariationMembersScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchExVariationMembersForClubMembers batchExVariationMember = new BatchExVariationMembersForClubMembers();
        Database.executeBatch(batchExVariationMember, 200);        
    }
}