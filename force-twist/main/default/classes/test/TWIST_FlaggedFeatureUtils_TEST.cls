@isTest
 public with sharing class TWIST_FlaggedFeatureUtils_TEST {

    private static final String langCountryDedicatedToTests = 'eng-us';

    @TestSetup
    public static void setup() {
        TWIST_Settings__c settings = new TWIST_Settings__c();
        settings.Name = 'test';
        settings.Password_Maxlength__c = 20;
        settings.Env_In_Reset_Password_Url__c = 'i1f';
        settings.SFCC_Feature_Flag_Endpoint__c = '/endpoint/';
        insert settings;

        Store__c store = new Store__c();
        store.RetailStoreId__c = 'A06';
        insert store;

        Language2__c lang = new Language2__c();
        lang.Iso2Code__c = 'US';
        lang.Iso3Code__c = 'ENG';
        insert lang;

        Country__c country = new Country__c();
        country.tech_duplicate__c = 'United_States';
        insert country;

        CountryLanguage__c countryLanguage = new CountryLanguage__c();
        countryLanguage.defaultStore__c = store.Id;
        countryLanguage.ATG_Locale__c = langCountryDedicatedToTests;
        countryLanguage.Country__c = country.Id;
        countryLanguage.Language__c = lang.Id;
        countryLanguage.Mulesoft_Local__c = 'eco-us';
        insert countryLanguage;
    }
    
    @isTest
    public static void test_querySingleFlag_doQuerySFB2C_APISucceeds() {
        // Given
        String featureKey = TWIST_FlaggedFeatureUtils.FEATURE_KEY_TEST_DO_QUERY_SFB2C_FALLBACK_FALSE;
        Test.startTest();
        HttpResponseMock mock = new HttpResponseMock().setStatusCode(200).setBody(new Map<String,Object> { featureKey => true });
        UnitTestsHelper.setSingleHttpMock(mock);
        Test.stopTest();
        
        // When
        TWIST_FlaggedFeatureUtils flag = new TWIST_FlaggedFeatureUtils(featureKey, langCountryDedicatedToTests);
        List<String> featureKeysToQueryFromSFB2C = flag.getFeatureKeysToQueryFromSFB2C();
        List<String> featureKeysToQueryFromSF = flag.getFeatureKeysToQueryFromSF();

        // Then
        System.assert(featureKeysToQueryFromSFB2C.contains(featureKey));
        System.assert(!featureKeysToQueryFromSF.contains(featureKey));
        System.assert(flag.isEnabled());
    }

    @isTest
    public static void test_querySingleFlag_doQuerySFB2C_APIFails() {
        // Given
        String featureKey = TWIST_FlaggedFeatureUtils.FEATURE_KEY_TEST_DO_QUERY_SFB2C_FALLBACK_FALSE;
        Test.startTest();
        HttpResponseMock mock = new HttpResponseMock().setStatusCode(500);
        UnitTestsHelper.setSingleHttpMock(mock);
        Test.stopTest();
        
        // When
        TWIST_FlaggedFeatureUtils flag = new TWIST_FlaggedFeatureUtils(featureKey, langCountryDedicatedToTests);
        List<String> featureKeysToQueryFromSFB2C = flag.getFeatureKeysToQueryFromSFB2C();
        List<String> featureKeysToQueryFromSF = flag.getFeatureKeysToQueryFromSF();

        // Then
        System.assert(featureKeysToQueryFromSFB2C.contains(featureKey));
        System.assert(featureKeysToQueryFromSF.contains(featureKey));
        System.assert(!flag.isEnabled());
    }

    @isTest
    public static void test_querySingleFlag_doNotQuerySFB2C() {
        // Given
        String featureKey1 = TWIST_FlaggedFeatureUtils.FEATURE_KEY_TEST_DO_NOT_QUERY_SFB2C_FALLBACK_TRUE;
        String featureKey2 = TWIST_FlaggedFeatureUtils.FEATURE_KEY_TEST_DO_NOT_QUERY_SFB2C_FALLBACK_FALSE;
        
        // When
        TWIST_FlaggedFeatureUtils flag1 = new TWIST_FlaggedFeatureUtils(featureKey1, langCountryDedicatedToTests);
        List<String> featureKeysToQueryFromSFB2C1 = flag1.getFeatureKeysToQueryFromSFB2C();
        List<String> featureKeysToQueryFromSF1 = flag1.getFeatureKeysToQueryFromSF();

        TWIST_FlaggedFeatureUtils flag2 = new TWIST_FlaggedFeatureUtils(featureKey2, langCountryDedicatedToTests);
        List<String> featureKeysToQueryFromSFB2C2 = flag2.getFeatureKeysToQueryFromSFB2C();
        List<String> featureKeysToQueryFromSF2 = flag2.getFeatureKeysToQueryFromSF();

        // Then
        System.assert(!featureKeysToQueryFromSFB2C1.contains(featureKey1));
        System.assert(featureKeysToQueryFromSF1.contains(featureKey1));
        System.assert(flag1.isEnabled());

        System.assert(!featureKeysToQueryFromSFB2C1.contains(featureKey2));
        System.assert(featureKeysToQueryFromSF2.contains(featureKey2));
        System.assert(!flag2.isEnabled());
    }
    
    @isTest
    public static void test_queryMultipleFlags_doQuerySFB2C_APISucceeds() {
        // Given
        String featureKey1 = TWIST_FlaggedFeatureUtils.FEATURE_KEY_TEST_DO_QUERY_SFB2C_FALLBACK_TRUE;
        String featureKey2 = TWIST_FlaggedFeatureUtils.FEATURE_KEY_TEST_DO_QUERY_SFB2C_FALLBACK_FALSE;
        Boolean expectedFlagValue1 = false;
        Boolean expectedFlagValue2 = true;
        Map<String,Object> body = new Map<String,Object> {
            featureKey1 => expectedFlagValue1,
            featureKey2 => expectedFlagValue2
        };
        Test.startTest();
        HttpResponseMock mock = new HttpResponseMock().setStatusCode(200).setBody(body);
        UnitTestsHelper.setSingleHttpMock(mock);
        Test.stopTest();
        
        // When
        TWIST_FlaggedFeatureUtils flag = new TWIST_FlaggedFeatureUtils(new List<String> { featureKey1, featureKey2 }, langCountryDedicatedToTests);
        List<String> featureKeysToQueryFromSFB2C = flag.getFeatureKeysToQueryFromSFB2C();
        List<String> featureKeysToQueryFromSF = flag.getFeatureKeysToQueryFromSF();

        // Then
        System.assert(featureKeysToQueryFromSFB2C.contains(featureKey1));
        System.assert(featureKeysToQueryFromSFB2C.contains(featureKey2));
        System.assert(!featureKeysToQueryFromSF.contains(featureKey1));
        System.assert(!featureKeysToQueryFromSF.contains(featureKey2));
        System.assertEquals(expectedFlagValue1, flag.isFeatureKeyTestDoQuerySFB2CFallbackTrueEnabled());
        System.assertEquals(expectedFlagValue2, flag.isFeatureKeyTestDoQuerySFB2CFallbackFalseEnabled());
    }

    @isTest
    public static void test_queryMultipleFlags_doQuerySFB2C_APIFails() {
        // Given
        String featureKey1 = TWIST_FlaggedFeatureUtils.FEATURE_KEY_TEST_DO_QUERY_SFB2C_FALLBACK_TRUE;
        String featureKey2 = TWIST_FlaggedFeatureUtils.FEATURE_KEY_TEST_DO_QUERY_SFB2C_FALLBACK_FALSE;
        Boolean expectedFlagValue1 = true;
        Boolean expectedFlagValue2 = false;
        Test.startTest();
        HttpResponseMock mock = new HttpResponseMock().setStatusCode(500);
        UnitTestsHelper.setSingleHttpMock(mock);
        Test.stopTest();
        
        // When
        TWIST_FlaggedFeatureUtils flag = new TWIST_FlaggedFeatureUtils(new List<String> { featureKey1, featureKey2 }, langCountryDedicatedToTests);
        List<String> featureKeysToQueryFromSFB2C = flag.getFeatureKeysToQueryFromSFB2C();
        List<String> featureKeysToQueryFromSF = flag.getFeatureKeysToQueryFromSF();

        // Then
        System.assert(featureKeysToQueryFromSFB2C.contains(featureKey1));
        System.assert(featureKeysToQueryFromSFB2C.contains(featureKey2));
        System.assert(featureKeysToQueryFromSF.contains(featureKey1));
        System.assert(featureKeysToQueryFromSF.contains(featureKey2));
        System.assertEquals(expectedFlagValue1, flag.isFeatureKeyTestDoQuerySFB2CFallbackTrueEnabled());
        System.assertEquals(expectedFlagValue2, flag.isFeatureKeyTestDoQuerySFB2CFallbackFalseEnabled());
    }

    @isTest
    public static void test_queryMultipleFlags_doNotQuerySFB2C() {
        // Given
        String featureKey1 = TWIST_FlaggedFeatureUtils.FEATURE_KEY_TEST_DO_NOT_QUERY_SFB2C_FALLBACK_TRUE;
        String featureKey2 = TWIST_FlaggedFeatureUtils.FEATURE_KEY_TEST_DO_NOT_QUERY_SFB2C_FALLBACK_FALSE;
        
        // When
        TWIST_FlaggedFeatureUtils flag = new TWIST_FlaggedFeatureUtils(new List<String> { featureKey1, featureKey2 }, langCountryDedicatedToTests);
        List<String> featureKeysToQueryFromSFB2C = flag.getFeatureKeysToQueryFromSFB2C();
        List<String> featureKeysToQueryFromSF = flag.getFeatureKeysToQueryFromSF();

        // Then
        System.assert(!featureKeysToQueryFromSFB2C.contains(featureKey1));
        System.assert(!featureKeysToQueryFromSFB2C.contains(featureKey2));
        System.assert(featureKeysToQueryFromSF.contains(featureKey1));
        System.assert(featureKeysToQueryFromSF.contains(featureKey2));
        System.assert(flag.isFeatureKeyTestDoNotQuerySFB2CFallbackTrueEnabled());
        System.assert(!flag.isFeatureKeyTestDoNotQuerySFB2CFallbackFalseEnabled());
    }

    @isTest
    public static void test_queryMultipleFlags_bothDoQueryAndDoNotQuerySFB2C_APISucceeds() {
        // Given
        String featureKey1 = TWIST_FlaggedFeatureUtils.FEATURE_KEY_TEST_DO_QUERY_SFB2C_FALLBACK_TRUE;
        String featureKey2 = TWIST_FlaggedFeatureUtils.FEATURE_KEY_TEST_DO_QUERY_SFB2C_FALLBACK_FALSE;
        String featureKey3 = TWIST_FlaggedFeatureUtils.FEATURE_KEY_TEST_DO_NOT_QUERY_SFB2C_FALLBACK_TRUE;
        String featureKey4 = TWIST_FlaggedFeatureUtils.FEATURE_KEY_TEST_DO_NOT_QUERY_SFB2C_FALLBACK_FALSE;
        Boolean expectedFlagValue1 = false;
        Boolean expectedFlagValue2 = true;
        Boolean expectedFlagValue3 = true;
        Boolean expectedFlagValue4 = false;
        Map<String,Object> body = new Map<String,Object> {
            featureKey1 => expectedFlagValue1,
            featureKey2 => expectedFlagValue2
        };
        Test.startTest();
        HttpResponseMock mock = new HttpResponseMock().setStatusCode(200).setBody(body);
        UnitTestsHelper.setSingleHttpMock(mock);
        Test.stopTest();
        
        // When
        TWIST_FlaggedFeatureUtils flag = new TWIST_FlaggedFeatureUtils(new List<String> { featureKey1, featureKey2, featureKey3, featureKey4 }, langCountryDedicatedToTests);
        List<String> featureKeysToQueryFromSFB2C = flag.getFeatureKeysToQueryFromSFB2C();
        List<String> featureKeysToQueryFromSF = flag.getFeatureKeysToQueryFromSF();

        // Then
        System.assert(featureKeysToQueryFromSFB2C.contains(featureKey1));
        System.assert(featureKeysToQueryFromSFB2C.contains(featureKey2));
        System.assert(!featureKeysToQueryFromSFB2C.contains(featureKey3));
        System.assert(!featureKeysToQueryFromSFB2C.contains(featureKey4));
        System.assert(!featureKeysToQueryFromSF.contains(featureKey1));
        System.assert(!featureKeysToQueryFromSF.contains(featureKey2));
        System.assert(featureKeysToQueryFromSF.contains(featureKey3));
        System.assert(featureKeysToQueryFromSF.contains(featureKey4));
        System.assertEquals(expectedFlagValue1, flag.isFeatureKeyTestDoQuerySFB2CFallbackTrueEnabled());
        System.assertEquals(expectedFlagValue2, flag.isFeatureKeyTestDoQuerySFB2CFallbackFalseEnabled());
        System.assertEquals(expectedFlagValue3, flag.isFeatureKeyTestDoNotQuerySFB2CFallbackTrueEnabled());
        System.assertEquals(expectedFlagValue4, flag.isFeatureKeyTestDoNotQuerySFB2CFallbackFalseEnabled());
    }

    @isTest
    public static void test_queryMultipleFlags_bothDoQueryAndDoNotQuerySFB2C_APIFails() {
        // Given
        String featureKey1 = TWIST_FlaggedFeatureUtils.FEATURE_KEY_TEST_DO_QUERY_SFB2C_FALLBACK_TRUE;
        String featureKey2 = TWIST_FlaggedFeatureUtils.FEATURE_KEY_TEST_DO_QUERY_SFB2C_FALLBACK_FALSE;
        String featureKey3 = TWIST_FlaggedFeatureUtils.FEATURE_KEY_TEST_DO_NOT_QUERY_SFB2C_FALLBACK_TRUE;
        String featureKey4 = TWIST_FlaggedFeatureUtils.FEATURE_KEY_TEST_DO_NOT_QUERY_SFB2C_FALLBACK_FALSE;
        Boolean expectedFlagValue1 = true;
        Boolean expectedFlagValue2 = false;
        Boolean expectedFlagValue3 = true;
        Boolean expectedFlagValue4 = false;
        Test.startTest();
        HttpResponseMock mock = new HttpResponseMock().setStatusCode(500);
        UnitTestsHelper.setSingleHttpMock(mock);
        Test.stopTest();
        
        // When
        TWIST_FlaggedFeatureUtils flag = new TWIST_FlaggedFeatureUtils(new List<String> { featureKey1, featureKey2, featureKey3, featureKey4 }, langCountryDedicatedToTests);
        List<String> featureKeysToQueryFromSFB2C = flag.getFeatureKeysToQueryFromSFB2C();
        List<String> featureKeysToQueryFromSF = flag.getFeatureKeysToQueryFromSF();

        // Then
        System.assert(featureKeysToQueryFromSFB2C.contains(featureKey1));
        System.assert(featureKeysToQueryFromSFB2C.contains(featureKey2));
        System.assert(!featureKeysToQueryFromSFB2C.contains(featureKey3));
        System.assert(!featureKeysToQueryFromSFB2C.contains(featureKey4));
        System.assert(featureKeysToQueryFromSF.contains(featureKey1));
        System.assert(featureKeysToQueryFromSF.contains(featureKey2));
        System.assert(featureKeysToQueryFromSF.contains(featureKey3));
        System.assert(featureKeysToQueryFromSF.contains(featureKey4));
        System.assertEquals(expectedFlagValue1, flag.isFeatureKeyTestDoQuerySFB2CFallbackTrueEnabled());
        System.assertEquals(expectedFlagValue2, flag.isFeatureKeyTestDoQuerySFB2CFallbackFalseEnabled());
        System.assertEquals(expectedFlagValue3, flag.isFeatureKeyTestDoNotQuerySFB2CFallbackTrueEnabled());
        System.assertEquals(expectedFlagValue4, flag.isFeatureKeyTestDoNotQuerySFB2CFallbackFalseEnabled());
    }
    
    @isTest
    public static void test_querySingleFlag_NoMatchingRecordsInCustomMetadata() {
        // Given
        String featureKey1 = TWIST_FlaggedFeatureUtils.FEATURE_KEY_TEST_DO_QUERY_SFB2C_FALLBACK_TRUE;
        String langCountry1 = 'dummy-lang-country';
        String featureKey2 = 'dummy-feature-key';
        String langCountry2 = langCountryDedicatedToTests;
        
        // When
        TWIST_FlaggedFeatureUtils flag1 = new TWIST_FlaggedFeatureUtils(featureKey1, langCountry1);
        List<String> featureKeysToQueryFromSFB2C1 = flag1.getFeatureKeysToQueryFromSFB2C();
        List<String> featureKeysToQueryFromSF1 = flag1.getFeatureKeysToQueryFromSF();

        TWIST_FlaggedFeatureUtils flag2 = new TWIST_FlaggedFeatureUtils(featureKey2, langCountry2);
        List<String> featureKeysToQueryFromSFB2C2 = flag2.getFeatureKeysToQueryFromSFB2C();
        List<String> featureKeysToQueryFromSF2 = flag2.getFeatureKeysToQueryFromSF();

        // Then
        System.assert(!flag1.isEnabled());
        System.assert(!flag2.isEnabled());
    }

}