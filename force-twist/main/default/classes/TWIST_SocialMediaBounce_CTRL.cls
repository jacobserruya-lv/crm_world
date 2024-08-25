// JSSI check code coverage of this class: some code has been added
public with sharing class TWIST_SocialMediaBounce_CTRL {
    
    public String utagDataStringified {get; set;}
    public String utagDataScript {get; set;}
    public String lwcAttributes {get; set;} // used by the TwistGoogleAnalytics LWC
    
    public String flowStepDebug {get; set;} // JSSI remove
    public String debug {get; set;} // JSSI remove

    private Map<String,String> currentPageParams;
    private Map<String,Cookie> currentPageCookies;
    
    private String origin;
    private String langCountry;
    private String dispatchCountry;
    private String page;

    
    public final String PARAM_PREFIX = 'param_';
    
    private enum FlowStep {
        BOUNCE_FROM_SALESFORCE_TO_SOCIAL_MEDIA,
        BOUNCE_FROM_SOCIAL_MEDIA_TO_SALESFORCE,
        SOCIAL_REGISTRATION,
        ERROR
    }
    
    public TWIST_SocialMediaBounce_CTRL() {
        system.debug('> TWIST_SocialMediaBounce_CTRL');
        this.initClassAttributes();
        this.setHardcodedQueryParamsForGA(); // JSSI remove
        system.debug('> flow step: ' + this.getFlowStep(this.currentPageParams));
        system.debug('> currentPageParams: ' + this.currentPageParams);
        this.processAsPerFlowStep(this.getFlowStep(this.currentPageParams));

        this.flowStepDebug = this.getFlowStep(this.currentPageParams).name(); // JSSI remove
    }
    
    private void setHardcodedQueryParamsForGA() { // JSSI remove
        this.currentPageParams.put(TWIST_QueryParamKey_CONST.USER_START_URL, '/jpn-jp/homepage');
        this.currentPageParams.put(TWIST_QueryParamKey_CONST.DEV_START_URL, 'header');
    }
    
    /******************************************************************************************************************************** */
    
    private void initClassAttributes() {
        this.currentPageParams = ApexPages.currentPage().getParameters();
        this.currentPageCookies = ApexPages.currentPage().getCookies();
        this.origin = this.getOrigin();
        this.langCountry = this.getLangCountry();
        this.dispatchCountry = this.getDispatchCountry();
        this.page = this.getPage();

        // this.debug = JSON.serializePretty(new Map<String,String> { // JSSI remove
        //     'origin' => this.origin,
        //     'langCountry' => this.langCountry,
        //     'dispatchCountry' => this.dispatchCountry,
        //     'page' => this.page
        // });
        
        this.utagDataStringified = TWIST_GoogleAnalytics_Utils.buildUtagDataObjectFromCurrentPageParams(
            this.origin,
            this.langCountry,
            this.dispatchCountry,
            this.page
        );
        this.utagDataScript = TWIST_Settings__c.getInstance().Utag__c;
    }
    
    private void processAsPerFlowStep(FlowStep step) {
        String redirectUrl;
        Map<String,String> gaMetadata = this.buildGoogleAnalyticsMetadata();
        Map<String,Object> payloadForAutodata;
        
        system.debug('> step: ' + step); // JSSI remove
        switch on step {
            when BOUNCE_FROM_SALESFORCE_TO_SOCIAL_MEDIA {
                redirectUrl = this.processWhenBouncingFromSalesforceToSocialMedia();
                payloadForAutodata = new Map<String,String> {
                    'categoryGa' => 'mylv',
                    'actionId' => 'social_login_intention',
                    'actionGa' => 'i_already_have_an_account',
                    'labelGa' => 'social_login_intention',
                    'event' => 'click'
                };
                this.setBrowserCookies();
            }
            
            when BOUNCE_FROM_SOCIAL_MEDIA_TO_SALESFORCE {
                redirectUrl = this.processWhenBouncingFromSocialMediaToSalesforce();
                payloadForAutodata = new Map<String,String> {
                    'categoryGa' => 'mylv',
                    'actionId' => 'social_login_succeeded',
                    'actionGa' => 'i_already_have_an_account',
                    'labelGa' => 'social_login_succeeded',
                    'event' => 'loginSuccess'
                };
            }
            
            when SOCIAL_REGISTRATION {
                if (!StringUtils.isValidBase64(this.currentPageParams.get(TWIST_QueryParamKey_CONST.ERROR_DESCRIPTION))) {
                    redirectUrl = this.processWhenError();
                    payloadForAutodata = new Map<String,String> {
                        'categoryGa' => 'mylv',
                        'actionId' => 'social_login_failed',
                        'actionGa' => 'i_already_have_an_account',
                        'labelGa' => 'social_login_failed',
                        'event' => 'loginFailure',
                        'errorId' => 'Query param ErrorDescription is not a valid base64: ' + this.currentPageParams.get(TWIST_QueryParamKey_CONST.ERROR_DESCRIPTION)
                    };
                }
                else {
                    redirectUrl = this.processWhenSocialRegistration();
                    payloadForAutodata = null;
                }
            }
            
            when ERROR {
                redirectUrl = this.processWhenError();
                payloadForAutodata = new Map<String,String> {
                    'categoryGa' => 'mylv',
                    'actionId' => 'social_login_failed',
                    'actionGa' => 'i_already_have_an_account',
                    'labelGa' => 'social_login_failed',
                    'event' => 'loginFailure',
                    'errorId' => 'Flow step set to FlowStep.ERROR'
                };
            }
        }
        
        system.debug('> redirectUrl: ' + redirectUrl);
        this.lwcAttributes = JSON.serialize(new Map<String,Object> {
            'redirectUrl' => redirectUrl,
            'payloadForAutodata' => payloadForAutodata
        });
    }

    private void setBrowserCookies() {
        this.setCookie(TWIST_QueryParamKey_CONST.ORIGIN, this.currentPageParams.get(TWIST_QueryParamKey_CONST.ORIGIN));
        this.setCookie(TWIST_QueryParamKey_CONST.LANG_COUNTRY, this.currentPageParams.get(TWIST_QueryParamKey_CONST.LANG_COUNTRY));
        this.setCookie(TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY, this.currentPageParams.get(TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY)); // JSSI useless in Twist?
        this.setCookie(TWIST_QueryParamKey_CONST.PAGE, this.currentPageParams.get(TWIST_QueryParamKey_CONST.PAGE));
        this.setCookie(TWIST_QueryParamKey_CONST.USER_START_URL, this.currentPageParams.get(TWIST_QueryParamKey_CONST.USER_START_URL));
        this.setCookie(TWIST_QueryParamKey_CONST.DEV_START_URL, this.currentPageParams.get(TWIST_QueryParamKey_CONST.DEV_START_URL));
        this.setCookie(TWIST_QueryParamKey_CONST.REDIRECT_URL, this.currentPageParams.get(TWIST_QueryParamKey_CONST.SUCCESS_URL)); // JSSI useless in Twist?
        
        // Save in Cookies all POST/GET params with prefix pattern (especially for successUrl, errorUrl, domain)
        this.debug = 'setting cookies: '; // JSSI remove
        for (String key : this.currentPageParams.keyset()){ // JSI pas clair si nécessaire dans Twist
            if (this.currentPageParams.get(key) != null ) {
                this.debug += PARAM_PREFIX + key + '=' + this.currentPageParams.get(key) + ' | '; // JSSI remove
                this.setCookie(PARAM_PREFIX + key, this.currentPageParams.get(key));
            }
        }
    }
    
    private Map<String,String> buildGoogleAnalyticsMetadata() {
        String userStartUrl;
        if(this.currentPageParams.get(TWIST_QueryParamKey_CONST.USER_START_URL) != null) {
            userStartUrl = this.currentPageParams.get(TWIST_QueryParamKey_CONST.USER_START_URL).escapeHtml4();
        }
        else if(this.currentPageCookies.get(TWIST_QueryParamKey_CONST.USER_START_URL) != null) {
            userStartUrl = this.currentPageCookies.get(TWIST_QueryParamKey_CONST.USER_START_URL).getValue();
        }
        
        String devStartUrl;
        if(this.currentPageParams.get(TWIST_QueryParamKey_CONST.DEV_START_URL) != null) {
            devStartUrl = this.currentPageParams.get(TWIST_QueryParamKey_CONST.DEV_START_URL).escapeHtml4();
        }
        else if(this.currentPageCookies.get(TWIST_QueryParamKey_CONST.DEV_START_URL) != null) {
            devStartUrl = (String) this.currentPageCookies.get(TWIST_QueryParamKey_CONST.DEV_START_URL).getValue();
        }
        
        String userStartDomain;
        if(devStartUrl != null) {
            userStartDomain = (devStartUrl == TWIST_QueryParamValue_CONST.DEV_START_URL_LOGIN || devStartUrl == TWIST_QueryParamValue_CONST.DEV_START_URL_REGISTRATION)
            ? TWIST_UrlUtils.getCommunityUrl(true)
            : TWIST_UrlUtils.getLvSiteBaseUrl();
        }
        return new Map<String,String> {
            TWIST_QueryParamKey_CONST.USER_START_URL => userStartUrl,
            TWIST_QueryParamKey_CONST.DEV_START_URL => devStartUrl,
            TWIST_QueryParamKey_CONST.USER_START_DOMAIN => userStartDomain
        };
    }
    
    private FlowStep getFlowStep(Map<String,String> pageParams) {
        if (String.isNotEmpty(pageParams.get(TWIST_QueryParamKey_CONST.SOCIAL_MEDIA))) {
            return FlowStep.BOUNCE_FROM_SALESFORCE_TO_SOCIAL_MEDIA;
        }
        if (String.isNotEmpty(pageParams.get(TWIST_QueryParamKey_CONST.ACCESS_TOKEN_SNAKE_CASE))) {
            return FlowStep.BOUNCE_FROM_SOCIAL_MEDIA_TO_SALESFORCE;
        }
        if (String.isNotEmpty(pageParams.get(TWIST_QueryParamKey_CONST.ERROR_CODE))) {
            return FlowStep.SOCIAL_REGISTRATION;
        }
        return FlowStep.ERROR;
    }
    
    /**
    * @return page to redirect to, from the TwistSocialMediaBounceWrapper LWC
    */
    private String processWhenBouncingFromSalesforceToSocialMedia() {
        String redirectUrl = String.format(
            '{0}services/auth/sso/{1}',
            new List<String> {
                TWIST_UrlUtils.getCommunityUrl(true),
                this.buildAuthProviderName()
            }
        );
        
        PageReference page = new PageReference(redirectUrl);
        Map<String,String> pageParams = page.getParameters();
        // ADD CURRENT PARAMETERS
        pageParams.putAll(this.currentPageParams);
        // REDIRECTION PARAMETERS
        String tmpStartUrl = TWIST_Utils.buildGetAuthorizationCodeUrl(
            this.currentPageParams.get(TWIST_QueryParamKey_CONST.STATE),
            this.currentPageParams.get(TWIST_QueryParamKey_CONST.CODE_CHALLENGE),
            this.currentPageParams.get(TWIST_QueryParamKey_CONST.CLIENT_ID),
            this.currentPageParams.get(TWIST_QueryParamKey_CONST.REDIRECT_URI)
        );
        String startUrl = this.addExtraQueryParamsToBuildUtagDataObjectWhenBackFromSocialMedia(tmpStartUrl);
        pageParams.put(TWIST_QueryParamKey_CONST.START_URL, startUrl); // JSSI check: likely to be useless
        return page.getUrl();
    }
    
    /**
    * @return page to redirect to, from the TwistSocialMediaBounceWrapper LWC
    */
    private String processWhenBouncingFromSocialMediaToSalesforce() {
        String redirectUrl;
        // this.debug = ApexPages.currentPage().getParameters().get(TWIST_QueryParamKey_CONST.START_URL); // JSSI remove
        
        // FROM URL PARAMETER
        String redirectUrlParam = ApexPages.currentPage().getParameters().get(TWIST_QueryParamKey_CONST.REDIRECT_URL);
        if(redirectUrlParam != null){
            redirectUrl = EncodingUtil.urlDecode(redirectUrlParam, 'UTF-8');
        }
        
        // FROM COOKIES
        Cookie redirectUrlCookie = ApexPages.currentPage().getCookies().get(TWIST_QueryParamKey_CONST.REDIRECT_URL);
        if(redirectUrl == null && redirectUrlCookie != null){
            redirectUrl = redirectUrlCookie.getValue();
        }
        
        return redirectUrl;
    }
    
    /**
    * @return page to redirect to, from the TwistSocialMediaBounceWrapper LWC
    */
    private String processWhenSocialRegistration() {
        String socialId = this.currentPageParams.get(TWIST_QueryParamKey_CONST.ERROR_DESCRIPTION);
        Map<String,String> queryParams = new Map<String,String> {
            TWIST_QueryParamKey_CONST.ORIGIN => this.origin,
            TWIST_QueryParamKey_CONST.LANG_COUNTRY => this.langCountry,
            TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY => this.dispatchCountry,
            TWIST_QueryParamKey_CONST.SOCIAL_ID => socialId
        };
        // JSSI code below seems useless; if yes, remove
        // Retrieve params from Cookies
        // for(String key : this.currentPageCookies.keyset()){
        //     if(key.contains(PARAM_PREFIX) && !queryParams.containsKey(key.substringAfter(PARAM_PREFIX))) {
        //         queryParams.put(key.substringAfter(PARAM_PREFIX), this.currentPageCookies.get(key).getValue());
        //     }
        // }

        for (String key : new List<String> { TWIST_QueryParamKey_CONST.STATE, TWIST_QueryParamKey_CONST.CODE_CHALLENGE, TWIST_QueryParamKey_CONST.CLIENT_ID, TWIST_QueryParamKey_CONST.REDIRECT_URI }){
            if (this.currentPageCookies.containsKey(PARAM_PREFIX + key)) {
                queryParams.put(key, this.currentPageCookies.get(PARAM_PREFIX + key).getValue());
            }
        }
        
        if (!StringUtils.isValidBase64(socialId)) {
            this.handleErrorWhenProcessingSocialRegistration(queryParams);
            return this.build404Url();
        }
        this.debug = JSON.serialize(queryParams); // JSSI remove
        return TWIST_Utils.buildTwistPageUrl(TWIST_IdentityPathsMdt_CONST.REGISTRATION_FORM, queryParams);
    }
    
    /**
    * @return page to redirect to, from the TwistSocialMediaBounceWrapper LWC
    */
    private String processWhenError() {
        return this.build404Url();
    }
    
    private void setCookie(String name, String value) {
        ApexPages.currentPage().setCookies(new List<Cookie> { new Cookie(name, value, '', 25000, true) });
    }
    
    private String build404Url() {
        return TWIST_Utils.buildTwistPageUrl(TWIST_IdentityPathsMdt_CONST.ERROR404, new Map<String,Object> {
            TWIST_QueryParamKey_CONST.LANG_COUNTRY => this.langCountry,
            TWIST_QueryParamKey_CONST.ORIGIN => this.origin,
            TWIST_QueryParamKey_CONST.CLIENT_ID => this.currentPageParams.get(TWIST_QueryParamKey_CONST.CLIENT_ID)
        });
    }
    
    @TestVisible
    private void handleErrorWhenProcessingSocialRegistration(Map<String,String> queryParams) {
        String providerId = this.currentPageParams.get(TWIST_QueryParamKey_CONST.PROVIDER_ID);
        Map<String,String> debugInfo = this.prodiverIsLine(providerId) ? this.buildDebugInfoForLine() : queryParams;
        new Logs(new Map<String,Object> {
            'level' => 'ERROR',
            'apexClass' => 'TWIST_SocialMediaBounce_CTRL',
            'category' => 'APEX CODE',
            'message' => queryParams.get(TWIST_QueryParamKey_CONST.SOCIAL_ID),
            'recordId' => providerId,
            'status_code' => this.currentPageParams.get(TWIST_QueryParamKey_CONST.ERROR_CODE),
            'application' => this.origin,
            'details' => JSON.serialize(debugInfo)
        });
    }
    
    private Boolean prodiverIsLine(String providerId) {
        List<AuthProvider> aList = [SELECT Id FROM AuthProvider WHERE DeveloperName = 'LineLV' LIMIT 1];
        if (aList.size() == 0) {
            return false;
        }
        String id = (String) aList.get(0).Id;
        return id.substring(0,15).equals(providerId); // providerId size is 15, Id Idsize is 18
    }
    
    private Map<String,String> buildDebugInfoForLine() {
        PageReference page = ApexPages.currentPage();
        Map<String,String> debugInfo = new Map<String,String>();
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
        return debugInfo;
    }
    
    private String buildAuthProviderName() {
        List<TWIST_Social_Media__mdt> socialMedia = [
            SELECT Auth_Provider_Name__c
            FROM TWIST_Social_Media__mdt
            WHERE Page_Key__c = :this.currentPageParams.get(TWIST_QueryParamKey_CONST.SOCIAL_MEDIA)
            AND Lang_Country__c = :this.langCountry
            LIMIT 1];
        String authProviderName = socialMedia.get(0).Auth_Provider_Name__c;
        if (authProviderName == 'WeChat') {
            String userAgent = ApexPages.currentPage().getHeaders().get(TWIST_QueryParamKey_CONST.USER_AGENT_UPPERCASE);
            if (String.isNotEmpty(userAgent) && userAgent.contains('Mobile')) {
                authProviderName += '_Mobile';
            }
        }
        return authProviderName;
    }

    private String addExtraQueryParamsToBuildUtagDataObjectWhenBackFromSocialMedia(String startUrl) {
        PageReference page = new PageReference(startUrl);
        Map<String,String> pageParams = page.getParameters();
        pageParams.put(TWIST_QueryParamKey_CONST.ORIGIN, this.currentPageParams.get(TWIST_QueryParamKey_CONST.ORIGIN));
        pageParams.put(TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY, this.currentPageParams.get(TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY));
        pageParams.put(TWIST_QueryParamKey_CONST.LANG_COUNTRY, this.currentPageParams.get(TWIST_QueryParamKey_CONST.LANG_COUNTRY));
        pageParams.put(TWIST_QueryParamKey_CONST.PAGE, this.currentPageParams.get(TWIST_QueryParamKey_CONST.PAGE));
        return page.getUrl();
    }

    private String getOrigin() {
        if (String.isNotEmpty(this.currentPageParams.get(TWIST_QueryParamKey_CONST.ORIGIN))) {
            return this.currentPageParams.get(TWIST_QueryParamKey_CONST.ORIGIN);
        }
        if (this.currentPageCookies.get(TWIST_QueryParamKey_CONST.ORIGIN) != null) {
            return this.currentPageCookies.get(TWIST_QueryParamKey_CONST.ORIGIN).getValue();
        }
        return IDENTITY_Settings__c.getInstance().Default_Origin_Parameter__c;
    }

    
    private String getLangCountry() {
        if (String.isNotEmpty(this.currentPageParams.get(TWIST_QueryParamKey_CONST.LANG_COUNTRY))) {
            return this.currentPageParams.get(TWIST_QueryParamKey_CONST.LANG_COUNTRY);
        }
        if (this.currentPageCookies.get(TWIST_QueryParamKey_CONST.LANG_COUNTRY).getValue() != null) {
            return this.currentPageCookies.get(TWIST_QueryParamKey_CONST.LANG_COUNTRY).getValue();
        }
        return IDENTITY_Settings__c.getInstance().Default_Language_Country_Parameter__c;
    }
    
    private String getDispatchCountry() {
        if (String.isNotEmpty(this.currentPageParams.get(TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY))) {
            return this.currentPageParams.get(TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY);
        }
        if (this.currentPageCookies.containsKey(TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY) && this.currentPageCookies.get(TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY).getValue() != null) {
            return this.currentPageCookies.get(TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY).getValue();
        }
        return '';
    }

    private String getPage() {
        if (String.isNotEmpty(this.currentPageParams.get(TWIST_QueryParamKey_CONST.PAGE))) {
            return this.currentPageParams.get(TWIST_QueryParamKey_CONST.PAGE);
        }
        if (this.currentPageCookies.containsKey(TWIST_QueryParamKey_CONST.PAGE) && this.currentPageCookies.get(TWIST_QueryParamKey_CONST.PAGE).getValue() != null) {
            return this.currentPageCookies.get(TWIST_QueryParamKey_CONST.PAGE).getValue();
        }
        return '';
    }

    
}