global class BatchCAClubMembershipScheduler implements Schedulable {
    global void execute(SchedulableContext sc) {
        BatchCAClubMembership memberShip = new BatchCAClubMembership('Sneakers');
        Database.executeBatch(memberShip, 200);        
    }
}