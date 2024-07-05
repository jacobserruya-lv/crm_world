global class BatchCWForClubMembersScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchCollectionWallForClubMembers cwMembers = new BatchCollectionWallForClubMembers(false, 1);
        Database.executeBatch(cwMembers, 200);
    }
}