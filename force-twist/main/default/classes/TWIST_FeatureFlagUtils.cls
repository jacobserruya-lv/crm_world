public with sharing class TWIST_FeatureFlagUtils {

    private Map<String,Boolean> flagsMap;

    @TestVisible
    private final static String FEATURE_KEY_ALTERNATIVE_LOGIN = 'oneTimeConnectionEnabled';
    @TestVisible
    private final static String FEATURE_KEY_DUMMY_SOCIAL_MEDIA = 'dummySocialMediaEnabled'; // used in unit test
    @TestVisible
    private final static String FEATURE_KEY_LINE_SOCIAL_LOGIN = 'lineSocialLoginEnabled';

    public TWIST_FeatureFlagUtils(String langCountry) {
        this.flagsMap = new Map<String,Boolean>();
        String bodyResponse;
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Mulesoft_SFID' + this.getEndpointUrl(langCountry));
            request.setMethod('GET');
            request.setHeader('client_id', '{!$Credential.Username}');
            request.setHeader('client_secret', '{!$Credential.Password}');
            HttpResponse response = http.send(request);
            bodyResponse = response.getStatusCode() == 200 ? response.getBody() : this.buildBodyResponseAsPerSalesforceFallbackValues();
        }
        catch (Exception e) {
            bodyResponse = this.buildBodyResponseAsPerSalesforceFallbackValues();
        }
        finally {
            this.initFlagsMap(bodyResponse);
        }
    }

    public Boolean isAlternativeLoginEnabled() {
        return this.isFeatureEnabled(FEATURE_KEY_ALTERNATIVE_LOGIN);
    }

    public Boolean isDummySocialMediaEnabled() {
        return this.isFeatureEnabled(FEATURE_KEY_DUMMY_SOCIAL_MEDIA);
    }

    public Boolean isLineSocialLoginEnabled() {
        return this.isFeatureEnabled(FEATURE_KEY_LINE_SOCIAL_LOGIN);
    }

    /** Private methods *************************************************************************************************** */

    @TestVisible
    private Map<String,Boolean> getFlagsMap() {
        return this.flagsMap;
    }

    private String getEndpointUrl(String langCountry) {
        String url;
        try {
            url = String.format(
                TWIST_Settings__c.getInstance().SFCC_Feature_Flag_Endpoint__c,
                new List<String> {
                    CountryLanguageManager.getMulesoftApisPrefix(langCountry),
                    langCountry
                });
        }
        catch (Exception e) {
            throw new CustomException(e.getMessage());
        }
        return url;
    }

    private void initFlagsMap(String response) {
        Map<String,Object> responseMap = (Map<String,Object>) JSON.deserializeUntyped(response);
        for (String key: responseMap.keySet()) {
            if (responseMap.get(key) instanceof Boolean) {
                this.flagsMap.put(key, Boolean.valueOf(responseMap.get(key)));
            }
        }
    }

    private Boolean isFeatureEnabled(String featureKey) {
        return this.flagsMap.containsKey(featureKey) ? this.flagsMap.get(featureKey) : null;
    }

    private String buildBodyResponseAsPerSalesforceFallbackValues() { // TODO implement real logic here
        return JSON.serialize(new Map<String,Boolean> {
            FEATURE_KEY_ALTERNATIVE_LOGIN => false,
            FEATURE_KEY_DUMMY_SOCIAL_MEDIA => true,
            FEATURE_KEY_LINE_SOCIAL_LOGIN => true
        });
    }

    private class CustomException extends Exception {}

}