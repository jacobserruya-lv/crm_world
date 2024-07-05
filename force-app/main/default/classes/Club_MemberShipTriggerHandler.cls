/**
 * @File Name          : Club_MemberShipTriggerHandler.cls
 * @Description        : Specific rules and verification or update on field when a ClubMemberShip is created
 * @Author             : calevm@balink.net
 * @Group              : Balink
 * @Last Modified By   : calevm@balink.net
 * @Last Modified On   : 06-20-2023
 * @Modification Log   :
 * Ver       Date            Author      		                     Modification
 * 1.0       06-25-2023      calevm@balink.net     Initial Version
 **/

public class Club_MemberShipTriggerHandler {
  public static void handleBeforeInsert(
    List<Club_MemberShip__c> clubMemberShipList
  ) {
    Set<String> dreamIdsList = clientIdList(clubMemberShipList);

    List<Account> clientList = [
      SELECT Id, Name, DREAMID__c
      FROM Account
      WHERE DREAMID__c IN :dreamIdsList
      AND DREAMID__c != Null
    ];

    Map<String, String> accountIdByDreamIdMap = accIdByDreamIdMap(clientList);
    Map<String, String> accountNameByDreamIdMap = accNameByDreamIdMap(
      clientList
    );

    for (Club_MemberShip__c pprp : clubMemberShipList) {
      if(accountIdByDreamIdMap.containsKey(pprp.dreamId__c) && accountNameByDreamIdMap.containsKey(pprp.dreamId__c)){
        pprp.clientId__c = accountIdByDreamIdMap.get(pprp.dreamId__c);
        pprp.Name = accountNameByDreamIdMap.get(pprp.dreamId__c) + '_' + pprp.Club_and_Seasons__c;
        pprp.Unique_Key__c = pprp.dreamId__c + '_' + pprp.Club_and_Seasons__c;
      }
    }
  }

  public static void handleAfterInsert(
    List<Club_MemberShip__c> clubMemberShipList
  ) {
    Set<String> dreamIdsList = clientIdList(clubMemberShipList);
    List<Club_MemberShip__c> membersToSendNotification = new List<Club_MemberShip__c>();
      
    for(Club_MemberShip__c member : clubMemberShipList){
      if(member.clientId__r.TECH_IsParallelMarket__pc == false && member.eCommerceClientCountry__c == true && (member.clubStatus__c == 'Pearl' || member.clubStatus__c == 'Ultra Rare' || member.clubStatus__c == 'Bronze')) {
        membersToSendNotification.add(member);
      }
    }

    if (!membersToSendNotification.isEmpty()) {
      IM_SendPushNotifications.ClientMemberShipSendPush(membersToSendNotification);
    }
  }

  public static void handleAfterAccountUpdate(List<Account> newAccList, Map<Id, Account> oldMapAccList) {    
    Map<String, Account> accByDreamIDList = Club_utils.getUpdatedDreamIDsAccounts(newAccList, oldMapAccList);
    List<Account> accList = accByDreamIDList.values();
    Set<String> accountEmailList = accEmailList(accList);
    List<Club_MemberShip__c> newMembers = Club_utils.membersToCreateForCa(accountEmailList);
    
    if (newMembers.size() > 0) {
      Database.insert(newMembers, false);
    }
  }

  public static void handleAfterUserDeactivated(
    List<User> newUserList,
    Map<Id, User> oldUserList
  ) {
    if(System.isBatch() || System.isFuture()) return;

    List<String> caProfileList = Club_Utils.caProfileList();
    List<User> caUsers = [
      SELECT Id, firstName, lastName, Email, isActive, Profile.Name
      FROM User 
      WHERE IsActive = FALSE
       AND Id IN :newUserList 
       AND Profile.Name IN :caProfileList
       AND Email LIKE '%@louisvuitton.com%'
    ];
    Set<String> updatedUserEmailList = Club_utils.userEmailList(caUsers);

    List<User> identityUsers = [
      SELECT Id, firstName, lastName, Email, isActive, Profile.Name, AccountId, Account.PersonEmail, Account.LastName, Account.FirstName
      FROM User 
      WHERE Is_Identity_User__c = TRUE 
      AND Email IN :updatedUserEmailList
    ];
    Map<String, User> identityUsersByPersonKeyMap = Club_utils.userByPersonKeyMap(identityUsers);
    List<User> identityUserToDeactivate = new List<User>();
    Set<Id> identityAccountIds = new Set<Id>();

    for (User u : caUsers) {
      Boolean isDeactivated = oldUserList.get(u.Id).IsActive == true;
      String personKey = (u.Email + u.firstName + u.lastName).toLowerCase();
      User existIdentity = identityUsersByPersonKeyMap.get(personKey);
      String accountPersonKey = existIdentity == null ? '' : (existIdentity.Account.PersonEmail + existIdentity.Account.firstName + existIdentity.Account.lastName).toLowerCase();
      Boolean isSimilarAccount = existIdentity != null && identityUsersByPersonKeyMap.containsKey(accountPersonKey);

      if (isDeactivated && existIdentity != null && isSimilarAccount && existIdentity.IsActive) {
        existIdentity.isActive = false;
        identityUserToDeactivate.add(existIdentity);
        identityAccountIds.add(existIdentity.AccountId);
      }
    }

    update identityUserToDeactivate;

    List<Club_MemberShip__c> clubMemberShipList = [
      SELECT Id
      FROM Club_MemberShip__c
      WHERE clientId__c IN :identityAccountIds
    ];

    if (!clubMemberShipList.isEmpty()) {
      Club_DeleteMembershipQueue deleteMembersQueue = new Club_DeleteMembershipQueue(clubMemberShipList);
      System.enqueueJob(deleteMembersQueue);
    }
  }

  private static Set<String> clientIdList(
    List<Club_MemberShip__c> clubMemberShipList
  ) {
    Set<String> dreamIds = new Set<String>();
    for (Club_MemberShip__c pr : clubMemberShipList) {
      dreamIds.add(pr.dreamId__c);
    }
    return dreamIds;
  }

  private static Map<String, Id> accIdByDreamIdMap(List<Account> clientList) {
    Map<String, Id> accountIdByDreamIdMap = new Map<String, Id>();
    for (Account acc : clientList) {
      accountIdByDreamIdMap.put(acc.DREAMID__c, acc.Id);
    }
    return accountIdByDreamIdMap;
  }

  private static Map<String, String> clubIdByDreamIdMap(List<Club_MemberShip__c> clubMemberShipList) {
    Map<String, String> clubIdByDreamIdMap = new Map<String, String>();
    for (Club_MemberShip__c member : clubMemberShipList) {
      clubIdByDreamIdMap.put(member.dreamId__c, member.Club_and_Seasons__c);
    }
    return clubIdByDreamIdMap;
  }

  private static Map<String, String> clubNameByIdMap(List<Club_and_Seasons__c> clubs) {
    Map<String, String> clubNameByIdMap = new Map<String, String>();
    for (Club_and_Seasons__c club : clubs) {
      clubNameByIdMap.put(club.Id, club.Name);
    }
    return clubNameByIdMap;
  }

  private static Map<String, String> accNameByDreamIdMap(
    List<Account> clientList
  ) {
    Map<String, String> accountNameByDreamIdMap = new Map<String, String>();
    for (Account acc : clientList) {
      accountNameByDreamIdMap.put(acc.DREAMID__c, acc.Name);
    }
    return accountNameByDreamIdMap;
  }

  private static Set<String> accEmailList(List<Account> clientList) {
    Set<String> accEmailList = new Set<String>();
    for (Account acc : clientList) {
      accEmailList.add(acc.PersonEmail);
    }
    return accEmailList;
  }
}