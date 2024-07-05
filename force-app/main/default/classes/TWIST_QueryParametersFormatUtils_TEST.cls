@isTest
public with sharing class TWIST_QueryParametersFormatUtils_TEST {

    @isTest
    public static void test_isDispatchCountryFormatValid_whenDispatchCountryIsEmpty() {
        // When
        Boolean result1 = TWIST_QueryParametersFormatUtils.isDispatchCountryFormatValid(null);
        Boolean result2 = TWIST_QueryParametersFormatUtils.isDispatchCountryFormatValid('');

        // Then
        System.assertEquals(false, result1);
        System.assertEquals(false, result2);
    }
    
    @isTest
    public static void test_isDispatchCountryFormatValid_whenDispatchCountryHasWrongFormat() {
        // When
        Boolean result1 = TWIST_QueryParametersFormatUtils.isDispatchCountryFormatValid('ae');
        Boolean result2 = TWIST_QueryParametersFormatUtils.isDispatchCountryFormatValid('AEZ');
        Boolean result3 = TWIST_QueryParametersFormatUtils.isDispatchCountryFormatValid('123456');

        // Then
        System.assertEquals(false, result1);
        System.assertEquals(false, result2);
        System.assertEquals(false, result2);
    }

    @isTest
    public static void test_isDispatchCountryFormatValid_whenDispatchCountryHasRightFormat() {
        // Given
        Boolean result = TWIST_QueryParametersFormatUtils.isDispatchCountryFormatValid('AE');

        // Then
        System.assert(result);
    }

    @isTest
    public static void test_isLangCountryFormatValid_whenLangCountryIsEmpty() {
        Boolean result1 = TWIST_QueryParametersFormatUtils.isLangCountryFormatValid(null);
        Boolean result2 = TWIST_QueryParametersFormatUtils.isLangCountryFormatValid('');

        // Then
        System.assertEquals(false, result1);
        System.assertEquals(false, result2);
    }

    @isTest
    public static void test_isDispatchCountryFormatValid_whenLangCountryHasWrongFormat() {
        // When
        Boolean result1 = TWIST_QueryParametersFormatUtils.isLangCountryFormatValid('eng-eng');
        Boolean result2 = TWIST_QueryParametersFormatUtils.isLangCountryFormatValid('fra-e1');
        Boolean result3 = TWIST_QueryParametersFormatUtils.isLangCountryFormatValid('ENG-E1');
        Boolean result4 = TWIST_QueryParametersFormatUtils.isLangCountryFormatValid('123456');

        // Then
        System.assertEquals(false, result1);
        System.assertEquals(false, result2);
        System.assertEquals(false, result3);
        System.assertEquals(false, result4);
    }

    @isTest
    public static void test_isDispatchCountryFormatValid_whenLangCountryHasRightFormat() {
        // Given
        Boolean result1 = TWIST_QueryParametersFormatUtils.isLangCountryFormatValid('eng-us');
        Boolean result2 = TWIST_QueryParametersFormatUtils.isLangCountryFormatValid('eng-e1');

        // Then
        System.assert(result1);
        System.assert(result2);
    }
    
}