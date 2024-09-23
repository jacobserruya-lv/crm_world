@isTest
public class ICX_CampaignListViewController_TEST {
    
    @testSetup
    public static void setupData(){
        Id profileCAId = [SELECT Id FROM Profile WHERE Name = 'ICONiCS_SA' LIMIT 1][0].Id;
        Id profileManagerId = [SELECT Id FROM Profile WHERE Name = 'ICONiCS_SA_Manager' LIMIT 1][0].Id;
        UserRole urManager = [Select Id, Name, DeveloperName FRom UserRole WHERE DeveloperName = 'EUR_CSC_UK_Nordics_Manager'];
        UserRole urCA = [Select Id, Name, DeveloperName FRom UserRole WHERE DeveloperName = 'EUR_CSC_UK_Nordics_SA'];
        
        
        User newManagerUser = ICX_TestFactory.createUser(profileManagerId);
        newManagerUser.lastName = 'TestManager';
        newManagerUser.UserRoleId = urManager.Id;
        insert newManagerUser;
        
        User newCAUser = ICX_TestFactory.createUser(profileCAId);
        newCAUser.UserRoleId = urCA.Id;
        newCAUser.lastName = 'TestCA';
        newCAUser.Alias = 'tsca';
        insert newCAUser;
    }
    
    @isTest
    public static void getCampaignsListCA_TEST(){
        
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
        Id AccId = [SELECT Id FROM Account LIMIT 1][0].Id;
        User userCA = [SELECT Id FROM User WHERE LastName = 'TestCA' LIMIT 1];
        
        Campaign__c cam = new Campaign__c(
            Name = 'Test Campaign',
            Country__c = 'FRA',
            Description__c = 'test test',
            StartDate__c = 	Date.today(),
            EndDate__c = Date.today().addDays(30),
            Priority__c = '8',
            Status__c = 'New'
        );
        
        insert cam;
        
        Campaign__c camTest = [SELECT Id FROM Campaign__c LIMIT 1];           
        CampaignMember__c camMember = new CampaignMember__c(
            Name = 'Test Member',
            Status__c = 'New',
            Member__c = AccId,
            Interested__c = 'No',
            Contacted__c = 'No',
            AssignedCA__c = userCA.Id,
            Campaign__c = camTest.Id
        );
        
        insert camMember;
        
        Test.startTest();
        System.runAs(userCA){
            ICX_CampaignListViewController.getCampaignsList(15, 0, null, null);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getCampaignsListManager_TEST(){
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
        Id AccId = [SELECT Id FROM Account LIMIT 1][0].Id;
        User userManager = [SELECT Id FROM User WHERE LastName = 'TestManager' LIMIT 1];
        User userCA = [SELECT Id FROM User WHERE LastName = 'TestCA' LIMIT 1];
        
        System.runAs(userManager){
            Campaign__c cam = new Campaign__c(
                Name = 'Test Campaign',
                Country__c = 'FRA',
                Description__c = 'test test',
                StartDate__c = 	Date.today(),
                EndDate__c = Date.today().addDays(30),
                Priority__c = '8',
                Status__c = 'New'
            );
            
            insert cam;
        }
        Campaign__c camTest = [SELECT Id FROM Campaign__c LIMIT 1];           
        CampaignMember__c camMember = new CampaignMember__c(
            Name = 'Test Member',
            Status__c = 'New',
            Member__c = AccId,
            Interested__c = 'No',
            Contacted__c = 'No',
            AssignedCA__c = userCA.Id,
            Campaign__c = camTest.Id
        );
        
        insert camMember;
        
        Test.startTest();
        System.runAs(userManager){
            ICX_CampaignListViewController.getCampaignsList(15, 0, null, null);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getCampaignMemberListManager_TEST(){
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
        Id AccId = [SELECT Id FROM Account LIMIT 1][0].Id;
        User userManager = [SELECT Id FROM User WHERE LastName = 'TestManager' LIMIT 1];
        User userCA = [SELECT Id FROM User WHERE LastName = 'TestCA' LIMIT 1];
        
        System.runAs(userManager){
            Campaign__c cam = new Campaign__c(
                Name = 'Test Campaign',
                Country__c = 'FRA',
                Description__c = 'test test',
                StartDate__c = 	Date.today(),
                EndDate__c = Date.today().addDays(30),
                Priority__c = '8',
                Status__c = 'New'
            );
            
            insert cam;
        }
        Campaign__c camTest = [SELECT Id FROM Campaign__c LIMIT 1];           
        CampaignMember__c camMember = new CampaignMember__c(
            Name = 'Test Member',
            Status__c = 'New',
            Member__c = AccId,
            Interested__c = 'No',
            Contacted__c = 'No',
            AssignedCA__c = userCA.Id,
            Campaign__c = camTest.Id
        );
        
        insert camMember;
        
        Test.startTest();
        System.runAs(userManager){
            ICX_CampaignListViewController.getCampaignMembersList(15, 0, null, null, null);
        }
        Test.stopTest();
    }
    
    @isTest
    public static void getCampaignsListFilter_TEST(){
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
        Id AccId = [SELECT Id FROM Account LIMIT 1][0].Id;
        User userManager = [SELECT Id FROM User WHERE LastName = 'TestManager' LIMIT 1];
        User userCA = [SELECT Id FROM User WHERE LastName = 'TestCA' LIMIT 1];
        
        System.runAs(userManager){
            Campaign__c cam = new Campaign__c(
                Name = 'Test Campaign 01',
                Country__c = 'FRA',
                Description__c = 'test test',
                StartDate__c = 	Date.today(),
                EndDate__c = Date.today().addDays(30),
                Priority__c = '7',
                Status__c = 'New'
            );
            
            insert cam;
        }
        Campaign__c camTest = [SELECT Id FROM Campaign__c LIMIT 1];           
        CampaignMember__c camMember = new CampaignMember__c(
            Name = 'Test Member',
            Status__c = 'New',
            Member__c = AccId,
            Interested__c = 'No',
            Contacted__c = 'No',
            AssignedCA__c = userCA.Id,
            Campaign__c = camTest.Id
        );
        
        insert camMember;
        
        Map<String, String> filterMap = new Map<String, String>{ 'Priority__c' => '7', 'Status__c' => 'New'};
            List<Map<String, String>> res = new List<Map<String, String>>();
        Test.startTest();
        System.runAs(userManager){
            res = ICX_CampaignListViewController.getCampaignsList(15, 0, 'Campaign' , filterMap);
        }
        Test.stopTest();
        
        System.assertEquals(1, res.size());
    }
    
    @isTest
    public static void getCampaignMemberListFilter_TEST(){
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
        Id AccId = [SELECT Id FROM Account LIMIT 1][0].Id;
        User userCA = [SELECT Id FROM User WHERE LastName = 'TestCA' LIMIT 1];
        
        Campaign__c cam = new Campaign__c(
            Name = 'Test Campaign',
            Country__c = 'FRA',
            Description__c = 'test test',
            StartDate__c = 	Date.today(),
            EndDate__c = Date.today().addDays(30),
            Priority__c = '8',
            Status__c = 'New'
        );
        
        insert cam;
        
        Campaign__c camTest = [SELECT Id FROM Campaign__c LIMIT 1];           
        CampaignMember__c camMember = new CampaignMember__c(
            Name = 'Test Member',
            Status__c = 'New',
            Member__c = AccId,
            Interested__c = 'No',
            Contacted__c = 'No',
            AssignedCA__c = userCA.Id,
            Campaign__c = camTest.Id
        );
        
        insert camMember;
        
        Map<String, String> filterMap = new Map<String, String>{ 'Campaign__r.Priority__c' => '8', 'Campaign__r.Status__c' => 'New', 'campaignName' => 'Test'};
            List<Map<String, String>> res = new List<Map<String, String>>();
        
        Test.startTest();
        res = ICX_CampaignListViewController.getCampaignMembersList(15, 0, 'Louis', filterMap, null);
        Test.stopTest();
        
        System.assertEquals(1, res.size());
    }
    
}