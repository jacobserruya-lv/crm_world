@isTest
public with sharing class CL_controller_TEST {
    @isTest
    public static void getManagementZoneLevels_TEST() {
        List<AggregateResult> mzl = CL_controller.getManagementZoneLevel();
        List<AggregateResult> mzl1 = CL_controller.getManagementZoneSubLevel1('15');
        List<AggregateResult> mzl2 = CL_controller.getManagementZoneSubLevel2('31');
        List<AggregateResult> mzl3 = CL_controller.getManagementZoneSubLevel3('98');
        List<AggregateResult> defaultStore = CL_controller.getDefaultStore('70');
        List<User> assignedCA = CL_controller.getAssignedCA('A06', new List<String>());
    }

    @isTest
    public static void getNumberofClientsForCA_TEST() {
        Integer numberofClientsForCA = CL_controller.getNumberofClientsForCA('56268685');
    } 

    @isTest
    public static void getNumberofClientsForCAList_TEST() {
        User user = createUser();
        Account acc = createAccount(user.Id, '110592086');
        Account acc2 = createAccount(user.Id, '110592090');
        List<String> caIdsList = new List<String>{user.Id};
        Map<string, Integer> numberofClientsForCAList = CL_controller.getNumberofClientsForCAList(caIdsList);
    }

    @isTest
    public static void getClientList_TEST() {
        List<String> dreamIds = new List<String>{'85739682','85740498','85743511','56119070','56268685'};
        List<Account> clients = CL_controller.getClientList(dreamIds, 'cache');
        List<Account> clients2 = CL_controller.getBasicClientList(dreamIds);
    }

    @isTest
    public static void getClientsByFilters_TEST() {
        List<String> ownerIds = new List<String>{'LVM005526'};
        String filters = '{ "filters": [{ "left": { "left": "is_10k", "operator": "=", "right": true }] }';
        List<Account> clients = CL_controller.getClientsByFilters(filters, '', '', '', ownerIds);
    }

    @isTest
    public static void getClientsByEngineFilters_TEST() {
        List<String> ownerIds = new List<String>{'LVM005526'};
        String filters = '{ "selectionCriterionIds": null,  "targetCriterionId": null, "creatorUserId": null, "set": { "SetType": "predicate-set", "Predicate": { "PredicateType": "predicates-group", "OperatorId": 1, "Predicates": [ { "PredicateType": "simple-predicate", "ValueType": "Text", "CriterionId": 282, "OperatorId": 1, "Values": [ "15" ] } ] } } }';
        Object clients = CL_controller.getClientsByEngineFilters(filters, '', '', '', ownerIds);
    }

    @isTest
    public static void getClientsByZoneQuery_TEST() {
        List<String> dreamIds = new List<String>{'85739682','85740498','85743511','56119070','56268685'};
        List<String> ownerIds = new List<String>{'LVM005526'};
        List<Account> clients = CL_controller.getClientsByZoneQuery('store', 'R33', dreamIds, ownerIds);
    }

    @isTest
    public static void getIsAllClientsInMyPerimeter_TEST() {
        List<String> clients = new List<String>();
        CL_controller.getIsAllClientsInMyPerimeter('level', '15', clients);
        CL_controller.getIsAllClientsInMyPerimeter('level1', '15', clients);
        CL_controller.getIsAllClientsInMyPerimeter('level2', '15', clients);
        CL_controller.getIsAllClientsInMyPerimeter('level3', '15', clients);
        CL_controller.getIsAllClientsInMyPerimeter('store', '15', clients);
    }

    @isTest
    public static void getAllStores_TEST() {
        createStore();
        Map<string,String> stores = CL_controller.getAllStores();
    }

    @isTest
    public static void getUserSettings_TEST() {
        User user = createUser();

        CT_unlockAuthorizedProfiles__c unlockProfile = new CT_unlockAuthorizedProfiles__c();
        unlockProfile.profiles__c = 'Test Setting';
        insert unlockProfile;

        CT_exclusiveOffer__c exclusiveOffer = new CT_exclusiveOffer__c();
        exclusiveOffer.isDisplay__c = true;
        insert exclusiveOffer;

        List<String> dreamIds = new List<String>{'85739682','85740498','85743511','56119070','56268685'};
        CL_controller.getIsAllClientsInMyZone('15', dreamIds);
        CL_controller.getExclusiveOfferSettings();
        CL_controller.getUnlockStoreProfilesSettings();
        CL_controller.getCurrentUserSettings();
    }
    
    @isTest
    public static void getClientListJobsDetails_TEST() {
        User user = createUser();
        Account acc = createAccount(user.Id, '110592077');
        Account acc2 = createAccount(user.Id, '110592081');
        Account acc3 = createAccount(user.Id, '110592088');
        List<String> clientIdsList = new List<String>{acc.Id, acc2.Id, acc3.Id};
        List<Account> accList = [SELECT PersonContactId FROM Account WHERE Id in :clientIdsList];
        CLI_CliList__c clientList = createClientList(user, accList);

        Map<Id, List<Id>> contactByCa = new Map<Id, List<Id>>{
            user.Id => new List<Id>()
        };

        for (Account account : accList) {
            contactByCa.get(user.Id).add(acc.PersonContactId);
        }

        List<CLI_CliList__c> clsForBatch = new List<CLI_CliList__c>{clientList};
        CT_CreateClientListBatch CMBatch = new CT_CreateClientListBatch(clsForBatch, contactByCa);
        Id jobId = Database.executeBatch(CMBatch);

        AsyncApexJob job = CL_controller.getClientListJobDetails(jobId);
        Parent_Child_job_id__c childJob = CL_controller.getChildJobId(jobId);
        CL_controller.deleteChildJob(jobId);
    }

    @isTest
    public static void getMissingEmailDreamIds_TEST() {
        List<String> dreamIds = new List<String>{'85739682','85740498','85743511','56119070','56268685'};
        List<String> clients = CL_controller.getMissingEmailDreamIds(dreamIds);
    }

    
    @isTest
    public static void getNotContactableClients_TEST() {
        List<String> dreamIds = new List<String>{'85739682','85740498','85743511','56119070','56268685'};
        User user = createUser();
        Account acc = createAccount(user.Id, dreamIds[0]);
        List<Map<String,String>> clients = CL_controller.getNotContactableClients(dreamIds, new List<String> {'CHINA'});
    }
    

    @isTest
    public static void addClientsToAnEventFromBatch_TEST() {
        Test.startTest();
        
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = 'A06');
		insert store;
        
        Brand_Experience__c ex = new Brand_Experience__c();
        ex.Name = 'test';
        ex.Status__c = 'Ready';
        ex.Experience_StartDate__c =  DateTime.Now().AddDays(45);
        ex.Experience_EndDate__c = DateTime.Now().AddDays(72) ;
        ex.RecordTypeId = BL_Experience_Variation_Utils.getRecordTypeExperience('Experience');
        insert ex;

        Brand_Experience_Variation__c exVar = new Brand_Experience_Variation__c();
        exVar.Brand_Experience__c = ex.Id;
        exVar.Store__c = store.Id;
        exVar.Name = 'test';
        exVar.Status__c = 'Draft';
        exVar.StartDateTime__c = DateTime.Now().AddDays(46);
        exVar.EndDateTime__c = DateTime.Now().AddDays(47);
        exVar.RecordTypeId = Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Physical_Event').getRecordTypeId();
        
        insert exVar;

        List<String> dreamIds = new List<String>{'85739682','85740498','85743511','56119070','56268685'};
            
            
		User user = createUser();
        Account acc = createAccount(user.Id, dreamIds[0]);

        List<Brand_Experience__c> events = CL_controller.getAllPublishedEvents();
        List<Brand_Experience_Variation__c> variations = CL_controller.getAllEventVariationById(ex.Id);

        CL_controller.addClientsToAnEventFromBatch(ex.Id, null, dreamIds);
        CL_controller.addClientsToAnEventFromBatch(ex.Id, exVar.Id, dreamIds);
        CL_controller.addClientsToAnEventFromBatch(ex.Id, exVar.Id, dreamIds); // Duplicate
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