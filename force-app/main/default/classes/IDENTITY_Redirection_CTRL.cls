/**
    About
    -----
    Description: Controller for IDENTITY_Redirection Visualforce Page
    Created for: Identity project
    Create date: Oct 2018

    Details
    -------
    ** SSO - Social lofin: redirect to auth provider sso url
    ** LOGIN: redirect to success url with access token
    ** SOCIAL LOGIN: redirect to registration page with friendly URL parameters
    ** EXCEPTION: redirect to Louis Vuitton
*/
public without sharing class IDENTITY_Redirection_CTRL {

    public String access_token {get;set;}
    public String lang_country {get; set;}
    public String country_local {get; set;}
    public String dispatch_country {get; set;}
    public String origin {get; set;}
    public String language {get; set;}
    public String customCss {get;set;}


    // GG ANALYTICS
    public Boolean userTracking {get; set;}
    public String eventCategory {get; set;}
    public String eventLabel {get; set;}
    public String eventAction {get; set;}
    public String connexionStatus {get; set;}
    public String pageName {get; set;}
    public String pageType {get; set;}
    public String userStartUrl {get; set;}
    public String userStartDomain {get; set;}
    public String devStartUrl {get; set;}
    public String trackingId {get; set;}
    public String clientId {get; set;}
    public Map<String,String> googleAnalyticsConfig {get; set;}

    public Map<String,String> paths {get; set;}

    // STATIC VALUES
    public final String DOMAIN = 'Louis Vuitton Domain';
    public final String SECURE_DOMAIN = 'Louis Vuitton Secure Domain';
    public final String ACCOUNT_DOMAIN = 'Account Domain';
    public final String REDIRECTION_PAGE = 'SSO Redirection Page';
    public final String LANG_COUNTRY_KEY = 'lang-country';
    public final String ORIGIN_KEY = 'origin';
    public final String RET_URL_KEY = 'redirectURL';
    public final String SOCIAL_MEDIA_KEY = 'social_media';
    public final String PARAM_PREFIX = 'param_';

    public Boolean isDevMode {get; set;}
    public Boolean isNewDesignActive {get; set;}

    public IDENTITY_Redirection_CTRL() {

        // FOR DEBUG
        System.debug('PARAMS');
        for(String key : ApexPages.currentPage().getParameters().keySet()){
            System.debug(key + ' ' + ApexPages.currentPage().getParameters().get(key));
        }

        getSettings();
        setContext();
        setPaths();
        
        // GG ANALYTICS TRACKING
         setUserTracking();
    }


    public void getSettings(){
        isNewDesignActive = IDENTITY_Settings__c.getInstance().Activate_New_Design__c;
    }

    /*
    *** DESCRIPTION Get URL parameters and define language, country, origin
    *** RETURN
    */
    public void setContext(){
        System.debug('>>> setContext() - datetime: ' + String.valueOf(Datetime.now().getTime()));
        // origin
        if(ApexPages.currentPage().getParameters().get(ORIGIN_KEY) != null){
            origin = ApexPages.currentPage().getParameters().get(ORIGIN_KEY);
        }
        else if(ApexPages.currentPage().getCookies().get(ORIGIN_KEY) != null){
            origin = ApexPages.currentPage().getCookies().get(ORIGIN_KEY).getValue();
        }
        else{
            origin = IDENTITY_Settings__c.getInstance().Default_Origin_Parameter__c;
        }

        // GA config
        googleAnalyticsConfig = IDENTITY_GoogleAnalytics_Utils.getConfig(origin);

        // lang-country
        System.debug('>>> page URL: ' + ApexPages.currentPage().getUrl());
        System.debug('>>> headers Host: ' + ApexPages.currentPage().getHeaders().get('Host'));
        System.debug('>>> headers Referer: ' + ApexPages.currentPage().getHeaders().get('Referer'));
        System.debug('>>> headers User-Agent: ' + ApexPages.currentPage().getHeaders().get('User-Agent'));
        System.debug('>>> headers X-Salesforce-Forwarded-To: ' + ApexPages.currentPage().getHeaders().get('X-Salesforce-Forwarded-To'));
        System.debug('>>> URL parameters: ' + JSON.serialize(ApexPages.currentPage().getParameters()));
        if(ApexPages.currentPage().getParameters().get(LANG_COUNTRY_KEY) != null){
            lang_country = ApexPages.currentPage().getParameters().get(LANG_COUNTRY_KEY);
        }
        else if(ApexPages.currentPage().getCookies().get(LANG_COUNTRY_KEY) != null){
            lang_country = ApexPages.currentPage().getCookies().get(LANG_COUNTRY_KEY).getValue();
        }
        else{
            lang_country = IDENTITY_Settings__c.getInstance().Default_Language_Country_Parameter__c;
        }

        System.debug('>>> origin: ' + origin);
        System.debug('>>> lang_country: ' + lang_country);

        // Set Cookies
        ApexPages.currentPage().setCookies(new List<Cookie>{
            new Cookie(ORIGIN_KEY, origin, '', 25000, true),
            new Cookie(LANG_COUNTRY_KEY, lang_country, '', 25000, true)
        });

        // dispatch_country -- for multi-country website
        if(Pattern.compile('[A-Z]{2}').matcher(ApexPages.currentPage().getParameters().get('dispatchCountry') ?? '').matches()) {
            dispatch_country = ApexPages.currentPage().getParameters().get('dispatchCountry');
        }
        country_local = lang_country.substringAfter('-');
        
        if(ApexPages.currentPage().getParameters().get('dev') != null) {
            isDevMode = true;
        }

        language = [
            SELECT Salesforce__c
            FROM Language_Mapping_ATG_SF__mdt
            WHERE ATG__c =: lang_country
            LIMIT 1
        ].Salesforce__c;

        // CSS        
        customCss = 'redesign-2019.css';
        if(origin == 'lvconnect'){
            customCss = 'lv-connect.css';
        }
    }

    /*
    *** DESCRIPTION Set redirection URL 
    *** RETURN      
    */
    public void setPaths(){
        paths = Identity_Utils.getPaths(lang_country, origin, dispatch_country);

        // success url 
        String successUrl = ApexPages.currentPage().getParameters().get('successUrl');
        if(successUrl != null && IDENTITY_Utils.isAllowedUrl(successUrl, paths, origin)){
            ApexPages.currentPage().setCookies(new List<Cookie>{
                new Cookie('redirectURL', successUrl, '', 25000, true)
            });
        }

        // Save in Cookies all POST/GET params with prefix pattern (especially for successUrl, errorUrl, domain)
        for(String key : ApexPages.currentPage().getParameters().keyset()){
            if(
                ApexPages.currentPage().getParameters().get(key) != null
                &&
                (
                    (key != 'succesUrl'  && key != 'errorUrl')
                    ||
                    ( (key == 'successUrl' || key == 'errorURl') && IDENTITY_Utils.isAllowedUrl(ApexPages.currentPage().getParameters().get(key), paths, origin))
                )
                
              ) {
                ApexPages.currentPage().setCookies(new List<Cookie>{
                    new Cookie(PARAM_PREFIX + key, ApexPages.currentPage().getParameters().get(key), '', 25000, true)
                });           
            }
        }

        // FOR DEBUG
        System.debug('PATHS');
        for(String key : paths.keySet()){
            System.debug(key + ' ' + paths.get(key));
        }
    }

    /*
    *** DESCRIPTION Set variables for GG Analytics User Tracking (social_login_succeeded/failed)
    *** RETURN      
    */
    public void setUserTracking(){
        
        userTracking = false; // by default

        // CLIENT ID
        if(ApexPages.currentPage().getCookies().get('clientId') != null && ApexPages.currentPage().getCookies().get('clientId').getValue() != null){ // GG cookie is only retrievable in Prod
            clientId = ApexPages.currentPage().getCookies().get('clientId').getValue();
        }
        else{
            clientId = Identity_Utils.getRandomClientId();
        }
        
        // TRACKING ID
        trackingId = [  SELECT Value__c 
                        FROM IDENTITY_Registration_Form__mdt 
                        WHERE Section__c = 'Settings' 
                        AND Context__c =: lang_country 
                        AND Field__c = 'Analytics_TID'
                    ].Value__c;
        
        // userStartUrl
        if(ApexPages.currentPage().getParameters().get('userStartUrl') != null)
        {
            System.debug('userStartUrl retrieved by Get params');
            userStartUrl = ApexPages.currentPage().getParameters().get('userStartUrl').escapeHtml4();
        }
        else if(ApexPages.currentPage().getCookies().get('userStartUrl') != null)
        {
            System.debug('userStartUrl retrieved by Cookie');
            userStartUrl = (String) ApexPages.currentPage().getCookies().get('userStartUrl').getValue();
        }

        // devStartUrl
        if(ApexPages.currentPage().getParameters().get('devStartUrl') != null)
        {
            devStartUrl = ApexPages.currentPage().getParameters().get('devStartUrl').escapeHtml4();
        }
        else if(ApexPages.currentPage().getCookies().get('devStartUrl') != null)
        {
            devStartUrl = (String) ApexPages.currentPage().getCookies().get('devStartUrl').getValue();
        }

        // userStartDomain
        if(devStartUrl != null)
        {
            if(devStartUrl == 'login' || devStartUrl == 'registration')
            {
                userStartDomain = paths.get(ACCOUNT_DOMAIN);
            }
            else 
            {
                userStartDomain = paths.get(DOMAIN);
            }    
        }

        /*
        System.debug('SET USER TRACKING');
        System.debug('userStartUrl: '+userStartUrl);
        System.debug('devStartUrl: '+devStartUrl);
        System.debug('userStartDomain: '+userStartDomain);
        System.debug('trackingId: '+trackingId);
        System.debug('clientId: '+clientId);
        */
    }
    
    /*
    *** DESCRIPTION Redirect to Salesforce link according rules
    *** RETURN      New PageReference 
    */
    public PageReference redirect() {
        
        String social_media = ApexPages.currentPage().getParameters().get('social_media');
        String error = ApexPages.currentPage().getParameters().get('ErrorCode');
        String access_token = ApexPages.currentPage().getParameters().get('access_token');
        String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');    
        
        PageReference successURL;

        // LOGIN CONNECTED APP 
        if(!String.isEmpty(access_token)){
            
            System.debug('LOGIN CONNECTED APP');

            String startUrl;
       
            // FROM URL PARAMETER 
            String retURL = ApexPages.currentPage().getParameters().get('redirectURL');
            if(retURL != null){
                startUrl = EncodingUtil.urlDecode(retURL, 'UTF-8');
            }

            // FROM COOKIES
            Cookie redirectURL = ApexPages.currentPage().getCookies().get('redirectURL');
            if(startUrl == null && redirectURL != null){
                startUrl = redirectURL.getValue();
            }

            // FROM SETTINGS
            if(startUrl == null){
                startUrl = paths.get(SECURE_DOMAIN) + paths.get('Registration Success Path');
            }
            
            successURL = new PageReference(startUrl);
            successURL.getParameters().put('access_token', access_token);

            // GOOGLE ANALYTICS TRACKING
            if(userStartUrl != null && devStartUrl != null)
            {
                userTracking = true;
                eventLabel = 'social_login_succeeded';
                connexionStatus = 'logged_user';
            }
        }
        // SSO
        else if(!String.isEmpty(social_media)){
            
            System.debug('SSO');
            
            // Redirection for WeChat Mobile users 
            if(String.isNotEmpty(userAgent) && userAgent.contains('Mobile') && social_media == 'WeChat'){
                social_media += '_Mobile';
            }

            successURL = new PageReference('/services/auth/sso/' + social_media);

            // ADD CURRENT PARAMETERS
            for(String key : ApexPages.currentPage().getParameters().keyset()){
                successURL.getParameters().put(key, ApexPages.currentPage().getParameters().get(key));
            }

            // REDIRECTION PARAMETERS
            String startURL = IDENTITY_Utils.getOauthUserAgentUrl(paths.get(REDIRECTION_PAGE), origin);

            successURL.getParameters().put('community', IDENTITY_Settings__c.getInstance().Community_URL__c);
            successURL.getParameters().put('startURL', startURL);

            // GOOGLE ANALYTICS TRACKING
            if(userStartUrl != null && devStartUrl != null)
            {
                ApexPages.currentPage().setCookies(new List<Cookie>{
                    new Cookie('userStartUrl', userStartUrl, '', 25000, true),
                    new Cookie('devStartUrl', devStartUrl, '', 25000, true)
                });
                
                userTracking = true;
                eventLabel = 'social_login_intention';
                connexionStatus = 'not_logged_user';
            }
        }
        // SOCIAL REGISTRATION
        else if(!String.isEmpty(error)){
            
            System.debug('SOCIAL REGISTRATION');

            successURL = new PageReference('/' + lang_country + '/' + origin + '/registration');

            String social_id = ApexPages.currentPage().getParameters().get('ErrorDescription');
            successURL.getParameters().put('social_id', social_id);
            
            if(userStartUrl != null && devStartUrl != null){
                successURL.getParameters().put('userStartUrl', userStartUrl.escapeHtml4());
                successURL.getParameters().put('devStartUrl', devStartUrl.escapeHtml4());
            }

            // Retrieve params from Cookies
            Map<String,String> params = new Map<String,String>();
            for(String key : ApexPages.currentPage().getCookies().keyset()){
                if(key.contains(PARAM_PREFIX) && ApexPages.currentPage().getCookies().get(key) != null) {
                    String cookieName = key.substringAfter(PARAM_PREFIX);
                    String cookieValue = ApexPages.currentPage().getCookies().get(key).getValue();
                    params.put(cookieName, cookieValue);
                }
            }
            successURL.getParameters().putAll(params);

            try{
                // IF FAIL => REAL ERROR
                EncodingUtil.base64Decode(social_id).toString();
                System.debug('CUSTOM ERROR FLOW');
            }
            catch(Exception ex){
                successURL = new PageReference('/' + lang_country + '/' + origin + '/Exception');
                Map<String,String> debugInfo = new Map<String,String>();
            	String providerId = String.valueOf(ApexPages.currentPage().getParameters().get('ProviderId'));
                if (prodiverIsLine(providerId)) {
                    addAdditionalDebugInfo(debugInfo);
                }
                else{
                    debugInfo = params;
                }
                new Logs(new Map<String,Object> {
                    'level' => 'ERROR', 
                    'apexClass' => 'IDENTITY_RegistrationHandler', 
                    'category' => 'APEX CODE',
                    'message' => social_id,
                    'recordId' => providerId,
                    'status_code' => error,
                    'application' => origin,
                    'details' => JSON.serialize(debugInfo)
                });
                System.debug('SYSTEM ERROR FLOW');

                // GOOGLE ANALYTICS TRACKING
                if(userStartUrl != null && devStartUrl != null)
                {
                    userTracking = true;
                    eventLabel = 'social_login_failed';
                    connexionStatus = 'not_logged_user';
                }
            }
        }
        // ERROR
        else {
            System.debug('ERROR');

            String error_url = paths.get(DOMAIN) + paths.get('Error Path');
            successURL = new PageReference(error_url);

            // GOOGLE ANALYTICS TRACKING
            if(userStartUrl != null && devStartUrl != null)
            {
                userTracking = true;
                eventLabel = 'social_login_failed';
                connexionStatus = 'not_logged_user';
            }
        }

        // FOR DEBUG
        System.debug('RETURNED URL ' + successURL.getUrl());
        System.debug('RETURNED PARAMS');
        for(String key : successURL.getParameters().keySet()){
            System.debug(key + ' ' + successURL.getParameters().get(key));
        }
        System.debug('COOKIES');
        for(String key : ApexPages.currentPage().getCookies().keyset()){
            System.debug(key + ' ' + ApexPages.currentPage().getCookies().get(key).getValue());
        }
        
        if(userTracking)
        {
            System.debug('TRACKING IS FIRED');
            
            if(devStartUrl == 'login')
            {
                eventCategory = 'mylv';
                eventAction = 'i_already_have_an_account';
                pageName = 'mylv/identification';
                pageType = 'connexion_module';
            }
            else if(devStartUrl == 'registration')
            {
                eventCategory = 'mylv';
                eventAction = 'create_an_account_form_sf';
                pageName = 'mylv/account_creation';
                pageType = 'account_creation';
            }
            else // social login from site (ATG side)
            // "mylv" for the authentification page
            // "buypath" for the checkout in the authentification page
            // "header" in the menu
            {
                eventCategory = devStartUrl;
                eventAction = 'i_already_have_an_account';
                pageName = 'mylv/identification';
                pageType = 'connexion_module';
            }

            try{
                // SEND SOCIAL LOGIN EVENT TO GG ANALYTICS
                IDENTITY_GoogleAnalytics_Utils.sendEvent(
                            trackingId,
                            clientId,
                            origin,
                            googleAnalyticsConfig.get('environmentType'),
                            googleAnalyticsConfig.get('environmentId'),
                            country_local,
                            lang_country,
                            eventCategory,
                            eventAction,
                            eventLabel,
                            userStartDomain + userStartUrl,
                            connexionStatus,
                            pageName,
                            pageType);
            }
            catch(Exception ex){
                System.debug('An error occured: ' + ex.getMessage() + ex.getStackTraceString());
            }
        }

        return successURL;
    }


    private Boolean prodiverIsLine(String providerId) {
        List<AuthProvider> aList = [SELECT Id FROM AuthProvider WHERE DeveloperName = 'Line' LIMIT 1];
        if (aList.size() == 0) {
            return false;
        }
        String id = (String) aList.get(0).Id;
        return id.substring(0,15).equals(providerId); // providerId size is 15, Id Idsize is 18
    }

    private void addAdditionalDebugInfo(Map<String,String> debugInfo) {
        PageReference page = ApexPages.currentPage();
        Map<String,Object> additionalInfo = new Map<String,Object> {
            'headers' => page.getHeaders(),
            'parameters' => page.getParameters(),
            'redirect' => page.getRedirect(),
            'redirectCode' => page.getRedirectCode(),
            'url' => page.getUrl()
        };
        Map<String,String> cookies = new Map<String,String>();
        for (String key: page.getCookies().keySet()) {
            cookies.put(key, String.valueOf(page.getCookies().get(key)));
        }
        additionalInfo.put('cookies', cookies);
        debugInfo.put('additionalInfo', JSON.serialize(additionalInfo));
    }
}