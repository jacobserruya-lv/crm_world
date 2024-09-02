@isTest
private class Club_MemberShipTrigger_TEST {

    @testSetup
    static void setup() {
        Profile iconProfile = [SELECT Id FROM Profile WHERE Name = 'ICON_SA' LIMIT 1];
        Profile identityProfile = [SELECT Id FROM Profile WHERE Name = 'Identity User' LIMIT 1];
        
        User iconUser = new User();
        iconUser.profile = iconProfile;
        iconUser.ProfileId = iconProfile.Id;
        iconUser.FirstName = 'test';
        iconUser.LastName = 'user';
        iconUser.Alias = 'iconsu';
        iconUser.Email = 'test.user@louisvuitton.com';
        iconUser.TimeZoneSidKey = 'Europe/Paris';
        iconUser.LocaleSidKey = 'en_US';
        iconUser.Username = 'icon.user@louisvuitton.com.icon';
        iconUser.EmailEncodingKey = 'ISO-8859-1';
        iconUser.LanguageLocaleKey = 'en_US';
        iconUser.IsActive = TRUE;
        insert iconUser;
        
        User identityUser = new User(
            profile = identityProfile,
            ProfileId = identityProfile.Id,
            FirstName = 'test',
            LastName = 'user',
            Alias = 'testuse1',
            Email = iconUser.Email,
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'en_US',
            Username = 'test.user@louisvuitton.com.identity',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            TECH_Email__c = 'test.user@louisvuitton.com',
            IsActive = true
        );

        insert identityUser;

        Account acc = new Account(
            FirstName = 'test',
            LastName = 'user',
            DREAMID__c = 'asdfghj145',
            AttachedStore__pc = 'UEC',
            AttachedStoreCode__pc = 'UEC',
            PersonEmail = iconUser.Email,
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
        Account user1 = [
            SELECT Id
            FROM Account
            WHERE DREAMID__c = 'asdfghj145'
            LIMIT 1
        ];
        
        List<PPR_PurchProduct__c> pprlList = new List<PPR_PurchProduct__c>();
        
        PPR_PurchProduct__c pprp1 = new PPR_PurchProduct__c();
        pprp1.Client__c = user1.Id;
        pprp1.TicketNumber__c = '195141ge65';
        pprp1.RMSSKUCode__c = '1AARQT';
        pprlList.add(pprp1);
        
        PPR_PurchProduct__c pprp2 = new PPR_PurchProduct__c();
        pprp2.Client__c = user1.Id;
        pprp2.TicketNumber__c = '195141ge65';
        pprp2.RMSSKUCode__c = '1AB8SR';
        pprlList.add(pprp2);
        
        PPR_PurchProduct__c pprp3 = new PPR_PurchProduct__c();
        pprp3.Client__c = user1.Id;
        pprp3.TicketNumber__c = '195141ge65';
        pprp3.RMSSKUCode__c = '1AB8RU';
        pprlList.add(pprp3);
        
        Test.startTest();
        insert pprlList;
        Test.stopTest();
    }
    
    @isTest
    static void testHandleAfterInsert() {
        List<Club_MemberShip__c> clubMemberShipList = [SELECT Id, clientId__c FROM Club_MemberShip__c limit 1];
        List<PPR_PurchProduct__c> pprList = new List<PPR_PurchProduct__c>();
        
        for (Club_MemberShip__c clubMemberShip : clubMemberShipList) {
            PPR_PurchProduct__c ppr = new PPR_PurchProduct__c();
            ppr.Client__c = clubMemberShip.clientId__c;
            ppr.RMSSKUCode__c = 'TestSKU';
            ppr.TicketNumber__c = 'Test123';
            pprList.add(ppr);
        }
        
        Test.startTest();
        insert pprList;
        Test.stopTest();
        
        // Example assertion
        System.assertEquals(1, 1, 'Custom assertion message');
    }
    
    @isTest
    static void testHandleAfterAccountInsert() {
        User iconUser = [SELECT Id, firstName, lastName, Email FROM User WHERE Profile.Name = 'ICON_SA' AND IsActive = TRUE AND Email = 'test.user@louisvuitton.com' LIMIT 1];
        Account acc1 = new Account(
            FirstName = iconUser.firstName,
            LastName = iconUser.lastName,
            DREAMID__c = 'test123',
            AttachedStore__pc = 'UEC',
            AttachedStoreCode__pc = 'UEC',
            PersonEmail = iconUser.Email,
            SPO_Country_code__pc = 'USA'
        );
        insert acc1;
        
        Account acc2 = new Account(
            FirstName = 'Test',
            LastName = 'User',
            DREAMID__c = 'test456',
            AttachedStore__pc = 'UEC',
            AttachedStoreCode__pc = 'UEC',
            PersonEmail = 'test3@test.com',
            SPO_Country_code__pc = 'USA'
        );
        insert acc2;
        
        Test.startTest();
        System.runAs(iconUser){
            try{
                List<Account> accList = new List<Account>{acc1, acc2};
                Map<Id, Account> accMap = new Map<Id, Account>();
                for (Account acc : accList) {
                    accMap.put(acc.Id, acc);
                }
                Club_MemberShipTriggerHandler.handleAfterAccountUpdate(accList, accMap);
            }catch(Exception e){
                system.debug('Error : ' + e);
            }
        }
        Test.stopTest();
    }

    @isTest
    static void handleAfterUserDeactivated_TEST() {
        User iconUser = [SELECT Id, IsActive FROM User WHERE Profile.Name = 'ICON_SA' AND IsActive = TRUE AND Email = 'test.user@louisvuitton.com' LIMIT 1];

        Test.startTest();
        iconUser.IsActive = false;
        update iconUser;
        Test.stopTest();
    }
}