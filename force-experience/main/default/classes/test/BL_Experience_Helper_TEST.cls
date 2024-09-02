@IsTest
private class BL_Experience_Helper_TEST {
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
		
        Id physicalEventRecordType = Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Physical_Event').getRecordTypeId();

        Brand_Experience_Variation__c exVar = new Brand_Experience_Variation__c(
            Brand_Experience__c = ex.Id,
            Name = 'test',
            Status__c = 'Preview',
            Type__c = 'Event',
            SubType__c = 'Digital',
            TargetingMethod__c = 'Dynamic',
            StartDateTime__c = system.today(),
            EndDateTime__c = system.today().addDays(1),
            recordTypeId = physicalEventRecordType
        );

        insert exVar;

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
            Status__c = 'Not Registered'
        );

        insert exMember;
    }

    @IsTest
    static void getExperiencesByClubName_TEST() {
        User testUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_SYSTEM_ADMINNISTRATOR);
        testUser.BypassWF__c = true;
        testUser.BypassVR__c = true;
        testUser.Country__c = 'FRANCE';
        insert testUser;

        System.runAs(testUser) {
            Test.startTest();
            BL_Experience_Helper.getExperiencesByClubName('Sneakers',10, 0);
            Test.stopTest();
        }
    }

    @IsTest
    static void updateExperienceMemberById_TEST() {
        User testUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_SYSTEM_ADMINNISTRATOR);
        testUser.BypassWF__c = true;
        testUser.BypassVR__c = true;
        testUser.Country__c = 'FRANCE';
        insert testUser;

        System.runAs(testUser) {
            Test.startTest();
            
            Brand_Experience_Variation_Member__c member = [SELECT Id FROM Brand_Experience_Variation_Member__c LIMIT 1];
           
            try {
                BL_Experience_Helper.updateExperienceMemberById(member.Id, new Map<String, String> {
                    'rsvpState' => 'Not Registered',
                    'rsvpDate' => '2023-08-03T14:05:53.185+03:00',
                    'participationStartDate' => '2023-08-02T14:05:53.185+03:00',
                    'participationEndDate' => '2023-08-06T14:05:53.185+03:00'
                });
            } catch(Exception e) {
                System.debug('Error expected');
            }
           
            Test.stopTest();
        }
    }

    @IsTest
    static void BL_Experiences_Constants_TEST() {
        Test.startTest();
        System.debug(BL_Experiences_Constants.USE_CASE_EXPERIENCE);
        System.debug(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION);
        System.debug(BL_Experiences_Constants.USE_CASE_EXPERIENCE_VARIATION_MEMBER);
        Test.stopTest();
    }
}