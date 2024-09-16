@IsTest
private class ExVariationMemberTriggerHandler_TEST {
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
		Date futureDate = system.today().addDays(2);
        
        Id physicalEventRecordType = Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Physical_Event').getRecordTypeId();

        Brand_Experience_Variation__c exVar = new Brand_Experience_Variation__c(
            Brand_Experience__c = ex.Id,
            Name = 'test',
            Status__c = 'Draft',
            TargetingMethod__c = 'Dynamic',
            StartDateTime__c = system.today(),
            EndDateTime__c = futureDate,
            Required_Appointment__c=true,
            recordTypeId=physicalEventRecordType
        );

        insert exVar;
        
        Date todayDate=Date.today();
        Brand_Experience_Variation__c exVar1 = new Brand_Experience_Variation__c(
            Brand_Experience__c = ex.Id,
            Name = 'test1',
            Status__c = 'Draft',
            TargetingMethod__c = 'Dynamic',
            StartDateTime__c = system.today(),
            EndDateTime__c = futureDate,
            Required_Appointment__c=true,
            recordTypeId=physicalEventRecordType
        );
        insert exVar1;

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

        IM_Notifications__c notificationTemplate = new IM_Notifications__c(Name='en_US',Experience_member_approved__c= 'New client(s) added to the event list : "{0}"', VariationMemberNomination__c='Your client "{0}" has been Approved by your manager' );
        insert notificationTemplate;
    }

    @isTest
    static void testHandleBeforeInsert() {
        Club_MemberShip__c clubM = [SELECT Id, clientId__c FROM Club_MemberShip__c LIMIT 1];
        List<Brand_Experience_Variation__c> exVar = [SELECT Id FROM Brand_Experience_Variation__c LIMIT 2];

        Brand_Experience_Variation_Member__c exMember = new Brand_Experience_Variation_Member__c(
            Brand_Experience_Variation__c = exVar[0].Id,
            ClubMember__c = clubM.Id,
            Client__c = clubM.clientId__c,
            Name = 'test'
        );
      

        Test.startTest();
        insert exMember;
        //System.assertnotequals(exMember.UniqueKey__c, exMember.Brand_Experience_Variation__c + '_' + exMember.Client__c);
        
        Brand_Experience_Variation_Member__c exMember1 = new Brand_Experience_Variation_Member__c(
            Brand_Experience_Variation__c = exVar[1].Id,
            ClubMember__c = clubM.Id,
            Client__c = clubM.clientId__c,
            Name = 'test2',
            NominationStatus__c = 'Approved'
        );
      
        insert exMember1;
        Test.stopTest();
        
    }
    @isTest
    static void testHandleBeforeUpdate() {
        Club_MemberShip__c clubM = [SELECT Id, clientId__c FROM Club_MemberShip__c LIMIT 1];
        Brand_Experience_Variation__c exVar = [SELECT Id FROM Brand_Experience_Variation__c LIMIT 1];

        Brand_Experience_Variation_Member__c exMember = new Brand_Experience_Variation_Member__c(
            Brand_Experience_Variation__c = exVar.Id,
            ClubMember__c = clubM.Id,
            Client__c = clubM.clientId__c,
            Name = 'test',
            NominationStatus__c = 'Pending'
        );
        insert exMember;
        
        Brand_Experience_Variation_Member_Guest__c guest = new Brand_Experience_Variation_Member_Guest__c(
            Name='Test Guest',
            Relationship__c ='Child',
            Brand_Experience_Variation_Member__c = exMember.Id            
        );
        insert guest;
        
        Test.startTest();
        exVar.Status__c = 'Participation Opened';
        update exVar;
        exMember.NominationStatus__c = 'Approved';
        exMember.rsvpState__c = 'Not Registered';
        
        update exMember;
        
      
        exMember.rsvpState__c = 'Registered';
        exMember.Attendance__c = 'No';
        update exMember;
        
        exMember.rsvpState__c = 'Registered';
        exMember.Attendance__c = 'Yes';
        update exMember;
        
        exMember.NominationStatus__c = 'Refused';
        update exMember;
        
       /* exMember.rsvpState__c = 'Declined';
        update exMember;*/
        
        exMember.rsvpState__c = 'Removed';
        update exMember;
        
        System.assertnotequals(exMember.UniqueKey__c, exMember.Brand_Experience_Variation__c + '_' + exMember.Client__c);
        Test.stopTest();
    }
    @isTest
    static void testHandleAppointmentUpdate() {
         Club_MemberShip__c clubM = [SELECT Id, clientId__c FROM Club_MemberShip__c LIMIT 1];
        Brand_Experience_Variation__c exVar = [SELECT Id FROM Brand_Experience_Variation__c LIMIT 1];

        Brand_Experience_Variation_Member__c exMember = new Brand_Experience_Variation_Member__c(
            Brand_Experience_Variation__c = exVar.Id,
            ClubMember__c = clubM.Id,
            Client__c = clubM.clientId__c,
            Name = 'test',
            NominationStatus__c = 'Pending'
        );
        insert exMember;
        
        Event myAppointment = new Event(
        	StartDateTime = DateTime.now().addHours(3),
            EndDateTime =DateTime.now().addDays(2),
            Subject= 'Event',
            Description= 'new test appoitment',
     		Event__c = exMember.Id
        );
        insert myAppointment;
        exVar.Status__c = 'Participation Opened';
        update exVar;
        Test.startTest();
        exMember.NominationStatus__c = 'Approved';
        exMember.rsvpState__c = 'Not Registered';
        exMember.Attendance__c='No';
        update exMember;
        
        Test.stopTest();
    }
}