@IsTest
private class ExperienceVariationTriggerHandler_TEST {
    @testSetup
    static void setup() {
        Club_and_Seasons__c clubSneakers = new Club_and_Seasons__c(
            Name = 'Sneakers'
        );
        insert clubSneakers;
        
        Brand_Experience__c ex = new Brand_Experience__c(
            Name = 'test',
            Status__c = 'Ongoing',
            ClubName__c = clubSneakers.Id
        );

        insert ex;

        Brand_Experience_Variation__c exVar = new Brand_Experience_Variation__c(
            Brand_Experience__c = ex.Id,
            Name = 'test',
            TargetingMethod__c = 'Dynamic',
            StartDateTime__c = system.now() ,
            RequiredClientRegistration__c = 'No Registration',
            EndDateTime__c = system.now() + 2000
        );
        insert  exVar;

        Account acc = new Account(
            FirstName = 'Yon',
            LastName = 'Memos',
            DREAMID__c = 'asdfghj145',
            AttachedStore__pc = 'UEC',
            AttachedStoreCode__pc = 'UEC',
            PersonEmail = 'test@test.com',
            SPO_Country_code__pc = 'USA'
        );
        insert acc;

        Club_MemberShip__c clubM = new Club_MemberShip__c(
            clientId__c = acc.Id,
            dreamId__c = 'asdfghj145',
            Club_and_Seasons__c = clubSneakers.id,
            clubStatus__c = 'Pearl',
            isMember__c = true, 
            isClubEligible__c = true,
            lastStatusUpdated__c = system.now(),
            Unique_Key__c = acc.DREAMID__c + '_' + clubSneakers.Name
        );
        insert clubM;
    }

    @isTest
    static void testHandleAfterUpdate() {
        User testUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_SYSTEM_ADMINNISTRATOR);
        insert testUser;

        System.runAs(testUser) {
            Test.startTest();
            Club_MemberShip__c clubM = [SELECT Id, clientId__c FROM Club_MemberShip__c LIMIT 1];
            Brand_Experience_Variation__c exVar = [SELECT Id FROM Brand_Experience_Variation__c LIMIT 1];


            Brand_Experience_Variation_Member__c exMember = new Brand_Experience_Variation_Member__c(
                Brand_Experience_Variation__c = exVar.Id,
                ClubMember__c = clubM.Id,
                Client__c = clubM.clientId__c,
                Name = 'test',
                Status__c ='Ready',
                isSelected__c = true,
                NominationStatus__c = 'Approved'
            );

          	insert exMember;
            
          
            exVar.Status__c = 'Participation Opened';
            update exVar;
        
            Test.stopTest();
        }
    }
    @isTest
    static void testHandleAfterUpdateForEndedStatus() {
        User testUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_SYSTEM_ADMINNISTRATOR);
        insert testUser;

        System.runAs(testUser) {
            Test.startTest();
            Club_MemberShip__c clubM = [SELECT Id, clientId__c FROM Club_MemberShip__c LIMIT 1];
            Brand_Experience_Variation__c exVar = [SELECT Id FROM Brand_Experience_Variation__c LIMIT 1];


            Brand_Experience_Variation_Member__c exMember = new Brand_Experience_Variation_Member__c(
                Brand_Experience_Variation__c = exVar.Id,
                ClubMember__c = clubM.Id,
                Client__c = clubM.clientId__c,
                Name = 'test',
                Status__c ='Ready',
                isSelected__c = true,
                NominationStatus__c = 'Approved'
            );

          	insert exMember;
            
          
            exVar.Status__c = 'Participation Opened';
            update exVar;
        
         	exVar.Status__c = 'Ended';
            update exVar;
            Test.stopTest();
        }
    }
}