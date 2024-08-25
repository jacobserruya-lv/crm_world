@isTest
public with sharing class CT_CreateClientMembersBatch_TEST {
    @isTest
    public static void createClientMembersBatch_TEST() {
        User user = createUser();
        Account acc = createAccount(user.Id, '110592100');
        Account acc2 = createAccount(user.Id, '110592104');
        Account acc3 = createAccount(user.Id, '110592108');
        List<String> clientIdsList = new List<String>{acc.Id, acc2.Id, acc3.Id};
        List<Account> accList = [SELECT PersonContactId FROM Account WHERE Id in :clientIdsList];
        List<String> contactIdsList = new List<String>();

        for (Account a : accList) {
            contactIdsList.add(a.PersonContactId);
        }

        String commaSepIds = contactIdsList.size() > 0 ? String.join(contactIdsList, ';') : '';

        CLI_CliList__c clientList = new CLI_CliList__c(
            Name = 'Test',
            Active__c = true,
            ExpirationDate__c = date.today().addYears(1),
            Description__c = 'Test',
            Is_visible_by_CA__c = true,
            Typology__c = 'topology',
            Type__c = 'regular',
            Offer_Code__c = 'offerCode',
            Show_In_Icon__c = true,
            TECH_LaunchAddMembersBatch__c = true,
            TECH_TempAccountIds__c = commaSepIds,
            TECH_CreatedFromTCLScreen__c = true,
            OwnerId = user.Id
        );    

        insert clientList;

        List<CLM_CliListMember__c> membersList = new List<CLM_CliListMember__c>();
        for (String id : contactIdsList) {
            CLM_CliListMember__c CLM = new CLM_CliListMember__c(
                ClientList__c = clientList.Id,
                Client__c = id
            );
            membersList.add(CLM);
        }

        List<String> alreadyNotifiedIds = new List<String>();
        CT_CreateClientMembersBatch CMBatch = new CT_CreateClientMembersBatch(membersList, alreadyNotifiedIds, 'regular');
        Id jobId = Database.executeBatch(CMBatch);
    }

    public static User createUser() {
        ApexPages.standardController controller = new ApexPages.standardController(new Account());
        Global_ClientViewDispatch_VFCx extension = new Global_ClientViewDispatch_VFCx(controller);
        Account currentAccount = extension.currentAccount;
        Profile p = [SELECT Id FROM Profile WHERE Name = 'STAR_Corporate'];
        User user = new User(Alias = 'Tester', Email = 'adminUser@testlv.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = p.Id,
				TimeZoneSidKey = 'America/Los_Angeles', UserName = randomNumber() + 'adminUser@testlv.com');
        insert user;
        return user;
    }

    public static Account createAccount(Id userId, string dreamId) {
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

    public static Integer randomNumber() {
        return Integer.valueof((Math.random() * 10000));
    }
}