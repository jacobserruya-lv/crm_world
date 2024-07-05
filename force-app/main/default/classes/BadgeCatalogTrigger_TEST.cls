@IsTest
private class BadgeCatalogTrigger_TEST {
    @testSetup
    static void setup() {
        User iconUser = new User();
        Profile iconProfile = [SELECT Id FROM Profile WHERE Name = 'ICON_SA' LIMIT 1];
        iconUser.profile = iconProfile;
        iconUser.ProfileId = iconProfile.Id;
        iconUser.LastName = 'iconi user';
        iconUser.Alias = 'iconsu';
        iconUser.Email = 'icon.user@louisvuitton.com.123';
        iconUser.TimeZoneSidKey = 'Europe/Paris';
        iconUser.LocaleSidKey = 'en_US';
        iconUser.Username = 'icon.user@louisvuitton.com.icon';
        iconUser.EmailEncodingKey = 'ISO-8859-1';
        iconUser.LanguageLocaleKey = 'en_US';
        iconUser.IsActive = TRUE;
        insert iconUser;
        
        Account acc = new Account(
            FirstName = 'Calev',
            LastName = 'Machiah',
            DREAMID__c = 'asdfghj145',
            AttachedStore__pc = 'UEC',
            AttachedStoreCode__pc = 'UEC',
            PersonEmail = 'test@test.com',
            SPO_Country_code__pc = 'USA'
        );
        insert acc;
        
        Club_and_Seasons__c clubSneakers = new Club_and_Seasons__c(
            Name = 'Sneakers'
        );
        insert clubSneakers;
        
        Club_MemberShip__c clubM = new Club_MemberShip__c(
            clientId__c = acc.Id,
            dreamId__c = 'asdfghj145',
            Club_and_Seasons__c = clubSneakers.id,
            clubStatus__c = 'Pearl',
            lastStatusUpdated__c = system.now(),
            Unique_Key__c = acc.DREAMID__c + '_' + clubSneakers.Name
        );
        insert clubM;
    }

    @isTest
    static void testHandleBeforeInsert() {
        Test.startTest();
        Club_and_Seasons__c club = [SELECT Id FROM Club_and_Seasons__c LIMIT 1];
        Club_Season__c season = new Club_Season__c(
            Name = 'test',    
            SeasonNumber__c = 1,
            Club__c = club.Id,
            StartDate__c = system.today(),
            EndDate__c = system.today()
        );
        insert season;

        Badge_Catalog__c badgeCatalog = new Badge_Catalog__c(
            Name = 'Test',
            badgeType__c = 'Global Engagement',
            BadgeSubType__c = 'In-Season',
            Club_Name__c = club.Id,
            ClubSeason__c = season.Id
        );
        insert badgeCatalog;

        Club_MemberShip__c member = [SELECT Id FROM Club_MemberShip__c LIMIT 1];
        Badge_Collection__c badgeCollection = new Badge_Collection__c(
            Name = 'Test',
            badgeId__c = badgeCatalog.Id,
            member_Id__c = member.Id
        );
                
        insert badgeCollection;
        System.assertnotequals(badgeCollection.UniqueKey__c, badgeCollection.member_Id__c + '_' + badgeCollection.badgeId__c);

        badgeCollection.badgeFlag__c = true;
        update badgeCollection;
        Test.stopTest();
    }
}