@isTest
class ICX_AccountIdsInvocTest {
    
    @testSetup 
    static void setup() {
        List<Account> testAccts = new List<Account>();
        testAccts.add(new Account(FirstName='test', LastName='TestSingleMatch', PersonMobilePhone='+3300000000'));
        for(Integer i=0; i<2 ;i++) {
            testAccts.add(new Account(FirstName='test', LastName='TestAcc'+i, PersonMobilePhone='+3300112233', PersonEmail='test@test.test'));
        }
        insert testAccts;
        Task t = new Task(
            Subject = 'TestTask',
            Status = 'Completed',
            Priority = 'Normal',
            OwnerId = UserInfo.getUserId()
        );
        insert t;
        Case c = new Case(
            Subject = 'TestCase',
            OwnerId = UserInfo.getUserId()
        );
        insert c;
    }
    
    @isTest
    static void testInboundMultiMatch(){
        Account acc1 = [SELECT Id FROM Account WHERE LastName='TestAcc0' LIMIT 1];
        Account acc2 = [SELECT Id FROM Account WHERE LastName='TestAcc1' LIMIT 1];
        Task t = [SELECT Id FROM Task WHERE Subject='TestTask' LIMIT 1];
        
		Test.startTest();
        ICX_AccountIdsInvoc.Request req = new ICX_AccountIdsInvoc.Request();
        req.accountIds = '!!!';
        req.direction = 'In';
        req.phoneNumber = '+3300112233';
        req.recordId = t.Id;
        
        List<ICX_AccountIdsInvoc.Request> requests = new List<ICX_AccountIdsInvoc.Request>{req};
        List<ICX_AccountIdsInvoc.Result> results = ICX_AccountIdsInvoc.getAccountIds(requests);
        List<String> accIds = results.get(0).AccountCollection;
        Boolean multimatch = results.get(0).multiMatch;
        Test.stopTest();

        Assert.areEqual(2, accIds.size());
        Assert.isTrue(accIds.contains(acc1.Id));
        Assert.isTrue(accIds.contains(acc2.Id));
        Assert.isTrue(multimatch);
    }

    @isTest
    static void testOuboundSingleMatch(){
        Task t = [SELECT Id FROM Task WHERE Subject='TestTask' LIMIT 1];
        Test.startTest();
        ICX_AccountIdsInvoc.Request req = new ICX_AccountIdsInvoc.Request();
        req.accountIds = '';
        req.phoneNumber = '+3300000000';
        req.direction = 'Out';
        req.recordId = t.Id;
        List<ICX_AccountIdsInvoc.Request> requests = new List<ICX_AccountIdsInvoc.Request>{req};
        List<ICX_AccountIdsInvoc.Result> results = ICX_AccountIdsInvoc.getAccountIds(requests);
        String whatId = results.get(0).whatId;
        Test.stopTest();

        Task task = [SELECT Id, WhatId FROM Task WHERE Id = :t.Id];
        Assert.areEqual(whatId, task.WhatId);
    }

    @isTest
    static void testInboundIdsToCollection(){
        Task t = [SELECT Id FROM Task WHERE Subject='TestTask' LIMIT 1];
        Account acc1 = [SELECT Id FROM Account WHERE LastName='TestAcc0' LIMIT 1];
        Account acc2 = [SELECT Id FROM Account WHERE LastName='TestAcc1' LIMIT 1];
        Test.startTest();  
        ICX_AccountIdsInvoc.Request req = new ICX_AccountIdsInvoc.Request();
        req.accountIds = acc1.Id+','+acc2.Id;
        req.phoneNumber = '+3300112233';
        req.recordId = t.Id;
        List<ICX_AccountIdsInvoc.Request> requests = new List<ICX_AccountIdsInvoc.Request>{req};
        List<ICX_AccountIdsInvoc.Result> results = ICX_AccountIdsInvoc.getAccountIds(requests);
        List<String> accIds = results.get(0).AccountCollection;
        Test.stopTest();
        
        Assert.areEqual(2, accIds.size());
        Assert.isTrue(accIds.contains(acc1.Id));
        Assert.isTrue(accIds.contains(acc2.Id));
    }  
   
    @isTest
    static void testCaseMultiMatch(){
        Contact contact1 = [SELECT Id FROM Contact WHERE AccountId IN (
            SELECT Id FROM Account WHERE LastName='TestAcc0'
        ) LIMIT 1];
        Contact contact2 = [SELECT Id FROM Contact WHERE AccountId IN (
            SELECT Id FROM Account WHERE LastName='TestAcc1'
        ) LIMIT 1];
        Case c = [SELECT Id FROM Case WHERE Subject='TestCase' LIMIT 1];
        
        Test.startTest();
        ICX_AccountIdsInvoc.Request req = new ICX_AccountIdsInvoc.Request();
        req.emailAddress = 'test@test.test';
        req.recordId = c.Id;
        List<ICX_AccountIdsInvoc.Request> requests = new List<ICX_AccountIdsInvoc.Request>{req};
        List<ICX_AccountIdsInvoc.Result> results = ICX_AccountIdsInvoc.getAccountIds(requests);
        List<String> accIds = results.get(0).AccountCollection;
        Boolean multimatch = results.get(0).multiMatch;
        Test.stopTest();
		      
        Assert.isTrue(multimatch);
        Assert.areEqual(2, accIds.size());
        Assert.isTrue(accIds.contains(contact1.Id));
        Assert.isTrue(accIds.contains(contact2.Id));
	
    }
}