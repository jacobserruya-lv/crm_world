@IsTest
private class FavoriteClubMemberTrigger_TEST {
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
        
        Club_and_Seasons__c clubSneakers = new Club_and_Seasons__c(
            Name = 'Sneakers'
        );
        insert clubSneakers;

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

        Account acc2 = new Account(
            FirstName = 'Pini',
            LastName = 'Amiram',
            DREAMID__c = 'asdfghj133',
            AttachedStore__pc = 'UEC',
            AttachedStoreCode__pc = 'UEC',
            PersonEmail = 'test1@test.com',
            SPO_Country_code__pc = 'USA'
        );
        insert acc2;
        
        Club_MemberShip__c clubM = new Club_MemberShip__c(
            clientId__c = acc.Id,
            dreamId__c = 'asdfghj145',
            Club_and_Seasons__c = clubSneakers.id,
            clubStatus__c = 'Pearl',
            isClubEligible__c = True,
            isMember__c = True,
            lastStatusUpdated__c = system.now(),
            Unique_Key__c = acc.DREAMID__c + '_' + clubSneakers.Name
        );
        insert clubM;

        Club_MemberShip__c clubM2 = new Club_MemberShip__c(
            clientId__c = acc2.Id,
            dreamId__c = 'asdfghj133',
            Club_and_Seasons__c = clubSneakers.id,
            clubStatus__c = 'Pearl',
            isClubEligible__c = True,
            isMember__c = True,
            lastStatusUpdated__c = system.now(),
            Unique_Key__c = acc2.DREAMID__c + '_' + clubSneakers.Name
        );
        insert clubM2;
    }

    @isTest
    static void testHandleInsert() {
        List<Club_MemberShip__c> members = [SELECT Id, Club_and_Seasons__c FROM Club_MemberShip__c LIMIT 2];
        Favorite_Club_Member__c favorite = new Favorite_Club_Member__c(
            Name = 'Test',
            clubMemberId__c = members[0].Id,
            favoriteClubMemberId__c = members[1].Id
        );
                
        Test.startTest();
        insert favorite;
        System.assertnotequals(favorite.UniqueKey__c, favorite.clubMemberId__c + '_' + favorite.favoriteClubMemberId__c);
        Test.stopTest();
    }
    @isTest
    static void testHandleDelete() {
        List<Club_MemberShip__c> members = [SELECT Id, Club_and_Seasons__c FROM Club_MemberShip__c LIMIT 2];
        Favorite_Club_Member__c favorite = new Favorite_Club_Member__c(
            Name = 'Test',
            clubMemberId__c = members[0].Id,
            favoriteClubMemberId__c = members[1].Id
        );
        insert favorite;
        Test.startTest();
        delete favorite;
        Test.stopTest();
    }
}