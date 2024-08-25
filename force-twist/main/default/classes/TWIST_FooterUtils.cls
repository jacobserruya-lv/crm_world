public with sharing class TWIST_FooterUtils {

    private static final Set<String> MOBILE_APPS = new Set<String> { 'lvapp', 'lvconnect' };

    // Keys used in the Map returned to the TwistFooter LWC
    @testVisible private static final String SECTION_KEY = 'section';
    @testVisible private static final String SOCIAL_KEY = 'social';
    @testVisible private static final String UK_STATEMENT_KEY = 'ukStatement';
    @testVisible private static final String SITEMAP_LABEL = 'Sitemap';
    @testVisible private static final String IS_MOBILE_APP_KEY = 'isMobileApp';
    @testVisible private static final String SHIP_TO_URL_KEY = 'shipToUrl';
    @testVisible private static final String CLIENT_SERVICE_PHONE_NUMBER_KEY = 'clientServicePhoneNumber';
    @testVisible private static final String DISPLAY_USER_RIGHTS_LOGO_KEY = 'displayUserRightsLogo';
    @testVisible private static final String COUNTRY_FLAG_KEY = 'countryFlag';
    @testVisible private static final String HIDE_FLAG_COUNTRY_KEY = 'hideFlagCountry';
    @testVisible private static final String ADDITIONAL_TEXT_KEY = 'additionalText';
   	@testVisible private static final String SITEMAP_LINK_KEY = 'sitemapLink';
    @testVisible private static final String HELP_SECTION_KEY = 'help';
    @testVisible private static final String SERVICES_SECTION_KEY = 'services';
    @testVisible private static final String ABOUT_SECTION_KEY = 'about';
    @testVisible private static final String CONNECT_SECTION_KEY = 'connect';
    
    // Keys used in the LV API reponse
    private static final String CATEGORIES_KEY = 'categories';
    @testVisible private static final String LEGAL_SECTION_KEY = 'legalSection';
    private static final String FOLDERS_KEY = 'folders';
    @testVisible private static final String CONTENT_KEY = 'content';
    @testVisible private static final String TYPE_ELEM_KEY = 'typeElem';
    @testVisible private static final String ID_ELEM_KEY = 'idElem';
    
    // Keys used in both the Map returned to the TwistFooter LWC / the LV API reponse
    @testVisible private static final String LABEL_KEY = 'label';
    private static final String SRC_KEY = 'src';
    @testVisible private static final String URL_KEY = 'url';
    private static final String ICON_KEY = 'icon';

    @testVisible private static final String TYPE_ELEM_TEXT = 'text';
    private static final String TYPE_ELEM_LINK = 'link';
    private static final String ID_ELEM_FOLLOW_US = 'follow_us';
    @testVisible private static final String ID_ELEM_TRANSPARENCY_US = 'ca_transparency';
    private static final String ID_ELEM_MSA_TRANSPARENCY = 'msa_transparency';
    @testVisible private static final String ID_ELEM_LEGAL_NOTICE = 'legalnotice';
    @testVisible private static final String ID_ELEM_PRIVACY_POLICY = 'Privacy Policy';
    @testVisible private static final String ID_ELEM_CONFIDENTIALITY_FRA_CA = 'Confidentialité';
    
    @testVisible private static Boolean forceThrowException = false;

    public static void initFooterConfig(Map<String,Object> footerConfig) {
        footerConfig.put(SECTION_KEY, new Map<String,Object> {});
        footerConfig.put(SOCIAL_KEY, new Map<String,Object> {});
    }
    
    public static void addFooterConfigFromSF(Map<String,Object> footerConfig, String baseUrl, String langCountry, String dispatchCountry, String origin) {
        try {
            if (forceThrowException) {
                throw new CustomException();
            }
            Map<String, Object> sitemapConfig = new Map<String, Object> {
                LABEL_KEY => SITEMAP_LABEL,
                URL_KEY => baseUrl+'/'+langCountry+'/sitemap'
            };
            footerConfig.put(SITEMAP_LINK_KEY, new Map<String,String> {
                LABEL_KEY => (String) sitemapConfig.get(LABEL_KEY),
                URL_KEY => (String) sitemapConfig.get(URL_KEY)
            });
            footerConfig.put(IS_MOBILE_APP_KEY, MOBILE_APPS.contains(origin));
            footerConfig.put(SHIP_TO_URL_KEY, baseUrl + '/dispatch?noDRP=true');
            footerConfig.putAll(new TWIST_FooterUtils_WithoutSharing().getFooterConfig(langCountry, dispatchCountry));
        }
        catch (Exception e) {
            footerConfig.clear();
            footerConfig.putAll(TWIST_Utils.buildFailureResponseObject('message', 'in TWIST_FooterUtils.addFooterConfigFromSF() > ' + e.getMessage()));
        }
    }
    
    public static void addFooterConfigFromLV(Map<String,Object> footerConfig, String lvApiUrl, String footerLinkBaseUrl, String clientServicePhoneNumber, String langCountry) {
        try {
            if (forceThrowException) {
                throw new CustomException();
            }
            Map<String,Object> footerConfigFromLvApi = getFooterConfigFromLvApi(lvApiUrl);
            addLegalNoticeAndPrivacyConfig(footerConfig, footerConfigFromLvApi, footerLinkBaseUrl);
            addSectionsConfig(footerConfig, footerConfigFromLvApi, footerLinkBaseUrl, clientServicePhoneNumber);
            addSocialConfig(footerConfig, footerConfigFromLvApi, footerLinkBaseUrl);
            footerConfig.put('_footerConfigFromLvApi', footerConfigFromLvApi); // uncomment for debug purposes
            if (isLangCountryUnitedKingdom(langCountry)) {
                addUkStatementConfig(footerConfig, footerConfigFromLvApi, footerLinkBaseUrl);
            }
            if (isLangCountryUsa(langCountry)) {
                addCaliforniaTransparencyConfigForUs(footerConfig, footerConfigFromLvApi, footerLinkBaseUrl);
            }
            if (isLangCountryFrenchCanada(langCountry)) {
                addConfidentialityConfigForFrenchCanada(footerConfig, footerConfigFromLvApi, footerLinkBaseUrl);
            }
        }
        catch (Exception e) {
            footerConfig.clear();
            footerConfig.putAll(TWIST_Utils.buildFailureResponseObject('message', 'in TWIST_FooterUtils.addFooterConfigFromLV() > ' + e.getMessage()));
        }
    }

    /** PRIVATE METHODS ******************************************************************************************************* */
    
    @testVisible
    private static Map<String,Object> getFooterConfigFromLvApi(String lvApiUrl) {
        try {
            HTTP_Utils request = new HTTP_Utils().get(lvApiUrl).call();
            return (Map<String,Object>) JSON.deserializeUntyped(request.responseBody());
        }
        catch (Exception e) {
            throw new CustomException('TWIST_FooterUtils.getFooterConfigFromLvApi()');
        }
    }

    @testVisible
      private static void addLegalNoticeAndPrivacyConfig(Map<String,Object> footerConfig, Map<String,Object> footerConfigFromLvApi, String footerLinkBaseUrl) {
        try {
            List<Object> legalSectionConfig = (List<Object>) footerConfigFromLvApi.get(LEGAL_SECTION_KEY);
            Map<String,Object> legalNoticeConfig = TWIST_ListUtils.filterByMapKeyValues(legalSectionConfig, ID_ELEM_KEY, ID_ELEM_LEGAL_NOTICE);
            Map<String,Object> privacyPolicyConfig = TWIST_ListUtils.filterByMapKeyValues(legalSectionConfig, LABEL_KEY, ID_ELEM_PRIVACY_POLICY);
           	addBaseUrlToRelativeUrlsForLinks(new List<Object> { legalNoticeConfig }, footerLinkBaseUrl);
            addBaseUrlToRelativeUrlsForLinks(new List<Object> { privacyPolicyConfig }, footerLinkBaseUrl);
        }
        catch (Exception e) {
            throw new CustomException('TWIST_FooterUtils.addLegalNoticeAndPrivacyConfig()');
        }
    }
    
    @testVisible
    private static void addConfidentialityConfigForFrenchCanada(Map<String,Object> footerConfig, Map<String,Object> footerConfigFromLvApi, String footerLinkBaseUrl) {
        try {
           List<Object> legalSectionConfig = (List<Object>) footerConfigFromLvApi.get(LEGAL_SECTION_KEY);
     	   Map<String,Object> confidentialityConfig = TWIST_ListUtils.filterByMapKeyValues(legalSectionConfig, LABEL_KEY, ID_ELEM_CONFIDENTIALITY_FRA_CA);
           addBaseUrlToRelativeUrlsForLinks(new List<Object> { confidentialityConfig }, footerLinkBaseUrl); 
        }
       	catch (Exception e) {
            throw new CustomException('TWIST_FooterUtils.addConfidentialityConfigForFrenchCanada()');
       }
    }
   	
    @testVisible 
    private static void addCaliforniaTransparencyConfigForUs(Map<String,Object> footerConfig, Map<String,Object> footerConfigFromLvApi, String footerLinkBaseUrl) {
        try {
            List<Object> legalSectionConfig = (List<Object>) footerConfigFromLvApi.get(LEGAL_SECTION_KEY);
     		Map<String,Object> transparencyConfig = TWIST_ListUtils.filterByMapKeyValues(legalSectionConfig, ID_ELEM_KEY, ID_ELEM_TRANSPARENCY_US);
        	addBaseUrlToRelativeUrlsForLinks(new List<Object> { transparencyConfig }, footerLinkBaseUrl);
        }
        catch (Exception e) {
            throw new CustomException('TWIST_FooterUtils.addCaliforniaTransparencyConfigForUs');
       }
    }

    @testVisible
    private static void addSectionsConfig(Map<String,Object> footerConfig, Map<String,Object> footerConfigFromLvApi, String footerLinkBaseUrl, String clientServicePhoneNumber) {
        try {
            List<Object> sectionsList = (List<Object>) footerConfigFromLvApi.get(CATEGORIES_KEY);
            Map<String,Object> sectionsConfig = (Map<String,Object>) footerConfig.get(SECTION_KEY);
            sectionsConfig.put(HELP_SECTION_KEY, buildSectionConfig((Map<String,Object>) sectionsList.get(0), footerLinkBaseUrl));
            updateClientServicePhoneNumber((Map<String,Object>) sectionsConfig, clientServicePhoneNumber);
            sectionsConfig.put(SERVICES_SECTION_KEY, buildSectionConfig((Map<String,Object>) sectionsList.get(1), footerLinkBaseUrl));
            sectionsConfig.put(ABOUT_SECTION_KEY, buildSectionConfig((Map<String,Object>) sectionsList.get(2), footerLinkBaseUrl));
            sectionsConfig.put(CONNECT_SECTION_KEY, buildSectionConfig((Map<String,Object>) sectionsList.get(3), footerLinkBaseUrl));
        }
        catch (Exception e) {
            throw new CustomException('TWIST_FooterUtils.addSectionsConfig()');
        }
    }

    private static Map<String,Object> buildSectionConfig(Map<String,Object> sectionConfig, String footerLinkBaseUrl) {
        List<Object> contentConfig = (List<Object>) sectionConfig.get(CONTENT_KEY);
        addContentTypeAttribute(contentConfig);
        addBaseUrlToRelativeUrlsForLinks(contentConfig, footerLinkBaseUrl);
        addCssStyleToAnchorTags(contentConfig);
        return sectionConfig;
    }

    private static void updateClientServicePhoneNumber(Map<String,Object> sectionsConfig, String clientServicePhoneNumber) {
        Map<String,Object> helpSectionConfig = (Map<String,Object>) sectionsConfig.get(HELP_SECTION_KEY);
        List<Object> contentConfig = (List<Object>) helpSectionConfig.get(CONTENT_KEY);
        Map<String,Object> clientServiceMessageConfig = TWIST_ListUtils.filterByMapKeyValues(contentConfig, TYPE_ELEM_KEY, TYPE_ELEM_TEXT);
        clientServiceMessageConfig.put(LABEL_KEY, String.valueOf(clientServiceMessageConfig.get(LABEL_KEY)).replace('{{clientServicePhoneNumber}}', clientServicePhoneNumber));
        sectionsConfig.remove(CLIENT_SERVICE_PHONE_NUMBER_KEY);
    }
    
    /**
     * @description Add a boolean attribute to any Map associated to a "content" key, which tells about the kind of content (isText / isLink)
     * This process is needed because the lwc:if={expression} primitive used in the LWC HTML file works with boolean expressions only
     */
    private static void addContentTypeAttribute(List<Object> contentConfig) {
        for (Integer i=0; i < contentConfig.size(); i++) {
            Map<String,Object> contentElt = (Map<String,Object>) contentConfig.get(i);
            String typeElem = (String) contentElt.get(TYPE_ELEM_KEY);
            if (TYPE_ELEM_TEXT.equals(typeElem)) {
                contentElt.put('isText', true);
            }
            if (TYPE_ELEM_LINK.equals(typeElem)) {
                contentElt.put('isLink', true);
            }
        }
    }

    private static void addBaseUrlToRelativeUrlsForLinks(List<Object> contentConfig, String footerLinkBaseUrl) {
        for (Integer i=0; i < contentConfig.size(); i++) {
            Map<String,Object> contentElt = (Map<String,Object>) contentConfig.get(i);
            if (TYPE_ELEM_LINK.equals(String.valueOf(contentElt.get(TYPE_ELEM_KEY))) && String.valueOf(contentElt.get(URL_KEY)).startsWith('/')) {
                contentElt.put(URL_KEY, footerLinkBaseUrl + contentElt.get(URL_KEY));
            }
        }
    }

    private static void addCssStyleToAnchorTags(List<Object> contentConfig) {
        for (Integer i=0; i < contentConfig.size(); i++) {
            Map<String,Object> contentElt = (Map<String,Object>) contentConfig.get(i);
            if (TYPE_ELEM_TEXT.equals(String.valueOf(contentElt.get(TYPE_ELEM_KEY)))) {
                contentElt.put(LABEL_KEY, String.valueOf(contentElt.get(LABEL_KEY)).replaceAll('<a ', '<a style="color:black; text-decoration:underline; cursor:pointer;" '));
            }
        }
    }
    
    @testVisible
    private static void addSocialConfig(Map<String,Object> footerConfig, Map<String,Object> footerConfigFromLvApi, String footerLinkBaseUrl) {
        try {
            footerConfig.put(SOCIAL_KEY, TWIST_ListUtils.filterByMapKeyValues((List<Object>) footerConfigFromLvApi.get(FOLDERS_KEY), ID_ELEM_KEY, ID_ELEM_FOLLOW_US));
            Map<String,Object> socialConfig = (Map<String,Object>) footerConfig.get(SOCIAL_KEY);
            List<Object> contentConfig = (List<Object>) socialConfig.get(CONTENT_KEY);
            addBaseUrlToRelativeUrlsForIcons(contentConfig, footerLinkBaseUrl);
        }
        catch (Exception e) {
            throw new CustomException('TWIST_FooterUtils.addSocialConfig()');
        }
    }
    
    @testVisible
    private static void addUkStatementConfig(Map<String,Object> footerConfig, Map<String,Object> footerConfigFromLvApi, String footerLinkBaseUrl) {
        try {
            footerConfig.put(UK_STATEMENT_KEY, TWIST_ListUtils.filterByMapKeyValues((List<Object>) footerConfigFromLvApi.get(LEGAL_SECTION_KEY), ID_ELEM_KEY, ID_ELEM_MSA_TRANSPARENCY));
            Map<String,Object> statementConfig = (Map<String,Object>) footerConfig.get(UK_STATEMENT_KEY);
            List<Object> contentConfig = (List<Object>) statementConfig.get(CONTENT_KEY);
            addBaseUrlToRelativeUrlsForStatements(contentConfig, footerLinkBaseUrl);
        }
        catch (Exception e) {
            throw new CustomException('TWIST_FooterUtils.addUkStatementConfig()');
        }
    }

    private static Boolean isLangCountryUnitedKingdom(String langCountry){
        return langCountry == 'eng-gb';
    }
    
    private static Boolean isLangCountryUsa(String langCountry){
        return langCountry == 'eng-us';
    }
    
    private static Boolean isLangCountryFrenchCanada(String langCountry){
        return langCountry == 'fra-ca';
    }

    private static void addBaseUrlToRelativeUrlsForIcons(List<Object> contentConfig, String footerLinkBaseUrl) {
        for (Integer i=0; i < contentConfig.size(); i++) {
            Map<String,Object> contentElt = (Map<String,Object>) contentConfig.get(i);
            if (String.valueOf(contentElt.get(ICON_KEY)).startsWith('/')) {
                contentElt.put(ICON_KEY, footerLinkBaseUrl + contentElt.get(ICON_KEY));
            }
        }
    }
    
    private static void addBaseUrlToRelativeUrlsForStatements(List<Object> contentConfig, String footerLinkBaseUrl) {
        for (Integer i=0; i < contentConfig.size(); i++) {
            Map<String,Object> contentElt = (Map<String,Object>) contentConfig.get(i);
            if (String.valueOf(contentElt.get(URL_KEY)).startsWith('/')) {
                contentElt.put(URL_KEY, footerLinkBaseUrl + contentElt.get(URL_KEY));
            }
        }
    }


    /** ******************************************************************************************************* */

    private without sharing class TWIST_FooterUtils_WithoutSharing {
        
        public Map<String,Object> getFooterConfig(String langCountry, String dispatchCountry) { 
            try {
                List<TWIST_Footer_Config__mdt> mdts = String.isEmpty(dispatchCountry)
                    ? [SELECT Client_Service_Phone_Number__c, Country_Flag_Src__c, Country_Flag_Label__c, Display_User_Rights_Logo__c, Hide_Flag_Country__c, Additional_Text__c  FROM TWIST_Footer_Config__mdt WHERE Language_Country__c = :langCountry LIMIT 1]
                    : [SELECT Client_Service_Phone_Number__c, Country_Flag_Src__c, Country_Flag_Label__c, Display_User_Rights_Logo__c, Hide_Flag_Country__c, Additional_Text__c FROM TWIST_Footer_Config__mdt WHERE Language_Country__c = :langCountry AND Dispatch_Country__c = :dispatchCountry LIMIT 1];
                if (mdts.size() == 0) {
                    return new Map<String,Object>();
                }
                TWIST_Footer_Config__mdt mdt = mdts.get(0);
                
                return new Map<String,Object> {
                CLIENT_SERVICE_PHONE_NUMBER_KEY => mdt.Client_Service_Phone_Number__c,
                DISPLAY_USER_RIGHTS_LOGO_KEY => mdt.Display_User_Rights_Logo__c,
                HIDE_FLAG_COUNTRY_KEY => mdt.Hide_Flag_Country__c,
                ADDITIONAL_TEXT_KEY => mdt.Additional_Text__c,
                COUNTRY_FLAG_KEY => new Map<String,String> {
                LABEL_KEY =>  mdt.Country_Flag_Label__c,
                SRC_KEY => mdt.Country_Flag_Src__c
                    }
                };
            }
            catch (Exception e) {
                throw new CustomException('TWIST_FooterUtils_WithoutSharing.getFooterConfig()');
            }
        }
    
    }

    private class CustomException extends Exception {}

}