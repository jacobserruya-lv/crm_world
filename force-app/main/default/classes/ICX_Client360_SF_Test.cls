@isTest
private class ICX_Client360_SF_Test {


   @isTest
   static void getrecordsListSize_TEST() {
 
 
     Account accts = ICX_TestFactory.createAccount();
     insert accts;
     ID accountId = accts.Id;
 
     Id recordType = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId();
     CareService__c carServ = ICX_TestFactory.createCareService(accountId, recordType);
     insert carServ;
 
     System.debug('display the message of careservice' + carServ);
 
 
     String objectName = 'CareService__c';
     String condition = 'WHERE Client__c =: accountId';
 
     Test.startTest();
     Integer numbersOfObjects = ICX_Client360_SF.getrecordsListSize(accountId,objectName,condition);
     Test.stopTest();
 
     System.debug('Here is the number of List Object' + numbersOfObjects);
 
     System.assertEquals(numbersOfObjects, 1);
   }

   @isTest
   static void getrecordsListSizeRemoteConsent_TEST() {
     Account accts = ICX_TestFactory.createAccount();
     insert accts;
     ID accountId = accts.Id;
 
     Id RCRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Remote_Consent').getRecordTypeId();
 
     Case cas = ICX_TestFactory.createCase(accountId);
     cas.RecordTypeId=RCRecordTypeId;
     insert cas;
     System.debug('All request display here =============-------------->>>>>>>>>>>>>>>>>>' + cas);
 
     Integer caseTest;
     Test.startTest();
     caseTest = ICX_Client360_SF.getrecordsListSizeRemoteConsent(accountId);
     Test.stopTest();
 
     System.assertEquals(caseTest, 1);
   }

   @isTest
   static void isGroupMember_TEST()
   {
      Id profileId = [SELECT Id FROM Profile WHERE Name = 'ICONiCS_SA'].Id;

      User use = ICX_TestFactory.createUser(profileId);
      insert use;
      Id userId = use.id;

       /* PermissionSetAssignment member = [
      SELECT Id, PermissionSet.Name
      FROM PermissionSetAssignment
      WHERE AssigneeId = :userId AND PermissionSet.Name = 'Icx_authToMerge'
    ];*/
      Id permissionSetId = [Select ID from PermissionSet  where Name = 'Icx_authToMerge' limit 1].id;
      PermissionSetAssignment permissionSetAssign = new PermissionSetAssignment();
      permissionSetAssign.AssigneeId = userId; 
      //permissionSetAssign.Name = 'Icx_authToMerge';
      permissionSetAssign.PermissionSetId = permissionSetId;
      insert permissionSetAssign;
       
      Id groupeId = [SELECT Id FROM GROUP WHERE DeveloperName='authToMerge' LIMIT 1].Id;
      
      GroupMember groupMember = new GroupMember();
      groupMember.UserOrGroupId = userId;
      groupMember.GroupId = groupeId;
      insert groupMember;

      //GroupMember ismember;
      PermissionSetAssignment ismember;
      Test.startTest();
      ismember = ICX_Client360_SF.isGroupMember(userId);
      Test.stopTest();

      Assert.isNotNull(ismember);



   }

   @isTest
   static void getAllRequests_TEST() {
     List<Case> caseTest = new List<Case>();
     Account accts = ICX_TestFactory.createAccount();
     insert accts;
     ID accountId = accts.Id;
 
     Case cas = ICX_TestFactory.createCase(accountId);
     cas.Type = 'Complaints';
     cas.Category__c = '';
     insert cas;
     System.debug('All request display here =============-------------->>>>>>>>>>>>>>>>>>' + cas);
     
     
     boolean isComplaints = true;
     boolean isRemotConsent = false;
 
 
     Test.startTest();
     caseTest = ICX_Client360_SF.getAllRequests(accountId, isComplaints,isRemotConsent);
     Test.stopTest();
 
     System.assertEquals(caseTest.size(), 1);
 
     
   }

   @isTest
   static void getAliases_TEST() {
     List<Alias_Member__c> aliasTest = new List<Alias_Member__c>();
 
     Account accts = ICX_TestFactory.createAccount();
     insert accts;
     ID accountId = accts.Id;
 
     Alias__C alia = ICX_TestFactory.createAlias();
     insert alia;
     Id aliasId = alia.Id;
 
     Alias_Member__c alia_member = ICX_TestFactory.createAlias_Member(accountId, aliasId);
     insert alia_member;
     Id alias_member_id = alia_member.Id;
 
     Test.startTest();
     aliasTest = ICX_Client360_SF.getAliases(accountId);
     Test.stopTest();
 
     System.debug('Try to see the Alias results' + aliasTest);
 
     System.assertEquals(aliasTest.size(), 1);
   }


//   @isTest
//   static void getClubMemberShip_TEST() {
//     Account accts = ICX_TestFactory.createAccount();
//     accts.DreamId__c = '1234';
//     insert accts;

//     Club_and_Seasons__c clubSeason = new Club_and_Seasons__c();
//     clubSeason.Name = 'Sneakers';
//     //------- if there is error on those field, remove those 3 sentences -----
//     clubSeason.clubSeasonStartDate__c = Datetime.now();
//     clubSeason.clubSeasonEndDate__c = Datetime.now() + 2;
//     clubSeason.clubSeason__c = 1;
//     insert clubSeason;

//     Club_MemberShip__c club1 = new Club_MemberShip__c();
//     club1.Name = 'Sneakers';
//     club1.clientId__c = accts.id;
//     club1.dreamId__c = accts.DreamId__c;
//     club1.clubStatus__c = 'Pearl';
//     club1.Unique_Key__c = accts.DreamId__c + clubSeason.Name;
//     club1.Club_and_Seasons__c = clubSeason.Id;
//     insert club1;

//     List<Club_MemberShip__c> clubMember = new List<Club_MemberShip__c>();

//     Test.startTest();
//     clubMember = ICX_Client360_SF.getClubMemberShip(accts.Id);
//     Test.stopTest();

//     System.assert(clubMember[0] != null);
//   }

@isTest
static void getPurchases_TEST() {
  List<Map<String, String>> purchasesTestList = new List<Map<String, String>>();

  Account accts = ICX_TestFactory.createAccount();
  insert accts;
  ID accountId = accts.Id;

  PPR_PurchProduct__c purch = ICX_TestFactory.createPurchases(accountId);
  insert purch;
  ID tempId = purch.Id;

  System.debug('Show the purchases here ===============>>>>>>>>>>>' + purch);
  System.debug('Show the purchases here ===============>>>>>>>>>>>' + tempId);

  Test.startTest();
  purchasesTestList = ICX_Client360_SF.getPurchases(accountId);
  Test.stopTest();

  // System.assertEquals(purchasesTestList.size(), 1);
  Assert.isNotNull(purchasesTestList);
}

@isTest
static void getPurchasesTable_TEST() {
  ICX_Client360_API_Helper.purchasesWrapper purchasesTestList = new ICX_Client360_API_Helper.purchasesWrapper();

  Account accts = ICX_TestFactory.createAccount();
  insert accts;
  ID accountId = accts.Id;

  PPR_PurchProduct__c purch = ICX_TestFactory.createPurchases(accountId);
  insert purch;
  ID tempId = purch.Id;
  Integer mylimit = 3;
  Integer myoffset = 3;

  System.debug('Show the purchases here ===============>>>>>>>>>>>' + purch);
  System.debug('Show the purchases here ===============>>>>>>>>>>>' + tempId);

  Test.startTest();
  purchasesTestList = ICX_Client360_SF.getPurchasesTable(accountId, mylimit, myoffset);
  Test.stopTest();

  // System.assertEquals(purchasesTestList.size(), 1);
  Assert.isNotNull(purchasesTestList);
}

@isTest
static void getCallingCampaigns_TEST() {
  List<ICX_Client360_API_Helper.WrapperLabelValueList> callCampList = new List<ICX_Client360_API_Helper.WrapperLabelValueList>();
  Boolean isWithButton = true;

  Account accts = ICX_TestFactory.createAccount();
  insert accts;
  ID accountId = accts.Id;

  Calling_Campaign__c callCam = ICX_TestFactory.createCallingCampaign(accountId);
  insert callCam;

  Test.startTest();
  callCampList = ICX_Client360_SF.getCallingCampaigns(accountId);
  Test.stopTest();

  System.debug('Try to see the Calling campaign  results' + callCampList);

  System.assertEquals(callCampList.size(), 1);
}

@isTest
static void getFamilies_TEST() {
  List<ICX_Client360_API_Helper.WrapperLabelValueList> familyList = new List<ICX_Client360_API_Helper.WrapperLabelValueList>();
  integer recordNumbers = 1;

  Account accts = ICX_TestFactory.createAccount();
  insert accts;
  ID accountId = accts.Id;
  System.debug('acc' + accts);

  Family__c faml = ICX_TestFactory.createFamily();
  insert faml;
  ID familyId = faml.Id;

  List<Family_Member__c> Family_Member = new List<Family_Member__c>();
  Family_Member = ICX_TestFactory.createFamily_MemberList(recordNumbers, accountId, familyId);
  insert Family_Member;
  Id Family_MemberId = Family_Member[0].Id;

  Test.startTest();
  familyList = ICX_Client360_SF.getFamilies(accountId);
  Test.stopTest();

  System.assertEquals(familyList[0].Id, Family_MemberId);
}

@isTest
static void getOrders_TEST() {
  List<ICX_Client360_API_Helper.OrderWrapper> orderLineList = new List<ICX_Client360_API_Helper.OrderWrapper>();

  Account accts = ICX_TestFactory.createAccount();
  insert accts;
  ID accountId = accts.Id;

  Store__c str = ICX_TestFactory.createStore('Weman Rings', 'DF6548');
  insert str;
  String storName = str.Name;

  Order__c mainOrder = ICX_TestFactory.createOrder(accountId);
  insert mainOrder;
  mainOrder.Store__c = str.Id;
  // update before the insert
  update mainOrder;
  System.debug('Try to see the order id' + mainOrder.Id);
  Id mainOrderId = mainOrder.Id;

  OrderShipping__c ordshi = ICX_TestFactory.createOrderShipping(mainOrderId);
  insert ordshi;
  String shippmentStatus = ordshi.Status__c;
  Id ordshiId = ordshi.Id;

  OrderLine__c orderLine = ICX_TestFactory.createOrderLine(mainOrderId, ordshiId);
  insert orderLine;

  Test.startTest();
  orderLineList = ICX_Client360_SF.getOrders(accountId, 1, 0);
  Test.stopTest();

  System.debug('SaySomthing naiubsduddsyuv ouhsyb ysiudyfgyu8gb' + orderLineList);

  System.assertEquals(orderLineList.size(), 1);
}

@isTest
static void getSurveys_TEST() {
  List<ICX_Client360_API_Helper.SurveyWrapper> surveyList = new List<ICX_Client360_API_Helper.SurveyWrapper>();

  Account accts = ICX_TestFactory.createAccount();
  insert accts;
  ID accountId = accts.Id;

  VO_Survey__c mainSurvey = ICX_TestFactory.createSurvey(accountId);
  insert mainSurvey;

  Test.startTest();
  surveyList = ICX_Client360_SF.getSurvey(accountId, 1, 0);
  Test.stopTest();

  System.debug('getSurveys_TEST surveyList: ' + surveyList);

  System.assertEquals(surveyList.size(), 1);
}




  @isTest
  static void getCareServiceRecords_TEST() {
    List<ICX_Client360_API_Helper.WrapperLabelValueList> careServLi = new List<ICX_Client360_API_Helper.WrapperLabelValueList>();


    Account accts = ICX_TestFactory.createAccount();
    insert accts;
    ID accountId = accts.Id;

    //get recordtypeid dynamically
    Id recordDistantType = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('DistantCareService').getRecordTypeId();
    Id recordStoreId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('StoreCareService').getRecordTypeId();
    CareService__c careServDis = ICX_TestFactory.createCareService(accountId, recordDistantType);
    CareService__c careServStr = ICX_TestFactory.createCareService(accountId, recordStoreId);
    List<CareService__c> careServList = new List<CareService__c>();
    careServList.add(careServDis);
    careServList.add(careServStr);
    insert careServList;

    System.debug('This is the Distant inserted object' + careServDis.RecordTypeId);
    System.debug('This is the tore inserted object' + careServStr.RecordTypeId);

    List<String> objectsNames = new List<String>{ 'Distant', 'Store', 'ALL' };
    List<boolean> results = new List<boolean>();

    Test.startTest();
    careServLi = ICX_Client360_SF.getCareServiceRecords(accountId, 1, 0, 'Distant');
    careServLi = ICX_Client360_SF.getCareServiceRecords(accountId, 1, 0, 'Store');
    Test.stopTest();

    System.assertEquals(careServList.size(), 2);
  }


  // futur use ?
  //  @isTest static void getSurveys_TEST()
  //  {
  //     List<ICX_Client360_API_Helper.WrapperLabelValueList> survList = new List<ICX_Client360_API_Helper.WrapperLabelValueList>();

  //  Id profileId =[select Id from Profile where Name = 'ICONiCS_SA'].Id;
  //  // List<VO_Config__c> voc = new List<VO_Config__c>();
  //  // VO_Config__c voc1 = new VO_Config__c();
  //  // voc1.Name = 'NUM OF Q';
  //  // voc1.Value = 50;

  //  // voc.add(voc1);
  //  // insert voc;
  //  Account accts = ICX_TestFactory.createAccount();
  //  insert accts;
  //  ID accountId = accts.Id;

  //  User use = ICX_TestFactory.createUser(profileId);
  //  insert use;
  //  Id useId = use.id;
  //  System.debug('See if useId existed in here ++++++++++++++++++++>>>>>>>>>>>>>>>>>>>'+ useId);

  //  VO_Survey__c surv = ICX_TestFactory.createSurvey(accountId);
  //  insert surv;
  //  Id survId = surv.ClientDreamID__c;
  //  System.debug('See if survId existed in here ++++++++++++++++++++>>>>>>>>>>>>>>>>>>>'+ survId);

  //  Test.startTest();
  //  survList = ICX_Client360_SF.getSurveys(accountId);
  //  Test.stopTest();

  //  System.debug('See if survay existed in here'+survList);

  //  System.assertEquals(survList.size(),1);

  //  }





//futur use ?
//   @isTest
//   static void getTags_TEST() {
//     List<Interests__c> tagsList = new List<Interests__c>();

//     Id profileId = [SELECT Id FROM Profile WHERE Name = 'ICONiCS_SA'].Id;

//     Account accts = ICX_TestFactory.createAccount();
//     insert accts;
//     ID accountId = accts.Id;

//     User use = ICX_TestFactory.createUser(profileId);
//     insert use;
//     Id useId = use.id;

//     Interests__c tag = ICX_TestFactory.createTags(accountId, useId);
//     insert tag;
//     System.debug('In the tags test we can see the account id' + tag.Client__c);

//     Test.startTest();
//     tagsList = ICX_Client360_SF.getTags(accountId);
//     Test.stopTest();

//     System.assertEquals(tagsList.size(), 1);
//   }

  @isTest
  static void getAuthorizationProfiles_TEST() {
    Map<String, Boolean> getAuthorProfilesList = new Map<String, Boolean>();

    Id profileId = [SELECT Id FROM Profile WHERE Name = 'ICONiCS_SA'].Id;

    User use = ICX_TestFactory.createUser(profileId);
    insert use;
    Id useId = use.id;

    String objectName = 'CareService__c';

    Test.startTest();
    getAuthorProfilesList = ICX_Client360_SF.getAuthorizationProfiles(useId, objectName);
    Test.stopTest();

    System.assertEquals(getAuthorProfilesList.size(), 5);
  }

  @isTest
  static void getUserProfileId_TEST() {

    Id profileId = [SELECT Id FROM Profile WHERE Name = 'ICONiCS_SA'].Id;

    User use = ICX_TestFactory.createUser(profileId);
    insert use;
    Id userId = use.id;

    Test.startTest();
    Id profileIdReturned = ICX_Client360_SF.getUserProfileId(userId);
    Test.stopTest();


    System.assertEquals(profileId, profileIdReturned);
  }

  @isTest
  static void getContact_TEST() {
    ICX_Client360_API_Helper.accountWrapper AccountRelContact = new ICX_Client360_API_Helper.accountWrapper();
  

    Account accts = ICX_TestFactory.createAccount();
    insert accts;
    ID accountId = accts.Id;

    Test.startTest();
    AccountRelContact = ICX_Client360_SF.getContact(accountId);
    Test.stopTest();


    System.assertEquals('Louis',AccountRelContact.firstName);
  }

  @isTest
  static void getKeyInformation_TEST() {
    ICX_Client360_API_Helper.WrapperLabelValueList AccountInformationKey = new ICX_Client360_API_Helper.WrapperLabelValueList();


    Account accts = ICX_TestFactory.createAccount();
    insert accts;
    ID accountId = accts.Id;

    Test.startTest();
    AccountInformationKey = ICX_Client360_SF.getKeyInformation(accountId);
    Test.stopTest();


    System.assertEquals(AccountInformationKey.Id, '0');
  }

  @isTest
  static void getCountry_TEST() {
    Map<String, String> countrCode = new Map<String, String>();

    CountryMapping__mdt countryCode = ICX_TestFactory.getCountryCode();
    //insert metadata

    Test.startTest();
    countrCode = ICX_Client360_SF.getCountry();
    Test.stopTest();

    //assert equal on Iso3Code__c
  }


  @isTest
  static void getStore_TEST()
  {
   Store__c newStore = ICX_TestFactory.createStore('LV FRANCE','A14');
   insert newStore;

   Map<String, String> storeMap = new Map<String, String>();
   Test.startTest();
   storeMap = ICX_Client360_SF.getStore();
   Test.stopTest();
   System.assertEquals(storeMap.size(), 1);


  }

  @isTest
  static void getPhoneCode_TEST() {
    List<Decimal> phoneCode = new List<Decimal>();

    CountryMapping__mdt PhoneCallCode = ICX_TestFactory.getPhoneCallCode();
    //insert metadata

    Test.startTest();
    phoneCode = ICX_Client360_SF.getPhoneCode();
    Test.stopTest();

    //assert equal on Calling_Code__c
  }

  @isTest
  static void getPurchasedProductId_TEST() {
     Account accts = ICX_TestFactory.createAccount();
     insert accts;
     ID accountId = accts.Id;
     
     PPR_PurchProduct__c purchProduct = new PPR_PurchProduct__c();
     purchProduct = ICX_TestFactory.createPurchases(accountId);
     insert purchProduct;
     Id purchTransNumber = purchProduct.TechTransactionId__c;
     
     Id purchProductId;
    Test.startTest();
    purchProductId = ICX_Client360_SF.getPurchasedProductId(purchTransNumber);
    Test.stopTest();

    System.assertEquals(purchProduct.Id, purchProductId);

  }

  @isTest
  static void getDreamId_TEST() {
    Account accts = ICX_TestFactory.createAccount();
    accts.DREAMID__c = '1234';
    insert accts;
    ID accountId = accts.Id;

    Test.startTest();
    String userDreamId = ICX_Client360_SF.getDreamID(accountId);
    Test.stopTest();

    Assert.isNotNull(userDreamId);
  }

  @isTest
  static void getContactId_TEST()
  {
   Account accts = ICX_TestFactory.createAccount();
    accts.DREAMID__c = '1234';
    insert accts;
    ID accountId = accts.Id;

    String contactId;
    Test.startTest();
    contactId = ICX_Client360_SF.getContactId(accountId);
    Test.stopTest();

    Assert.isNotNull(contactId);
  }


  @isTest
  static void getAccount_TEST() {


    Account accts = ICX_TestFactory.createAccount();
    insert accts;
    ID accountId = accts.Id;

    Test.startTest();
    Account userAccount = ICX_Client360_SF.getAccount(accountId);
    Test.stopTest();

    Assert.isNotNull(userAccount);
  }



  @isTest
  static void IsIdentityUser_TEST() {


    Account accts = ICX_TestFactory.createAccount();
    insert accts;
    ID accountId = accts.Id;


    Test.startTest();
    User userIdentity = ICX_Client360_SF.IsIdentityUser(accountId);
    Test.stopTest();

    Assert.IsNull(userIdentity);
  }

  @isTest
  static void getExportTracabilty_TEST() {
    Account accts = ICX_TestFactory.createAccount();
    accts.DreamId__c = '1234';
    insert accts;
  
    Export_Purchases_Tracability__c exportTracability = new Export_Purchases_Tracability__c();
    exportTracability.Status__c = 'New';
    exportTracability.DreamId__c = '1234';
    insert exportTracability;
    Export_Purchases_Tracability__c result;
    Test.startTest();
    result = ICX_Client360_SF.getExportTracabilty(accts.DreamId__c);
    Test.stopTest();
    System.assert(result != null);
  }


  @isTest
  static void icx_getClient360_SF_getUserProfileId() {
    Id profileId = [SELECT Id FROM Profile WHERE Name = 'ICONiCS_SA'].Id;
    User use = ICX_TestFactory.createUser(profileId);
    insert use;
    Id useId = use.id;

    Test.startTest();
    ID profId = ICX_Client360_SF.getUserProfileId(useId);
    Test.stopTest();

    Assert.isNotNull(profId);
  }

     @isTest
    static void getStylingSF_Test(){
        Account accts = ICX_TestFactory.createAccount();
        insert accts;
        String acctsId = (String)accts.id;
        
        Task newTaskIW = new Task(Subject = 'New Look', 
                                Type = 'LookBook',
                                LookId_IW__c = '12345',
                                IsWardrobing__c = true,
                                whatid = acctsId
                                );   
        insert newTaskIW;
                     
        List<Map<String,String>> IWList = new List<Map<String,String>>();       
        
        Test.startTest();
        IWList = ICX_Client360_SF.getStylingSF(accts.id, 3,0);
        Test.stopTest();
        
        System.assertEquals(IWList.size(), 1);
    }

     @isTest
    static void icx_getClientelingRequest_Test(){
        Account accts = ICX_TestFactory.createAccount();
        accts.DreamId__c = '1234';
        insert accts;
        
        Id caseRecordIdClienteling = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Clienteling').getRecordTypeId();
        Case cas = ICX_TestFactory.createCase(accts.Id);
        cas.RecordTypeId = caseRecordIdClienteling;
        cas.Status = 'New';
        insert cas;

        List<Case> caseList = new List<Case>();
        
        
        Test.startTest();
        caseList = ICX_Client360_SF.getClientelingRequests(accts.Id);
        Test.stopTest();
        
        System.assertEquals(caseList.size(), 1);
    }

    @isTest
    static void testGetRelatedComments() {
        
        Account testAccount = new Account(
            FirstName = 'Test',
            LastName = 'User',
            PersonMobilePhone = '0123456789',
            PersonEmail = 'testuser@example.com'
        );
        insert testAccount;
        
        // Create a test user
        Profile profile = [SELECT Id FROM Profile WHERE Name = 'Standard User' LIMIT 1];
        User testUser = new User(
            Alias = 'tuser',
            Email = 'testuser@example.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'User',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = profile.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            UserName = 'testuser' + DateTime.now().getTime() + '@example.com'
        );
        insert testUser;
        
        // Create test comments
        List<Fraud_Comment__c> comments = new List<Fraud_Comment__c>();
        for (Integer i = 0; i < 5; i++) {
            comments.add(new Fraud_Comment__c(
                Client__c = testAccount.Id,
                OwnerId = testUser.Id,
                Comment__c = 'Test comment ' + i,
                Reason__c ='DD'
                //  TechOwnerName__c = 'Test Tech Owner ' + i,
                
            ));
        }
        insert comments;
        
        // Test the getRelatedComments method
        Test.startTest();
        List<Fraud_Comment__c> result = ICX_Client360_SF.getRelatedComments(testAccount.Id);
        Test.stopTest();
        
        // Verify the results
        System.assertEquals(5, result.size(), 'The number of related comments should be 5');
        System.assertEquals('Test comment 0', result[0].Comment__c, 'The most recent comment should be "Test comment 0"');
    }

}