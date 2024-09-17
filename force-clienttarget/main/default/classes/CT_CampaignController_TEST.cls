@isTest
public with sharing class CT_CampaignController_TEST {
    @testSetup
    static void setup() {
        Campaign__c cmp = new Campaign__c();
        cmp.Name = 'test';
        cmp.Status__c = 'Ongoing';
        insert cmp;

		User user = createUser();
        Account acc = createAccount(user.Id, '85739682');

        CampaignMember__c cmpMember = new CampaignMember__c();
        cmpMember.Campaign__c = cmp.Id;
        cmpMember.Member__c = acc.Id;
        insert cmpMember;
    }

    @isTest
    public static void pushClientsToCampaignFromBatch_TEST() {
        Test.startTest();
        
        Campaign__c cmp = [SELECT Id FROM Campaign__c LIMIT 1];
        List<String> dreamIds = new List<String>{'85739682','85740498','85743511','56119070','56268685'};
		User user = [SELECT Id FROM User LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE DREAMID__c = '85739682' LIMIT 1];

        CT_CampaignController.pushClientsToCampaignFromBatch(
            cmp.Id,
            new Map<String, String> { '85739682' => null }
        );

        Test.stopTest();
    }

    @isTest
    public static void getAllCampaigns_TEST() {
        Test.startTest();
        List<Campaign__c> campaigns = CT_CampaignController.getAllCampaigns();
        Test.stopTest();
    }

    @isTest
    public static void assignCampaignMembersToCA_TEST() {
        Test.startTest();

        Campaign__c cmp = [SELECT Id FROM Campaign__c LIMIT 1];
        List<String> dreamIds = new List<String>{'85739682','85740498','85743511','56119070','56268685'};
		User user = [SELECT Id FROM User LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE DREAMID__c = '85739682' LIMIT 1];

        CT_CampaignController.assignCampaignMembersToCA(
            new List<String> { acc.Id },
            user.Id,
            cmp.Id
        );
        Test.stopTest();
    }

    @isTest
    public static void getCampaignMembersByAccountIds_TEST() {
        Test.startTest();

        Campaign__c cmp = [SELECT Id FROM Campaign__c LIMIT 1];
        List<String> dreamIds = new List<String>{'85739682','85740498','85743511','56119070','56268685'};
		User user = [SELECT Id FROM User LIMIT 1];
        Account acc = [SELECT Id FROM Account WHERE DREAMID__c = '85739682' LIMIT 1];

        CT_CampaignController.getCampaignMembersByAccountIds(
            cmp.Id,
            dreamIds
        );
        Test.stopTest();
    }

    @isTest
    public static void getNumberOfClientsAttachedToCA_TEST() {
        Test.startTest();

        Campaign__c cmp = [SELECT Id FROM Campaign__c LIMIT 1];
		User user = [SELECT Id FROM User LIMIT 1];

        CT_CampaignController.getNumberOfClientsAttachedToCA(
            new List<string> { user.Id },
            cmp.Id
        ) ;
        Test.stopTest();
    }

    @isTest
    public static void pushClientsToCampaignFromBatchError_TEST() {
        Test.startTest();
        Campaign__c cmp = new Campaign__c();
        cmp.Name = 'test';
        cmp.Status__c = 'Ongoing';
        insert cmp;

        try {
            delete cmp;
            // Failed the test in purpose in order to test the error lines 
            CT_CampaignController.pushClientsToCampaignFromBatch(
                cmp.Id,
                new Map<String, String> { '85739682' => null }
            );
        } catch(Exception e) {
            System.debug(e);
        }

        Test.stopTest();
    }

    public static User createUser() {
        ApexPages.standardController controller = new ApexPages.standardController(new Account());
        Global_ClientViewDispatch_VFCx extension = new Global_ClientViewDispatch_VFCx(controller);
        Account currentAccount = extension.currentAccount;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'STAR_Corporate'];
        User user = new User(Alias = 'Tester', Email = 'adminUser@testlv.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = p.Id,
				TimeZoneSidKey = 'America/Los_Angeles', UserName = 'adminUser@testlv.com');
        insert user;
        return user;
    }

    public static Account createAccount(Id userId, String dreamId) {
        Account acc = new Account(
            Firstname = 'test' + randomNumber(),
            LastName = 'test' + randomNumber(),
            PersonEmail = 'test' + dreamId + '@balink.net',
            OwnerId = userId,
            DREAMID__c = dreamId
        );
        insert acc;
        return acc;
    }

    private static void createStore() {
        store__c storeRecord = new store__c(
            RetailStoreId__c = 'R33',
            Name = 'Test'
        );
        insert storeRecord;
    }

    public static Integer randomNumber() {
        return Integer.valueof((Math.random() * 10));
    }

    public static String randomDreamId() {
        String dreamId = '';
        for (Integer i = 0; i < 8; i++) {
            dreamId += randomNumber();
        }
        return dreamId;
    }
}