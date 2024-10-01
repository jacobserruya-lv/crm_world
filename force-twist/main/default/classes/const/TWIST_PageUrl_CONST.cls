public with sharing class TWIST_PageUrl_CONST {

    public static final String LOGIN_URL = String.format('TWIST_LWCWrapper?{0}={1}', new List<String> { TWIST_QueryParamKey_CONST.PAGE, TWIST_QueryParamValue_CONST.PAGE_LOGIN });
    public static final String ALTERNATIVE_LOGIN_URL =String.format('TWIST_LWCWrapper?{0}={1}', new List<String> { TWIST_QueryParamKey_CONST.PAGE, TWIST_QueryParamValue_CONST.PAGE_ALTERNATIVE_LOGIN });
    public static final String FORGOT_PASSWORD_URL = String.format('TWIST_LWCWrapper?{0}={1}', new List<String> { TWIST_QueryParamKey_CONST.PAGE, TWIST_QueryParamValue_CONST.PAGE_FORGOT_PASSWORD });
    public static final String RESET_PASSWORD_URL = String.format('TWIST_LWCWrapper?{0}={1}', new List<String> { TWIST_QueryParamKey_CONST.PAGE, TWIST_QueryParamValue_CONST.PAGE_RESET_PASSWORD });
    public static final String REGISTRATION_URL = String.format('TWIST_LWCWrapper?{0}={1}', new List<String> { TWIST_QueryParamKey_CONST.PAGE, TWIST_QueryParamValue_CONST.PAGE_ACCOUNT_CREATION });
    public static final String EXCEPTION_URL = String.format('TWIST_LWCWrapper?{0}={1}', new List<String> { TWIST_QueryParamKey_CONST.PAGE, TWIST_QueryParamValue_CONST.PAGE_ERROR_404 });

    public static final String ACTIVATION_URL = String.format('TWIST_LWCWrapper?{0}={1}', new List<String> { TWIST_QueryParamKey_CONST.PAGE, TWIST_QueryParamValue_CONST.PAGE_ACCOUNT_CREATION });
    public static final String REDIRECTION_URL = String.format('TWIST_SocialMediaBounce?{0}={1}', new List<String> { TWIST_QueryParamKey_CONST.PAGE, TWIST_QueryParamValue_CONST.PAGE_SOCIAL_LOGIN });
    public static final String SOCIAL_LOGIN_URL = String.format('TWIST_SocialMediaBounce?{0}={1}', new List<String> { TWIST_QueryParamKey_CONST.PAGE, TWIST_QueryParamValue_CONST.PAGE_SOCIAL_LOGIN });

    /**
     * @description this method is only used for unit testing
     */
    public static List<String> getConstants() {
        return new List<String> {
            LOGIN_URL,
            ALTERNATIVE_LOGIN_URL,
            FORGOT_PASSWORD_URL,
            RESET_PASSWORD_URL,
            REGISTRATION_URL,
            EXCEPTION_URL,
            ACTIVATION_URL,
            REDIRECTION_URL,
            SOCIAL_LOGIN_URL
        };
    }
}