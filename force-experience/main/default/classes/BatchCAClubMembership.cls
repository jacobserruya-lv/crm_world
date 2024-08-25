public with sharing class BatchCAClubMembership implements Database.Batchable<sObject>, Database.Stateful {
  Club_and_Seasons__c club = new Club_and_Seasons__c();

  public BatchCAClubMembership(String clubName) {
    club = Club_utils.getClubByName(clubName);
  }

  public Database.QueryLocator start(Database.BatchableContext bc) {
    if (club == null) return null;

    List<String> caProfileList = Club_Utils.caProfileList(); 

    String query = 'SELECT Id, FirstName, LastName, Email, Profile.Name ' +
                   'FROM User ' +
                   'WHERE IsActive = TRUE ' +
                   'AND Profile.UserLicense.LicenseDefinitionKey = \'SFDC\' ' +
                   'AND Profile.Name IN :caProfileList '+ 
                   'AND Email LIKE \'%@louisvuitton.com%\'';

    if (Test.isRunningTest()) {
      query += ' ORDER BY CreatedDate DESC LIMIT 1';
    }

    return Database.getQueryLocator(query);
  }

  public void execute(Database.BatchableContext bc, List<User> userCaList) {
    Set<String> userEmailList = Club_utils.userEmailList(userCaList);

    List<User> identityUsers = [
      SELECT id, FirstName, LastName, Email, Profile.Name, AccountId, Account.FirstName, Account.LastName, Account.DREAMID__c, Account.PersonEmail
      FROM User
      WHERE Profile.Name = 'Identity User'
      AND Email IN :userEmailList 
      AND AccountId != NULL
      AND Account.DREAMID__c != NULL
    ];

    Map<string, User> salesforceUsersByPersonKey = Club_utils.userByPersonKeyMap(userCaList);
    
    List<Club_MemberShip__c> members = new List<Club_MemberShip__c>();
    for (User userIdentity : identityUsers) {
      String identityKey = (userIdentity.Email + userIdentity.FirstName + userIdentity.LastName).toLowerCase();
      String identityAccountKey = (userIdentity.Account.PersonEmail + userIdentity.Account.FirstName + userIdentity.Account.LastName).toLowerCase();

      if (identityKey == identityAccountKey && salesforceUsersByPersonKey.containsKey(identityKey)) {
        Club_MemberShip__c member = new Club_MemberShip__c(
          clientId__c = userIdentity.AccountId,
          dreamId__c = userIdentity.Account.DREAMID__c,
          Club_and_Seasons__c = club.Id,
          clubStatus__c = 'Client Advisor',
          isClubEligible__c = true,
          lastStatusUpdated__c = System.now(),
          Unique_Key__c = userIdentity.Account.DREAMID__c + '_' + club.Name
        );

        members.add(member);
      }
    }

    Database.insert(members, false);
  }

  public void finish(Database.BatchableContext bc){
  }
}