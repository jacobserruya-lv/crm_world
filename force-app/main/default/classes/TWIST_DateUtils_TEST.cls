@isTest
public with sharing class TWIST_DateUtils_TEST {
    
    @isTest
    public static void test_getDateFormatByLangCountry_langCountriesMatchEnglishDateFormat() {
        // Given
        String langCountry1 = 'eng-us';
        String langCountry2 = 'eng-kw';
        String langCountry3 = 'fra-ca';
        String expectedDateFormat = String.format('{0}{1}{2}{3}{4}', new List<String> {
            TWIST_DateUtils.yearPlaceholder,
            TWIST_DateUtils.dateSeparator,
            TWIST_DateUtils.monthPlaceholder,
            TWIST_DateUtils.dateSeparator,
            TWIST_DateUtils.dayPlaceholder
        });

        // When
        String dateFormat1 = TWIST_DateUtils.getDateFormatByLangCountry(langCountry1);
        String dateFormat2 = TWIST_DateUtils.getDateFormatByLangCountry(langCountry2);
        String dateFormat3 = TWIST_DateUtils.getDateFormatByLangCountry(langCountry3);
        
        // Then
        System.assertEquals(expectedDateFormat, dateFormat1);
        System.assertEquals(expectedDateFormat, dateFormat2);
        System.assertEquals(expectedDateFormat, dateFormat3);
    }

    @isTest
    public static void test_getDateFormatByLangCountry_langCountriesMatchFrenchDateFormat() {
        // Given
        String langCountry1 = 'fra-fr';
        String langCountry2 = 'ara-ae';
        String langCountry3 = 'zhs-cn';
        String expectedDateFormat = String.format('{0}{1}{2}{3}{4}', new List<String> {
            TWIST_DateUtils.dayPlaceholder,
            TWIST_DateUtils.dateSeparator,
            TWIST_DateUtils.monthPlaceholder,
            TWIST_DateUtils.dateSeparator,
            TWIST_DateUtils.yearPlaceholder
        });

        // When
        String dateFormat1 = TWIST_DateUtils.getDateFormatByLangCountry(langCountry1);
        String dateFormat2 = TWIST_DateUtils.getDateFormatByLangCountry(langCountry2);
        String dateFormat3 = TWIST_DateUtils.getDateFormatByLangCountry(langCountry3);
        
        // Then
        System.assertEquals(expectedDateFormat, dateFormat1);
        System.assertEquals(expectedDateFormat, dateFormat2);
        System.assertEquals(expectedDateFormat, dateFormat3);
    }

    @isTest
    public static void test_getDateFormatByLangCountry_langCountriesMatchNeitherEnglishNorFrenchDateFormat() {
        // Given
        String langCountry = 'zzz-zz';
        String expectedDateFormat = String.format('{0}{1}{2}{3}{4}', new List<String> {
            TWIST_DateUtils.monthPlaceholder,
            TWIST_DateUtils.dateSeparator,
            TWIST_DateUtils.dayPlaceholder,
            TWIST_DateUtils.dateSeparator,
            TWIST_DateUtils.yearPlaceholder
        });

        // When
        String dateFormat = TWIST_DateUtils.getDateFormatByLangCountry(langCountry);
        
        // Then
        System.assertEquals(expectedDateFormat, dateFormat);
    }

}