@isTest
public with sharing class TWIST_CollectibleWallet_API_TEST {

    private static final List<String> listWalledId = new List<String> { 'id-cw-001', 'id-cw-002', 'id-cw-003' };

    @testSetup
    static void makeData() {
        Identity_TestFactory.createSettings();
        Identity_TestFactory.createUser('TEST','TEST','collectible@wallet.test','0500000000','972');

        User user = getIdentityUser();
        insert new Collectible_Wallet__c(Client__c = user.accountId, Wallet_Id__c = listWalledId.get(0));
        insert new Collectible_Wallet__c(Client__c = user.accountId, Wallet_Id__c = listWalledId.get(1));
        insert new Collectible_Wallet__c(Client__c = user.accountId, Wallet_Id__c = listWalledId.get(2));
    }

    @isTest
    public static void test_updateCollectibleWallet_insertSingleItemScenario() {
        // Given
        User user = getIdentityUser();
        List<Object> wallets = new List<Object> {
            new Map<String,Object> { 'old' => null, 'new' => 'id-cw-004' }
        };
        buildRestContextObject(user.accountId, wallets);
        
        // When
        Test.startTest();
        TWIST_CollectibleWallet_API.updateCollectibleWallet();
        Test.stopTest();
        
        // Then
        assertResponseIsSuccessful(RestContext.response);

        List<Collectible_Wallet__c> foundWallets = findCollectibleWalletsByAccountId(user.accountId);
        System.assertEquals(listWalledId.size() + wallets.size(), foundWallets.size());
    }

    @isTest
    public static void test_updateCollectibleWallet_insertMultipleItemsScenario() {
        // Given
        User user = getIdentityUser();
        List<Object> wallets = new List<Object> {
            new Map<String,Object> { 'old' => null, 'new' => 'id-cw-004' },
            new Map<String,Object> { 'old' => null, 'new' => 'id-cw-005' },
            new Map<String,Object> { 'old' => null, 'new' => 'id-cw-006' }
        };
        buildRestContextObject(user.accountId, wallets);
        
        // When
        Test.startTest();
        TWIST_CollectibleWallet_API.updateCollectibleWallet();
        Test.stopTest();
        
        // Then
        assertResponseIsSuccessful(RestContext.response);

        List<Collectible_Wallet__c> foundWallets = findCollectibleWalletsByAccountId(user.accountId);
        System.assertEquals(listWalledId.size() + wallets.size(), foundWallets.size());
    }
    

    @isTest
    public static void test_updateCollectibleWallet_updateSingleItemScenario() {
        // Given
        User user = getIdentityUser();
        String oldWalledId = listWalledId.get(0);
        String newWalledId = 'id-cw-004';
        List<Object> wallets = new List<Object> {
            new Map<String,Object> { 'old' => oldWalledId, 'new' => newWalledId }
        };
        buildRestContextObject(user.accountId, wallets);
        
        // When
        Test.startTest();
        TWIST_CollectibleWallet_API.updateCollectibleWallet();
        Test.stopTest();
        
        // Then
        assertResponseIsSuccessful(RestContext.response);

        List<String> listWalledIdThatShouldNowExist = listWalledId.clone();
        listWalledIdThatShouldNowExist.remove(listWalledIdThatShouldNowExist.indexOf(oldWalledId));
        listWalledIdThatShouldNowExist.add(newWalledId);

        List<Collectible_Wallet__c> foundWallets = findCollectibleWalletsByAccountId(user.accountId);
        System.assertEquals(listWalledIdThatShouldNowExist.size(), foundWallets.size());
        for (Collectible_Wallet__c wallet : foundWallets) {
            System.assert(listWalledIdThatShouldNowExist.contains((String) wallet.Wallet_Id__c));
        }
    }

    @isTest
    public static void test_updateCollectibleWallet_deleteSingleItemScenario() {
        // Given
        User user = getIdentityUser();
        List<Object> wallets = new List<Object> {
            new Map<String,Object> { 'old' => listWalledId.get(0), 'new' => null }
        };
        buildRestContextObject(user.accountId, wallets);
        
        // When
        Test.startTest();
        TWIST_CollectibleWallet_API.updateCollectibleWallet();
        Test.stopTest();
        
        // Then
        assertResponseIsSuccessful(RestContext.response);

        List<Collectible_Wallet__c> foundWallets = findCollectibleWalletsByAccountId(user.accountId);
        System.assertEquals(listWalledId.size() - wallets.size(), foundWallets.size());
    }

    @isTest
    public static void test_updateCollectibleWallet_deleteMultipleItemsScenario() {
        // Given
        User user = getIdentityUser();
        List<Object> wallets = new List<Object> {
            new Map<String,Object> { 'old' => listWalledId.get(0), 'new' => null },
            new Map<String,Object> { 'old' => listWalledId.get(1), 'new' => null },
            new Map<String,Object> { 'old' => listWalledId.get(2), 'new' => null }
        };
        buildRestContextObject(user.accountId, wallets);
        
        // When
        Test.startTest();
        TWIST_CollectibleWallet_API.updateCollectibleWallet();
        Test.stopTest();
        
        // Then
        assertResponseIsSuccessful(RestContext.response);

        List<Collectible_Wallet__c> foundWallets = findCollectibleWalletsByAccountId(user.accountId);
        System.assertEquals(listWalledId.size() - wallets.size(), foundWallets.size());
    }

    @isTest
    public static void test_updateCollectibleWallet_wrongParametersScenario1() {
        // Given
        buildRestContextObject('dummy-account-id', new List<Object>());
        RestContext.request.requestBody = null;

        // When
        Test.startTest();
        TWIST_CollectibleWallet_API.updateCollectibleWallet();
        Test.stopTest();

        // Then
        assertResponseIsFailing(RestContext.response);
    }

    @isTest
    public static void test_updateCollectibleWallet_wrongParametersScenario2() {
        // Given
        buildRestContextObject('dummy-account-id', new List<Object>());
        Map<String,Object> wrongBody = new Map<String,Object>();
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(wrongBody));

        // When
        Test.startTest();
        TWIST_CollectibleWallet_API.updateCollectibleWallet();
        Test.stopTest();

        // Then
        assertResponseIsFailing(RestContext.response);
    }

    @isTest
    public static void test_updateCollectibleWallet_wrongParametersScenario3() {
        // Given
        buildRestContextObject('dummy-account-id', new List<Object>());
        Map<String,Object> wrongBody = new Map<String,Object> { TWIST_CollectibleWallet_API.ACCOUNT_ID_KEY => 'dummy-account-id' };
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(wrongBody));

        // When
        Test.startTest();
        TWIST_CollectibleWallet_API.updateCollectibleWallet();
        Test.stopTest();

        // Then
        assertResponseIsFailing(RestContext.response);
    }

    @isTest
    public static void test_updateCollectibleWallet_wrongParametersScenario4() {
        // Given
        buildRestContextObject('dummy-account-id', new List<Object>());
        Map<String,Object> wrongBody = new Map<String,Object> { TWIST_CollectibleWallet_API.WALLETS_KEY => new List<Object>() };
        RestContext.request.requestBody = Blob.valueOf(JSON.serialize(wrongBody));

        // When
        Test.startTest();
        TWIST_CollectibleWallet_API.updateCollectibleWallet();
        Test.stopTest();

        // Then
        assertResponseIsFailing(RestContext.response);
    }

    /***************************************************************************************************************************** */

    private static User getIdentityUser() {
        return [SELECT Id, Email, AccountId FROM User WHERE Is_Identity_User__c = true AND AccountId != null LIMIT 1];
    }

    private static List<Collectible_Wallet__c> findCollectibleWalletsByAccountId(String accountId) {
        return [SELECT Name, Client__c, Wallet_Id__c FROM Collectible_Wallet__c WHERE Client__c = :accountId];
    }

    private static void buildRestContextObject(String accountId, List<Object> wallets) {
        RestRequest req = new RestRequest();
        req.httpMethod = 'PATCH';
        req.requestURI = '/services/apexrest/collectibleWallet/';
        req.addHeader('Content-Type','application/json');
        req.requestBody = buildRequestBody(accountId, wallets);
        RestContext.request = req;

        RestContext.response = new RestResponse();
    }

    private static Blob buildRequestBody(String accountId, List<Object> wallets) {
        Map<String,Object> requestBody = new Map<String,Object> {
            TWIST_CollectibleWallet_API.ACCOUNT_ID_KEY => accountId,
            TWIST_CollectibleWallet_API.WALLETS_KEY => wallets
        };
        return Blob.valueOf(JSON.serialize(requestBody));
    }

    private static void assertResponseIsSuccessful(RestResponse response) {
        System.assertEquals(200, response.statusCode);
        Map<String,Object> responseBody = blobToMap(response.responseBody);
        System.assert(responseBody.containsKey('success'));
        System.assert(responseBody.containsKey('message'));
        System.assert((Boolean) responseBody.get('success'));
        System.assertEquals('OK', (String) responseBody.get('message'));
    }

    private static void assertResponseIsFailing(RestResponse response) {
        System.assertNotEquals(200, response.statusCode);
        Map<String,Object> responseBody = blobToMap(response.responseBody);
        System.assert(responseBody.containsKey('success'));
        System.assert(responseBody.containsKey('message'));
        System.assert(!(Boolean) responseBody.get('success'));
    }

    private static Map<String,Object> blobToMap(Blob b) {
        return (Map<String,Object>) JSON.deserializeUntyped(b.toString());
    }
}