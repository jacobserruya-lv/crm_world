@IsTest
class BatchExVariationMembersScheduler_Test {
    @testSetup
    static void setup() {
        User testUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_SYSTEM_ADMINNISTRATOR);
        testUser.BypassWF__c = true;
        testUser.BypassVR__c = true;
        testUser.Country__c = 'FRANCE';
        insert testUser;

        Club_and_Seasons__c clubSneakers = new Club_and_Seasons__c(
            Name = 'Sneakers'
        );
        insert clubSneakers;
        
        RecordType ClubRecordType =  [SELECT Id FROM RecordType WHERE DeveloperName = 'Club_Experience' AND SObjectType = 'Brand_Experience__c'];

        Id ClubExperienceRecordType = Schema.SObjectType.Brand_Experience__c.getRecordTypeInfosByDeveloperName().get('Club_Experience')?.getRecordTypeId();

        Brand_Experience__c ex = new Brand_Experience__c(
            Name = 'test',
            Status__c = 'Draft',
            ClubName__c = clubSneakers.Id
        );
        ex.RecordType = ClubRecordType;

        System.runAs(testUser) {
            insert ex;
        }
        Id recordTypeForDigitalEvent = Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Digital_Event_Variation').getRecordTypeId();
        Brand_Experience_Variation__c exVar = new Brand_Experience_Variation__c(
            Brand_Experience__c = ex.Id,
            Name = 'Test For Members',
            RecordTypeId = recordTypeForDigitalEvent,
            Status__c = 'Draft',
            Type__c = 'Event',
            SubType__c = 'Digital',
            TargetingMethod__c = 'Dynamic',
            StartDateTime__c = DateTime.Now().AddDays(1),
            EndDateTime__c = DateTime.Now().AddDays(2),
            RequiredClientRegistration__c = 'No Registration',
            ClientRegistrationDateLimit__c = false
        );

        Brand_Experience_Variation__c exVar2 = new Brand_Experience_Variation__c(
            Brand_Experience__c = ex.Id,
            Name = 'test',
            Status__c = 'Participation Opened',
            RecordTypeId = recordTypeForDigitalEvent,
            Type__c = 'Event',
            SubType__c = 'Digital',
            TargetingMethod__c = 'Dynamic',
            StartDateTime__c = DateTime.Now().AddDays(3),
            EndDateTime__c = DateTime.Now().AddDays(4),
            RequiredClientRegistration__c = 'No Registration',
            ClientRegistrationDateLimit__c = false
        );

        Brand_Experience_Variation__c exVar3 = new Brand_Experience_Variation__c(
            Brand_Experience__c = ex.Id,
            Name = 'test',
            Status__c = 'Registration Opened',
            Type__c = 'Event',
            SubType__c = 'Digital',
            RecordTypeId = recordTypeForDigitalEvent,
            TargetingMethod__c = 'Dynamic',
            StartDateTime__c = DateTime.Now().AddDays(7),
            EndDateTime__c = DateTime.Now().AddDays(8),
            ClientRegistrationDateLimit__c = true,
            RegistrationStartDateTime__c =  DateTime.Now().AddDays(5),
            RegistrationEndDateTime__c =  DateTime.Now().AddDays(6),
            RequiredClientRegistration__c = 'Mandatory',
            EligibleEuropeCountries__c = 'ALA',
            EligibleAfricaMiddleEastCountries__c = 'DZA',
            EligibleAmericasCountries__c = 'AIA',
            EligibleAsiaPacificCountries__c = 'AFG'
        );

        Brand_Experience_Variation__c exVar4 = new Brand_Experience_Variation__c(
            Brand_Experience__c = ex.Id,
            Name = 'test',
            RecordTypeId = recordTypeForDigitalEvent,
            RequiredClientRegistration__c = 'No Registration',
            Status__c = 'Participation Opened',
            TargetingMethod__c = 'Dynamic',
            StartDateTime__c = DateTime.Now().AddDays(9),
            EndDateTime__c = DateTime.Now().AddDays(10)
        );

        insert new List<Brand_Experience_Variation__c> {exVar, exVar2, exVar3, exVar4};

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

        Brand_Experience_Variation_Member__c exMember = new Brand_Experience_Variation_Member__c(
            Brand_Experience_Variation__c = exVar.Id,
            ClubMember__c = clubM.Id,
            Client__c = acc.Id,
            Name = 'test',
            Status__c = 'Ready',
            IsSelected__c = true
        );

        insert exMember;

        exVar.Status__c = 'Ready';
        update exVar;
    }

    @isTest 
    static void scheduleTest() {
        Test.startTest();
        String cron = '0 0 23 * * ?';
        BatchExVariationMembersScheduler schd = new BatchExVariationMembersScheduler();
        String jobId = System.schedule('test BatchExVariationMembersScheduler', cron, schd);
        Test.stopTest();
    }

    @isTest 
    static void scheduleQuableTest1() {
        Brand_Experience_Variation__c var = [SELECT Id FROM Brand_Experience_Variation__c WHERE Name = 'Test For Members' LIMIT 1];

        Test.startTest();
        var.Status__c = 'Registration Opened';
        update var;
        Test.stopTest();
    }


    @isTest 
    static void scheduleQuableTest2() {
        Brand_Experience_Variation__c var = [SELECT Id FROM Brand_Experience_Variation__c WHERE Name = 'Test For Members' LIMIT 1];

        Test.startTest();
        var.Status__c = 'Participation Opened';
        update var;
        Test.stopTest();
    }
}