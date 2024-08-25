@isTest
public with sharing class CT_CSVParseController_TEST {
    @isTest
    public static void readCSVFile_TEST() {
        Id idContentDocument = '069f0000000oJQqAAM';

        CT_CSVParseController.readCSVFile(idContentDocument);
    } 

    @isTest
    public static void getEmptyOwnersIds_TEST() {
        List<String> caIdsList = new List<String>();

        CT_CSVParseController.getEmptyOwnersIds('level', '15' , caIdsList);
        CT_CSVParseController.getEmptyOwnersIds('level1', '15' , caIdsList);
        CT_CSVParseController.getEmptyOwnersIds('level2', '15' , caIdsList);
        CT_CSVParseController.getEmptyOwnersIds('level3', '15' , caIdsList);
        CT_CSVParseController.getEmptyOwnersIds('store', '15' , caIdsList);
    }

    @isTest
    public static void createReassignCL_TEST() {
        User user = createUser();
        Store__c store = createStore();
        Account acc = createAccount(user.Id, '110592106', store.Id);
        List<String> clientIdsList = new List<String>{acc.Id, '001i000002EdkBpAAJ','001i000002EdkBvAAJ'};
        String caId = user.Id;

        CT_CSVParseController.createReassignCL(clientIdsList, caId);
    }

    @isTest
    public static void createCLwithMembers_TEST() {
        Test.startTest();
        User user = createUser();
        User user2 = IC_TestFactory.createUser('dreamuserLV@lvtest.com');
        user2.profileId = IC_UTILS.getSAProfile();
        user2.DefaultStore__c = 'LV GUADALAJARA PALACIO DE HIERRO';
        user2.DREAMId__c = '123456';
        user2.isactive = true;
        insert user2;

        Store__c store = createStore();
        Account acc = createAccount(user.Id, '110592110', store.Id);
        Account acc2 = createAccount(user2.Id, '110582114', store.Id);
        String name = 'Test List';
        Date expirationDate = date.today();
        List<String> dreamIdsList = new List<String>{acc.DREAMID__c};
        String parseParams = '{"type":"exclusive","showInIcon":"false","topology":"NBA MSG Experience","offerCode":"exclu_nba_1_2020","clientWithEmail":"true","createEmpty":"false","zone":"R33","zoneType":"store"}';

        CT_CSVParseController.createCLwithMembers(name, expirationDate, name, dreamIdsList, null, parseParams);

        List<String> caList = new List<String>{user.Id};
        dreamIdsList = new List<String>{acc2.DREAMID__c};
        parseParams = '{"type":"exclusive","showInIcon":"false","topology":"NBA MSG Experience","offerCode":"exclu_nba_1_2020","clientWithEmail":"true","createEmpty":"true","zone":"R33","zoneType":"store"}';
        CT_CSVParseController.createCLwithMembers(name, expirationDate, name, dreamIdsList, caList, parseParams);
        Test.stopTest();
    }

    @isTest
    public static void masterCLTriggerTest() {
        User user = createUser();
        Store__c store = createStore();
        Account acc = createAccount(user.Id, '110592110', store.Id);
        Account acc2 = createAccount(user.Id, '110592114', store.Id);

        CLI_CliList__c masterClientList = new CLI_CliList__c(
            Name = 'Master',
            Active__c = true,
            ExpirationDate__c = date.today(),
            Description__c = 'Test description',
            Is_visible_by_CA__c = true,
            Type__c = 'regular',
            Show_In_Icon__c = true,
            TECH_LaunchAddMembersBatch__c = false,
            TECH_CreatedFromTCLScreen__c = true,
            IsMasterClientList__c = true
        ); 
        insert masterClientList;

        CLI_CliList__c childCl = new CLI_CliList__c(
            Name = 'Child',
            Active__c = true,
            ExpirationDate__c = date.today(),
            Description__c = 'Test description',
            Is_visible_by_CA__c = true,
            Type__c = 'regular',
            Show_In_Icon__c = true,
            TECH_LaunchAddMembersBatch__c = false,
            TECH_CreatedFromTCLScreen__c = true,
            IsMasterClientList__c = false,
            Master_Client_List__c = masterClientList.Id
        ); 
        insert childCl;

        masterClientList.Description__c = 'Updated description';
        update masterClientList;
        delete masterClientList;
    }

    @isTest
    public static void isAllFromOneStore_TEST() {
        User user = createUser();
        Store__c store = createStore();
        Account acc = createAccount(user.Id, '110592115', store.Id);
        List<String> dreamIds = new List<String>{acc.DREAMID__c,'85739682','85740498','85743511','56119070','56268685'};

        CT_CSVParseController.isAllFromOneStore(dreamIds);
    }

    @isTest
    public static void isAllClientsWithStore_TEST() {
        User user = createUser();
        Store__c store = createStore();
        Account acc = createAccount(user.Id, '110592121', store.Id);
        List<String> dreamIds = new List<String>{acc.DREAMID__c,'85739682','85740498','85743511','56119070','56268685'};
        
        CT_CSVParseController.isAllClientsWithStore(dreamIds);
    }

    @isTest
    public static void getClientsMissingStore_TEST() {
        List<String> dreamIds = new List<String>{'85739682','85740498','85743511','56119070','56268685'};
        List<SObject> accounts = CT_CSVParseController.getClientsMissingStore(dreamIds);
    }

    @isTest
    public static void getProductCategoriesList_TEST() {
        CT_CSVParseController.getProductCategoriesList();
    }

    public static User createUser() {
        ApexPages.standardController controller = new ApexPages.standardController(new Account());
        Global_ClientViewDispatch_VFCx extension = new Global_ClientViewDispatch_VFCx(controller);
        Account currentAccount = extension.currentAccount;
        Profile p = [select id from profile where id=:IC_Utils.getStarCorporateProfile()];
        User user = new User(Alias = 'Tester', Email = 'adminUser@testlv.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = p.Id,
				TimeZoneSidKey = 'Europe/Paris', UserName = 'adminUser@testlv.com');
        insert user;
        return user;
    }

    public static Account createAccount(Id userId, string dreamId, Id storeId) {
        Account acc = new Account(
            Firstname = 'test' + randomNumber(),
            LastName = 'test' + randomNumber(),
            PersonEmail = 'test' + dreamId + '@balink.net',
            OwnerId = userId,
            DREAMID__c = dreamId,
            Store__pc = storeId
        );
        insert acc;  
        return acc;
    }

    private static store__c createStore() {
        store__c storeRecord = new store__c(
            RetailStoreId__c = 'R33',
            Name = 'Test'
        );
        insert storeRecord;
        return storeRecord;
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