@isTest
public with sharing class TWIST_GoogleAnalytics_Utils_TEST {
    
    @isTest
    public static void test_buildUtagDataObject() {
        // Given
        String origin = 'mylv';
        String langCountry = 'eng-us';
        String page = 'login';
        String dispatchCountry = '';

        // When
        String utagDataStringified = TWIST_GoogleAnalytics_Utils.buildUtagDataObjectFromCurrentPageParams(origin, langCountry, dispatchCountry, page);
        Map<String,String> utagData = (Map<String,String>) JSON.deserialize(utagDataStringified, Map<String,String>.class);
        Set<String> expectedConfigAttributes = new Set<String> {
            TWIST_QueryParamKey_CONST.ENVIRONMENT_TYPE,
            TWIST_QueryParamKey_CONST.ENVIRONMENT_ID,
            TWIST_QueryParamKey_CONST.ENVIRONMENT_VERSION,
            TWIST_QueryParamKey_CONST.ENVIRONMENT_LANGUAGE,
            TWIST_QueryParamKey_CONST.TEALIUM_ENV,
            TWIST_QueryParamKey_CONST.CURRENCY_CODE,
            TWIST_QueryParamKey_CONST.PAGE_NAME,
            TWIST_QueryParamKey_CONST.PAGE_TYPE,
            TWIST_QueryParamKey_CONST.PAGE_RANK,
            TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY
        };

        // Then
        System.assertEquals(expectedConfigAttributes, utagData.keySet(), 'msg');
    }
}
