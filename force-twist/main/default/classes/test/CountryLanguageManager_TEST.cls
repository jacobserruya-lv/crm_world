@isTest
public with sharing class CountryLanguageManager_TEST {
    
    @isTest
    public static void test_getMulesoftApisPrefix_nominalCase() {
        // Given
        String langCountry = 'eng-us';
        String prefix = 'eco-us';

        Test.startTest();
        Country__c country = new Country__c();
        country.tech_duplicate__c = 'United_States';
        insert country;

        Language2__c language = new Language2__c();
        language.Iso2Code__c = 'US';
        language.Iso3Code__c = 'ENG';
        insert language;

        insert new CountryLanguage__c(
            Country__c = country.Id,
            Language__c = language.Id,
            ATG_Locale__c = langCountry,
            Mulesoft_Local__c = prefix
        );
        
        // When
        String actualPrefix = CountryLanguageManager.getMulesoftApisPrefix(langCountry);
        Test.stopTest();
        
        // Then
        System.assertEquals(prefix, actualPrefix);
    }
    
    @isTest
    public static void test_getMulesoftApisPrefix_shouldThrowException1() {
        // Given
        String langCountry = 'zzz-zz';
        String expectedExceptionMessage = String.format('LangCountry "{0}" is unknown', new List<String> { langCountry });
        
        try {
            // When
            Test.startTest();
            String actualPrefix = CountryLanguageManager.getMulesoftApisPrefix(langCountry);
            Test.stopTest();
        }
        catch (Exception e) {
            // Then
            System.assertEquals(expectedExceptionMessage, e.getMessage());
        }
    }

}