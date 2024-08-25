@IsTest
public class ExVariationGuestTriggerHandler_TEST {
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
        
        /*
        Date todayDate=Date.today();
        Date futureDate = todayDate.addDays(2);
        Brand_Experience_Variation__c exVar1 = new Brand_Experience_Variation__c(
            Brand_Experience__c = ex.Id,
            Name = 'test1',
            Status__c = 'Draft',
            TargetingMethod__c = 'Dynamic',
            StartDateTime__c = futureDate,
            EndDateTime__c = futureDate
        );
        insert exVar1;*/

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
        
         Brand_Experience_Variation_Member_Guest__c guest = new Brand_Experience_Variation_Member_Guest__c(
            Name='Test Guest',
            Relationship__c ='Child',
            Brand_Experience_Variation_Member__c = exMember.Id            
        );
        insert guest;
    }
    @isTest
    static void testHandleBeforeInsert() {
        Brand_Experience_Variation_Member__c member = [SELECT Id FROM Brand_Experience_Variation_Member__c LIMIT 1];
        Brand_Experience_Variation_Member_Guest__c guest = new Brand_Experience_Variation_Member_Guest__c(
            Name='Test Guest',
            Relationship__c ='Child',
            Brand_Experience_Variation_Member__c = member.Id            
        );
        Test.startTest();
        insert guest;
        Test.stopTest();
    }
    @isTest
    static void testHandleBeforeUpdate() {
       Brand_Experience_Variation_Member__c member = [SELECT Id FROM Brand_Experience_Variation_Member__c LIMIT 1];
       Brand_Experience_Variation_Member_Guest__c guest = new Brand_Experience_Variation_Member_Guest__c(
            Name='Test Guest',
            Relationship__c ='Child',
            Brand_Experience_Variation_Member__c = member.Id            
        );
        insert guest;
        guest.Relationship__c='Friend';
        Test.startTest();
        update guest;
        Test.stopTest();
    }
    @isTest
    static void testHandleAfterDelete() {
        Brand_Experience_Variation_Member_Guest__c guest =[SELECT Id FROM Brand_Experience_Variation_Member_Guest__c LIMIT 1];
        
        Test.startTest();
        delete guest;
        Test.stopTest();
    }
    
}