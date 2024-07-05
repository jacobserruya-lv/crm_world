@isTest
public class ICX_Flow_AccountController_TEST {

    @isTest
    public static void getUserTest() {
        // init create user
        Id profileId = ICX_TestFactory.PROFILE_ICONICS_SA;
        User userTest = ICX_TestFactory.createUser(profileId);
        userTest.DefaultStore__c = 'A06';
        insert userTest;

        // Test
        Test.startTest();
        User result;
        System.runAs(userTest) {
            result = ICX_Flow_AccountController.getUser();
        }
        Test.stopTest();

        // Check
        System.assert(result != null);
        System.assertEquals('A06', result.DefaultStore__c);
    }

    @isTest
    public static void getStoreJsonTest() {
        // Test
        Test.startTest();
        String storeListJson = ICX_Flow_AccountController.getStoreJson();
        Test.stopTest();
        
        // Check
        System.assert(String.isNotBlank(storeListJson));
        List<PicklistEntry> storeList = (List<PicklistEntry>) JSON.deserialize(storeListJson, List<PicklistEntry>.class);

        System.assert(storeList != null);
        System.assert(!storeList.isEmpty());
    }

    @isTest
    public static void getUserProfileTest() {
        // init
        Id profileId = ICX_TestFactory.PROFILE_ICONICS_SA;
        User userTest = ICX_TestFactory.createUser(profileId);
        insert userTest;

        // Test
        Test.startTest();
        User result;
        System.runAs(userTest) {
            result = ICX_Flow_AccountController.getUserProfile();
        }
        Test.stopTest();

        // Check
        System.assert(result != null);
        System.assertEquals(userTest.Id, result.Id);
        System.assertEquals(ICX_TestFactory.PROFILE_ICONICS_SA_NAME, result.Profile.Name);
    }

    @isTest
    public static void getStoreTest() {

        // Init
        String storeCode = 'AXX';
        Store__c store = ICX_TestFactory.createStore( 'My Store Test', storeCode);
        Store__c store2 = ICX_TestFactory.createStore('My Store Test 2', 'AZZ');
        insert new List<Store__c> { store, store2};

        // Test
        Test.startTest();
        Store__c result = ICX_Flow_AccountController.getStore(storeCode);
        Test.stopTest();

        // Check
		System.assert(result != null);
        System.assertEquals(store.Name, result.Name);
        System.assertEquals(store.Id, result.Id);
    }

	/*@isTest
    public static void getAccountTest() {
        // TODO Webservice Mock
        // Test only for test coverage as SO_WS_POSFacade.clientSearch is already tested
       ///Account acc = ICX_Flow_AccountController.getAccountFromRMS('storeCode', 'rmsId', 'wwRmsClientCode');
    }*/

    @isTest
    public static void getAccountIdTest() {
        // Init
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        Task tsk = ICX_TestFactory.creatCallTaskOnAccount(acc.Id);
        insert tsk;

        Test.startTest();
        Id accId = ICX_Flow_AccountController.getAccountId(tsk.Id);
        Test.stopTest();

        System.assertEquals(acc.Id, accId);
    }

    @isTest
    public static void insertAccountTest() {
        Account acc = ICX_TestFactory.createAccount();
        acc.DREAMID__c = 'XXXXXX';

        Test.startTest();
        Account result = ICX_Flow_AccountController.insertAccount(acc);
        Test.stopTest();

		System.assert(result != null);
        System.assert(String.isBlank(result.DREAMId__c));
    }
}