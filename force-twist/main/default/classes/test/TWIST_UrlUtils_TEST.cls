@isTest
public with sharing class TWIST_UrlUtils_TEST {

    private static String regexPatternForBaseUrl = 'https://([a-zA-Z0-9_.\\-&&[^/\\?]]+)(/twist/)?'; // see https://stackoverflow.com/a/25609014 for this pattern: [^/\\?]
    private static String regexPatternForVisualforcePageUrl = 'apex/[a-zA-Z0-9\\-_]+';
    private static String regexPatternForQueryString = '(\\?\\w+=\\w+){1}(\\&\\w+=\\w+)*';

    @isTest
    static void test_buildQueryStringFromMap_WithEmptyParam() {
        // Given
        Map<String,Object> params = new Map<String,Object>();
        String expected = '';
        // When
        String result = TWIST_UrlUtils.buildQueryStringFromMap(params);
        // Then
        System.assertEquals(expected, result, 'ERROR');
    }

    @isTest
    static void test_buildQueryStringFromMap_WithNullParam() {
        // Given
        Map<String,Object> params = null;
        String expected = '';
        // When
        String result = TWIST_UrlUtils.buildQueryStringFromMap(params);
        // Then
        System.assertEquals(expected, result, 'ERROR');
    }

    @isTest
    static void test_buildQueryStringFromMap_WithSingleParam() {
        // Given
        Map<String,Object> params = new Map<String,Object> { 'key' => 'string' };
        String expected = '?key=string';
        // When
        String result = TWIST_UrlUtils.buildQueryStringFromMap(params);
        // Then
        System.assertEquals(expected, result, 'ERROR');
    }

    @isTest
    static void test_buildQueryStringFromMap_WithMultipleParams() {
        // Given
        Map<String,Object> params = new Map<String,Object> {
            'key1' => 'string',
            'key2' => 555,
            'key3' => false
        };
        String expected = '?key1=string&key2=555&key3=false';
        // When
        String result = TWIST_UrlUtils.buildQueryStringFromMap(params);
        // Then
        System.assertEquals(expected, result, 'ERROR');
    }

    @isTest
    static void test_buildVisualforcePageUrl_FirstMethodVersion() {
        // Given
        TWIST_Settings__c settings = new TWIST_Settings__c();
        settings.Password_Maxlength__c = 20;
        settings.AOB_Site_URL__c = 'https://base-url/twist/';
        insert settings;

        String regexPattern = String.format(
            '^{0}{1}$',
            new List<String> {
                regexPatternForBaseUrl,
                regexPatternForVisualforcePageUrl
            }
        );
        Pattern p = Pattern.compile(regexPattern);

        // When
        String url = TWIST_UrlUtils.buildVisualforcePageUrl('TWIST_i18nCustomLabels');
        Matcher pm = p.matcher(url);
        
        // Then
        System.assert(pm.matches(), 'ERROR');
    }

    @isTest
    static void test_buildVisualforcePageUrl_SecondMethodVersion() {
        // Given
        TWIST_Settings__c settings = new TWIST_Settings__c();
        settings.Password_Maxlength__c = 20;
        settings.AOB_Site_URL__c = 'https://base-url/twist/';
        insert settings;

        String regexPattern = String.format(
            '^{0}{1}{2}$',
            new List<String> {
                regexPatternForBaseUrl,
                regexPatternForVisualforcePageUrl,
                regexPatternForQueryString
            });
        Pattern p = Pattern.compile(regexPattern);

        // When
        String url = TWIST_UrlUtils.buildVisualforcePageUrl(
            'TWIST_i18nCustomLabels',
            new Map<String,Object> {
                'key1' => 'string',
                'key2' => 555,
                'key3' => false
            });
        Matcher pm = p.matcher(url);
        
        // Then
        System.assert(pm.matches(), 'ERROR');
    }

    @isTest
    public static void test_getCommunityUrl() {
        // Given
        TWIST_Settings__c settings = new TWIST_Settings__c();
        settings.Password_Maxlength__c = 20;
        settings.AOB_Site_URL__c = 'https://louisvuitton--socialmed.sandbox.my.site.com/twist/';
        insert settings;

        // When
        String akamaizedUrl = TWIST_UrlUtils.getCommunityUrl(true);
        String forceDotComUrl = TWIST_UrlUtils.getCommunityUrl(false);

        // Then
        System.assert(akamaizedUrl.startsWith('https://account-'));
        System.assert(akamaizedUrl.endsWith('.louisvuitton.com/'));
        System.assert(forceDotComUrl.startsWith('https://louisvuitton--'));
        System.assert(forceDotComUrl.endsWith('.com/twist/'));
    }

    @isTest
    static void test_getUrlPrefix() {
        // Given
        String expected = 'us';
        // When
        String result = TWIST_UrlUtils.getUrlPrefix('eng-us');
        // Then
        System.assertEquals('us', result, 'ERROR');
    }
}
