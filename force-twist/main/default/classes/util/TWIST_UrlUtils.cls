public without sharing class TWIST_UrlUtils {

    public static String buildQueryStringFromMap(Map<String,Object> params) {
        String result = '';
        if (params != null && params.size() > 0) {
            result = '?';
            List<String> paramsKeyValues = new List<String>();
            for (String key: params.keySet()) {
                if (String.isNotEmpty(String.valueOf(params.get(key)))) {
                    paramsKeyValues.add(key + '=' + String.valueOf(params.get(key)));
                }
            }
            result += String.join(paramsKeyValues, '&');
        }
        return result;
    }

    public static String buildVisualforcePageUrl(String visualforcePageName) {
        return buildVisualforcePageUrl(visualforcePageName, new Map<String,Object>());
    }

    public static String buildVisualforcePageUrl(String visualforcePageName, Map<String,Object> visualforcePageParams) {
        return String.format('{0}apex/{1}{2}', new List<String> {
            (String) TWIST_Utils.getTwistSetting('AOB_Site_URL__c'),
            visualforcePageName,
            buildQueryStringFromMap(visualforcePageParams)
        });
    }

    public static String getLvSiteBaseUrl() {
        return (String) TWIST_Utils.getTwistSetting('Reset_Password_Redirection_Host__c');
    }

    public static String getLvSiteBaseUrl(String langCountry) {
        return String.format((String) TWIST_Utils.getTwistSetting('Footer_Links_Base_Url__c'), new List<String> { getUrlPrefix(langCountry) });
    }
    
    public static String getUrlPrefix(String langCountry) {
        String urlPrefix='eu';
        List<TWIST_Footer_Config__mdt> listLangCountry = [SELECT Language_Country__c, Url_Prefix__c FROM TWIST_Footer_Config__mdt WHERE Language_Country__c = :langCountry LIMIT 1];
        if(!listLangCountry.isEmpty()){
            if(listLangCountry[0].Url_Prefix__c != null){
                urlPrefix = (String)listLangCountry[0].Url_Prefix__c;  
                
            }
        }
        return urlPrefix;
    }
    
    public static String getCommunityUrl(Boolean akamaized) {
        return akamaized
            ? (String) TWIST_AppSettings_UTIL.getSetting('akamaizedCommunityUrl')
            : (String) TWIST_Utils.getTwistSetting('AOB_Site_URL__c');
    }

}
