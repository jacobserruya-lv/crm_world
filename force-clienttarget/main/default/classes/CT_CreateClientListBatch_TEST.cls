@isTest
public with sharing class CT_CreateClientListBatch_TEST {
    @isTest
    public static void createClientListBatch_TEST() {
        User user = createUser();
        List<String> dreamIds = new List<String>{'110592092', '110592096', '110592098'};
        List<Account> accList = createAccounts(user.Id, dreamIds);
        CLI_CliList__c clientList = createClientList(user, accList);
        List<CLI_CliList__c> clsForBatch = new List<CLI_CliList__c>{clientList};

        
        Map<Id, List<Id>> contactByCa = new Map<Id, List<Id>>{
            user.Id => new List<Id>()
        };

        for (Account acc : accList) {
            contactByCa.get(user.Id).add(acc.PersonContactId);
        }

        CT_CreateClientListBatch CMBatch = new CT_CreateClientListBatch(clsForBatch, contactByCa);
        Id jobId = Database.executeBatch(CMBatch);
        
        List<String> dreamIds2 = new List<String>{'110592135', '110592138', '110592125'};
        accList = createAccounts(user.Id, dreamIds2);
        CLI_CliList__c clientList2 = createClientList(user, accList);
        List<CLI_CliList__c> clsForBatch2 = new List<CLI_CliList__c>{clientList2};
        contactByCa.put(user.Id, new List<Id>());
        for (Account acc : accList) {
            contactByCa.get(user.Id).add(acc.PersonContactId);
        }
        CT_CreateClientListBatch CMBatch2 = new CT_CreateClientListBatch(clsForBatch2, contactByCa);
        Id jobId2 = Database.executeBatch(CMBatch2);
    }

    public static CLI_CliList__c createClientList(User user, List<Account> accList) {
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
            Typology__c = 'NBA Regular',
            Type__c = 'exclusive',
            Offer_Code__c = 'exclu_nba_1_2020',
            Show_In_Icon__c = true,
            TECH_LaunchAddMembersBatch__c = true,
            TECH_TempAccountIds__c = commaSepIds,
            TECH_CreatedFromTCLScreen__c = true,
            OwnerId = user.Id
        );      

        return clientList;
    }

    public static List<Account> createAccounts(Id userId, List<String> dreamIds) {
        List<String> clientIdsList = new List<String>();

        for (String id : dreamIds) {
            Account acc = createAccount(userId, id);
            clientIdsList.add(acc.Id);
        }
        
        return [SELECT PersonContactId FROM Account WHERE Id in :clientIdsList];
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

    public static Integer randomNumber() {
        return Integer.valueof((Math.random() * 10000));
    }
}