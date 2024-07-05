@isTest
private class ValidateCaCode_API_Test {
    @isTest static void testValidCaCode() {
        Store__c testStore = new Store__c(RetailStoreId__c = 'test');
        insert testStore;

        String caCode = 'validCaCode';

        RestRequest req = new RestRequest();
        req.addParameter('caCode', caCode);
        req.addParameter('storeId', testStore.Id);
        RestContext.request = req;

         Test.startTest();
         ValidateCaCode_API.validateCaCode();
         Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
         String responseBody = RestContext.response.responseBody.toString();
         Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
         Boolean caValidationWsResult = (Boolean)responseMap.get('caValidationWsResult');
         System.assertEquals(true, caValidationWsResult);
         String message = (String)responseMap.get('message');
         System.assertEquals('', message);
    }
    
    @isTest static void testNullCaCode() {
        Store__c testStore = new Store__c(RetailStoreId__c = 'test');
        insert testStore;

        String caCode = null;

        RestRequest req = new RestRequest();
        req.addParameter('caCode', caCode);
        req.addParameter('storeId', testStore.Id);
        RestContext.request = req;

         Test.startTest();
         ValidateCaCode_API.validateCaCode();
         Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
         String responseBody = RestContext.response.responseBody.toString();
         Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
         Boolean caValidationWsResult = (Boolean)responseMap.get('caValidationWsResult');
         System.assertEquals(false, caValidationWsResult);
         String message = (String)responseMap.get('message');
         System.assertEquals('CA code or store code is empty', message);
    }

    @isTest static void testNotValidCaCode() {
        Store__c testStore = new Store__c(RetailStoreId__c = 'test');
        insert testStore;

        String caCode = 'notValidCaCode';

        RestRequest req = new RestRequest();
        req.addParameter('caCode', caCode);
        req.addParameter('storeId', testStore.Id);
        RestContext.request = req;

         Test.startTest();
         ValidateCaCode_API.validateCaCode();
         Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
         String responseBody = RestContext.response.responseBody.toString();
         Map<String, Object> responseMap = (Map<String, Object>)JSON.deserializeUntyped(responseBody);
         Boolean caValidationWsResult = (Boolean)responseMap.get('caValidationWsResult');
         System.assertEquals(false, caValidationWsResult);
         String message = (String)responseMap.get('message');
         System.assertEquals('Error for the input CA code ' + caCode + ' and the store code ' + testStore.RetailStoreId__c, message);
    }
}