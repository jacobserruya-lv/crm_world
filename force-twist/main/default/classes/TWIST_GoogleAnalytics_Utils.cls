public with sharing class TWIST_GoogleAnalytics_Utils {

        public static String buildUtagDataObjectFromCurrentPageParams(String origin, String langCountry, String dispatchCountry, String page) {
            Map<String,String> utagData = buildUtagDataObject(new Map<String,String> {
                TWIST_QueryParamKey_CONST.ORIGIN => origin,
                TWIST_QueryParamKey_CONST.LANG_COUNTRY => langCountry,
                TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY => dispatchCountry,
                TWIST_QueryParamKey_CONST.PAGE => page
            });
            return JSON.serialize(utagData);
        }
        
        private static Map<String,String> buildUtagDataObject(Map<String,String> queryParams) {
            Map<String,String> utagData = new Map<String,String>();
            try {
                String origin = queryParams.get(TWIST_QueryParamKey_CONST.ORIGIN);
                String langCountry = queryParams.get(TWIST_QueryParamKey_CONST.LANG_COUNTRY);
                String dispatchCountry = queryParams.get(TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY);
                String page = queryParams.get(TWIST_QueryParamKey_CONST.PAGE);
                String metaLanguageATG = getMetaLanguage(langCountry);
                Map<String,Object> settings = TWIST_Utils.getLoginFormSettings();
                if(String.isEmpty(origin)){
                    origin = (String) settings.get('defaultOriginParameter');
                }
                if(String.isEmpty(langCountry)){
                    langCountry = (String) settings.get('defaultLangCountryParameter');
                }
                String currencyCode = TWIST_RegistrationUtils.getDefaultSettings(langCountry).get('Currency Code').Default_Value__c;
                TWIST_GA_config__mdt gaConfig = getGAConfig(origin);
                Map<String, Object> pageName = (Map<String, Object>) JSON.deserializeUntyped(gaConfig.PageName__c);
                Map<String, Object> pageType = (Map<String, Object>) JSON.deserializeUntyped(gaConfig.PageType__c);
                Map<String, Object> pageRank = (Map<String, Object>) JSON.deserializeUntyped(gaConfig.Page_Rank__c);
                
                utagData.put(TWIST_QueryParamKey_CONST.ENVIRONMENT_TYPE, gaConfig.Environment_Type__c);
                utagData.put(TWIST_QueryParamKey_CONST.ENVIRONMENT_ID, gaConfig.Environment_Id__c);
                utagData.put(TWIST_QueryParamKey_CONST.ENVIRONMENT_VERSION, langCountry.substringAfter('-'));
                utagData.put(TWIST_QueryParamKey_CONST.ENVIRONMENT_LANGUAGE, metaLanguageATG);
                utagData.put(TWIST_QueryParamKey_CONST.TEALIUM_ENV, settings.get('tealiumEnv') != null ? (String) settings.get('tealiumEnv') : null);
                utagData.put(TWIST_QueryParamKey_CONST.CURRENCY_CODE, currencyCode);
                utagData.put(TWIST_QueryParamKey_CONST.PAGE_NAME, page != null ? (String) pageName.get(page) : null);
                utagData.put(TWIST_QueryParamKey_CONST.PAGE_TYPE, page != null ? (String) pageType.get(page) : null);
                utagData.put(TWIST_QueryParamKey_CONST.PAGE_RANK, page != null ? (String) pageRank.get(page) : null);
                utagData.put(TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY, dispatchCountry);
            }
            catch(Exception ex) {
                System.debug('Exception: ' + ex.getMessage() + '\n' + ex.getStackTraceString());
            }
            return lowerCaseValues(utagData);
        }
        
        private static String getMetaLanguage(String langCountry) {
            return [SELECT Meta_Language__c FROM Language_Mapping_ATG_SF__mdt WHERE ATG__c =: langCountry LIMIT 1].Meta_Language__c;
        }
        
        private static TWIST_GA_config__mdt getGAConfig(String origin) {
            return [SELECT Environment_Type__c, Environment_Id__c, PageName__c, PageType__c, Page_Rank__c FROM TWIST_GA_config__mdt WHERE Origin__c = :origin];
        }
        
        private static Map<String,String> lowerCaseValues(Map<String,String> utagData) {
            for (String key : utagData.keySet()) {
                String value = utagData.get(key);
                if (value != null) {
                    utagData.put(key, value.toLowerCase());
                }
            }
            return utagData;
        }
        
    }