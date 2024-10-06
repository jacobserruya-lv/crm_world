@IsTest
private class ExperienceVariationTriggerHandler_TEST {
    @testSetup
    static void setup() {
        Club_and_Seasons__c clubSneakers = new Club_and_Seasons__c(
            Name = 'Sneakers'
        );
        insert clubSneakers;
        
        Id experienceRecordType = Schema.SObjectType.Brand_Experience__c.getRecordTypeInfosByDeveloperName().get('Experience')?.getRecordTypeId();

        Brand_Experience__c ex = new Brand_Experience__c(
            Name = 'test',
            Status__c = 'Ongoing',
            ClubName__c = clubSneakers.Id,
            recordTypeId=experienceRecordType
        );

        insert ex;
        
        Id ClubExperienceRecordType = Schema.SObjectType.Brand_Experience__c.getRecordTypeInfosByDeveloperName().get('Club_Experience')?.getRecordTypeId();

        Brand_Experience__c clubex = new Brand_Experience__c(
            Name = 'test',
            Status__c = 'draft',
            ClubName__c = clubSneakers.Id,
            recordTypeId=ClubExperienceRecordType
        );

        insert clubex;
		
        Id physicalEventRecordType = Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Physical_Event').getRecordTypeId();

        Brand_Experience_Variation__c exVar = new Brand_Experience_Variation__c(
            Brand_Experience__c = ex.Id,
            Name = 'test',
            TargetingMethod__c = 'Dynamic',
            StartDateTime__c = system.now().addDays(2) ,
            RequiredClientRegistration__c = 'No Registration',
            EndDateTime__c = system.now().addDays(5),
            recordTypeId=physicalEventRecordType
        );
        insert  exVar;
        
        Brand_Experience_Variation__c exVar1 = new Brand_Experience_Variation__c(
            Brand_Experience__c = clubex.Id,
            Name = 'test',
            TargetingMethod__c = 'Dynamic',
            StartDateTime__c = system.now().addDays(3) ,
            RequiredClientRegistration__c = 'No Registration',
            EndDateTime__c = system.now().addDays(6),
            recordTypeId=physicalEventRecordType
        );
        insert  exVar1;

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
            Brand_Experience_Variation__c exVar = [SELECT Id FROM Brand_Experience_Variation__c WHERE Brand_Experience__r.recordType.developerName='Club_Experience' LIMIT 1];


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
            
            // exVar.Status__c = 'Draft';
            // update exVar;
            // exVar.Status__c = 'Preview';
            // update exVar;
            // exVar.Status__c = 'Registration Opened';
            // update exVar;
            // exVar.Status__c = 'Registration Closed';
            // update exVar;
          	// exVar.Status__c = 'Selection Opened';
            // update exVar;
            // exVar.Status__c = 'Selection Closed';
            // update exVar;
            exVar.Status__c = 'Participation Opened';
            update exVar;
         	exVar.Status__c = 'Ended';
            update exVar;
            Test.stopTest();
        }
    }
    // @isTest
    // static void testHandleBeforeInsert() {
        
    //     User testUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_SYSTEM_ADMINNISTRATOR);
    //     insert testUser;
	// 	Brand_Experience__c ex= [SELECT Id FROM Brand_Experience__c WHERE RecordType.DeveloperName = 'Experience'];
    //     Id physicalEventRecordType = Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Physical_Event').getRecordTypeId();

    //     System.runAs(testUser) {
    //         Brand_Experience_Variation__c exVar1 = new Brand_Experience_Variation__c(
    //             Brand_Experience__c = ex.Id,
    //             Name = 'test',
    //             TargetingMethod__c = 'Dynamic',
    //             StartDateTime__c = system.now().addDays(3) ,
    //             RequiredClientRegistration__c = 'No Registration',
    //             EndDateTime__c = system.now().addDays(6),
    //             recordTypeId=physicalEventRecordType
    //         );
    //         insert  exVar1;
    // 	}
    // }
    
    //  @isTest
    // static void testHandleBeforeUpdate() {
        
    //     User testUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_SYSTEM_ADMINNISTRATOR);
    //     insert testUser;
	// 	Brand_Experience__c ex= [SELECT Id FROM Brand_Experience__c WHERE RecordType.DeveloperName = 'Experience'];
    //     Id physicalEventRecordType = Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Physical_Event').getRecordTypeId();        
    //     Brand_Experience_Variation__c exVar1 = new Brand_Experience_Variation__c(
    //         Brand_Experience__c = ex.Id,
    //         Status__c ='Draft',
    //         Name = 'test',
    //         TargetingMethod__c = 'Dynamic',
    //         StartDateTime__c = system.now().addDays(3) ,
    //         RequiredClientRegistration__c = 'No Registration',
    //         EndDateTime__c = system.now().addDays(6),
    //         recordTypeId=physicalEventRecordType
    //     );
    //     insert  exVar1;
        
    //     System.runAs(testUser) {
    //         Brand_Experience_Variation__c exVar = [SELECT Id FROM Brand_Experience_Variation__c WHERE Brand_Experience__r.recordType.developerName='Experience' LIMIT 1];
    //         exVar.Status__C = 'Ready';
    //         Test.startTest();
    //         update exVar;
    //         Test.StopTest();

    //     }
    // }
}