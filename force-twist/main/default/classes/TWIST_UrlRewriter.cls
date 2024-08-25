global with sharing class TWIST_UrlRewriter implements Site.UrlRewriter {

    private PageReference newUrl;
    private Boolean to404Log;
    private String toDefaultParamLog;

    /*
    *** DESCRIPTION Redirect to Salesforce link according rules
    *** RETURN      New PageReference
    */
    global PageReference mapRequestUrl(PageReference friendlyURL) {

        Matcher urlMatcher = lvUrlPatternMatcher(friendlyURL.getUrl());
        if (!urlMatcher.matches()) {
            return friendlyURL;
        }



        String langCountry = urlMatcher.group(1).toLowerCase();
        String origin = urlMatcher.group(2);
        String pageKey = urlMatcher.group(3).toLowerCase();
        String dispatchCountry = '';

        if(!TWIST_QueryParametersFormatUtils.isLangCountryFormatValid(langCountry)){
            newUrl = new PageReference(TWIST_PageUrl_CONST.EXCEPTION_URL);
            addContextParametersToNewUrl(TWIST_Settings__c.getInstance().Default_Language_Country_Parameter__c, origin, dispatchCountry);
            addClientIdParameterForAkamaiCompatibility();
            return newUrl;
        }

       
        
        // MANAGE NEW LOCALES WITH DISPATCH COUNTRY
        List<TWIST_Footer_Config__mdt> listLangCountry = [
            SELECT Language_Country__c, Dispatch_Country__c
            FROM TWIST_Footer_Config__mdt
            WHERE MasterLabel = :langCountry
            LIMIT 1
        ];
        if (!listLangCountry.isEmpty()) {
            langCountry = listLangCountry.get(0).Language_Country__c;
            dispatchCountry = listLangCountry.get(0).Dispatch_Country__c;
        }

        // DEFAULT LANG-COUNTRY
        TWIST_Settings__c twistSettings = TWIST_Settings__c.getInstance();
        Set<String> languageCountryValues = new Set<String> (twistSettings.Language_Country_Values__c.split('/'));
        if (!languageCountryValues.contains(langCountry)) {
            toDefaultParamLog = langCountry;
            langCountry = twistSettings.Default_Language_Country_Parameter__c;
        }


        // PAGE KEY ERROR CASES
        if (!isPagekeyOfTypeLogin(pageKey)
        && !isPagekeyOfTypeSocialLogin(pageKey, langCountry)
        && !isPagekeyOfTypeRegistration(pageKey, friendlyURL)
        && !isPagekeyOfTypeAlternativeLogin(pageKey, langCountry)
        && !isPagekeyOfTypeForgotPassword(pageKey)
        && !isPagekeyOfTypeResetPassword(pageKey)
        ) {
            newUrl = new PageReference(TWIST_PageUrl_CONST.EXCEPTION_URL);
            to404Log = true;
        }

        addContextParametersToNewUrl(langCountry, origin, dispatchCountry);
        addFlagParametersToNewUrl(toDefaultParamLog, to404Log, friendlyURL);
        addCurrentParametersToNewUrl(friendlyURL);
        addClientIdParameterForAkamaiCompatibility();

        return newUrl;
    }

    global List<PageReference> generateUrlFor(List<PageReference> yourSalesforceUrls) {
        return null;
    }

    // REGISTRATION PATTERN: /lang-country/origin/pagekey?params
    private Matcher lvUrlPatternMatcher(String friendlyUrl) {
        Pattern registrationPattern = Pattern.compile('/([a-zA-Z0-9]+-[a-zA-Z0-9]+)/([a-zA-Z]+)/(([a-zA-Z0-9\\-]+)*)([#a-zA-Z0-9=+_?.%&-]+)*');
        return registrationPattern.matcher(friendlyUrl);
    }

    private Boolean isPagekeyOfTypeRegistration(String pageKey, Pagereference friendlyURL) {
        Set<String> registrationPagekeys = getRegistrationPagekeys();
        if (!registrationPagekeys.contains(pageKey)) {
            return false;
        }

        // MYREPAIRS / OSA / EXCLUSIVE EXPERIENCE / CHECKOUT activation flows
        List<String> accountIdWithTrustOrigin = new List<String>();
        String accountId;
        String isTrustOrigin;
        String mode = TWIST_Mode_CONST.REGISTRATION;
        String encryptedAccountId = friendlyURL.getParameters().get('cid');
        if (!String.isEmpty(encryptedAccountId)) {
            try {
                Map<String, Object> cidMap = TWIST_RegistrationUtils.extractAccountId(encryptedAccountId);
                accountId = cidMap.containsKey('accountId') ? cidMap.get('accountId').toString() : null ;
                isTrustOrigin = cidMap.containsKey('isTrustOrigin') ? cidMap.get('isTrustOrigin').toString() : 'false' ;
                List<Account> accounts = [SELECT Id, PersonEmail, LoginPhone__pc FROM Account WHERE Id =: accountId];
                if (!accounts.isEmpty()) {
                    accountId = accounts[0].Id;
                    List<User> users = IDENTITY_Utils.getUsers(accounts[0]);
                    if (!users.isEmpty()) {
                        mode = TWIST_Mode_CONST.LOGIN;
                        accountId = users[0].AccountId;
                        newUrl = new PageReference(TWIST_PageUrl_CONST.LOGIN_URL);
                        newUrl.getParameters().put(TWIST_QueryParamKey_CONST.ACCOUNT, accountId);
                    }
                    else {
                        mode = TWIST_Mode_CONST.ACTIVATION;
                        newUrl = new PageReference(TWIST_PageUrl_CONST.ACTIVATION_URL);
                        newUrl.getParameters().put(TWIST_QueryParamKey_CONST.ACCOUNT, accountId);
                        newUrl.getParameters().put(TWIST_QueryParamKey_CONST.TRUST_ORIGIN, isTrustOrigin);
                    }
                }
            }
            catch (Exception ex) {
                System.debug(ex.getMessage());
            }
        }

        if (mode == TWIST_Mode_CONST.REGISTRATION) {
            newUrl = new PageReference(TWIST_PageUrl_CONST.REGISTRATION_URL);
        }
        return true;
    }

    private Set<String> getRegistrationPagekeys() {
        Set<String> pageKeys = new Set<String>();
        for(TWIST_IDENTITY_Paths__mdt path: [SELECT Name__c, Value__c, Context__c, Application__c FROM TWIST_IDENTITY_Paths__mdt WHERE Name__c = :TWIST_IdentityPathsMdt_CONST.REGISTRATION_FORM]){
            pageKeys.add(path.Value__c.split('/')[3]);
        }
        return pageKeys;
    }
    
    private Boolean isPagekeyOfTypeSocialLogin(String pageKey, String langCountry) {
        if ('line'.equals(pageKey) && !new TWIST_FeatureFlagUtils(langCountry).isLineSocialLoginEnabled()) {
            return false;
        }

        List<TWIST_Social_Media__mdt> socialMedia = [SELECT Page_Key__c FROM TWIST_Social_Media__mdt WHERE Lang_Country__c = :langCountry];
        for (TWIST_Social_Media__mdt media : socialMedia) {
            if (pageKey.equals(media.Page_Key__c)) {
                newUrl = new PageReference(TWIST_PageUrl_CONST.SOCIAL_LOGIN_URL);
                newUrl.getParameters().put(TWIST_QueryParamKey_CONST.SOCIAL_MEDIA, pageKey);
                return true;
            }
        }
        return false;
    }

    private Boolean isPagekeyOfTypeLogin(String pageKey) {
        Set<String> loginPageKeys = this.getPagekeys(TWIST_IdentityPathsMdt_CONST.LOGIN_FORM);
        if (loginPageKeys.contains(pageKey)) {
            newUrl = new PageReference(TWIST_PageUrl_CONST.LOGIN_URL);
            return true;
        }
        return false;
    }

    private Boolean isPagekeyOfTypeForgotPassword(String pageKey) {
        Set<String> pageKeys = this.getPagekeys(TWIST_IdentityPathsMdt_CONST.FORGOT_PASSWORD_FORM);
        if (pageKeys.contains(pageKey)) {
            newUrl = new PageReference(TWIST_PageUrl_CONST.FORGOT_PASSWORD_URL);
            return true;
        }
        return false;
    }

    private Boolean isPagekeyOfTypeResetPassword(String pageKey) {
        Set<String> pageKeys = this.getPagekeys(TWIST_IdentityPathsMdt_CONST.RESET_PASSWORD_FORM);
        if (pageKeys.contains(pageKey)) {
            newUrl = new PageReference(TWIST_PageUrl_CONST.RESET_PASSWORD_URL);
            return true;
        }
        return false;
    }
    
    private Boolean isPagekeyOfTypeAlternativeLogin(String pageKey, String langCountry) {
        Set<String> pageKeys = this.getPagekeys(TWIST_IdentityPathsMdt_CONST.ALTERNATIVE_LOGIN_FORM);

        if (pageKeys.contains(pageKey) && new TWIST_FeatureFlagUtils(langCountry).isAlternativeLoginEnabled()) {
            newUrl = new PageReference(TWIST_PageUrl_CONST.ALTERNATIVE_LOGIN_URL);
            return true;
        }
        return false;
    }

    private Set<String> getPagekeys(String keyName) {
        Set<String> pageKeys = new Set<String>();
        for(TWIST_IDENTITY_Paths__mdt path: [SELECT Name__c, Value__c, Context__c, Application__c FROM TWIST_IDENTITY_Paths__mdt WHERE Name__c = :keyName]){
            pageKeys.add(path.Value__c.substring(path.Value__c.lastIndexOf('/') + 1));
        }
        return pageKeys;
    }

    private void addContextParametersToNewUrl(String langCountry, String origin, String dispatchCountry) {
        newUrl.getParameters().put(TWIST_QueryParamKey_CONST.LANG_COUNTRY, langCountry);
        newUrl.getParameters().put(TWIST_QueryParamKey_CONST.ORIGIN, origin);
        if(!String.isEmpty(dispatchCountry)){
            newUrl.getParameters().put(TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY, dispatchCountry);
        }
    }

    // ADD FLAGS (NEED TO CREATE A LOG IN VF PAGE)
    private void addFlagParametersToNewUrl(String toDefaultParamLog, Boolean to404Log, PageReference friendlyURL) {
        newUrl.getParameters().put(TWIST_QueryParamKey_CONST.UPDATED_TO_DEFAULT_LANG_COUNTRY, toDefaultParamLog);
        newUrl.getParameters().put(TWIST_QueryParamKey_CONST.ERROR_404, String.valueOf(to404Log));
        newUrl.getParameters().put(TWIST_QueryParamKey_CONST.FRIENDLY_URL, friendlyURL.getUrl());
    }

    private void addCurrentParametersToNewUrl(PageReference friendlyURL) {
        Map<String,String> parameters = newUrl.getParameters();
        for (String key: friendlyURL.getParameters().keyset()) {
            parameters.put(key, friendlyURL.getParameters().get(key));
        }
    }

    private void addClientIdParameterForAkamaiCompatibility() {
        Map<String,String> parameters = newUrl.getParameters();
        if (!parameters.keySet().contains(TWIST_QueryParamKey_CONST.CLIENT_ID) && !parameters.keySet().contains(camelCaseToKebabCase(TWIST_QueryParamKey_CONST.CLIENT_ID))) {
            parameters.put(TWIST_QueryParamKey_CONST.CLIENT_ID, '');
        }
    }
    
    private String camelCaseToKebabCase(String input) {
        String output = '';
        for (String c : input.split('')) {
            output += !c.toLowerCase().equals(c) ? '-' + c.toLowerCase() : c;
        }
        return output.startsWith('-') ? output.substring(1) : output;
    }
}