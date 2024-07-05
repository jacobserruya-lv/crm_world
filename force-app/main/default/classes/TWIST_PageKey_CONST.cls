public with sharing class TWIST_PageKey_CONST {
    
    public static final String LANG_COUNTRY = 'langCountry';
    public static final String DISPATCH_COUNTRY = 'dispatchCountry';
    public static final String ORIGIN = 'origin';
    public static final String DOMAIN = 'domain';
    public static final String REDIRECT_URL = 'redirectURL';
    public static final String SOCIAL_MEDIA = 'socialMedia';
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
    public static final String TOKEN = 'token';
    public static final String STATE = 'state';
    public static final String CODE_CHALLENGE = 'codeChallenge';
    public static final String CLIENT_ID = 'clientId';
    public static final String REDIRECT_URI = 'redirectUri';
    public static final String PAGE = 'page';

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
            TOKEN,
            STATE,
            CODE_CHALLENGE,
            CLIENT_ID,
            REDIRECT_URI,
            PAGE
        };
    }

}