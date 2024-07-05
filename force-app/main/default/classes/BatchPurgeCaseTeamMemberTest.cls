@isTest
private class BatchPurgeCaseTeamMemberTest {
    
    
    @testSetup
    static void setupTestData() {
        CaseTeamRole testCaseTeamRole;
      
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
        Case testCase = new Case(
            Subject = 'Test Case',
            Status = 'Closed',
            AccountId = acc.Id,
            CreatedDate = DateTime.now().addYears(-10),
            ClosedDate =  DateTime.newInstance(2015, 3, 19, 12, 28, 18)
        );
        system.debug(testCase); 
        insert testCase;  
        
        User testUser = new User(
                FirstName = 'debo',
                LastName = 'Marc',
                Username = 'testdeboma@gmail.com',
                Email = 'testebomarc@gmail.com',
                Alias = 'Tdeboma',
                CommunityNickname = 'testdebomarc',
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'Standard User'].Id,
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US',
                TimeZoneSidKey = 'America/Los_Angeles'
            
        );
        insert testUser;
        
        System.runAs(new User(Id = UserInfo.getUserId())) {
        testCaseTeamRole = new CaseTeamRole(
            Name = 'Test Case Team Role',
            AccessLevel = 'Read');
        insert testCaseTeamRole;
        }


        CaseTeamMember testCaseTeamMember = new CaseTeamMember(
            ParentId = testCase.Id,
            MemberId = testUser.Id,
            TeamRoleId = testCaseTeamRole.Id
        );
        insert testCaseTeamMember;
      
    }

    @isTest
    static void testBatchExecution() {
        Test.startTest();
        BatchPurgeCaseTeamMember batch = new BatchPurgeCaseTeamMember(0);
        
        System.debug('Debo ' + [SELECT Id,Parent.ClosedDate,Parent.Status FROM CaseTeamMember][0].Parent.Status +  [SELECT Id,Parent.ClosedDate,Parent.Status FROM CaseTeamMember][0].Parent.ClosedDate);
        Database.executeBatch(batch);
        Test.stopTest();
        
        Integer caseTeamMemberCount = [SELECT COUNT() FROM CaseTeamMember];
        System.assertEquals(0, caseTeamMemberCount, 'Tous les enregistrements ont été supprimés.');
               
    }

}