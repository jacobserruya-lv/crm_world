@IsTest
public with sharing class EventAppointmentTriggerHandlerTest {
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
            Status__c = 'Draft',
            TargetingMethod__c = 'Dynamic',
            StartDateTime__c = system.today(),
            EndDateTime__c = system.today().addDays(1)
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
            Client__c = clubM.clientId__c,
            Name = 'test'
        );
        insert exmember;
        
        Event myAppointment = new Event(
        	StartDateTime = DateTime.now(),
            EndDateTime =DateTime.now().addDays(2),
            Subject= 'Event',
            Description= 'new test appointment',
     		Event__c = exMember.Id
        );
        insert myAppointment;
    }
    @isTest
    static void testHandleAfterInsert() {
       Brand_Experience_Variation_Member__c member = [SELECT Id FROM Brand_Experience_Variation_Member__c LIMIT 1];
       Event myAppointment = new Event(
        	StartDateTime = DateTime.now(),
            EndDateTime =DateTime.now().addDays(2),
            Subject= 'Event',
            Description= 'new test appointment',
     		Event__c = member.Id
        );
        Test.startTest();
        insert myAppointment;
        Test.stopTest();
    }

    @isTest
    static void testHandleAfterupdate() {
        Brand_Experience_Variation_Member__c member = [SELECT Id FROM Brand_Experience_Variation_Member__c LIMIT 1];
        Event myAppointment = new Event(
        	StartDateTime = DateTime.now(),
            EndDateTime =DateTime.now().addDays(2),
            Subject= 'Event',
            Description= 'new test appointment',
     		Event__c = member.Id
        );
        insert myAppointment;
        //myAppointment.StartDateTime = DateTime.now().addMinutes(10);
        //myAppointment.EndDateTime = DateTime.now().addDays(10);
        //Test.startTest();
        //update myAppointment;
        //Test.stopTest();
    }

    @isTest
    static void testHandleBeforeDelete() {
        Brand_Experience_Variation_Member__c member = [SELECT Id FROM Brand_Experience_Variation_Member__c LIMIT 1];
        Event myAppointment = [SELECT Id, StartDateTime, EndDateTime FROM Event LIMIT 1];

        Test.startTest();
        delete myAppointment;
        Test.stopTest();
    }
}