public with sharing class Club_utils {
  public static List<String> caProfileList() {
    List<LV_Club_Setting__mdt> setting = [
      SELECT caProfilesFilter__c
      FROM LV_Club_Setting__mdt
      WHERE DeveloperName = 'Sneakers'
      LIMIT 1
    ];

    if (setting.isEmpty()) {
      return new List<String>{'ICON_SA Manager', 'ICONiCS_SA_Manager', 'ICON_SA','ICON_Manager','ICON_Corporate','ICONiCS_SA','ICONiCS_Manager','ICONiCS_Corporate'};
    }

    return setting[0].caProfilesFilter__c.split(',');
  } 

  public static Set<String> userEmailList(List<User> userList) {
    Set<String> userEmailList = new Set<String>();
    for (User user : userList) {
      userEmailList.add(user.Email);
    }
    return userEmailList;
  }

  public static Map<String, Account> getUpdatedDreamIDsAccounts(List<Account> clientList, Map<Id, Account> oldMapAccList) {
    Map<String, Account> accByDreamIDList = new Map<String, Account>();
    for (Account acc : clientList) {
      Account oldAcc = oldMapAccList.get(acc.Id);
      if (String.isNotBlank(acc.DREAMID__c) && oldAcc != null && String.isBlank(oldAcc.DreamId__C)) {
        accByDreamIDList.put(acc.DREAMID__c, acc);
      }
    }
    return accByDreamIDList;
  }

  public static Map<String, User> userByPersonKeyMap(List<User> userList) {
    Map<String, User> userByPersonKeyMap = new Map<String, User>();
    for (User u : userList) {
      userByPersonKeyMap.put((u.Email + u.firstName + u.lastName).toLowerCase(), u);
    }
    return userByPersonKeyMap;
  }

  public static Club_and_Seasons__c getClubByName(String name) {
    List<Club_and_Seasons__c> clubs = [SELECT Id, Name FROM Club_and_Seasons__c WHERE Name = :name LIMIT 1];
    if (clubs.isEmpty()) {
      return null;
    } else {
      return clubs[0];
    }
  }

  public static List<Club_MemberShip__c> membersToCreateForCa(Set<String> emailsFilter) {      
    List<String> caProfileList = caProfileList(); 

    List<User> userSalesforceList = [ 
      SELECT Id, FirstName, LastName, Email, Profile.Name
      FROM User
      WHERE IsActive = TRUE
      AND Profile.UserLicense.LicenseDefinitionKey = 'SFDC'
      AND Profile.Name IN :caProfileList
      AND Email LIKE '%@louisvuitton.com%'
      AND Email IN :emailsFilter
    ];
    System.debug('userSalesforceList: ' + userSalesforceList);

    Set<String> userEmailList = Club_utils.userEmailList(userSalesforceList);

    List<User> identityUsers = [
      SELECT id, FirstName, LastName, Email, Profile.Name, AccountId, Account.FirstName, Account.LastName, Account.DREAMID__c, Account.PersonEmail
      FROM User
      WHERE IsActive = TRUE
      AND Profile.Name = 'Identity User'
      AND Email IN :userEmailList
      AND AccountId != NULL
      AND Account.DREAMID__c != NULL
    ];
    System.debug('identityUsers: ' + identityUsers);

    Map<string, User> salesforceUsersByPersonKey = Club_utils.userByPersonKeyMap(userSalesforceList);
    
    Club_and_Seasons__c clubSneakers = Club_utils.getClubByName('Sneakers');
    if (clubSneakers == null) return new List<Club_MemberShip__c>();

    List<Club_MemberShip__c> members = new List<Club_MemberShip__c>();
    for (User userIdentity : identityUsers) {
      String identityKey = (userIdentity.Email + userIdentity.FirstName + userIdentity.LastName).toLowerCase();
      String identityAccountKey = (userIdentity.Account.PersonEmail + userIdentity.Account.FirstName + userIdentity.Account.LastName).toLowerCase();
      System.debug(userIdentity.Account);

      if (identityKey == identityAccountKey && salesforceUsersByPersonKey.containsKey(identityKey)) {
        Club_MemberShip__c member = new Club_MemberShip__c(
          clientId__c = userIdentity.AccountId,
          dreamId__c = userIdentity.Account.DREAMID__c,
          Club_and_Seasons__c = clubSneakers.Id,
          clubStatus__c = 'Client Advisor',
          isClubEligible__c = true,
          lastStatusUpdated__c = System.now(),
          Unique_Key__c = userIdentity.Account.DREAMID__c + '_' + clubSneakers.Name
        );

        members.add(member);
      }
    }

    return members;
  }
}