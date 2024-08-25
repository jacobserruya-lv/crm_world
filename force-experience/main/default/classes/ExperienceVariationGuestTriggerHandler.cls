public with sharing class ExperienceVariationGuestTriggerHandler {
    
    public static void handleTrigger(List<Brand_Experience_Variation_Member_Guest__c> newList, Map<Id, Brand_Experience_Variation_Member_Guest__c> newMap, List<Brand_Experience_Variation_Member_Guest__c> oldList, Map<Id, Brand_Experience_Variation_Member_Guest__c> oldMap, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when BEFORE_INSERT {
                handleBeforeInsert(newList);
            }
            when AFTER_INSERT {
                handleAfterInsert(newList);
            }
            when AFTER_UPDATE {
                handleAfterUpdate(newList,oldMap);
            }
            when AFTER_DELETE {
                handleAfterDelete(oldList);
            }
            when else {
                //do nothing for AFTER_UNDELETE, BEFORE_DELETE, or BEFORE_UPDATE
            }
        }
    }
    private static void handleBeforeInsert(List<Brand_Experience_Variation_Member_Guest__c> newList) {
        populateFieldsOnGuest(newList);
    }
    private static void handleAfterInsert(List<Brand_Experience_Variation_Member_Guest__c> newList) {
        populateFieldsOnMember(newList, 'increase');
    }
    private static void handleAfterUpdate(List<Brand_Experience_Variation_Member_Guest__c> newList, Map<Id,Brand_Experience_Variation_Member_Guest__c> oldMap) {
        updateFieldsOnMember(newList, oldMap);
    }
    private static void handleafterDelete(List<Brand_Experience_Variation_Member_Guest__c> oldList) {
        populateFieldsOnMember(oldList, 'decrease');
    }
    private static void updateFieldsOnMember(List<Brand_Experience_Variation_Member_Guest__c> newList, Map<Id,Brand_Experience_Variation_Member_Guest__c> oldMap){
        List<Brand_Experience_Variation_Member_Guest__c> relevantGuests = new List<Brand_Experience_Variation_Member_Guest__c>();
        for (Brand_Experience_Variation_Member_Guest__c updatedGuest : newList) {
            if (updatedGuest.Relationship__c!=oldMap.get(updatedGuest.Id).Relationship__c) {
                relevantGuests.add(updatedGuest);
            }
            if (!relevantGuests.isEmpty()) {
                Map<Id,Brand_Experience_Variation_Member__c> membersMap = queryMembersPerId(newList);
                for (Brand_Experience_Variation_Member_Guest__c guest : relevantGuests) {
                    Brand_Experience_Variation_Member__c member = membersMap.get(guest.Brand_Experience_Variation_Member__c);
                    member.Relationship__c= concatRelationshipsForMember(member);
                }
                update membersMap.values();
            }
        }
    }
    private static void populateFieldsOnGuest(List<Brand_Experience_Variation_Member_Guest__c> newList){
        for (Brand_Experience_Variation_Member_Guest__c guest : newList) {
            guest.Status__c = 'Registered'; // 'Confirmed' label
        }
    }
    private static void populateFieldsOnMember(List<Brand_Experience_Variation_Member_Guest__c> guestList, String operation){
        Map<Id,Brand_Experience_Variation_Member__c> membersMap = queryMembersPerId(guestList);
        Map<Id,Brand_Experience_Variation_Member__c> membersToUpdate = new Map<Id,Brand_Experience_Variation_Member__c>();
        for (Brand_Experience_Variation_Member_Guest__c guest : guestList) {
            Brand_Experience_Variation_Member__c member = membersMap.get(guest.Brand_Experience_Variation_Member__c);
            member.GuestNumber__c = member.GuestNumber__c==null?0:member.GuestNumber__c;
            if (operation=='increase') {
                member.GuestNumber__c++;
            }
            else{
                member.GuestNumber__c--;
            }
            member.Relationship__c= concatRelationshipsForMember(member);
            membersToUpdate.put(member.Id, member);
        }
        system.debug('**membersToUpdate: '+membersToUpdate);
        if (!membersToUpdate.values().isEmpty()) {
            update membersToUpdate.values();  
        }
    }
    private static Map<Id, Brand_Experience_Variation_Member__c> queryMembersPerId(List<Brand_Experience_Variation_Member_Guest__c> guestList) {
        List<Id> membersList = new List<Id>();
        Map<Id, Brand_Experience_Variation_Member__c> membersPerId = new Map<Id, Brand_Experience_Variation_Member__c>();
        for (Brand_Experience_Variation_Member_Guest__c guestChild : guestList) {
            membersList.add(guestChild.Brand_Experience_Variation_Member__c);
        }

        for(Brand_Experience_Variation_Member__c member:[SELECT Id, Relationship__c, GuestNumber__c, (SELECT Id,Relationship__c, Status__c FROM Activation_Member_s_Guests__r ORDER BY CreatedDate) FROM Brand_Experience_Variation_Member__c WHERE Id IN:membersList]){
            membersPerId.put(member.Id, member);
        }
        return membersPerId;
    }
    private static String concatRelationshipsForMember(Brand_Experience_Variation_Member__c member) {
        List<String> relationshipList = new List<String>();
        for (Brand_Experience_Variation_Member_Guest__c guest : member.Activation_Member_s_Guests__r) {
            relationshipList.add(guest.Relationship__c);
        }
        String concatedRelationship=String.join(relationshipList, ',');
        return concatedRelationship;
    }
}