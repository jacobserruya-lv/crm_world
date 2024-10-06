@IsTest
class BatchCAClubMembershipScheduler_TEST {
    @testSetup
    static void setup() {
        Profile iconProfile = [SELECT Id FROM Profile WHERE Name = 'ICON_SA' LIMIT 1];
        Profile identityProfile = [SELECT Id FROM Profile WHERE Name = 'Identity User' LIMIT 1];

        User iconUser = new User(
            profile = iconProfile,
            ProfileId = iconProfile.Id,
            FirstName = 'test',
            LastName = 'user',
            Alias = 'testuser',
            Email = 'test.user@louisvuitton.com',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'en_US',
            Username = 'test.user@louisvuitton.com.icon',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            IsActive = TRUE
        );

        insert iconUser;

        Club_and_Seasons__c clubSneakers = new Club_and_Seasons__c(
            Name = 'Sneakers'
        );
        insert clubSneakers;
    }

    @isTest 
    static void scheduleTest() {
        Test.startTest();
        Identity_TestFactory.createSettings();
        Identity_TestFactory.createUser('test','user','test.user@louisvuitton.com','0541234567','972');

        List<Account> accounts = [SELECT Id, DreamId__C FROM Account WHERE PersonEmail = 'test.user@louisvuitton.com' LIMIT 1];
        
        if(!accounts.isEmpty()){
            Account acc = accounts.get(0);
            acc.DreamId__C = 'asdfghj145';
        	update acc;
        }
      
        String cron = '0 0 23 * * ?';
        BatchCAClubMembershipScheduler schd = new BatchCAClubMembershipScheduler();
        String jobId = System.schedule('test BatchCAClubMembershipScheduler', cron, schd);
        Test.stopTest();
    }
}