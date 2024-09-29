public without sharing class TWIST_Utils {
    
    public static PageReference buildPageReference(String partialURL, Map<String,String> queryParams) {
        PageReference page = new Pagereference(partialURL);
        for (String key: queryParams.keySet()) {
            page.getParameters().put(key.trim(), queryParams.get(key).trim());
        }
        return page.setRedirect(true);
    }
    
    public static Map<String,Object> getLoginFormSettings() {
        Map<String,Object> result= new Map<String,Object>();
        Map<String,Object> settings = getIdentitySettings(new List<String> {
            'Password_Maxlength__c',
            'Default_Origin_Parameter__c',
            'Default_Language_Country_Parameter__c'
        });
        result.put('passwordMaxlength', settings.get('Password_Maxlength__c'));
        result.put('defaultOriginParameter', settings.get('Default_Origin_Parameter__c'));
        result.put('defaultLangCountryParameter', settings.get('Default_Language_Country_Parameter__c'));
        settings = getRegistrationSettings(new List<String> { 'Tealium_Environment__c' });
        result.put('tealiumEnv', settings.get('Tealium_Environment__c'));
        settings = getTwistSettings(new List<String> { 'Allow_Plus_Symbol_In_Email__c' });
        result.put('AllowPlusSymbolInEmail', (settings.get('Allow_Plus_Symbol_In_Email__c') == true));
        return result;
    }
    
    public static Map<String,Object> getForgotPasswordFormSettings(Map<String,Object> queryParams) {
        Map<String,Object> result= new Map<String,Object>();
        Map<String,Object> settings = getTwistSettings(new List<String> { 'Allow_Plus_Symbol_In_Email__c' });
        result.put('AllowPlusSymbolInEmail', (settings.get('Allow_Plus_Symbol_In_Email__c') == true));
        result.put('loginUrl', buildTwistPageUrl(TWIST_IdentityPathsMdt_CONST.LOGIN_FORM, queryParams));
        result.put('registrationUrl', buildTwistPageUrl(TWIST_IdentityPathsMdt_CONST.REGISTRATION_FORM, queryParams));
        return result;
    }
    
    public static Map<String,Object> getAccountSettings(){
        Map<String,Object> result= new Map<String,Object>();
        Map<String,Object> settings = getIdentitySettings(new List<String> {
            'Password_Maxlength__c',
            'Default_Origin_Parameter__c',
            'Default_Language_Country_Parameter__c'
        });
        result.put('passwordMaxlength', settings.get('Password_Maxlength__c'));
        result.put('defaultOriginParameter', settings.get('Default_Origin_Parameter__c'));
        result.put('defaultLangCountryParameter', settings.get('Default_Language_Country_Parameter__c'));
        
        Map<String,Object> twistSettings = getTwistSettings(new List<String> { 'Allow_Plus_Symbol_In_Email__c' });
        result.put('AllowPlusSymbolInEmail', (twistSettings.get('Allow_Plus_Symbol_In_Email__c') == true));
        
        settings = getRegistrationSettings(new List<String> {
            'Tealium_Environment__c',
            'Code_Validity_Time__c',
            'Sent_Email_Limit__c',
            'Sent_SMS_Limit__c'
        });
        result.put('tealiumEnv', settings.get('Tealium_Environment__c'));
        result.put('CodeValidityTime', settings.get('Code_Validity_Time__c'));
        result.put('SentEmailLimit', settings.get('Sent_Email_Limit__c'));
        result.put('SentSMSLimit', settings.get('Sent_SMS_Limit__c'));
        return result;
    }
    
    /*
    * @description Get LVApp url scheme for redirection
    * @returns {String}
    */
    public static String getLVappUrlScheme(){
        String path;
        IDENTITY_Paths__mdt[] paths = [SELECT Value__c FROM IDENTITY_Paths__mdt WHERE Name__c = 'LVAPP URL Scheme' LIMIT 1];
        if(!paths.IsEmpty()) {
            path = String.valueOf(paths[0].Value__c);
        }
        return path;
    }
    
    public static Map<String,Object> buildSuccessResponseObject() {
        return buildResponseObject(true, null);
    }
    
    public static Map<String,Object> buildSuccessResponseObject(String responseKey, Object responseValue) {
        return buildResponseObject(true, new Map<String,Object> { responseKey => responseValue });
    }
    
    public static Map<String,Object> buildSuccessResponseObject(Map<String,Object> response) {
        return buildResponseObject(true, response);
    }
    
    public static Map<String,Object> buildFailureResponseObject() {
        return buildResponseObject(false, null);
    }
    
    public static Map<String,Object> buildFailureResponseObject(String responseKey, Object responseValue) {
        return buildResponseObject(false, new Map<String,Object> { responseKey => responseValue });
    }
    
    public static Boolean isMapResponseOfTypeFailureResponseObject(Map<String,Object> m) {
        return m.containsKey('success')
        && Boolean.valueOf(m.get('success')) == false
        && m.containsKey('message')
        && String.isNotEmpty(String.valueOf('message'));
    }
    
    public static Boolean isValidEmail(String email) {
        Map<String,Object> settings = getTwistSettings(new List<String> { 'Allow_Plus_Symbol_In_Email__c' });
        String emailRegex = settings.get('Allow_Plus_Symbol_In_Email__c') == true ? '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$' : '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';// source: http://www.regular-expressions.info/email.html
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);
        return MyMatcher.matches();
    }
    
    public static Map<String,String> getUserByEmail(String email) {
        if(!String.isEmpty(email)){
            List<User> users = [
                SELECT Id, Username, LanguageLocaleKey, HasVerifiedEmail__c, LocaleSidKey, Title, LastName, FirstName, Country__c, MobilePhone, IsActive
                FROM User
                WHERE Is_Identity_User__c = true AND (Username = :email OR TECH_Email__c = :email)
                LIMIT 1
            ];
            if(!users.isEmpty()){
                return convertNullToEmptyValUser(users[0]);
            }
        }
        return null;
    }
    public static List<Account> findAccountsByEmail(String email) {
        return String.isBlank(email)
        ? new List<Account>() : [
        SELECT Id, LastName,FirstName,PersonContactId, PersonMobilePhone, LocalMobilePhone__pc,Title__pc,
        PrimaryCountry__pc, SPO_Country_code__pc,LoginPhone__pc,LocalLoginPhone__pc,PersonEmail,
        LoginPhoneCallingCode__pc, HomeAddressCountryCode__pc,salutation,MobilePhoneCountryCallingCode__pc
        FROM Account
        WHERE PersonEmail = :email];
    }
    /*
    *** DESCRIPTION Create a new user without sending email to the user and set its password if not null
    *** RETURN      External User TWIST
    */
    public static user createExternalMyLVUser(Account acc, String password) {
        Account Client = IDENTITY_Utils.setupAccount(acc);
        CountryLanguage__c locales = IDENTITY_Utils.getLocales(client.SPO_Country_Code__pc);
        User identityUser = new User(
        
        // Identity Fields
        ProfileId = IDENTITY_Settings__c.getInstance().ProfileId__c,
        ContactId = client.personContactId,
        
        // Identifier Fields
        Username = IDENTITY_Utils.getUsername(client.PersonEmail, client.LoginPhone__pc),
        Email = IDENTITY_Utils.getUsername(client.PersonEmail, client.LoginPhone__pc),
        MobilePhone = client.LoginPhone__pc,
        
        // Contact Fields
        Title = client.Salutation,
        LastName = client.LastName,
        FirstName = client.FirstName,
        Alias = IDENTITY_Utils.getAlias(client.FirstName, client.LastName),
        
        // Local Fields
        Country__c = client.PrimaryCountry__pc,
        EmailEncodingKey = 'UTF-8',
        LanguageLocaleKey = locales.Salesforce_Language__c,
        LocaleSidKey = locales.Salesforce_Locale__c,
        TimeZoneSidKey = 'Europe/Paris'
        );
        // Don't send any welcome email
        Database.DMLOptions dlo = new Database.DMLOptions();
        dlo.EmailHeader.triggerUserEmail = false;
        dlo.EmailHeader.triggerOtherEmail = false;
        identityUser.setOptions(dlo);
        // Set Password
        if(String.isNotBlank(password)){
            Database.Insert(identityUser) ;
            System.setPassword(identityUser.Id, password);
        }
        
        return identityUser;
    }
    public static Map<String,String> convertUserToMap(User usExt){
        return convertNullToEmptyValUser(usExt);
    }
    public static Boolean canFindMyLVUserWithEmail(String email) {
        return (getUserByEmail(email) != null);
    }
    
    public static void activateUser(Id userId) {
        List<User> users = [SELECT IsActive FROM User WHERE Id =: userId LIMIT 1];
        if(!users.isEmpty() && users[0].get('IsActive') == false) {
            User user = users[0];
            user.IsActive = true;
            update user;
        }
    }
    
    public static Boolean doPasswordsMatch(String password, String confirmPassword) {
        return !String.isEmpty(password) && !String.isEmpty(confirmPassword) && password.equals(confirmPassword);
    }
    
    public static Boolean doesPasswordMatchStringPattern(String password) { // JSI recopier les tests U de la méthode invalidPassword() dans IDENTITY_Utils_TEST
        return isPasswordLongEnough(password)
        && hasUpperCharacter(password)
        && hasLowerCharacter(password)
        && hasNumberCharacter(password)
        && hasSpecialCharacter(password);
    }
    
    public static Boolean isPasswordTooLong(String password) {
        return password.length() > Integer.valueOf(TWIST_Settings__c.getInstance().Password_Maxlength__c);
    }
    
    public static Boolean doesPasswordContainUserFirstNameOrLastName(String password, Map<String,String> user) {
        return  password.contains(user.get('FirstName')) || password.contains(user.get('LastName'));
    }
    
    public static String buildForgotPasswordFormUrl(String langCountry, String origin, String dispatchCountry) {
        String url =  buildTwistPageUrl(langCountry, origin, TWIST_IdentityPathsMdt_CONST.FORGOT_PASSWORD_FORM);
        if(!String.isEmpty(dispatchCountry)){
            url = url+'?dispatchCountry='+dispatchCountry;
        }
        return url;
    }
    
    public static String buildTwistPageUrl(String pageName, Map<String,Object> queryParams) {



        String url = String.format('{0}{1}/{2}/{3}', new List<String> {
            TWIST_UrlUtils.getCommunityUrl(true),
            (String) queryParams.get(TWIST_QueryParamKey_CONST.LANG_COUNTRY),
            (String) queryParams.get(TWIST_QueryParamKey_CONST.ORIGIN),
            getPageKey(pageName)
        });
        return url + buildQueryParamsString(queryParams);
    }

    public static String buildTwistAlternativeLoginPageUrl(String pageName, Map<String,Object> queryParams) {
        String url = String.format('{0}{1}/{2}/{3}', new List<String> {
            TWIST_Settings__c.getInstance().Community_URL__c,
            (String) queryParams.get(TWIST_QueryParamKey_CONST.LANG_COUNTRY),
            (String) queryParams.get(TWIST_QueryParamKey_CONST.ORIGIN),
            getPageKey(pageName)
        });
        return url + buildQueryParamsString(queryParams);
    }
    
    public static String buildTwistPageUrl(String pageName, Map<String,Object> queryParams, List<String> queryParamsToRemove) {
        if (queryParamsToRemove != null && !queryParamsToRemove.isEmpty()) {
            for (String key: queryParamsToRemove) {
                queryParams.remove(key);
            }
        }
        return buildTwistPageUrl(pageName, queryParams);
    }
    
    public static String getLoginFormBaseUrl(String langCountry, String origin) {
        return buildTwistPageUrl(langCountry, origin, TWIST_IdentityPathsMdt_CONST.LOGIN_FORM);
    }
    
    public static String getRegistrationFormBaseUrl(String langCountry, String origin) {
        return buildTwistPageUrl(langCountry, origin, TWIST_IdentityPathsMdt_CONST.REGISTRATION_FORM);
    }
    
    public static Map<String,String> getResetPasswordEmailSettings() {
        return !Test.isRunningTest() ? ThirdParty_Utils.getSettings('TWIST_SFMC_Reset_Password_Email') : new Map<String,String> {
            'definitionKey' => 'dummy-definition-key',
            'endpoint' => 'https://dummy-sfmc-api.net',
            'client_id' => 'dummy-client-id',
            'client_secret' => 'dummy-client-secret'
        };
    }
    
    public static Map<String,String> getAccountCreationdEmailSettings() {
        return !Test.isRunningTest() ? ThirdParty_Utils.getSettings('TWIST_SFMC_Account_Creation_Email') : new Map<String,String> {
            'definitionKey' => 'dummy-definition-key',
            'endpoint' => 'https://dummy-sfmc-api.net',
            'client_id' => 'dummy-client-id',
            'client_secret' => 'dummy-client-secret'
        };
    }
    
    public static String getResetPasswordUrl(String langCountry, String dispatchCountry, String origin, String token) {
        String resetPasswordPath = getPathFromPattern(TWIST_IdentityPathsMdt_CONST.RESET_PASSWORD_FORM, langCountry, dispatchCountry, origin);
        String url = String.format(
            '{0}{1}?token={2}',
            new List<String> {
                TWIST_UrlUtils.getLvSiteBaseUrl(langCountry),
                resetPasswordPath,
                token
            }
        );
        if(!String.isEmpty(dispatchCountry)){
            url += '&dispatchCountry=' + dispatchCountry;
        }
        return url;
    }
    
    public static String getPathFromPattern(String pathPattern, String langCountry, String dispatchCountry, String origin) {
        TWIST_IDENTITY_Paths__mdt path = [SELECT Name__c, Value__c FROM TWIST_IDENTITY_Paths__mdt WHERE Name__c =: pathPattern LIMIT 1];
        String value = path.Value__c.replace('lang_country', langCountry);
        TWIST_Settings__c  settings = TWIST_Settings__c.getInstance();
        List<String> originsToReplaceList = new List<String>();
        originsToReplaceList.addAll(settings.origins_to_replace__c.split(';'));
        String defaultOrigin = settings.target_origin__c;
        if(settings != null && settings.origins_to_replace__c != null && settings.target_origin__c != null && originsToReplaceList.contains(origin)){
        	return value.replace('origin', defaultOrigin);
        }
        else {
            return value.replace('origin', origin);
       	}
    }
    
    public static String buildGetAuthorizationCodeUrl(String state, String codeChallenge, String clientId, String redirectUri) {
        return String.format(
        '/services/oauth2/authorize?response_type=code&state={0}&code_challenge={1}&client_id={2}&redirect_uri={3}',
        new List<String> { state, codeChallenge, clientId, redirectUri }
        );
    }
    
    //this method has been replaced by the getLangCountryISO2CountryCode  if it's and no other use is found for this method it must be deleted
    public static String getUserISO2CountryCode(String userCountry) {
        List<Country__c> country = [SELECT Name, Iso2Code__c FROM Country__c WHERE Name =: userCountry LIMIT 1];
        
        String iso2Code = 'US';
        if(!country.IsEmpty() && isValidCountryCode(String.valueOf(country[0].Iso2Code__c))) {
            iso2Code = String.valueOf(country[0].Iso2Code__c);
        }
        return iso2Code;
    }
    
    public static String getLangCountryISO2CountryCode(String langCountry) {
        String iso2Code = 'US';
        if(String.IsNotBlank(langCountry)){
            String countryLocal = langCountry.substringAfter('-');
            if(isValidCountryCode(countryLocal)) {
                iso2Code = countryLocal;
            }
        }
        return iso2Code;
    }
    
    public static void setContext(String origin, String langCountry, String dispatchCountry ,Map<String,Object> componentConfig){
        if(String.isEmpty(langCountry)){
            langCountry = (String) componentConfig.get('defaultLangCountryParameter');
        }
        if(String.isEmpty(origin)){
            origin = (String) componentConfig.get('defaultOriginParameter');
        }
        Language_Mapping_ATG_SF__mdt languageMappingATG = [SELECT Salesforce__c ,Meta_Language__c FROM Language_Mapping_ATG_SF__mdt WHERE ATG__c =: langCountry LIMIT 1];
        componentConfig.put(TWIST_QueryParamKey_CONST.LANG_COUNTRY, langCountry);
        componentConfig.put(TWIST_QueryParamKey_CONST.COUNTRY_LOCAL, langCountry.substringAfter('-'));
        componentConfig.put(TWIST_QueryParamKey_CONST.META_LANGUAGE, languageMappingATG.Meta_Language__c);
        componentConfig.put(TWIST_QueryParamKey_CONST.SF_LANGUAGE, languageMappingATG.Salesforce__c );
        componentConfig.put(TWIST_QueryParamKey_CONST.ORIGIN, origin);
        componentConfig.put(TWIST_QueryParamKey_CONST.CUSTOMER_SERVICE_PHONE_NUMBER, IDENTITY_Utils.getClientServicePhoneNumber(langCountry, dispatchCountry));
    }
    
    public static Integer countVerificationCodes(String email, String phoneNumber) {
        if (String.isEmpty(email) && String.isEmpty(phoneNumber)) {
            return 0;//through error maybe ?
        }
        try {
            String recordId  = !String.isEmpty(email) ? email :  phoneNumber ;
            DateTime before24Hours = System.Now().addHours(-24);
            List<AggregateResult> aggregateResults = [SELECT COUNT(Id) totalRequests FROM Registration_Code_Verification_Request__c WHERE Record_Id__c =: recordId AND CreatedDate >: before24Hours];
            return (Integer) aggregateResults[0]?.get('totalRequests');
            
        }
        catch(Exception e) {
            System.debug('> Error in method TWIST_Utils.countVerificationCodes(): ' + e.getMessage());
        }
        return 0;
        
    }
    
    public static User getUserByAccountId(String accountId) {
        try {
            User[] users = [SELECT Id, Username, AccountId, IsActive FROM User WHERE AccountId = :accountId LIMIT 1];
            return users.IsEmpty() ? null : users[0];
        }
        catch(Exception e) {
            return null;
        }
    }
    
    public static User getUserByUsername(String username) {
        List<User> users = new List<User>();
        if(!String.isEmpty(username)){
            users = [
            SELECT Id, Username, AccountId, IsActive
            FROM User
            WHERE (TECH_MobilePHone__c =: username OR Username =: username OR TECH_Email__c =: username) AND (IsActive = true OR IsActive = false) AND Is_Identity_User__c = true
            LIMIT 1
            ];
        }
        if(users.isEmpty()) {
            return null;
        }
        return users[0];
    }
    
    public static void activateUser(User user) {
        if (user != null && !user.IsActive) {
            IDENTITY_UTILS.activeUser(user.Id);
        }
    }
    
    public static void writeErrorLogs(Map<String,Object> queryParams, String className) {
        String origin = (String) queryParams.get(TWIST_QueryParamKey_CONST.ORIGIN);
        String defaultCountryLangLog = (String) queryParams.get(TWIST_QueryParamKey_CONST.UPDATED_TO_DEFAULT_LANG_COUNTRY);
        
        if (defaultCountryLangLog != null && Boolean.valueOf(defaultCountryLangLog)) {
            new Logs( new Map<String,Object> {
                'level' => 'ERROR',
                'apexClass' => className,
                'category' => 'EVENT',
                'message' => Label.IDENTITY_LOG_Lang_Country_Parameter,
                'recordId' => defaultCountryLangLog,
                'application' => origin
            });
        }
        
        String log404 = (String) queryParams.get(TWIST_QueryParamKey_CONST.ERROR_404);
        if (log404 != null && Boolean.valueOf(log404)) {
            new Logs( new Map<String,Object> {
                'level' => 'ERROR',
                'apexClass' => className,
                'category' => 'EVENT',
                'status_code' => Label.IDENTITY_LOG_404,
                'message' => String.isNotEmpty(Site.getErrorDescription()) ? Site.getErrorDescription() : Label.IDENTITY_LOG_404,
                'application' => origin
            });
        }
    }
    
    public static Object getTwistSetting(String field) {
        return getTwistSettings(new List<String> { field }).get(field);
    }
    
    public static Map<String,Object> getTwistSettings(List<String> fields) {
        Map<String,Object> result = new Map<String,Object>();
        try {
            TWIST_Settings__c settings = TWIST_Settings__c.getInstance();
            for (String field: fields) {
                result.put(field, settings.get(field));
            }
        }
        catch(Exception e) {
            System.debug('> Error in method TWIST_Utils.getTwistSettings(): ' + e.getMessage());
        }
        return result;
    }
    
    public static List<String> getOfferCodeValues(List<String> picklistValuesOfferCodeString){
        Schema.DescribeFieldResult XXPR_OfferCode = Exclusive_Experience__c.Offer_Code__c.getDescribe();
        Schema.sObjectField fieldOfferCode = XXPR_OfferCode.getSObjectField();
        List<PicklistEntry> picklistValuesOfferCode = fieldOfferCode.getDescribe().getPicklistValues();
        
        for(PicklistEntry pe : picklistValuesOfferCode){
            picklistValuesOfferCodeString.add(pe.getValue());
        }
        return picklistValuesOfferCodeString;
    }
    
    public static Boolean isUtmCampaignValid(String utmCampaign){
        List<String> picklistValuesOfferCodeString = new List<String>();
        getOfferCodeValues(picklistValuesOfferCodeString);
        return utmCampaign != null && picklistValuesOfferCodeString.contains(utmCampaign);
    }
    
    public static Boolean doRedirectionToLVapp(String userAgent, Map<String,String> params, Boolean isUtmCampaignValid){
        return isUtmCampaignValid
        && isExcludeOfferWebOnly(params.get('utm_campaign'))
        && isValidParamsForExclusiveOffer(params)
        && isMobileDevice(userAgent);
    }
    
    public static Boolean isMobileDevice(String userAgent) {
        return userAgent.contains('Android') || userAgent.contains('webOS') || userAgent.contains('iPhone') || userAgent.contains('iPad') || userAgent.contains('BlackBerry') || userAgent.contains('Windows Phone');
    }
    
    public static String getAccountId(String cid){
        Map<String, Object> cidMap = new Map<String, Object>();
        if (!String.isEmpty(cid)){
            cidMap = TWIST_RegistrationUtils.extractAccountId(cid);
            String accountId = cidMap.containsKey('accountId') ? cidMap.get('accountId').toString() : null;
            List<Account> accounts = [SELECT Id, PersonEmail, LoginPhone__pc FROM Account WHERE Id =: accountId];
            if (!accounts.isEmpty()) {
                accountId = accounts[0].Id;
                List<User> users = IDENTITY_Utils.getUsers(accounts[0]);
                if (!users.isEmpty()) {
                    return users[0].AccountId;
                }
            }
        }
        return null;
    }
    
    public static String getUserIdentifier(String utmCampaign, String identifier){
        return isUtmCampaignValid(utmCampaign) ? identifier : truncateIdentifier(identifier);
    }
    
    /*
    * @description Truncate Username
    * @param {String} username
    * @returns {String}
    */
    public static String truncateIdentifier(String identifier) {
        return String.isNotEmpty(identifier) && identifier.length() >= 3 ? identifier.substring(0,3)+'***' : '';
    }
    
    @future
    public static void updateUserVerifiedEmail(String username) {
        try{
            if(hasUserVerifiedEmail(username)){
                List<User> users = [SELECT id, UserName, HasVerifiedEmail__c from user WHERE UserName =: userName];
                if(!users.isEmpty()){
                    User user = users[0];
                    if(user.HasVerifiedEmail__c == false){
                        user.HasVerifiedEmail__c = true;
                        update user;
                    }
                }
            }
        }
        catch(Exception e) {
            System.debug('> Error in method TWIST_Utils.updateUserVerifiedEmail(): ' + e.getMessage());
        }
    }
    
    public static Boolean hasUserVerifiedEmail(String username) {
        List<TwoFactorMethodsInfo> twoFactorMethodsInfoList = [SELECT HasUserVerifiedEmailAddress FROM 	TwoFactorMethodsInfo WHERE 	User.Username =: username];
        if(!twoFactorMethodsInfoList.isEmpty()){
            return twoFactorMethodsInfoList[0].HasUserVerifiedEmailAddress;
        }
        return false;
    }
    
    public static Map<String,String> getPaths(String lang_country, String origin, String dispatch_country){
        Map<String,String> paths = new Map<String,String>();
        
        // GET ALL PATHS
        for(TWIST_IDENTITY_Paths__mdt path : [
            SELECT Name__c, Value__c, Context__c, Application__c
            FROM TWIST_IDENTITY_Paths__mdt
            WHERE (Context__c =: lang_country OR Context__c = null)
            AND (Application__c =: origin OR Application__c = null)
            ORDER BY Application__c, Context__c ASC NULLS FIRST]
        ){
            String value = path.Value__c;
            value = value.replace('lang_country', lang_country);
            value = value.replace('origin', origin);
            
            if(!String.isEmpty(dispatch_country)){
                value = value.replaceAll('\\[dispatchCountry=dispatch_country\\]', 'dispatchCountry=dispatch_country');
                value = value.replace('dispatch_country', dispatch_country);
            }
            else {
                value = value.replaceAll('&\\[dispatchCountry=dispatch_country\\]', '');
                value = value.replaceAll('\\[dispatchCountry=dispatch_country\\]', '');
            }
            
            paths.put(path.Name__c, value);
        }
        
        return paths;
    }
    
    public static void blockUser(Map<String, Object> setting, String email, String value, String langCountry) {
        Integer legalAge = (Integer)setting.get('legalAge');
        Integer timeBlock = (Integer)setting.get('timeBlockValue');
        String countyLanguage = (String)setting.get('langCountry');
        String errorMessage;
        if(isMinimumAge(value, legalAge) && countyLanguage == langCountry) {
            try {
                errorMessage = TWIST_i18nTranslations.translateSingleLabel('Twist_Account_Creation_Wrong_birthdate', TWIST_login.getLanguage(langCountry));
                throw new CustomException(errorMessage);
            } catch(Exception e){
                TwistCacheManager__c obj = new TwistCacheManager__c();
                obj.Key__c = email;
                obj.LangCountry__c = langCountry;
                obj.TTL__c = timeBlock;
                obj.Type__c = 'AGE_RESTRICTION';
                obj.Value__c = value;
                insert obj;
                throw new CustomException(errorMessage);
            }
        }
    }

    public static Map<String,String> getSocialProvidersByLangCountry(String langCountry, Map<String,Object> queryParams) {
        Map<String,String> paths = TWIST_Utils.getPaths(langCountry, 'mylv', '');
        Map<String,String> result = new Map<String,String>();
        List<TWIST_Social_Media__mdt> socialMediaList = [
            SELECT Auth_Provider_Name__c, Page_Key__c
            FROM TWIST_Social_Media__mdt
            WHERE Lang_Country__c = :langCountry
            ];
        for (TWIST_Social_Media__mdt socialMedia : socialMediaList) {
            String socialMediaName = socialMedia.Auth_Provider_Name__c;
            String socialMediaType = socialMedia.Page_Key__c;
            queryParams.put('redirect_url', EncodingUtil.urlEncode(paths.get(TWIST_IdentityPathsMdt_CONST.LV_SECURE_DOMAIN) + paths.get(TWIST_IdentityPathsMdt_CONST.SOCIAL_LOGIN_SUCCES_PATH) + socialMediaType, 'UTF-8'));
            queryParams.put('error_redirect_url', EncodingUtil.urlEncode(paths.get(TWIST_IdentityPathsMdt_CONST.LV_API_DOMAIN) + paths.get(TWIST_IdentityPathsMdt_CONST.SOCIAL_LOGIN_ERROR_PATH) + socialMediaType, 'UTF-8'));
            result.put(socialMediaName, buildTwistPageUrl(socialMediaName, queryParams));
        }
        return result;
    }

    public static String getSocialProviderTypeByProviderId(String ProviderId){
        String socialProviderType;
        AuthProvider[] authProvider = [SELECT DeveloperName FROM AuthProvider WHERE Id = :ProviderId LIMIT 1];
        if(!authProvider.IsEmpty()) {
            String authProviderName = String.valueOf(authProvider[0].DeveloperName);
            socialProviderType = getPageKey(authProviderName);
        }
        return socialProviderType;
    }

    public static Map<String, String> getSplittedPhoneFromFullPhone(String fullPhone) {
        List<String> splittedPhoneNumber = fullPhone.replaceAll('[+-]','').split(' ');
        if(splittedPhoneNumber.size()>1){
            return new Map<String,String> {
                'callingCode' 	            => splittedPhoneNumber[0],
                'iso2Code' 	                => getIso2CodeForCallingCode(Integer.valueOf(splittedPhoneNumber[0])),
                'internationalMobilePhone'  => '+' + splittedPhoneNumber[0] + splittedPhoneNumber[1],
                'mobilePhone' 			    => '0' + splittedPhoneNumber[1]
            };
        }
        return null;
    }
    
    public static String genderToSalutation(String gender) {
        Map<String, String> genderToSalutation = new Map<String, String> {
            'male' => '02',
            'female' => '04',
            'other' => '02'
        };
        gender = gender.toLowerCase();
        return genderToSalutation.containsKey(gender) ? genderToSalutation.get(gender) : null ;
    }
    
    public static Boolean isUserBlocked(String email, String langCountry) {
        Boolean isblocked = false;
        List<TwistCacheManager__c> userBlocked = [SELECT Key__c, LangCountry__c, TTL__c, Value__c, Type__c, CreatedDate FROM TwistCacheManager__c WHERE Key__c =: email AND LangCountry__c =: langCountry LIMIT 1];
        if(!userBlocked.isEmpty()){
            String getKey = (String)userBlocked[0].Key__c;
            String getLangCountry = (String)userBlocked[0].LangCountry__c;
            Integer getTtl = (Integer)userBlocked[0].TTL__c;
            DateTime creationDate = (DateTime)userBlocked[0].CreatedDate;
            DateTime currentDate = datetime.now();
            DateTime addedHour = creationDate.addhours(getTtl);
            if(getKey == email && getLangCountry == langCountry && currentDate < addedHour){
                isblocked = true;
            }
         }
        return isblocked;
    }
     
    public static Boolean isMinimumAge(String birthdate, Integer legalAge){
         if(birthdate != null){
            List<String> partsBirthdate = birthdate.split('-');
            Date birthdateObject = Date.newInstance(Integer.valueOf(partsBirthdate[0]), Integer.valueOf(partsBirthdate[1]), Integer.valueOf(partsBirthdate[2]));
            return birthdateObject.addYears(legalAge) > Date.today();
        }
        return false;
    }

    /**
     * @param {String} stringDate (YYYY-MM-DD format)
     */
    public static Boolean isFutureDate(String stringDate) {
        try {
            if (String.isNotEmpty(stringDate)) {
                List<String> parts = stringDate.split('-');
                Date inputDate = Date.newInstance(Integer.valueOf(parts[0]), Integer.valueOf(parts[1]), Integer.valueOf(parts[2]));
                return inputDate >= Date.today();
            }
        }
        catch (Exception e) {
            System.debug(e.getMessage());
        }
        return false;
    }

    public static string createRandomPassword(){

        String randomVal = '';
        String upperCaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        String lowerCaseChars = 'abcdefghijklmnopqrstuvwxyz';
        String specialChars = '*[!#$&()*+,\\-.:;<=>?@\\[\\]^_{|}~]';
        String digit = '0123456789';
        String allChars = upperCaseChars + lowerCaseChars + specialChars + digit;
        Integer maxLength = Integer.valueOf(IDENTITY_Settings__c.getInstance().Password_Maxlength__c);
        randomVal += StringUtils.generateRandomString(1, upperCaseChars);
        randomVal += StringUtils.generateRandomString(1, lowerCaseChars);
        randomVal += StringUtils.generateRandomString(1, digit);
        randomVal += StringUtils.generateRandomString(1, specialChars);
        randomVal += StringUtils.generateRandomString(maxLength - 4, allChars);
        return shuffleString(randomVal);
    }

    /* PRIVATE METHODS ***************************************************************************************/
    
    @TestVisible
    private static String getIso2CodeForCallingCode(Integer callingCode) {
        List<CountryMapping__mdt> countryMappingList = [SELECT Iso2Code__c FROM CountryMapping__mdt WHERE Calling_Code__c = : callingCode];
        if(!countryMappingList.isEmpty()){
            CountryMapping__mdt countryMapping = countryMappingList[0];
            return countryMapping.Iso2Code__c;
        }
        return null;
    }
    
    private static Boolean isValidCountryCode(String countryCode) {
        return countryCode != null && countryCode.length() == 2;
    }
    
    //convert null values to empty strings ''
    private static Map<String,String> convertNullToEmptyValUser(User user) {
        Map<String,String> result = new Map<String,String>();
        Set<String> userPropertiesToReturn = new Set<String> {'Id', 'LanguageLocaleKey', 'HasVerifiedEmail__c', 'LocaleSidKey', 'FirstName', 'LastName', 'Country__c', 'Title', 'MobilePhone', 'Username'};
        
        Map<String,Object> mapUserObject = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(user));
        Set<String> userObjectKeyset = mapUserObject.keySet();
        String getKey = '';

        for (String key: userPropertiesToReturn) {
            if(key == 'HasVerifiedEmail__c') {
                if (user.get(key) == true){
                    getKey = 'true'; 
                }
                else{ 
                    getKey = 'false';
                }
            } else {
                getKey = (String) user.get(key);
            }
            
            result.put(
                key,
                userObjectKeyset.contains(key) && user.get(key) != null ? getKey : ''
            );
        }
            
        // Specific cases
        result.put('IsActive', userObjectKeyset.contains('IsActive') && user.IsActive == true ? 'true' : 'false');
        
        return result;
    }
    
    private static Map<String,Object> getIdentitySettings(List<String> fields) {
        Map<String,Object> result = new Map<String,Object>();
        try {
            IDENTITY_Settings__c settings = IDENTITY_Settings__c.getInstance();
            for (String field: fields) {
                result.put(field, settings.get(field));
            }
        }
        catch(Exception e) {
            System.debug('> Error in method TWIST_Utils.getIdentitySettings(): ' + e.getMessage());
        }
        return result;
    }
    
    private static Map<String,Object> getRegistrationSettings(List<String> fields) {
        Map<String,Object> result = new Map<String,Object>();
        try {
            TWIST_Registration_Form_Settings__c settings = TWIST_Registration_Form_Settings__c.getInstance();
            for (String field: fields) {
                result.put(field, settings.get(field));
            }
        }
        catch(Exception e) {
            System.debug('> Error in method TWIST_Utils.getRegistrationSettings(): ' + e.getMessage());
        }
        return result;
    }
    
    private static Map<String,Object> buildResponseObject(Boolean responseSuccess, Map<String,Object> responseParams) {
        Map<String,Object> result = new Map<String,Object> { 'success' => responseSuccess };
        if (responseParams != null && !responseParams.isEmpty()) {
            result.putAll(responseParams);
        }
        return result;
    }
    
    private static Boolean isPasswordLongEnough(String password) {
        return !String.isEmpty(password) && password.length() >= 8;
    }
    
    private static Boolean hasUpperCharacter(String str) {
        return doesStringMatchRegexp('(?=.*[A-Z])', str);
    }
    
    private static Boolean hasLowerCharacter(String str) {
        return doesStringMatchRegexp('(?=.*[a-z])', str);
    }
    
    private static Boolean hasNumberCharacter(String str) {
        return doesStringMatchRegexp('(?=.*[0-9])', str);
    }
    
    private static Boolean hasSpecialCharacter(String str) {
        return doesStringMatchRegexp('(?=.*[!#$&()*+,\\-.:;<=>?@\\[\\]^_{|}~])', str);
    }
    
    private static Boolean doesStringMatchRegexp(String regexp, String str) {
        return Pattern.compile(regexp).matcher(str).find();
    }
    
    private static String buildTwistPageUrl(String langCountry, String origin, String pageName) {
        return String.format('{0}{1}/{2}/{3}', new List<String> {
            // TWIST_Settings__c.getInstance().Community_URL__c,
            TWIST_UrlUtils.getCommunityUrl(true),
            langCountry,
            origin,
            getPageKey(pageName)
        });
    }
    
    private static String buildQueryParamsString(Map<String,Object> queryParams) {
        Map<String,Object> queryParamsClone = queryParams.clone();
        queryParamsClone.remove(TWIST_QueryParamKey_CONST.LANG_COUNTRY);
        queryParamsClone.remove(TWIST_QueryParamKey_CONST.ORIGIN);
        String result;
        if (queryParamsClone.size() > 0) {
            result = '?';
            List<String> paramsKeyValues = new List<String>();
            for (String key: queryParamsClone.keySet()) {
                if (String.isNotEmpty((String) queryParamsClone.get(key))) {
                    paramsKeyValues.add(key + '=' + (String) queryParamsClone.get(key));
                }
            }
            result += String.join(paramsKeyValues, '&');
        }
        return result;
    }
    
    @TestVisible
    private static String getPageKey(String pageName) { // return first key, for the sake of simplicity
        List <TWIST_IDENTITY_Paths__mdt> paths = [SELECT Value__c FROM TWIST_IDENTITY_Paths__mdt WHERE Name__c = :pageName AND Context__c = ''];
        String value;
        if(!paths.isEmpty()){
            value = String.valueOf(paths[0].Value__c);
            return value.substring(value.lastIndexOf('/') + 1);
        }
        return null;
    }
    
    private static Boolean isValidParamsForExclusiveOffer(Map<String,String> params){
        return params.containsKey('cid')
        && params.get('origin').toLowerCase() != 'lvapp'
        && (params.containsKey('utm_campaign') || params.containsKey('campaign'))
        && !params.get('utm_campaign').startsWithIgnoreCase('web') ;
    }

    private static Boolean isExcludeOfferWebOnly(String utmCampaign){
        List<String> webOnlyOffers = new List<String>();
        if(String.isNotEmpty(TWIST_Settings__c.getInstance().Exclu_Offers_Web_Only__c)){
            webOnlyOffers = TWIST_Settings__c.getInstance().Exclu_Offers_Web_Only__c.split(';');
        }
        return !webOnlyOffers.isEmpty() && !webOnlyOffers.contains(utmCampaign);
    }

    private static String shuffleString(String input) {

        List<String> charList = new List<String>();
        for (Integer i = 0; i < input.length(); i++) {
            charList.add(input.substring(i, i + 1));
        }

        Integer n = charList.size();
        for (Integer i = 0; i < n; i++) {
            Integer j = (Integer) Math.floor(Math.random() * n);
            String temp = charList[i];
            charList[i] = charList[j];
            charList[j] = temp;
        }

        String shuffledString = '';
        for (String c : charList) {
            shuffledString += c;
        }

        return shuffledString.toString();
    }
  
    public class CustomException extends Exception {}
    
}