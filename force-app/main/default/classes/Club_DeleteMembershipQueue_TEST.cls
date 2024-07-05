@isTest
private class Club_DeleteMembershipQueue_TEST {
    @testSetup
    static void setup() {
        Club_and_Seasons__c clubSneakers = new Club_and_Seasons__c(
            Name = 'Sneakers'
        );
        insert clubSneakers;

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

    @IsTest
    static void excute() {
        Test.startTest();
        List<Club_MemberShip__c> clubMemberShipList = [
            SELECT Id
            FROM Club_MemberShip__c
            LIMIT 1
        ];
        Club_DeleteMembershipQueue deleteMembersQueue = new Club_DeleteMembershipQueue(clubMemberShipList);
        System.enqueueJob(deleteMembersQueue);
        Test.stopTest();
    } 
}