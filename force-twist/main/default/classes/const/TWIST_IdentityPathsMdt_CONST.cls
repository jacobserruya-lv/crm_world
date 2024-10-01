public with sharing class TWIST_IdentityPathsMdt_CONST {
    
    public static final String ALTERNATIVE_LOGIN_FORM = 'Alternative Login Form Path';
    public static final String REGISTRATION_FORM = 'Registration Form Path';
    public static final String LOGIN_FORM = 'Login Form Path';
    public static final String FORGOT_PASSWORD_FORM = 'Forgot Password Form Path';
    public static final String RESET_PASSWORD_FORM = 'Reset Password Form Path';
    public static final String ERROR404 = 'Error 404 Page Path';
    public static final String LVAPP_URL_SCHEME = 'LVAPP URL Scheme';
    
    /**
     * @description this method is only used for unit testing
     */
    public static List<String> getConstants() {
        return new List<String> {
            ALTERNATIVE_LOGIN_FORM,
            REGISTRATION_FORM,
            LOGIN_FORM,
            FORGOT_PASSWORD_FORM,
            RESET_PASSWORD_FORM,
            ERROR404,
            LVAPP_URL_SCHEME
        };
    }

}
