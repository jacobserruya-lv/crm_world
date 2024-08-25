@isTest
public with sharing class TWIST_FeatureFlagUtils_TEST {
    
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
        countryLanguage.ATG_Locale__c = 'eng-us';
        countryLanguage.Country__c = country.Id;
        countryLanguage.Language__c = lang.Id;
        countryLanguage.Mulesoft_Local__c = 'eco-us';
        insert countryLanguage;
    }

    @isTest
    public static void test_nominalCase() {
        // Given
        Map<String,Object> body = new Map<String,Object> {
            TWIST_FeatureFlagUtils.FEATURE_KEY_ALTERNATIVE_LOGIN => false,
            TWIST_FeatureFlagUtils.FEATURE_KEY_LINE_SOCIAL_LOGIN => true
        };
        Test.startTest();
        HttpResponseMock mock = new HttpResponseMock().setStatusCode(200).setBody(body);
        Test.stopTest();
        UnitTestsHelper.setSingleHttpMock(mock);

        // When
        TWIST_FeatureFlagUtils flags = new TWIST_FeatureFlagUtils('eng-us');
        Map<String,Boolean> flagsMap = flags.getFlagsMap();
        
        // Then
        System.assert(flagsMap.containsKey(TWIST_FeatureFlagUtils.FEATURE_KEY_ALTERNATIVE_LOGIN));
        System.assert(flagsMap.containsKey(TWIST_FeatureFlagUtils.FEATURE_KEY_LINE_SOCIAL_LOGIN));
        System.assertEquals(body.get(TWIST_FeatureFlagUtils.FEATURE_KEY_ALTERNATIVE_LOGIN), flags.isAlternativeLoginEnabled());
        System.assertEquals(body.get(TWIST_FeatureFlagUtils.FEATURE_KEY_LINE_SOCIAL_LOGIN), flags.isLineSocialLoginEnabled());
    }
    
    @isTest
    public static void test_whenExceptionThrown() {
        // Given
        HttpResponseMock mock = new HttpResponseMock().setStatusCode(500);
        Test.startTest();
        UnitTestsHelper.setSingleHttpMock(mock);
        Test.stopTest();
        
        // When
        TWIST_FeatureFlagUtils flags = new TWIST_FeatureFlagUtils('eng-us');
        Map<String,Boolean> flagsMap = flags.getFlagsMap();

        // Then
        System.assert(!flagsMap.isEmpty());
        System.assert(flagsMap.containsKey(TWIST_FeatureFlagUtils.FEATURE_KEY_ALTERNATIVE_LOGIN));
        System.assert(flagsMap.containsKey(TWIST_FeatureFlagUtils.FEATURE_KEY_LINE_SOCIAL_LOGIN));
        System.assert(flagsMap.containsKey(TWIST_FeatureFlagUtils.FEATURE_KEY_DUMMY_SOCIAL_MEDIA));
    }

}