/**
    About
    -----
    Description: Controller for IDENTITY_Login VisualForce Page
    Created for: Identity project
    Create date: Oct 2018

    Details
    -------
    Called for registration of MyLV Account from Louis Vuitton Site
    Used also for social registration from social login flow
*/
global without sharing class IDENTITY_Login_CTRL {

    // METADATA
    public Map<String,Map<String,IDENTITY_Registration_Form__mdt>> fields {get; set;}
    public Map<String,String> paths {get; set;}
    public IDENTITY_Registration_Form_Settings__c form_settings {get; set;}
    public IDENTITY_Settings__c identity_settings {get; set;}
    public Map<String,String> country_mapping {get;set;}
    public Map<String,String> country_iso_mapping {get;set;}
    public Map<String,String> code_mapping {get;set;}

    public String clientServicePhoneNumber {get; set;}

    // SETUP
    public Boolean isDevMode {get; set;}
    public Boolean isNewDesignActive {get; set;}
    public Boolean isSocialLoginActive {get;set;}
    public String mode {get; set;}
    public String tealiumEnv {get; set;}
    public Integer passwordMaxlength {get; set;}
    
    // FORM
    public String password {get; set;}
    public String username {get; set;}
    public String username_truncated {get; set;}
    public User user {get; set;}
    public String currency_code {get; set;}
    public String calling_code {get; set;}
    public String mobile {get; set;}
    public String mobile_truncated {get; set;}
    public Boolean isEmailFieldVisible {get; set;}
    public String emailFieldVisibilityStyle {get; set;}
    public String mobileFieldVisibilityStyle {get; set;}
    public Boolean isWeChatVisible {get; set;}    
    public String customCss {get;set;}

    // URL PARAMETERS
    public String lang_country {get; set;}
    public String origin {get; set;}
    public String dispatch_country {get; set;}
    public String country_local {get; set;}
    public String language {get; set;}
    public String meta_language {get; set;}
    public String accountId {get; set;}
    public String cid {get; set;}
    public String cidUrlEncoded {get; set;}
    public String currentUrl {get; set;}
    public String trackingId {get; set;}
    public String clientId {get; set;}
    public Map<String,String> googleAnalyticsConfig {get; set;}

    // PARAMETER FOR ACTIVATION FORM CONTEXT
    public Boolean redirectToLvApp {get;set;}
    public String redirectionDeeplinkValue {get; set;}
    public Boolean isExclusiveOffer {get; set;}

    // URL PARAMETER FOR WARDROBING CONTEXT
    public String lookId {get; set;}
    public String linkedToLook {get; set;}

    // STATIC VALUES
    public final String DOMAIN = 'Louis Vuitton Domain';
    public final String SECURE_DOMAIN = 'Louis Vuitton Secure Domain';
    public final String SECURE_DOMAIN_WEB = 'Louis Vuitton Secure Domain Web';

    public final String STANDARD_MODE = 'LOGIN';
    public final String KNOWN_MODE = 'KNOWN_LOGIN';


    /****************  SETUP  ****************/
    
    public IDENTITY_Login_CTRL() {
        // FOR DEBUG
        System.debug('Identity_Login_CTRL');
        System.debug('PARAMS');
        for(String key : ApexPages.currentPage().getParameters().keySet()){
            System.debug('>>> ' + key + ' ' + ApexPages.currentPage().getParameters().get(key));
        }
        
        // GLOBAL
        getSettings();    
        setCountryMapping();

        // URL PARAMETERS
        setContext();
        setPaths();

        // MODE
        setMode();

        // FORM
        setForm();

        // SOCIAL LOGIN
        getSocialSettings();
        
        // GG ANALYTICS TRACKING
        setUserTracking();
    }

    public PageReference log (){
         
        string defaultCountryLangLog=ApexPages.currentPage().getParameters().get('defaultCountryLangLog');
        if(!String.isEmpty(defaultCountryLangLog) && boolean.valueOf(defaultCountryLangLog) != false){
            new Logs( new Map<String,Object> {
                'level' => 'ERROR', 
                'apexClass' => 'IDENTITY_Login_CTRL',
                'category' => 'EVENT',
                'message' => Label.IDENTITY_LOG_Lang_Country_Parameter,
                'recordId' => ApexPages.currentPage().getParameters().get('defaultCountryLangLog'),
                'application' => origin
            });
        }

        if(ApexPages.currentPage().getParameters().get('404Log') != null && ApexPages.currentPage().getParameters().get('404Log') == 'true'){
            new Logs( new Map<String,Object> {
                'level' => 'ERROR', 
                'apexClass' => 'IDENTITY_Login_CTRL',
                'category' => 'EVENT',
                'status_code' => Label.IDENTITY_LOG_404,
                'message' => String.isNotEmpty(Site.getErrorDescription()) ? Site.getErrorDescription() : Label.IDENTITY_LOG_404,
                'application' => origin
            });
        }
        
        return null;
    }

    /*
    *** DESCRIPTION Set mode of the page: standard or social and sub mode: creation or matching 
    ***             Known Mode: if accountId params contains exisitng user Id, fill its username 
    *** RETURN      
    */
    public void setMode(){
        mode = STANDARD_MODE;

        // ACTIVATION FORM 
        cid = ApexPages.currentPage().getParameters().get('cid');
        cidUrlEncoded = cid != null ? EncodingUtil.urlEncode(cid, 'UTF-8') : '';
        accountId = ApexPages.currentPage().getParameters().get('accountId');
        if(!String.isEmpty(accountId)){
            mode = KNOWN_MODE;
        }

        if(ApexPages.currentPage().getParameters().get('dev') != null) {
            isDevMode = true;
        }

        // CARE SERVICE + EXCLUSIVE EXPERIENCE FLOWS HAS TO BE REDIRECTED TO LV APP
        redirectToLvApp = false;
        redirectionDeeplinkValue = 'mylv';
        isExclusiveOffer = false;
        // Exclusive Experience
        Schema.DescribeFieldResult XXPR_OfferCode = Exclusive_Experience__c.Offer_Code__c.getDescribe();
        Schema.sObjectField fieldOfferCode = XXPR_OfferCode.getSObjectField();
        List<PicklistEntry> picklistValuesOfferCode = fieldOfferCode.getDescribe().getPicklistValues();
        List<String> picklistValuesOfferCodeString = new List<String>();
        for(PicklistEntry pe : picklistValuesOfferCode){
            picklistValuesOfferCodeString.add(pe.getValue());
        }
        String utmCampaign = ApexPages.currentPage().getParameters().get('utm_campaign');
        if(utmCampaign != null && picklistValuesOfferCodeString.contains(utmCampaign)){
            redirectionDeeplinkValue = 'myexclusive';
            isExclusiveOffer = true;
            // GET Web-only offer codes
            String[] webOnlyOffers = new List<String>();
            if(String.isNotEmpty(IDENTITY_Settings__c.getInstance().Exclu_Offers_Web_Only__c)){
                webOnlyOffers = IDENTITY_Settings__c.getInstance().Exclu_Offers_Web_Only__c.split(';');
            }
            if(!utmCampaign.startsWithIgnoreCase('web') && !webOnlyOffers.contains(utmCampaign)){
                redirectToLvApp = true;
            }
        }
        // Care Service
        if( ApexPages.currentPage().getParameters().get('campaign') != null && ApexPages.currentPage().getParameters().get('campaign').contains('careService')){
            redirectToLvApp = true;
            redirectionDeeplinkValue = 'mycareservice';
        }
        System.debug('NEED REDIRECTION TO LV APP: '+redirectToLvApp);
    }

    /*
    *** DESCRIPTION Get custom settings values and set settings for the page
    *** RETURN      
    */
    public void getSettings(){
        form_settings = IDENTITY_Registration_Form_Settings__c.getInstance();
        identity_settings = IDENTITY_Settings__c.getInstance();

        isNewDesignActive = identity_settings.Activate_New_Design__c;
        tealiumEnv = form_settings.Tealium_Environment__c;
        passwordMaxlength = Integer.valueOf(identity_settings.Password_Maxlength__c);
    }

    /*
    *** DESCRIPTION Set settings values for social login
    *** RETURN      
    */
    public void getSocialSettings(){
        isSocialLoginActive = false;
		for (AuthProvider provider : [SELECT Id, DeveloperName, FriendlyName FROM AuthProvider]) {
            if(fields.get('Login').get(provider.DeveloperName) != null && !fields.get('Login').get(provider.DeveloperName).Is_Hidden__c){
                isSocialLoginActive = true;
            }
		}

        // WeChat Social Login visibility: desktop / tablet / wechat browser
        String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        isWeChatVisible = false;
        if( String.isNotEmpty(userAgent) && ( !userAgent.contains('Mobile') || (userAgent.contains('Mobile') && userAgent.contains('iPad')) || (userAgent.contains('Mobile') && userAgent.contains('MicroMessenger')) ) ){
            isWeChatVisible = true;
        }
    }

    /*
    *** DESCRIPTION Get custom metadata of country mapping and keep values into map
    *** RETURN      
    */
    public void setCountryMapping(){
        List<CountryMapping__mdt> country_format = [SELECT PicklistValueSet__c, Iso2Code__c, Iso3Code__c
            FROM CountryMapping__mdt
            WHERE PicklistValueSet__c != null AND Iso2Code__c != null
            ORDER BY PicklistValueSet__c ASC];

        country_mapping = new Map<String,String>();
        country_iso_mapping = new Map<String,String>();
        for(CountryMapping__mdt cm : country_format){
            country_mapping.put(cm.Iso2Code__c, cm.PicklistValueSet__c);
            country_iso_mapping.put(cm.Iso2Code__c, cm.Iso3Code__c);
        }

        List<CountryMapping__mdt> code_format = [SELECT Iso2Code__c, Calling_Code__c 
            FROM CountryMapping__mdt
            WHERE Iso2Code__c != null AND Calling_Code__c != null
            ORDER BY Calling_Code__c ASC];

        code_mapping = new Map<String,String>();
        for(CountryMapping__mdt cm : code_format){
            code_mapping.put(cm.Iso2Code__c, String.ValueOf(cm.Calling_Code__c).substringBefore('.'));
        }
    }

    /*
    *** DESCRIPTION Get URL parameters and define language, country, origin
    *** RETURN      
    */
    public void setContext(){
        // origin
        origin = ApexPages.currentPage().getParameters().get('origin');
        if(origin == null){
            origin = identity_settings.Default_Origin_Parameter__c;
        }

        // GA Config
        googleAnalyticsConfig = IDENTITY_GoogleAnalytics_Utils.getConfig(origin);

        // dispatch_country -- for multi-country website
        if(Pattern.compile('[A-Z]{2}').matcher(ApexPages.currentPage().getParameters().get('dispatchCountry') ?? '').matches()) {
            dispatch_country = ApexPages.currentPage().getParameters().get('dispatchCountry');
        }

        // lang-country        
        lang_country = ApexPages.currentPage().getParameters().get('lang-country');
        if(lang_country == null){
            lang_country = identity_settings.Default_Language_Country_Parameter__c;
        }
        country_local = lang_country.substringAfter('-');
        
        language = [
            SELECT Salesforce__c
            FROM Language_Mapping_ATG_SF__mdt
            WHERE ATG__c =: lang_country
            LIMIT 1
        ].Salesforce__c;

        meta_language = [
            SELECT Meta_Language__c
            FROM Language_Mapping_ATG_SF__mdt
            WHERE ATG__c =: lang_country
            LIMIT 1
        ].Meta_Language__c;

        clientServicePhoneNumber = IDENTITY_Utils.getClientServicePhoneNumber(lang_country, dispatch_country);

        // CSS        
        customCss = 'redesign-2019.css';
        if(origin == 'lvconnect'){
            customCss = 'lv-connect.css';
        }
        
        // WARDROBING
        lookId = ApexPages.currentPage().getParameters().get('lookId');
    }

    /*
    *** DESCRIPTION Set redirection URL 
    *** RETURN      
    */
    public void setPaths(){
        paths = Identity_Utils.getPaths(lang_country, origin, dispatch_country);

        // DOMAIN
        String domainFromQueryParam = ApexPages.currentPage().getParameters().get('domain');
        if(!String.isEmpty(domainFromQueryParam)){
            paths.put(DOMAIN, domainFromQueryParam);
        }

        // SUCCESS URL
        if(ApexPages.currentPage().getParameters().get('successUrl') != null && IDENTITY_Utils.isAllowedUrl(ApexPages.currentPage().getParameters().get('successUrl'), paths, origin)){
            paths.put('Login Success URL', ApexPages.currentPage().getParameters().get('successUrl'));
        }
        else {
            paths.put('Login Success URL', paths.get(SECURE_DOMAIN) + paths.get('Login Success Path'));
        }

        // ERROR URL
        if(ApexPages.currentPage().getParameters().get('errorUrl') != null && IDENTITY_Utils.isAllowedUrl(ApexPages.currentPage().getParameters().get('errorUrl'), paths, origin)){
            paths.put('Login Error URL', ApexPages.currentPage().getParameters().get('errorUrl'));
        }
        else {
            paths.put('Login Error URL', paths.get(SECURE_DOMAIN) + paths.get('Login Error Path'));
        }

        // FOR DEBUG
        System.debug('>>> PATHS');
        for(String key : paths.keySet()){
            System.debug('>>> ' + key + ' ' + paths.get(key));
        }
    }

    /*
    *** DESCRIPTION Get fields from custom metadata
    *** RETURN      
    */
    public void setForm(){

        List<IDENTITY_Registration_Form__mdt> metadata = [
            SELECT Field__c, Is_Required__c, Section__c, Is_Hidden__c, Value__c 
            FROM IDENTITY_Registration_Form__mdt
            WHERE Context__c =: lang_country AND Form__c IN ('Login', 'Settings')
        ];
        
        fields = new Map<String,Map<String,IDENTITY_Registration_Form__mdt>>();
        for(IDENTITY_Registration_Form__mdt field : metadata){
            if(fields.get(field.Section__c) == null){
                fields.put(field.Section__c, new Map<String,IDENTITY_Registration_Form__mdt>());
            }
            fields.get(field.Section__c).put(field.Field__c, field);
        }

        if(mode == KNOWN_MODE){
            
            User[] users = [SELECT Id, Username, TECH_Email__c, TECH_MobilePhone__c FROM User WHERE AccountId =: accountId];
            Account[] accounts = [SELECT Id, LocalLoginPhone__pc, LoginPhoneCountryCode__pc, MobilePhoneCountryCode__pc FROM Account WHERE Id =: accountId];
            
            if(!users.IsEmpty()){
                if(!fields.get('Login').get('email').Is_Hidden__c && fields.get('Login').get('mobile_phone').Is_Hidden__c){
                    username = users[0].TECH_Email__c;
                    username_truncated = isExclusiveOffer == true ? username : IDENTITY_Utils.truncateUsername(username);
                }
                else {
                    username = users[0].Username;
                    username_truncated = isExclusiveOffer == true ? username : IDENTITY_Utils.truncateUsername(username);
                    mobile = users[0].TECH_MobilePhone__c;
                    mobile_truncated = isExclusiveOffer == true ? mobile.substring(3) :  IDENTITY_Utils.truncateUsername(mobile.substring(3));
                    if(!String.isEmpty(accounts[0].LoginPhoneCountryCode__pc))
                        calling_code = accounts[0].LoginPhoneCountryCode__pc;
                    else if(!String.isEmpty(accounts[0].MobilePhoneCountryCode__pc))
                        calling_code = accounts[0].MobilePhoneCountryCode__pc;
                }
            }
        }
        else {
            calling_code = fields.get('Login').get('mobile_phone').Value__c;
        }
        
        // Email/Mobile field visibility
        isEmailFieldVisible = false;
        emailFieldVisibilityStyle = 'none';
        mobileFieldVisibilityStyle = 'grid';
        if(
            (!fields.get('Login').get('email').Is_Hidden__c && country_local != 'cn')
            ||
            (!fields.get('Login').get('email').Is_Hidden__c && country_local == 'cn' && (origin == 'lvapp' || origin == 'lvconnect') )
          ){
            isEmailFieldVisible = true;
            emailFieldVisibilityStyle = 'grid';
        }
        if(!fields.get('Login').get('email').Is_Hidden__c && country_local != 'cn'){
            mobileFieldVisibilityStyle = 'none';
        }
    }

    /*
    *** DESCRIPTION Set variables for GG Analytics User Tracking (sign_in_succeeded/failed + social_login_succeeded/failed)
    *** RETURN      
    */
    public void setUserTracking(){
        // CURRENT URL
        if(ApexPages.currentPage().getParameters().get('friendlyUrl') != null){
            currentUrl = paths.get('Account Domain')+ApexPages.currentPage().getParameters().get('friendlyUrl').escapeHtml4();
            System.debug('currentUrl : ' + currentUrl);
        }       

        // CLIENT ID
        if(ApexPages.currentPage().getCookies().get('clientId') != null && ApexPages.currentPage().getCookies().get('clientId').getValue() != null){ // GG cookie is only retrievable in Prod
            clientId = ApexPages.currentPage().getCookies().get('clientId').getValue();
        }
        else{
            clientId = Identity_Utils.getRandomClientId();
        }        
        
        // TRACKING ID
        trackingId = fields.get('Settings').get('Analytics_TID').Value__c;
        
        System.debug('SET USER TRACKING');
        System.debug('currentUrl: '+ currentUrl);
        System.debug('clientId: '+ clientId);
        System.debug('trackingId: '+ trackingId);
    }

    /****************  DYNAMIC VALUES  ****************/

    /*
    *** DESCRIPTION Get Picklist options for calling code
    *** RETURN      ListList<SelectOption> => ISO2 / '+' Calling Code   
    */
    public List<SelectOption> getCallingCodes() {
        List<SelectOption> options = new List<SelectOption>();

        for(String val : code_mapping.keySet()){
            options.add(new SelectOption(val, '+' + code_mapping.get(val)));
        }
        
        return options;
    }

    /****************  NAVIGATION  ****************/

    /*
    *** DESCRIPTION Forgot Password Link
    *** RETURN      PageReference    External
    */
    public PageReference forgotPassword(){ 
        if(country_local == 'cn'){
            return new PageReference(paths.get(SECURE_DOMAIN_WEB) + paths.get('Forgot Password Path'));
        }
        List<String> Twist_local_list = identity_settings.Twist_locals__c?.split(';');
        if(origin == 'lvapp' && Twist_local_list.contains(country_local)){
            return new PageReference(paths.get(SECURE_DOMAIN_WEB) + paths.get('Forgot Password Path'));
        }
        return new PageReference(paths.get(DOMAIN) + paths.get('Forgot Password Path'));
    }

    /****************  SUBMIT  ****************/

    /*
    *** DESCRIPTION Create a log if getHTMLFragment script fails to load
    *** RETURN      PageReference    always null
    */
    public PageReference onScriptError(){
        String src = ApexPages.currentPage().getParameters().get('src');
        
        new Logs(new Map<String,Object> {
            'level' => 'ERROR', 
            'apexClass' => 'IDENTITY_Login_CTRL', 
            'category' => 'CALLOUT',
            'message' => 'ERROR LOADING GET HTML FRAGMENT SCRIPT',
            'recordId' => src,
            'application' => origin
        });

        return null;
    }

    /****************  EVENT  ****************/

    /*
    *** DESCRIPTION Check if email already exist for Identity User
    *** RETURN      Boolean    true => available
    */
    @RemoteAction
    global static Boolean onLoginEmailChange(String email) { 
        User user = IDENTITY_Utils.getUserByUsername(email);
        if(user != null){
            return false;
        }

        return true;
    }

    /*
    *** DESCRIPTION Check if mobile phone already exist for Identity User
    *** RETURN      Boolean    true => available
    */
    @RemoteAction
    global static Boolean onLoginMobilePhoneChange(String mobilephone) {
        User user = IDENTITY_Utils.getUserByUsername(mobilephone);
        if(user != null){
            return false;
        }

        return true;
    }
    
    /*
    *** DESCRIPTION Login with password method
    *** RETURN      PageReference   External
    */
    public PageReference loginPasswordMethod() {
        
        try{

        	System.debug(username);
            System.debug(password);

            if(IDENTITY_Utils.passwordTooLong(password)){
                throw new CustomException(Label.EM_password_too_long);
             }

            user = IDENTITY_Utils.getUserByUsername(username);
            username = user.Username;

            PageReference loginPage = IDENTITY_Utils.loginOauthUserAgentMethod(username, password, paths.get('Login Success URL'), origin); 
            System.debug(username);
            // LOGIN SUCCESS
            if(loginPage != null){
                // SEND LOGIN SUCCESS EVENT TO GG ANALYTICS
                IDENTITY_GoogleAnalytics_Utils.sendEvent(
                    trackingId,
                    clientId,
                    origin,
                    googleAnalyticsConfig.get('environmentType'),
                    googleAnalyticsConfig.get('environmentId'),
                    country_local,
                    lang_country,
                    'mylv',
                    'i_already_have_an_account',
                    'sign_in_succeeded',
                    currentUrl,
                    'logged_user',
                    'mylv/identification',
                    'connexion_module' );
                
                if(!String.isEmpty(lookid)){
                    linkedToLook = IDENTITY_UTILS.shareLook(lookId, user.AccountId, origin);
                }

                // OAUTH USER AGENT REDIRECTION - SCOPE: ACCESS TOKEN, REFRESH TOKEN 
                if(origin == 'lvapp' || origin == 'lvconnect'){
                    System.debug('################# TEST IMAD '+loginPage);
                    return loginPage;
                }

                // JWT LOGIN TRANSPARANT REDIRECTION - SCOPE: ACCESS TOKEN
                Map<String,String> params = new Map<String,String>();
                if(!String.isEmpty(lookid)){
                    params.put('lookId', linkedToLook);
                }
                return IDENTITY_Utils.loginJWTMethod(username, paths.get('Login Success URL'), params);
            }
            else {
                System.debug('An error occured: Incorrect password');
            }
        }
        catch(Exception ex){
            System.debug('An error occured: ' + ex.getMessage() + ex.getStackTraceString());
        }

        return null;
    }

    /*
    *** DESCRIPTION Logout - redirect to error URL
    *** RETURN      PageReference   External
    */
    public PageReference logout() {

        return new PageReference(paths.get('Login Error URL'));
    }

    /*
    *** DESCRIPTION Social Login - redirect to SSO 
    *** RETURN      PageReference   Internal
    */
    public PageReference socialLogin() {
        String social_media = Apexpages.currentPage().getParameters().get('social_media');
        PageReference page = new PageReference(paths.get('Account Domain') + paths.get('SSO ' + social_media));        
        // SUCCESS URL
        System.debug('IDENTITY_Login_CTRL SocialLogin 1 '+paths.get('Account Domain'));
        System.debug('IDENTITY_Login_CTRL SocialLogin 2 '+paths.get('SSO ' + social_media));
        if(ApexPages.currentPage().getParameters().get('successUrl') != null && IDENTITY_Utils.isAllowedUrl(ApexPages.currentPage().getParameters().get('successUrl'), paths, origin)){
            page.getParameters().put('successUrl', ApexPages.currentPage().getParameters().get('successUrl'));
        }
        else {
            page.getParameters().put('successUrl', paths.get(SECURE_DOMAIN) + paths.get('Login Success Path'));
        }

        // ERROR URL
        if(ApexPages.currentPage().getParameters().get('errorUrl') != null && IDENTITY_Utils.isAllowedUrl(ApexPages.currentPage().getParameters().get('errorUrl'), paths, origin)){
            page.getParameters().put('errorUrl', ApexPages.currentPage().getParameters().get('errorUrl'));
        }
        else {
            page.getParameters().put('errorUrl', paths.get(SECURE_DOMAIN) + paths.get('Login Error Path'));
        }
        
        // FOR GG ANALYTICS NEEDS      
        if(ApexPages.currentPage().getParameters().get('friendlyUrl') != null){
            page.getParameters().put('userStartUrl', ApexPages.currentPage().getParameters().get('friendlyUrl').escapeHtml4());
            page.getParameters().put('devStartUrl', 'login');
        }
        return page;
    }
    /****************  WRAPPER  ****************/
    public class CustomException extends Exception {}

}