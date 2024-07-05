public with sharing class TWIST_UtilsServices {

    private static final Set<String> LANG_COUNTRY_WITH_RTL_DIRECTION = new Set<String> { 'ara-ae' };
    private static final Set<String> MOBILE_APPS = new Set<String> { 'lvapp', 'lvconnect' };
    private static final String SETTING_LINK_SWITCH_TO_LANGUAGE = 'Link Switch To Language';
    private static final String PICKLIST_COUNTRIES = 'Countries';

    @AuraEnabled(cacheable=true)
    public static String buildError404Url(String langCountry, String origin, String clientId) {
        Map<String,Object> queryParams = new Map<String,Object> ();
        queryParams.put(TWIST_PageKey_CONST.LANG_COUNTRY, langCountry);
        queryParams.put(TWIST_PageKey_CONST.ORIGIN, origin);
        queryParams.put(TWIST_PageKey_CONST.CLIENT_ID, clientId);
        return TWIST_Utils.buildTwistPageUrl(TWIST_IdentityPathsMdt_CONST.ERROR404, queryParams);
    }
    
    public static String buildError404Url(String origin, String clientId) {
        
        return '';
    }

    @AuraEnabled(cacheable=true)
    public static String getPageDirection(String langCountry) {
        return LANG_COUNTRY_WITH_RTL_DIRECTION.contains(langCountry) ? 'rtl' : 'ltr';
    }

    @AuraEnabled(cacheable=true)
    public static Boolean isMobileApp(String origin) {
        return MOBILE_APPS.contains(origin) ? true : false;
    }
    
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getHeaderAndFooterUrls(String langCountry) {
        TWIST_Settings__c twistSettings = TWIST_Settings__c.getInstance();
        String[] arabicLocales = twistSettings.Countries_New_Locales__c.split('/');
       	String country = langCountry.substringAfter('-');
       	List <Twist_HeaderAndFooterUrls__mdt> listUrls = [SELECT id, value__c, name__c  FROM Twist_HeaderAndFooterUrls__mdt];
        Map<String,String> mUrls = new Map<String,String>();
        
        for(Twist_HeaderAndFooterUrls__mdt url: listUrls){
            if(url.value__c.contains('careers') && arabicLocales.contains(country)){
                url.value__c = url.value__c.replace('lang-country', twistSettings.Default_Language_Country_Parameter__c);
            }
            url.value__c = url.value__c.replace('lang-country', langCountry);
            mUrls.put(url.name__c, url.value__c);
        }
          	return mUrls;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getSwitchToLanguage(String langCountry) {
        Map<String, Object> settingsSwitchToLanguage = new Map<String, Object>();
        List <TWIST_Default_Settings__mdt> metadata = [SELECT Setting__c, Is_Required__c, Default_Value__c 
                                                       FROM TWIST_Default_Settings__mdt 
                     WHERE Country_Language__c =: langCountry AND Setting__c =: SETTING_LINK_SWITCH_TO_LANGUAGE LIMIT 1];
        if(!metadata.isEmpty()){
           settingsSwitchToLanguage.put('isRequired', metadata[0].Is_Required__c);
           settingsSwitchToLanguage.put('value', metadata[0].Default_Value__c);
        }
        return settingsSwitchToLanguage;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String, Object> getFlagData(String langCountry, String dispatchCountry, String language) {
        String country = dispatchCountry;
        Map<String, Object> flagDetails = new Map<String, Object>();
        if(String.isEmpty(dispatchCountry)){
            String[] splitLangCountry = langCountry.split('-');
            country = splitLangCountry[1].toUpperCase();
            if(country == 'E1'){
                TWIST_Settings__c twistSettings = TWIST_Settings__c.getInstance();
                flagDetails.put('title', twistSettings.Default_Language_Country_Flag_Title__c);
                flagDetails.put('label', twistSettings.Default_Language_Country_Flag_Label__c);
                return flagDetails;
            }
        }
        List<CountryMapping__mdt> clist = [SELECT Picklist__c, Iso2Code__c ,Iso3Code__c FROM CountryMapping__mdt WHERE Picklist__c != null AND Iso2Code__c =: country];
        if(!clist.isEmpty()){
            Map<String,Object> countryListTranslated = TWIST_i18nTranslations.translatePicklist(PICKLIST_COUNTRIES, language);
            String flagLabel = countryListTranslated.get(clist[0].Picklist__c).toString();
            List <String> countryLabel = flagLabel.split(' ');
            for (Integer i = 0; i < countryLabel.size(); i++) {
                countryLabel[i] = countryLabel[i].toLowerCase().capitalize();
                flagLabel = String.join(countryLabel, ' ');
            }
            flagDetails.put('title', country.toLowerCase());
            flagDetails.put('label', flagLabel);
        }
        return flagDetails;
    }
}