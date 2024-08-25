@isTest
public with sharing class TWIST_WireService_TEST {
    
    @TestSetup
    static void makeData(){
        TWIST_Settings__c settings = new TWIST_Settings__c();
        settings.Name = 'test';
        settings.Community_URL__c = 'community_url';
        settings.Password_Maxlength__c = 20;
        settings.Default_Language_Country_Flag_Title__c = 'world';
        settings.Default_Language_Country_Flag_Label__c = 'ENGLISH (INTL)';
        settings.Countries_New_Locales__c = 'ae/sa/kw/qa';
        settings.Default_Language_Country_Parameter__c = 'eng-e1';
        insert settings;
    }
    
    @isTest
    static void test_buildError404Url() {
        // Given
        String langCountry = 'fra-fr';
        String origin = 'mylv';
        String clientId = 'TESTTWIST001';
        
        // When
        String result = TWIST_WireService.buildError404Url(langCountry, origin, clientId);
        String expected = String.format('{0}{1}/{2}/{3}?{4}', new List<String> {
            TWIST_UrlUtils.getCommunityUrl(true),
            langCountry,
            origin,
            TWIST_PageUrl_CONST.EXCEPTION_URL.substringAfter('='),
            'client-id=' + clientId
        });
        
        // Then
        System.assertEquals(expected, result);
    }
    
    @isTest
    static void test_getPageDirection_withLtrLanguage() {
        // Given
        String langCountry = 'fra-fr';
        
        // When
        String result = TWIST_WireService.getPageDirection(langCountry);
        
        // Then
        System.assertEquals('ltr', result, 'Method test_getPageDirection_withLtrLanguage failed');
    }
    
    @isTest
    static void test_getPageDirection_withRtlLanguage() {
        // Given
        String langCountry = 'ara-ae';
        
        // When
        String result = TWIST_WireService.getPageDirection(langCountry);
        
        // Then
        System.assertEquals('rtl', result, 'Method test_getPageDirection_withRtlLanguage failed');
    }
    
    @isTest
    static void test_getHeaderAndFooterUrls() {
        List <Twist_HeaderAndFooterUrls__mdt> listUrls = [SELECT id, value__c, name__c  FROM Twist_HeaderAndFooterUrls__mdt];
        Map<String,String> result = TWIST_WireService.getHeaderAndFooterUrls('ara-ae');
        System.assertEquals(true, result.get('Apps').contains('ara-ae'));
    }

    @isTest
    static void test_getHeaderAndFooterUrlsForFraCa() {
        List <Twist_HeaderAndFooterUrls__mdt> listUrls = [SELECT id, value__c, name__c  FROM Twist_HeaderAndFooterUrls__mdt];
        Map<String,String> result = TWIST_WireService.getHeaderAndFooterUrls('fra-ca');
        System.assertEquals(true, result.get('Apps').contains('fra-ca'));
    }

    @isTest
    static void test_getSwitchToLanguage() {
        Map<String, Object> result = TWIST_WireService.getSwitchToLanguage('eng-ae');
        System.assertEquals(result, new Map<String, Object>{
            'isRequired' => true,
            'value' =>'ara'
        });
    }
    
    @isTest
    static void test_getSwitchToLanguage2() {
        Map<String, Object> result = TWIST_WireService.getSwitchToLanguage('eng-e1');
        System.assertEquals(result, new Map<String, Object>{});
    }
    
    @isTest
    static void test_getFooterConfig_nominalCase(){
        // Given
        UnitTestsHelper.setSingleHttpMock(new HttpResponseMock().setBody(TWIST_FooterUtils_TEST.getLvApiResponse()));
        // When
        Map<String,Object> footerConfig = TWIST_WireService.getFooterConfig('eng-us', '', 'mylv');
        // Then
        System.assert(!footerConfig.isEmpty(), 'ERROR');
    }
    
    @isTest
    static void test_getFooterConfig_whenExceptionIsThrown(){
        // Given
        TWIST_WireService.forceThrowException = true;
        // When
        Map<String,Object> footerConfig = TWIST_WireService.getFooterConfig('eng-us', '', 'mylv');
        // Then
        System.assert(TWIST_Utils.isMapResponseOfTypeFailureResponseObject(footerConfig), 'ERROR');
    }
    
}