public with sharing class TWIST_FlaggedFeatureUtils {

    private Map<String,Boolean> queriedFlaggedFeatures;
    private List<String> featureKeysToQueryFromSFB2C;
    private List<String> featureKeysToQueryFromSF;

    // Folowing values have to match both Twist_Flagged_Features__mdt.Feature_Key__c and keys returned by SFB2C API
    @TestVisible public final static String FEATURE_KEY_TEST_DO_QUERY_SFB2C_FALLBACK_TRUE = 'testDoQuerySFB2CFallbackTrue'; // only used in unit tests
    @TestVisible public final static String FEATURE_KEY_TEST_DO_QUERY_SFB2C_FALLBACK_FALSE = 'testDoQuerySFB2CFallbackFalse'; // only used in unit tests
    @TestVisible public final static String FEATURE_KEY_TEST_DO_NOT_QUERY_SFB2C_FALLBACK_TRUE = 'testDoNotQuerySFB2CFallbackTrue'; // only used in unit tests
    @TestVisible public final static String FEATURE_KEY_TEST_DO_NOT_QUERY_SFB2C_FALLBACK_FALSE = 'testDoNotQuerySFB2CFallbackFalse'; // only used in unit tests
    @TestVisible public final static String FEATURE_KEY_ALTERNATIVE_LOGIN = 'oneTimeConnectionEnabled';
    @TestVisible public final static String FEATURE_KEY_LINE_SOCIAL_LOGIN = 'lineSocialLoginEnabled';
    @TestVisible public final static String FEATURE_KEY_GOOGLE_SOCIAL_LOGIN = 'googleSocialLoginEnabled';

    /** Constructors **************************************************************************************************************** */

    public TWIST_FlaggedFeatureUtils(String featureKey, String langCountry) {
        this(new List<String> { featureKey }, langCountry);
    }

    public TWIST_FlaggedFeatureUtils(List<String> featureKeys, String langCountry) {
        this.initQueriedFlaggedFeatures(featureKeys);
        this.featureKeysToQueryFromSFB2C = new List<String>();
        this.featureKeysToQueryFromSF = new List<String>();

        // Dispatch flagged features according to their Do_Query_SFB2C attribute
        List<Twist_Flagged_Features__mdt> records = this.getTwistFeatureFlagsMetadata(featureKeys, langCountry);
        for (Twist_Flagged_Features__mdt record : records) {
            if (record.Do_Query_SFB2C__c) {
                this.featureKeysToQueryFromSFB2C.add(record.Feature_Key__c);
            }
            else {
                this.featureKeysToQueryFromSF.add(record.Feature_Key__c);
            }
        }

        // Handle flagged features to be queried from SFB2C
        if (this.featureKeysToQueryFromSFB2C.size() >= 1) {
            Map<String,Boolean> result = this.queryFeatureFlagsFromSFB2C(this.featureKeysToQueryFromSFB2C, langCountry);
            for (String featureKey : result.keySet()) {
                if (result.get(featureKey) == null ) {
                    this.featureKeysToQueryFromSF.add(featureKey);
                }
                else {
                    this.queriedFlaggedFeatures.put(featureKey, result.get(featureKey));
                }
            }
        }

        // Handle flagged features to be queried from SF
        if (this.featureKeysToQueryFromSF.size() >= 1) {
            for (Twist_Flagged_Features__mdt record : records) {
                if (this.featureKeysToQueryFromSF.contains(record.Feature_Key__c)) {
                    this.queriedFlaggedFeatures.put(record.Feature_Key__c, record.Flag_Value__c);
                }
            }
        }
    }

    public Boolean isEnabled() {
        if (this.queriedFlaggedFeatures.keySet().size() != 1) {
            throw new CustomException('Method "isEnabled" can only be called when instantiating this class with a single feature key.');
        }
        String featureKey = new List<String>(this.queriedFlaggedFeatures.keySet()).get(0);
        return this.queriedFlaggedFeatures.get(featureKey);
    }

    public Boolean isAlternativeLoginEnabled() {
        return isFeatureEnabled(FEATURE_KEY_ALTERNATIVE_LOGIN);
    }

    public Boolean isLineSocialLoginEnabled() {
        return isFeatureEnabled(FEATURE_KEY_LINE_SOCIAL_LOGIN);
    }

    public Boolean isGoogleSocialLoginEnabled() {
        return isFeatureEnabled(FEATURE_KEY_GOOGLE_SOCIAL_LOGIN);
    }

    /** Private methods ************************************************************************************************* */

    @TestVisible private List<String> getFeatureKeysToQueryFromSFB2C() {
        return this.featureKeysToQueryFromSFB2C;
    }

    @TestVisible private List<String> getFeatureKeysToQueryFromSF() {
        return this.featureKeysToQueryFromSF;
    }

    @TestVisible private Boolean isFeatureKeyTestDoQuerySFB2CFallbackTrueEnabled() {
        return isFeatureEnabled(FEATURE_KEY_TEST_DO_QUERY_SFB2C_FALLBACK_TRUE);
    }

    @TestVisible private Boolean isFeatureKeyTestDoQuerySFB2CFallbackFalseEnabled() {
        return isFeatureEnabled(FEATURE_KEY_TEST_DO_QUERY_SFB2C_FALLBACK_FALSE);
    }

    @TestVisible private Boolean isFeatureKeyTestDoNotQuerySFB2CFallbackTrueEnabled() {
        return isFeatureEnabled(FEATURE_KEY_TEST_DO_NOT_QUERY_SFB2C_FALLBACK_TRUE);
    }

    @TestVisible private Boolean isFeatureKeyTestDoNotQuerySFB2CFallbackFalseEnabled() {
        return isFeatureEnabled(FEATURE_KEY_TEST_DO_NOT_QUERY_SFB2C_FALLBACK_FALSE);
    }

    private void initQueriedFlaggedFeatures(List<String> featureKeys) {
        this.queriedFlaggedFeatures = new Map<String,Boolean>();
        for (String featureKey : featureKeys) {
            this.queriedFlaggedFeatures.put(featureKey, false);
        }
    }

    private List<Twist_Flagged_Features__mdt> getTwistFeatureFlagsMetadata(List<String> featureKeys, String langCountry) {
        return [
            SELECT Feature_Key__c, Do_Query_SFB2C__c, Flag_Value__c
            FROM Twist_Flagged_Features__mdt
            WHERE Feature_Key__c IN :featureKeys
            AND Lang_Country__c = :langCountry
        ];
    }

    private Boolean isFeatureEnabled(String featureKey) {
        if (!this.queriedFlaggedFeatures.containsKey(featureKey)) {
            throw new CustomException('Feature "' + featureKey + '" must be queried before invoking this method.');
        }
        return this.queriedFlaggedFeatures.get(featureKey);
    }

    private Map<String,Boolean> queryFeatureFlagsFromSFB2C(List<String> featureKeys, String langCountry) {
        Map<String,Boolean> result = new Map<String,Boolean>();
        try {
            Http http = new Http();
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Mulesoft_SFID' + this.getEndpointUrl(langCountry));
            request.setMethod('GET');
            request.setHeader('client_id', '{!$Credential.Username}');
            request.setHeader('client_secret', '{!$Credential.Password}');
            HttpResponse response = http.send(request);
            if (response.getStatusCode() != 200) {
                return this.buildMapWithNullValues(featureKeys);
            }
            Map<String,Object> bodyMap = (Map<String,Object>) JSON.deserializeUntyped(response.getBody());
            for (String featureKey : featureKeys) {
                result.put(featureKey, bodyMap.containsKey(featureKey) ? (Boolean) bodyMap.get(featureKey) : null);
            }
        }
        catch (Exception e) {
            return this.buildMapWithNullValues(featureKeys);
        }
        return result;
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

    private Map<String,Boolean> buildMapWithNullValues(List<String> mapKeys) {
        Map<String,Boolean> result = new Map<String,Boolean>();
        for (String mapKey : mapKeys) {
            result.put(mapKey, null);
        }
        return result;
    }

    private class CustomException extends Exception {}

}