public with sharing class FavoriteClubMemberTriggerHandler {
    public static void handleTrigger(List<Favorite_Club_Member__c> newList, Map<Id, Favorite_Club_Member__c> newMap, List<Favorite_Club_Member__c> oldList, Map<Id, Favorite_Club_Member__c> oldMap, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when BEFORE_INSERT {
                handleBeforeInsert(newList);
            }
            when AFTER_INSERT {
                handleAfterInsert(newList);
            }
            when AFTER_DELETE {
                handleAfterDelete(oldList);
            }
            when else {
                //do nothing for AFTER_UNDELETE, BEFORE_DELETE, or BEFORE_UPDATE
            }
        }
    }

    public static void handleBeforeInsert(List<Favorite_Club_Member__c> newList) {
        for (Favorite_Club_Member__c favorite : newList) {
            favorite.UniqueKey__c = favorite.clubMemberId__c + '_' + favorite.favoriteClubMemberId__c;
        }
    }
    public static void handleAfterInsert(List<Favorite_Club_Member__c> newList) {
        updateFollowingFollowersCount(newList, 'inc');
    }
    public static void handleAfterDelete(List<Favorite_Club_Member__c> oldList) {
        updateFollowingFollowersCount(oldList, 'dec');
    }
    private static void updateFollowingFollowersCount(List<Favorite_Club_Member__c> clubMembersList, String operation) {
        List<Id> followingIds = new List<Id>();
        List<Id> followerIds = new List<Id>();
        for (Favorite_Club_Member__c fvrt : clubMembersList) {
            followingIds.add(fvrt.clubMemberId__c);
            followerIds.add(fvrt.favoriteClubMemberId__c);
        }
        queryAndUpdateRecords(followingIds, followerIds, operation);
    }
    private static void queryAndUpdateRecords(List<Id> followingIds, List<Id> followerIds, String operation) {
        Map<Id, Club_Membership__c> updatedFollowRecords = new Map<Id, Club_Membership__c>();
        for (Club_Membership__c member : [SELECT Id, Following_Count__c, follower_Count__c FROM Club_Membership__c WHERE (Id IN:followingIds OR Id IN:followerIds) AND isClubEligible__c=True AND isMember__c=True]) {
            member.Following_Count__c=member.Following_Count__c==null?0:member.Following_Count__c;            
            member.follower_Count__c=member.follower_Count__c==null?0:member.follower_Count__c;
            switch on operation {
                when 'inc' { //on create Favorite_Club_Member__c
                    if (followingIds.contains(member.Id)) {
                        member.Following_Count__c++;
                    }
                    if (followerIds.contains(member.Id)){
                        member.follower_Count__c++; 
                    }
                }
                when 'dec' { //on delete Favorite_Club_Member__c
                    if (followingIds.contains(member.Id)) {
                        member.Following_Count__c--;
                    }
                    if (followerIds.contains(member.Id)){
                        member.follower_Count__c--; 
                    }
                }
            }
            updatedFollowRecords.put(member.Id, member);
        }
        if (!updatedFollowRecords.values().isEmpty()) {
            update updatedFollowRecords.values();
        }
    }
}