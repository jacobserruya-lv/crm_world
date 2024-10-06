@isTest
private class IDENTITY_GoogleAnalytics_Utils_TEST {
    
    @IsTest
    static void test_getConfig() {
        // Given
        String trueOrigin = 'lvapp';
        String dummyOrigin = 'fafa';
        String environmentType = 'app';
        String environmentId = 'LVPassAPP';

        // When
        Test.startTest();
        Map<String,String> trueConfig = IDENTITY_GoogleAnalytics_Utils.getConfig(trueOrigin);
        Map<String,String> dummyConfig = IDENTITY_GoogleAnalytics_Utils.getConfig(dummyOrigin);
		Test.stopTest();

        // Then
        System.assertEquals(environmentType, trueConfig.get('environmentType'), 'error');
        System.assertEquals(environmentId, trueConfig.get('environmentId'), 'error');

        System.assertEquals(null, dummyConfig.get('environmentType'), 'error');
        System.assertEquals(null, dummyConfig.get('environmentId'), 'error');
    }

    @IsTest
    static void test_sendEvent() {
        IDENTITY_GoogleAnalytics_Utils.sendEvent(
            'trackingId',
            'clientId',
            'origin',
            'environmentType',
            'environmentId',
            'environmentVersion',
            'environmentLanguage',
            'eventCategory',
            'eventAction',
            'eventLabel',
            'currentUrl',
            'connexionStatus',
            'pageName',
            'pageType');
    }

    @isTest
    static void test_MetaDataTypeForMyLvOrigin() {
        // Given
        String origin = 'MyLV';
        String expectedEnvironmentType = 'site';
        String expectedEnvironmentId = 'louisvuitton.com';

        // When
        IDENTITY_GA_Config__mdt config = [SELECT Environment_Type__c, Environment_Id__c FROM IDENTITY_GA_Config__mdt WHERE Origin__c = :origin];
        String environmentType = config.Environment_Type__c;
        String environmentId = config.Environment_Id__c;

        // Then
        System.assertEquals(expectedEnvironmentType, environmentType, 'ERROR');
        System.assertEquals(expectedEnvironmentId, environmentId, 'ERROR');
    }

    @isTest
    static void test_MetaDataTypeForLvAppOrigin() {
        // Given
        String origin = 'lvapp';
        String expectedEnvironmentType = 'app';
        String expectedEnvironmentId = 'LVPassAPP';

        // When
        IDENTITY_GA_Config__mdt config = [SELECT Environment_Type__c, Environment_Id__c FROM IDENTITY_GA_Config__mdt WHERE Origin__c = :origin];
        String environmentType = config.Environment_Type__c;
        String environmentId = config.Environment_Id__c;

        // Then
        System.assertEquals(expectedEnvironmentType, environmentType, 'ERROR');
        System.assertEquals(expectedEnvironmentId, environmentId, 'ERROR');
    }

    @isTest
    static void test_MetaDataTypeForLvConnectOrigin() {
        // Given
        String origin = 'lvconnect';
        List<String> expectedEnvironmentTypes = new List<String>();
        expectedEnvironmentTypes.add('ppi'); // for Staging instance
        expectedEnvironmentTypes.add('prd'); // for Prod instance
        String expectedEnvironmentId = 'Connect';

        // When
        IDENTITY_GA_Config__mdt config = [SELECT Environment_Type__c, Environment_Id__c FROM IDENTITY_GA_Config__mdt WHERE Origin__c = :origin];
        String environmentType = (String)config.Environment_Type__c;
        String environmentId = config.Environment_Id__c;

        // Then
        System.assertEquals(true, expectedEnvironmentTypes.contains(environmentType), 'ERROR');
        System.assertEquals(expectedEnvironmentId, environmentId, 'ERROR');
    }

}
