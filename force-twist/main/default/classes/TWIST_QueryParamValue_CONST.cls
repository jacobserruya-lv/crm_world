public with sharing class TWIST_QueryParamValue_CONST {
    
    public static final String PAGE_LOGIN = 'login';
    public static final String PAGE_FORGOT_PASSWORD = 'forgotPassword';
    public static final String PAGE_RESET_PASSWORD = 'resetPassword';
    public static final String PAGE_ACCOUNT_CREATION = 'accountCreation';
    public static final String PAGE_ERROR_404 = 'error404';
    public static final String PAGE_SOCIAL_LOGIN = 'socialLogin';
    public static final String PAGE_ALTERNATIVE_LOGIN = 'alternativeLogin';
    
    public static final String DEV_START_URL_LOGIN = 'login';
    public static final String DEV_START_URL_REGISTRATION = 'registration';
    
    /**
    * @description this method is only used for unit testing
    */
    public static List<String> getConstants() {
        return new List<String> {
            PAGE_LOGIN,
            PAGE_FORGOT_PASSWORD,
            PAGE_RESET_PASSWORD,
            PAGE_ACCOUNT_CREATION,
            PAGE_ERROR_404,
            PAGE_SOCIAL_LOGIN,
            DEV_START_URL_LOGIN,
            DEV_START_URL_REGISTRATION,
            PAGE_ALTERNATIVE_LOGIN
        };
    }
}