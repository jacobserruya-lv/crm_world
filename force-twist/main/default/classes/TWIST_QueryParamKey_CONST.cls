public with sharing class TWIST_QueryParamKey_CONST {
    
    public static final String LANG_COUNTRY = 'langCountry';
    public static final String DISPATCH_COUNTRY = 'dispatchCountry';
    public static final String ORIGIN = 'origin';
    public static final String DOMAIN = 'domain';
    public static final String REDIRECT_URL = 'redirect-url';
    public static final String SOCIAL_MEDIA = 'socialMedia';
    public static final String ACCESS_TOKEN_SNAKE_CASE = 'access_token';
    public static final String ERROR_CODE = 'ErrorCode';
    public static final String ACCOUNT = 'accountId';
    public static final String CID = 'cid';
    public static final String TRUST_ORIGIN = 'isTrustOrigin';
    public static final String UPDATED_TO_DEFAULT_LANG_COUNTRY = 'defaultCountryLangLog';
    public static final String ERROR_404 = '404Log';
    public static final String FRIENDLY_URL = 'friendlyUrl';
    public static final String UTM_CAMPAIGN = 'utm_campaign';
    public static final String CAMPAIGN = 'campaign';
    public static final String LOOK_ID = 'lookId';
    public static final String META_LANGUAGE = 'metaLanguage';
    public static final String ENVIRONMENT_LANGUAGE = 'environmentLanguage';
    public static final String ENVIRONMENT_TYPE = 'environmentType';
    public static final String ENVIRONMENT_ID = 'environmentId';
    public static final String ENVIRONMENT_VERSION = 'environmentVersion';
    public static final String TEALIUM_ENV = 'tealiumEnv';
    public static final String CURRENCY_CODE = 'currencyCode';
    public static final String PAGE_NAME = 'pageName';
    public static final String PAGE_TYPE = 'pageType';
    public static final String PAGE_RANK = 'pageRank';
    public static final String SF_LANGUAGE = 'language';
    public static final String COUNTRY_LOCAL = 'countryLocal';
    public static final String CUSTOMER_SERVICE_PHONE_NUMBER = 'clientServicePhoneNumber';
    public static final String GOOGLE_ANALYTICS_CONFIG = 'googleAnalyticsConfig';
    public static final String ERROR_URL = 'errorUrl';
    public static final String SOCIAL_ID = 'social_id';
    public static final String SUCCESS_URL = 'successUrl';
    public static final String TOKEN = 'token';
    public static final String STATE = 'state';
    public static final String CODE_CHALLENGE = 'code-challenge';
    public static final String CLIENT_ID = 'client-id';
    public static final String REDIRECT_URI = 'redirect-uri';
    public static final String PAGE = 'page';
    public static final String START_URL = 'startURL';
    public static final String ERROR_DESCRIPTION = 'ErrorDescription';
    public static final String PROVIDER_ID = 'ProviderId';
    public static final String USER_START_URL = 'userStartUrl';
    public static final String DEV_START_URL = 'devStartUrl';
    public static final String USER_START_DOMAIN = 'userStartDomain';
    public static final String USER_AGENT_UPPERCASE = 'USER-AGENT';
    public static final String TOKEN_INVALID_ERROR_MESSAGE = 'token-invalid-error-message';
    public static final String ACCOUNT_ACTIVATION = 'account_activation';

    /**
     * @description this method is only used for unit testing
     */
    public static List<String> getConstants() {
        return new List<String> {
            LANG_COUNTRY,
            DISPATCH_COUNTRY,
            ORIGIN,
            DOMAIN,
            REDIRECT_URL,
            SOCIAL_MEDIA,
            ACCESS_TOKEN_SNAKE_CASE,
            ERROR_CODE,
            ACCOUNT,
            CID,
            TRUST_ORIGIN,
            UPDATED_TO_DEFAULT_LANG_COUNTRY,
            ERROR_404,
            FRIENDLY_URL,
            UTM_CAMPAIGN,
            CAMPAIGN,
            LOOK_ID,
            META_LANGUAGE,
            ENVIRONMENT_LANGUAGE,
            ENVIRONMENT_TYPE,
            ENVIRONMENT_ID,
            ENVIRONMENT_VERSION,
            TEALIUM_ENV,
            CURRENCY_CODE,
            PAGE_NAME,
            PAGE_TYPE,
            PAGE_RANK,
            SF_LANGUAGE,
            COUNTRY_LOCAL,
            CUSTOMER_SERVICE_PHONE_NUMBER,
            GOOGLE_ANALYTICS_CONFIG,
            ERROR_URL,
            SOCIAL_ID,
            SUCCESS_URL,
            TOKEN,
            STATE,
            CODE_CHALLENGE,
            CLIENT_ID,
            REDIRECT_URI,
            PAGE,
            ACCOUNT_ACTIVATION,
            START_URL,
            ERROR_DESCRIPTION,
            PROVIDER_ID,
            USER_START_URL,
            DEV_START_URL,
            USER_START_DOMAIN,
            TOKEN_INVALID_ERROR_MESSAGE,
            USER_AGENT_UPPERCASE
        };
    }

}