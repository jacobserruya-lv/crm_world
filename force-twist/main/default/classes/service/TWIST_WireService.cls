public with sharing class TWIST_WireService {
    
    private static final Set<String> LANG_COUNTRY_WITH_RTL_DIRECTION = new Set<String> { 'ara-ae' };
    private static final Set<String> MOBILE_APPS = new Set<String> { 'lvapp', 'lvconnect' };
    private static final String SETTING_LINK_SWITCH_TO_LANGUAGE = 'Link Switch To Language';
    private static final String PICKLIST_COUNTRIES = 'Countries';
    
    @testVisible private static Boolean forceThrowException = false;
    
    @AuraEnabled(cacheable=true)
    public static String buildError404Url(String langCountry, String origin, String clientId) {
        Map<String,Object> queryParams = new Map<String,Object> ();
        queryParams.put(TWIST_QueryParamKey_CONST.LANG_COUNTRY, langCountry);
        queryParams.put(TWIST_QueryParamKey_CONST.ORIGIN, origin);
        queryParams.put(TWIST_QueryParamKey_CONST.CLIENT_ID, clientId);
        return TWIST_Utils.buildTwistPageUrl(TWIST_IdentityPathsMdt_CONST.ERROR404, queryParams);
    }
    
    @AuraEnabled(cacheable=true)
    public static String getPageDirection(String langCountry) {
        return LANG_COUNTRY_WITH_RTL_DIRECTION.contains(langCountry) ? 'rtl' : 'ltr';
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getHeaderAndFooterUrls(String langCountry) {
        TWIST_Settings__c twistSettings = TWIST_Settings__c.getInstance();
        String[] arabicLocales = twistSettings.Countries_New_Locales__c.split('/');
        String[] locales = langCountry.split('-');
        String country = langCountry.substringAfter('-');
        List <Twist_HeaderAndFooterUrls__mdt> listUrls = [SELECT id, value__c, name__c  FROM Twist_HeaderAndFooterUrls__mdt];
        Map<String,String> mUrls = new Map<String,String>();
        
        for(Twist_HeaderAndFooterUrls__mdt url: listUrls){
            if (locales[0] == 'fra'){ // TODO not covered by tests
                url.value__c = url.value__c.replace('contact-us','nous-contacter');
                url.value__c = url.value__c.replace('legal-notices','mentions-legales');
                url.value__c = url.value__c.replace('stores','magasins');
                url.value__c = url.value__c.replace('sustainability','developpement-durable');
            }
            if(arabicLocales.contains(country)){
                url.value__c = url.value__c.replace('legal-notices', 'legal-privacy');
            }
            if(url.value__c.contains('careers') && arabicLocales.contains(country)){
                url.value__c = url.value__c.replace('lang-country', twistSettings.Default_Language_Country_Parameter__c);
            }
            url.value__c = url.value__c.replace('lang-country', langCountry);
            url.value__c = url.value__c.replace('prefix', TWIST_UrlUtils.getUrlPrefix(langCountry));
            mUrls.put(url.name__c, url.value__c);
        }
        return mUrls;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getSwitchToLanguage(String langCountry) {
        Map<String, Object> settingsSwitchToLanguage = new Map<String, Object>();
        List <TWIST_Default_Settings__mdt> metadata = [
        SELECT Setting__c, Is_Required__c, Default_Value__c 
        FROM TWIST_Default_Settings__mdt 
        WHERE Country_Language__c =: langCountry
        AND Setting__c =: SETTING_LINK_SWITCH_TO_LANGUAGE
        LIMIT 1
        ];
        if(!metadata.isEmpty()){ // TODO not covered by tests
            settingsSwitchToLanguage.put('isRequired', metadata[0].Is_Required__c);
            settingsSwitchToLanguage.put('value', metadata[0].Default_Value__c);
        }
        return settingsSwitchToLanguage;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> getFooterConfig(String langCountry, String dispatchCountry, String origin) {
        Map<String,Object> footerConfig = new Map<String,Object>();
        try {
            if (forceThrowException) {
                throw new CustomException();
            }
            Map<String,Object> settings = TWIST_Utils.getTwistSettings(new List<String> { 'Footer_Links_Base_Url__c', 'Footer_Info_API__c' });
            String baseUrl = String.format((String) settings.get('Footer_Links_Base_Url__c'), new List<String> { TWIST_UrlUtils.getUrlPrefix(langCountry) });
            TWIST_FooterUtils.initFooterConfig(footerConfig);
            TWIST_FooterUtils.addFooterConfigFromSF(footerConfig, baseUrl, langCountry, dispatchCountry, origin);
            if (!TWIST_Utils.isMapResponseOfTypeFailureResponseObject(footerConfig)) {
                    TWIST_FooterUtils.addFooterConfigFromLV(
                    footerConfig,
                    String.format((String) settings.get('Footer_Info_API__c'), new List<String> { langCountry }),
                    baseUrl,
                    (String) footerConfig.get('clientServicePhoneNumber'),
                    langCountry
                );
            }
        }
        catch(Exception e) {
            footerConfig = TWIST_Utils.buildFailureResponseObject('message', e.getMessage());
        }
        return footerConfig;
    }
        
    private class CustomException extends Exception {}
    
}
