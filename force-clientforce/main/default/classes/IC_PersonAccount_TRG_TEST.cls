/**
About
-----
Description: Test class for IC_PersonAccount_TRG
Created for: SOW: IC002 ICON project - client visibility
Create date: Jan 2014

Details
-------
Class contains test methods

Update History
--------------
Jan 2014 / Created by Marie TOURNE
Jul 2016 / Modified by Marieme TOURE - ICON OWner: adding a new test method named "updateOwnerbyDREAM" - testing ICON owner modifications (DREAM user should not be able to update account owner when account is locked)
Jul 2016 / Modified by Marieme TOURE - ICON OWner: Deactivating functions as account assignement is now handled by DREAM
Feb-March 2020 / BW / Denodo - CLient anonymization
June 2023 / update test class managing dream user with sytsem user
Feb 2024 / Modified By ouramdane.a (Catch Anonymization Errors)
*/
@isTest
private class IC_PersonAccount_TRG_TEST {
    
    @TestSetup
    public static void setup() {
        
        String identityProfile = [SELECT Id FROM Profile WHERE Name = 'Identity User' and UserLicense.name ='External Identity'][0].Id;
        insert new IC_Config__c(
            Name = 'Identity User',
            Value__c = identityProfile
        );
    }
    
    /* Creation of one account - default user is inactive*/
    static testMethod void createAccountDefaultUserInactiveTest() {
        
        //User dream = [SELECT Id FROM User Where Alias = 'dream'];
        User dream = Test_Utils.createUser('eqsdqsdqd2');
        //perform Insert as DREAM user
        System.runAs(dream){
            User technicalUser = IC_TestFactory.createUser('techuser'+String.valueOf(System.today())+'@lvtest.com');
            technicalUser.profileId = IC_UTILS.getDreamProfile();
            technicalUser.DREAMID__C='test';
            technicalUser.IsActive = false;
            insert technicalUser;
            
            ICON_Default_Store_Owner__c defaultStoreOwner = new ICON_Default_Store_Owner__c(Store__c='test', Default_Store_Owner__c = technicalUser.Id);
            insert defaultStoreOwner;
            
            Account a = IC_TestFactory.createAccount();
            a.AttachedStore__pc='test';
            
            test.startTest();
            insert a;
            test.stopTest();
            
            a = [SELECT ownerId FROM Account where Id = :a.Id];
            
            System.assertEquals(dream.Id,a.ownerId, 'Account should be assigned to dreamId on insert - technical user is inactive');
        }
    }
    
    /* Creation of one account - no default user */
    static testMethod void createAccountNoDefaultUserInactiveTest() {
        
        //User dream = [SELECT Id FROM User Where Alias = 'dream'];
        User dream = Test_Utils.createUser('dsfsfsfdsfds');
        //perform Insert as DREAM user
        System.runAs(dream){
            Account a = IC_TestFactory.createAccount();
            a.AttachedStore__pc='test';
            
            test.startTest();
            insert a;
            test.stopTest();
            
            a = [SELECT ownerId FROM Account where Id = :a.Id];
            
            System.assertEquals(dream.Id,a.ownerId, 'Account should be assigned to dreamId on insert - no technical user');
        }
    }
    
    /* Update of one account - last modifier store country flag updated */
    static testMethod void updateAccountPipaTest() {
        
       // User dream = [SELECT Id FROM User Where Alias = 'dream']; 
        User dream = Test_Utils.createUser('eqsdqsdqd');
        
        //perform Insert as DREAM user
        System.runAs(dream){
            
            Account a = IC_TestFactory.createAccount();
            insert a;
            
            test.startTest();
            a.Shoes__pc = '44';
            update a;
            System.debug('## last modified flag: '+a.LastModifierStoreCountry__pc);
            test.stopTest();
        }
    }
    
    /* Update of one account -change owner manually*/
    /* Jul 16 - MTOU - ICON OWner: Updating test method (DREAM should be able to update account owner without locking it*/
      static testMethod void updateAccountTestInactiveUser() {
          List<User> listUser = new List<User>();
        List<Account> listAccount = new List<Account>();
        Map<String,ID> mapProfile = new Map<String,ID>();
        
        //User dream = [SELECT Id FROM User Where Profileid != :IC_UTILS.getDreamProfile() limit 1];
        User dream = [SELECT Id FROM User Where Id = :UserInfo.getUserId()];
        for (Profile pr : [SELECT id, name from Profile where Name ='ICON_SA' OR Name = 'ICON_Interface DREAM']){
            mapProfile.put(pr.name, pr.id);
        }
        
      
        
        system.debug('dream ' + dream);
        //perform Insert as DREAM user
        System.runAs(dream){
            
            User sa = IC_TestFactory.createUser('sa'+String.valueOf(System.today())+'@lvtest.com',mapProfile.get('ICON_SA') /*IC_UTILS.getSAProfile()*/);
            User technicalUser = IC_TestFactory.createUser('techuser'+String.valueOf(System.today())+'@lvtest.com');
            technicalUser.profileId = mapProfile.get('ICON_Interface DREAM');
            technicalUser.DREAMID__C='test';
            listUser.add(technicalUser);
            //insert technicalUser;
            listUser.add(sa);
            //insert sa;
            insert listUser;
            
            Account a = IC_TestFactory.createAccount();
            a.AttachedStore__pc='test';
            a.ownerId = sa.Id;
            listAccount.add(a);
            //insert a;
            // prospect
            Account act = IC_TestFactory.createAccount();
            act.IsProspect__pc = true;
            //insert act;
            listAccount.add(act);
            insert listAccount;
            act.HistoricalSpendYUAN__pc = 12;
   
            ICON_Default_Store_Owner__c defaultStoreOwner = new ICON_Default_Store_Owner__c(Store__c='test', Default_Store_Owner__c = technicalUser.Id);
            insert defaultStoreOwner;
            a.ownerId = sa.Id;          
            
            test.startTest();
            update a;
            update act;
            test.stopTest();
            
            a = [SELECT ownerId,TECH_OwnerManuallyChanged__c FROM Account where Id = :a.Id];
            
            System.assertEquals(sa.Id,a.ownerId, 'Account should be assigned to SA when changed manually');
            //System.assertEquals(true, a.TECH_OwnerManuallyChanged__c,'TECH_OwnerManuallyChanged__c should be true');
            System.assertEquals(false, a.TECH_OwnerManuallyChanged__c,'TECH_OwnerManuallyChanged__c should be false');
            
            
            
            
        }
    }
    
    // Begin MTOU - Testing ICON Owner modifications
    // 1- when a non DREAM user changes the account owner then account should be locked
    // 2- DREAM should not be able to change account owner when the account is locked
    static testMethod void updateOwnerbyDREAM()
    {
         Map<String,ID> mapProfile = new Map<String,ID>();
         List<User> listUser = new List<User>();
                
        User dreamUser = Test_Utils.createUser('dfsffdf');
        
        for (Profile pr : [SELECT id, name from Profile where Name ='ICON_SA'  OR  Id=:Label.IC_System_Admin_Profile_Id]){
            mapProfile.put(pr.name, pr.id);
        }
        // create 2 SAs
        User sa1 = IC_TestFactory.createUser('sa1'+String.valueOf(System.today())+'@lvtest.com', mapProfile.get('ICON_SA'));
        //insert sa1;
        listUser.add(sa1);
        User sa2 = IC_TestFactory.createUser('sa2'+String.valueOf(System.today())+'@lvtest.com', mapProfile.get('ICON_SA'));
        //insert sa2;
         listUser.add(sa2);
        
        // create admin user
        User adm = IC_TestFactory.createUser('adm'+String.valueOf(System.today())+'@lvtest.com', mapProfile.get('System Administrator'));
        //insert adm;
         listUser.add(adm);
         insert listUser;
        // create a client
        
        Account a = IC_TestFactory.createAccount();
        a.AttachedStore__pc='test';
        a.ownerId = sa1.Id;
        insert a;
        Test.startTest();
        system.runAs(dreamUser)
        {
            
            a.OwnerId = sa2.id;
            update a;
            system.assertEquals(sa2.id, a.OwnerId);
            system.assertEquals(false, a.TECH_OwnerManuallyChanged__c);
            system.assertEquals(null, a.TECH_ManualReassignmentDate__c);
        }
        a.OwnerId = sa1.id;
        update a;
        system.assertEquals(sa1.id, a.OwnerId);
        system.runAs(dreamUser)
        {
            a.OwnerId = sa2.id;
            update a;
            system.assertEquals(sa2.id, a.OwnerId);

        }
        test.stopTest();
    }
    // End MTOUz
    @isTest
    public static void anonymizeUserTest() {
        Id roleId = [select id from UserRole where developerName = 'Corporate_Central'][0].Id;  
        User datastageUser = IC_TestFactory.createUser('techuser'+String.valueOf(System.today())+'@lvtest.com');
        datastageUser.profileId = IC_UTILS.getInterfaceDatastageProfile();
        //technicalUser.DREAMID__C='test';
        datastageUser.BypassVR__c = true;
        datastageUser.userRoleId = roleId;
        datastageUser.IsActive = true;
        insert datastageUser;
        
        String personAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        System.debug('personAccountRecordTypeId=' + personAccountRecordTypeId);
        
        Account accNoUser = createPersonAccount();
        Account accWithUserWithoutSocialMedia = createPersonAccount();
        Account accWithUserWithSocialMedia = createPersonAccount();
        
        System.runAs(datastageUser) {
            
            insert new List<Account> {accNoUser, accWithUserWithoutSocialMedia, accWithUserWithSocialMedia};
                
                Integer autoNumber = 0;
            Social_Media_Identifier__c social = createSocialMediaIdentifier(accNoUser.Id);
            Social_Media_Identifier__c social2 = createSocialMediaIdentifier(accWithUserWithSocialMedia.Id);
            insert new List<Social_Media_Identifier__c> {social, social2};
                
                Case request = IC_TestFactory.createCase(accNoUser);
            request.SuppliedName = 'xxx';
            insert request;
        }
        
        List<User> userList = new List<User>();
   
        
        // Test
                 string anonymizeLastname = 'anonymize_';
        System.runAs(datastageUser) {
              User usr = createIdentityUser(accWithUserWithoutSocialMedia.Id, 'Lastname');
        User usr2 = createIdentityUser(accWithUserWithSocialMedia.Id, 'Lastname22');
        userList.add(usr);
        userList.add(usr2);
        // ****** 25/05/2021 Imad To Check After DATAChinaIsolation
        insert userList;
        
            Test.startTest();
            accNoUser.Anonymization_key__c = '123456789';
            accWithUserWithoutSocialMedia.Anonymization_key__c = '123456790';
            accWithUserWithSocialMedia.Anonymization_key__c = '123456791';
            
            update new List<Account> {accNoUser, accWithUserWithoutSocialMedia, accWithUserWithSocialMedia};
                Test.stopTest();
        }
        
        // Check
        List<Social_Media_Identifier__c> socialList = [SELECT Id FROM Social_Media_Identifier__c];
        // ****** 25/05/2021 Imad To Check After DATAChinaIsolation
         System.assertEquals(0, socialList.size());
        
        List<User> userResultList = [SELECT Id, Lastname, IsActive, Tracking_Identity_User__c FROM User WHERE Id IN :userList];
        // ****** 25/05/2021 Imad To Check After DATAChinaIsolation
           System.assertEquals(2, userResultList.size());
        for (User userResult : userResultList) {
            // ****** 25/05/2021 Imad To Check After DATAChinaIsolation
          //   System.assertEquals(anonymizeLastname, userResult.Lastname.left(10).toLowerCase());
             // System.assertEquals(false, userResult.IsActive);
           // System.assert(userResult.Tracking_Identity_User__c == null);
        }
    }
    @isTest
    public static void anonymizeUser_AccountNoAnonymization_Test() {
        
        Account accNotAnonymizedWithUser = createPersonAccount();
        insert new List<Account> {accNotAnonymizedWithUser};
            
            User usr = createIdentityUser(accNotAnonymizedWithUser.Id, 'Lastname');
        insert usr;
        
        // Test
        Test.startTest();
        accNotAnonymizedWithUser.PersonMobilePhone = '+33133445566';
        update accNotAnonymizedWithUser;
        Test.stopTest();
        
        List<Account> resultList = [SELECT Id, PersonMobilePhone FROM Account];
        System.assertEquals(1, resultList.size());
        
        List<User> userList = [SELECT Id, Lastname, IsActive, Tracking_Identity_User__c FROM User WHERE Id = :usr.Id];
        System.assertEquals(1, userList.size());
        System.assertEquals('Lastname', userList.get(0).Lastname);
        System.assertEquals(true, userList.get(0).IsActive);
        System.assert(userList.get(0).Tracking_Identity_User__c != null);
    }
    
    //Add By ouramdane.a
    //Catch Anonymization errors
    @isTest
    private static void catchAnonymizationErrors_Test() {
		Account acct = createPersonAccount();
		INSERT acct;
		
		Store__c newStore = new Store__c(Name='Store AS', RetailStoreId__c = 'A06', Status__c = 'Open');
		INSERT newStore;
		
		Case request = IC_TestFactory.createCase(acct);
		request.SuppliedName = 'xxx';
		request.Store__c = newStore.Id;
		INSERT request;

		newStore.Status__c = 'Close';
		UPDATE newStore;
        
		User thisUser = [SELECT Id FROM User WHERE Alias = 'autoproc' LIMIT 1];
        System.runAs(thisUser) {
            Test.startTest();
            acct.Anonymization_key__c = '2024022718350014';
            UPDATE acct;
            Test.stopTest();
            
            Account ac = [SELECT Id, Firstname2__pc FROM Account WHERE Id = :acct.Id LIMIT 1];
            System.assertNotEquals('Anonymize', ac.Firstname2__pc, 'Account Not Anonymized');
            System.assertEquals(2, [SELECT count() FROM CF_AnonymizationErrorLog__c WHERE CF_AccountId__c = :acct.Id], 'Anonymization Errors Log');
		}
	}
    
    static testMethod void updateChinaChinaVisibilitybyDREAM()
    {
        // get DREAM user
       // User dreamUser = [Select Id, username from User where CommunityNickname = 'dream' and  profileId = :IC_UTILS.getDreamProfile() Limit 1];
        User dreamUser = Test_Utils.createDreamUser();
        // create a client
        Account a = IC_TestFactory.createAccount();
        a.AttachedStore__pc='test';
        insert a;
        //Create PPR_PurchProduct__c attached to account test
        PPR_PurchProduct__c ppr = IC_TestFactory.createPurchaseProduct(a.Id);
        ppr.PurchaseCountry__c = 'CHN';
        insert ppr;
        
        system.runAs(dreamUser)
        {
            // Updating the account owner as Dream user => account should not be locked
            a.TECH_ChinaVisibility__c = 'CN';
            update a;
            system.assertEquals(1, [SELECT Id FROM PPR_PurchProduct__c WHERE Client__c =: a.Id].Size());
            a.TECH_ChinaVisibility__c = 'INT_CN_ATT';
            update a;
            system.assertEquals(1, [SELECT Id FROM PPR_PurchProduct__c WHERE Client__c =: a.Id].Size());
            ppr.PurchaseCountry__c = 'HKG';
            Update ppr;
            a.TECH_ChinaVisibility__c = 'INT_CN_ATT';
            update a;
            system.assertEquals(0, [SELECT Id FROM PPR_PurchProduct__c WHERE Client__c =: a.Id].Size());
            
        }
        
    }
    @isTest
    public static void greyMarket_Test() {
        Account acc = createPersonAccount();
        insert acc;
        
        List<Account> accList = [SELECT ParallelMarket_Status__pc, ParallelMarket_StatusDate__pc FROM Account WHERE Id = :acc.Id];
        System.assertEquals(1, accList.size());
        System.assert(accList[0].ParallelMarket_Status__pc == null);
     //   System.assert(accList[0].ParallelMarket_StatusDate__pc == null);
        
        Test.startTest();
        acc.ParallelMarket_Status__pc = 'Orange';
        update acc;
        Test.stopTest();
        
        List<Account> accResultList = [SELECT ParallelMarket_Status__pc, ParallelMarket_StatusDate__pc FROM Account WHERE Id = :acc.Id];
        System.assertEquals(1, accResultList.size());
        System.assert(accResultList[0].ParallelMarket_StatusDate__pc != null);
        System.assertEquals('Orange', accResultList[0].ParallelMarket_Status__pc);
    }
    
    private static Account createPersonAccount() {
        String personAccountRecordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Person Account').getRecordTypeId();
        System.debug('personAccountRecordTypeId=' + personAccountRecordTypeId);
        
        Account acc = IC_TestFactory.createAccount();
        acc.PersonEmail = 'myEmail@email.com';
        acc.RecordTypeId = personAccountRecordTypeId;
        return acc;
    }
    
    private static User createIdentityUser(Id accountId, String lastname) {
        Profile identityProfile = [SELECT Id FROM Profile WHERE Name = 'Identity User' and UserLicense.name ='External Identity' ];
        UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' Limit 1];
        
        Datetime x =  Datetime.now();
        Integer milliSeconds = x.millisecond();
        
        Contact ctc = [SELECT Id FROM Contact  WHERE AccountId = :accountId LIMIT 1];
        
        String email = 'test' + milliSeconds + '@anonymizeUserTest.com';
        
        User usr = IC_TestFactory.createUser(email);
        usr.ProfileId = identityProfile.Id;
        //usr.UserRoleId = portalRole.Id;
        if(ctc!=null){
        usr.ContactId = ctc.Id;
        }
        usr.lastname = lastname;
        usr.IsActive = true;
        usr.TECH_Email__c = email;
        usr.Tracking_Identity_User__c = 'HELLO IDENTITY';
        return usr;
    }
    
    public static Social_Media_Identifier__c createSocialMediaIdentifier(Id accountId) {
        Social_Media_Identifier__c social = new Social_Media_Identifier__c();
        social.Client__c = accountId;
        social.social_media_type__c = 'Line';
        social.Opt_In__c = true;
        social.Social_Id__c = EncodingUtil.base64Encode(Blob.valueOf('TEST' + accountId));
        
        Datetime x =  Datetime.now();
        Integer milliSeconds = x.millisecond();
        
        social.Social_SF_External_Id__c = 'anyid-' + milliSeconds + accountId;
        return social;
    }
}