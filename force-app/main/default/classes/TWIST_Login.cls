/**
* Note: @AuraEnabled with cachebale=false is needed to execute DML statement in a method called from a LWC
* Explaination: https://www.gammone.com/en/programming/how-to-resolve-the-too-many-dml-statements-1-error-in-salesforce
*/

public without sharing class TWIST_Login {

    private static Map<String,Object> componentConfig = new Map<String,Object>();

    private static final String DOMAIN = 'Louis Vuitton Domain';
    private static final String SECURE_DOMAIN = 'Louis Vuitton Secure Domain';
    private static final String STANDARD_MODE = 'LOGIN';
    private static final String KNOWN_MODE = 'KNOWN_LOGIN';
    private static final String ONE_TIME_CONNECTION = 'Show Alternative Login Link';

    @AuraEnabled(cacheable=true)
    public static String getLanguage(String langCountry) {
        if (String.isEmpty(langCountry)) {
            TWIST_Settings__c settings = TWIST_Settings__c.getInstance();
            langCountry = (String) settings.get('Default_Language_Country_Parameter__c');
            return langCountry;
        }
        Language_Mapping_ATG_SF__mdt mapping = [SELECT Salesforce__c FROM Language_Mapping_ATG_SF__mdt WHERE ATG__c =: langCountry LIMIT 1];
        return (String) mapping.Salesforce__c;
    }

    /**
     * @description Replaces the former IDENTITY_Login_CTRL constructor method
     */
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> initComponentConfig(Map<String,Object> queryParams) {
        String origin = (String) queryParams.get(TWIST_QueryParamKey_CONST.ORIGIN);
        String langCountry = (String) queryParams.get(TWIST_QueryParamKey_CONST.LANG_COUNTRY);
        String dispatchCountry = (String) queryParams.get(TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY);
        String domain = (String) queryParams.get(TWIST_QueryParamKey_CONST.DOMAIN);
        
        String cid = (String) queryParams.get(TWIST_QueryParamKey_CONST.CID);
        String accountId = TWIST_Utils.getAccountId(cid);
        String utmCampaign = queryParams.get(TWIST_QueryParamKey_CONST.UTM_CAMPAIGN) != null ? (String)queryParams.get(TWIST_QueryParamKey_CONST.UTM_CAMPAIGN) : null;
        
        getSettings();
        setContext(origin, langCountry, dispatchCountry);
        langCountry = (String) componentConfig.get('langCountry'); // might have been update by previous method
        setForm(langCountry, (String) componentConfig.get('countryLocal'), origin, accountId, utmCampaign);
        setForgotPasswordUrl(langCountry, origin, queryParams);
        setAlternativeLoginUrl(langCountry, origin, queryParams);
        setRegistrationBaseUrl(langCountry, origin);
        setIsRedirectToRegistration(accountId, cid);
        getSocialSettings(langCountry, queryParams);
        writeLogs(queryParams);

        return componentConfig;
    }

    @AuraEnabled(cacheable=false)
    public static Map<String,Object> login(String email, String password, Map<String,Object> queryParams, String language) {
        
                String cid = queryParams.get(TWIST_QueryParamKey_CONST.CID) != null ? (String)queryParams.get(TWIST_QueryParamKey_CONST.CID) : null;
        String accountId;
        if(cid != null){
            accountId = TWIST_Utils.getAccountId(cid);
        }
        try {
            Boolean isFormValid = String.isEmpty(accountId)
                ? validateFormDataWithEmail(email, password, language)
                : validateFormDataWithoutEmail(password, language);
            if (!isFormValid) {
                return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Error_Message_CheckEmailAndPassword', language));
            }

            User user = !String.isEmpty(accountId) ? TWIST_Utils.getUserByAccountId(accountId) : IDENTITY_Utils.getUserByUsername(email);
            if (user == null) {
                return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Error_Message_CheckEmailAndPassword', language));
            }

            Pagereference page = TWIST_LoginService.doSalesforceLogin(
                user.Username,
                password,
                String.valueOf(queryParams.get(TWIST_QueryParamKey_CONST.STATE)),
                String.valueOf(queryParams.get(TWIST_QueryParamKey_CONST.CODE_CHALLENGE)),
                String.valueOf(queryParams.get(TWIST_QueryParamKey_CONST.CLIENT_ID)),
                String.valueOf(queryParams.get(TWIST_QueryParamKey_CONST.REDIRECT_URI))
            );
            if (page == null) {
                return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Error_Message_CheckEmailAndPassword', language));
            }

            //DEPRECATED
            // String lookId = (String) queryParams.get(TWIST_QueryParamKey_CONST.LOOK_ID);
            // if (!String.isEmpty(lookId)) {
            //     IDENTITY_UTILS.shareLook(lookId, user.AccountId, (String) queryParams.get(TWIST_QueryParamKey_CONST.ORIGIN));
            // }
            return TWIST_Utils.buildSuccessResponseObject('redirectUrl', page.getUrl());
        }
        catch(Exception e) {
            new Logs(new Map<String,Object> { 'level' => 'ERROR', 'apexClass' => 'TWIST_Login', 'category' => 'SYSTEM', 'message' => e.getMessage() }); }
        return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_LoginProcessError', language));
    }
    @AuraEnabled(cacheable=false)
    public static Boolean isAlternativeLoginEnabled (String langCountry, String origin){
       
        return origin != 'mylv' ? false : new TWIST_FeatureFlagUtils(langCountry).isAlternativeLoginEnabled();
    }

    @AuraEnabled(cacheable=false)
    public static Boolean isLineButtonEnabled (String langCountry, String origin){

         return origin != 'mylv' ? false : new TWIST_FeatureFlagUtils(langCountry).isLineSocialLoginEnabled();
    }

    /** PRIVATE METHODS *********************************************************************************************** */

    @testVisible
    private static void writeLogs(Map<String,Object> queryParams) {
        TWIST_Utils.writeErrorLogs(queryParams, 'TWIST_Login');
    }

    /**
     * @return true if form is valid, false otherwise
     */
    @testVisible
    private static Boolean validateFormDataWithEmail(String email, String password, String language) {
        return !String.isEmpty(email) && !String.isEmpty(password) && !IDENTITY_Utils.passwordTooLong(password);
    }

    /**
     * @return true if form is valid, false otherwise
     */
    @testVisible
    private static Boolean validateFormDataWithoutEmail(String password, String language) {
        return !String.isEmpty(password) && !IDENTITY_Utils.passwordTooLong(password);
    }

    private static void getSettings() {
        componentConfig.putAll(TWIST_Utils.getLoginFormSettings());
    }

    /**
     * @description get URL parameters and define language, country, origin
     */
    private static void setContext(String origin, String langCountry, String dispatchCountry) {
       
        if(String.isEmpty(origin)){
            origin = (String) componentConfig.get('defaultOriginParameter');
        }
       
        componentConfig.put('googleAnalyticsConfig', IDENTITY_GoogleAnalytics_Utils.getConfig(origin));

        TWIST_Utils.setContext(origin, langCountry, dispatchCountry, componentConfig);

      }

    @testVisible
    private static void setForm(String langCountry, String countryLocal, String origin, String accountId, String utmCampaign) {
        try {
            
            List<IDENTITY_Registration_Form__mdt> metadata = [
                SELECT Field__c, Is_Required__c, Section__c, Is_Hidden__c, Value__c
                FROM IDENTITY_Registration_Form__mdt
                WHERE Context__c =: langCountry AND Form__c IN ('Login', 'Settings')
            ];
            
            Map<String,Map<String,IDENTITY_Registration_Form__mdt>> fields = new Map<String,Map<String,IDENTITY_Registration_Form__mdt>>();
            for(IDENTITY_Registration_Form__mdt field : metadata){
                if(fields.get(field.Section__c) == null){
                    fields.put(field.Section__c, new Map<String,IDENTITY_Registration_Form__mdt>());
                }
                fields.get(field.Section__c).put(field.Field__c, field);
            }
            componentConfig.put('fields', fields);
            String pageMode = String.isEmpty(accountId) ? STANDARD_MODE : KNOWN_MODE; // known Mode: if accountId matches an existing user Id, fill his username
            String callingCode;
            String username;
            String mobile;
            if(pageMode == KNOWN_MODE){
                User[] users = [SELECT Id, Username, TECH_Email__c, TECH_MobilePhone__c , AccountId FROM User WHERE AccountId =: accountId];

                if(!users.IsEmpty()) {
                    User user = users[0];
                    if(!fields.get('Login').get('email').Is_Hidden__c && fields.get('Login').get('mobile_phone').Is_Hidden__c){
                        username = user.TECH_Email__c;
                    }
                    else {
                        username = user.Username;
                        mobile = user.TECH_MobilePhone__c;
                        callingCode = getCallingCode(user);
                    }
                    //componentConfig.put('cid', cid);
                    componentConfig.put('mobile',  TWIST_Utils.getUserIdentifier(utmCampaign, mobile));
                    componentConfig.put('username',   TWIST_Utils.getUserIdentifier(utmCampaign, username));
                    componentConfig.put('showUsernameField', false);
                }
            }
            else {
                callingCode = fields.get('Login').get('mobile_phone').Value__c;
                componentConfig.put('showUsernameField', true);
            }
            componentConfig.put('callingCode', callingCode);
            
            // // Email/Mobile field visibility
            Boolean isEmailFieldVisible = false;
            String emailFieldVisibilityStyle = 'none';
            String mobileFieldVisibilityStyle = 'grid';
            if(
                (!fields.get('Login').get('email').Is_Hidden__c && countryLocal != 'cn')
                ||
                (!fields.get('Login').get('email').Is_Hidden__c && countryLocal == 'cn' && (origin == 'lvapp' || origin == 'lvconnect') )
            ){
                isEmailFieldVisible = true;
                emailFieldVisibilityStyle = 'grid';
            }
            if(!fields.get('Login').get('email').Is_Hidden__c && countryLocal != 'cn'){
                mobileFieldVisibilityStyle = 'none';
            }
            componentConfig.put('isEmailFieldVisible', isEmailFieldVisible);
            componentConfig.put('emailFieldVisibilityStyle', emailFieldVisibilityStyle);
            componentConfig.put('mobileFieldVisibilityStyle', mobileFieldVisibilityStyle);

        } catch (Exception ex) {
              new Logs( new Map<String,Object> {
                'level' => 'ERROR',
                'apexClass' => 'TWIST_Login',
                'category' => 'EVENT',
                'exception_case' => ex,
                'message' => 'TWIST_Login.setForm()',
                'application' => origin
            });
        }
    }

    private static void getSocialSettings(String langCountry, Map<String,Object> queryParams){
        componentConfig.put('socialMediaProviders', TWIST_Utils.getSocialProvidersByLangCountry(langCountry, queryParams));
    }

    @testVisible
    private static String getCallingCode(User user) {
        List<Account> accounts = [SELECT Id, LocalLoginPhone__pc, LoginPhoneCountryCode__pc, MobilePhoneCountryCode__pc FROM Account WHERE Id = :user.AccountId];
        if (!accounts.isEmpty()) {
            Account account = accounts.get(0);
            if(!String.isEmpty(account.LoginPhoneCountryCode__pc)) {
                return account.LoginPhoneCountryCode__pc;
            }
            if(!String.isEmpty(account.MobilePhoneCountryCode__pc)) {
                return account.MobilePhoneCountryCode__pc;
            }
        }
        return null;
    }

    // private static void setPathDispatch(String langCountry) {
    //     Map<String,String> paths = new Map<String,String>();
    //     for(IDENTITY_Paths__mdt path : [SELECT Name__c, Value__c
    //                                     FROM IDENTITY_Paths__mdt
    //                                     WHERE Name__c IN ('Louis Vuitton Domain', 'Dispatch')
    //                                     AND (Context__c =: langCountry OR Context__c = null)]){

    //         paths.put(path.Name__c, path.Value__c);
    //     }

    //     componentConfig.put('pathDispatch', paths.get('Louis Vuitton Domain')+paths.get('Dispatch'));
    // }

    private static void setForgotPasswordUrl(String langCountry, String origin, Map<String,Object> queryParams) {
        componentConfig.put('forgotPasswordUrl', TWIST_Utils.buildTwistPageUrl(TWIST_IdentityPathsMdt_CONST.FORGOT_PASSWORD_FORM, queryParams));
    }

    private static void setAlternativeLoginUrl(String langCountry, String origin, Map<String,Object> queryParams) {
        componentConfig.put('alternativeLoginUrl', TWIST_Utils.buildTwistAlternativeLoginPageUrl(TWIST_IdentityPathsMdt_CONST.ALTERNATIVE_LOGIN_FORM, queryParams));
    }

    private static void setRegistrationBaseUrl(String langCountry, String origin){
        componentConfig.put('registrationBaseUrl', TWIST_Utils.getRegistrationFormBaseUrl(langCountry, origin));
    }
    private static void setIsRedirectToRegistration(String accountId, String cid){
        //accountId != null means there is an exisitng user
        componentConfig.put('isRedirectToRegistration', (cid != null && accountId == null) ? true : false) ;
    }

}