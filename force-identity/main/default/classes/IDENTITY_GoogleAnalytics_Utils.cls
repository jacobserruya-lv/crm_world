global without sharing class IDENTITY_GoogleAnalytics_Utils {
    
    public static Map<String,String> getConfig(String origin) {
        Map<String,String> config = new Map<String,String>();
        try {
            IDENTITY_GA_Config__mdt record = [SELECT Environment_Type__c, Environment_Id__c FROM IDENTITY_GA_Config__mdt WHERE Origin__c = :origin];
            config.put('environmentType', record.Environment_Type__c);
            config.put('environmentId', record.Environment_Id__c);
        }
        catch(Exception e) {
            System.debug('>>> Method: IDENTITY_GoogleAnalytics_Utils.getConfig(): no result found for orgin "' + origin + '"');
        }
        return config;
    }

    public static void sendEvent(
        String trackingId,
        String clientId,
        String origin,
        String environmentType,
        String environmentId,
        String environmentVersion,
        String environmentLanguage,
        String eventCategory,
        String eventAction,
        String eventLabel,
        String currentUrl,
        String connexionStatus,
        String pageName,
        String pageType
    ) {
        Map<String,String> params = new Map<String,String> {
            'trackingId' => trackingId,
            'clientId' => clientId,
            'origin' => origin,
            'environmentType' => environmentType,
            'environmentId' => environmentId,
            'environmentVersion' => environmentVersion,
            'environmentLanguage' => environmentLanguage,
            'eventCategory' => eventCategory,
            'eventAction' => eventAction,
            'eventLabel' => eventLabel,
            'currentUrl' => EncodingUtil.urlEncode(currentUrl, 'UTF-8'),
            'connexionStatus ' => connexionStatus,
            'pageName' => pageName,
            'pageType' => pageType
        };
        System.debug('>>> ANALYTICS PARAMS:');
        for(String key : params.keySet()){
            System.debug('>>> ' + key + ': ' + params.get(key));
        }
        Google_Analytics_API.sendUserTrackingEvent(params);
    }

}
