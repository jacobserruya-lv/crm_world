global with sharing class Club_DeleteMembershipQueue implements Queueable {
    List<Club_MemberShip__c> membersToDelete = new List<Club_MemberShip__c>();

    public Club_DeleteMembershipQueue(List<Club_MemberShip__c> members) {
        membersToDelete = members;
    }

    global void execute(QueueableContext context) {
        Database.delete(membersToDelete, false);
    }
}