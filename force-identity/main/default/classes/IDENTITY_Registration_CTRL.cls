/**
    About
    -----
    Description: Controller for IDENTITY_Registration VisualForce Page
    Created for: Identity project
    Create date: Oct 2018

    Details
    -------
    Called for registration of MyLV Account from Louis Vuitton Site
    Used also for social registration from social login flow
*/
global without sharing class IDENTITY_Registration_CTRL {

    // METADATA
    public Map<String,Map<String,IDENTITY_Registration_Form__mdt>> fields {get; set;}
    public Map<String,String> paths {get; set;}
    public IDENTITY_Registration_Form_Settings__c form_settings {get; set;}
    public IDENTITY_Settings__c identity_settings {get; set;}
    public Boolean hideCountryList {get; set;}

      /*
    *** DESCRIPTION Get list for country select 
    ***             if only one country for lang_country : select country and hide field
    ***             if multiple countries for lang_country (param dispatchCountry) : display only these countries
    ***             if default value for lang_country (eng-e1) : display all countries besides the ones related to specific lang_country
	***             Resolve picklist translation with correct locale
    *** RETURN      
    */
    
    public List<CountryMapping__mdt> countries_values {
        get
        {
		hideCountryList = false;
        String CountryListType;
        List<CountryLanguage__c> countriesPerCountryLang = new List<CountryLanguage__c>();
        List<String> dispatchCountries = new List<String>();
        List<String> countriesWithCountryLang = new List<String>();

        if(!String.isEmpty(fields.get('Personal').get('country').Value__c)){
            if(String.isEmpty(dispatch_country)){
                CountryListType = 'SPECIFIC';
                hideCountryList = true;
            } 
            else{
                countriesPerCountryLang = [SELECT Dispatch_Country__c FROM CountryLanguage__c WHERE ATG_LOCALE__c =: lang_country AND Dispatch_Country__c != null];
                if(countriesPerCountryLang.isEmpty() || countriesPerCountryLang.size() == 1){
                    CountryListType = 'SPECIFIC';
                    hideCountryList = true;
                }  
                else{
                    CountryListType = 'DISPATCH';
                    for(CountryLanguage__c c: countriesPerCountryLang){
                        if(!String.isBlank(c.Dispatch_Country__c)){
                            dispatchCountries.add(String.valueOf(c.Dispatch_Country__c));
                        }
                     } 
                 }  
            }
        }
        else{
            CountryListType = 'ALL';
            List<CountryLanguage__c> allDispatchCountries = [SELECT Dispatch_Country__c FROM CountryLanguage__c WHERE Dispatch_Country__c != null];
            for(CountryLanguage__c c: allDispatchCountries){
                countriesWithCountryLang.add(String.valueOf(c.Dispatch_Country__c));
            } 
            List<IDENTITY_Registration_Form__mdt> allUniqueCountries = [SELECT Value__c FROM IDENTITY_Registration_Form__mdt WHERE Field__c ='country' and Value__c !=null];
            for(IDENTITY_Registration_Form__mdt c: allUniqueCountries){
                countriesWithCountryLang.add(String.valueOf(c.Value__c));
            }
        }
        
        Map<String,String> country_picklist = new Map<String,String>();
        List<CountryMapping__mdt> clist = [SELECT Picklist__c, Iso2Code__c FROM CountryMapping__mdt WHERE Picklist__c != null];
        for(CountryMapping__mdt mdt: clist) {
            //only one country for lang_country 
            if(CountryListType == 'SPECIFIC'){
                if(mdt.ISO2Code__c == fields.get('Personal').get('country').Value__c){
                    country_picklist.put(mdt.Picklist__c, mdt.ISO2Code__c);
                }  
            }
             //multiple countries for lang_country (param dispatchCountry)
            else if(CountryListType == 'DISPATCH'){
                if(dispatchCountries.contains(mdt.ISO2Code__c)){
                    country_picklist.put(mdt.Picklist__c, mdt.ISO2Code__c);
                  }
               
            }
            //default: all countries besides specific ones
            else{
                if(!countriesWithCountryLang.contains(mdt.ISO2Code__c)){
                    country_picklist.put(mdt.Picklist__c, mdt.ISO2Code__c);
                }
            }      
        }           
        countries_values = new List<CountryMapping__mdt>();
        for (PicklistEntry entry : CountryMapping__mdt.Picklist__c.getDescribe().getPicklistValues())
        {
            if(country_picklist.get(entry.getValue()) != null){
                countries_values.add(new CountryMapping__mdt(Picklist__c = entry.getLabel(), Iso2Code__c = country_picklist.get(entry.getValue())));
            }
        }
     	return countries_values;
     }
        private set;
    }
    public Map<String,String> country_mapping {get;set;}
    public Map<String,String> country_iso_mapping {get;set;}
    public Map<String,String> code_mapping {get;set;}
    public String captcha_url {get; set;}
    public String captcha_appId {get; set;}
    public String captcha_ticket {get; set;}
    public String captcha_randstr {get; set;}

    // SETUP
    public String mode {get; set;}
    public String sub_mode {get; set;}
    public Boolean isLoading {get; set;}
    public Boolean isConfirmed {get; set;}
    public Boolean isCreated {get; set;}
    public String registrationException {get; set;}
    public Boolean isValidCaptcha {get; set;}
    public Integer expanded_kisa_details_index {get; set;}
    public Boolean isUnverifiedSenderAddress {get;set;}
    public Boolean isSocialLoginActive {get;set;}
    public Boolean isSocialLoginAG {get;set;}
    public Boolean isDevMode {get; set;}
    public String tealiumEnv {get; set;}
    public Boolean isNewDesignActive {get; set;}
    public String browser {get; set;}
    public String page {get; set;}
    public Integer passwordMaxlength {get; set;}
    public Boolean koreaAddressFields {get; set;} 
    public Boolean korea_lang_country {get; set;} 

    //VERIFICATION SENDING STATUS
    public Boolean isSentSuccess {get;set;}
    public Boolean isSentLimitReached {get;set;}

    // COUNTER
    public Integer counter_message {get; set;}

    // FORM
    public Account account {get; set;}
    public Account account_activation {get; set;}
    public Client client {get; set;}
    public Client client_origin {get; set;} 
    public String client_country {get; set;}
    public String client_login_email {get; set;}
    public String client_login_international_mobile_phone {get; set;}
    public String fname {get; set;}
    public String input_code {get; set;}
    public String social_id {get; set;}
    private Map<String, Datetime> verification_codes {get; set;}
    public User user {get; set;}
    public String password {get; set;}
    public String username {get; set;}
    public Map<String, String> social_params {get; set;}
    public Boolean isEmailFieldVisible {get; set;}
    public String checkoutPreviousPage {get; set;}
    public Boolean isWeChatVisible {get; set;}
    public Boolean isSocialLoginVisible {get; set;}
    public String customCss {get;set;}
    public String privacyPolicyLink {get;set;}

    // PREVENT EMAIL/MOBILE UPDATE
    public String validationCodeEmail {get;set;}
    public String validationCodeMobile {get;set;}

    // URL PARAMETERS
    public String lang_country {get; set;}
    public String origin {get; set;}
    public String dispatch_country {get; set;}
    public String country_local {get; set;}
    public String language {get; set;}
    public String meta_language {get; set;}
    public String currentUrl {get; set;}

    // GG ANALYTICS
    public Boolean userTracking {get; set;}
    public String eventCategory {get; set;}
    public String eventLabel {get; set;}
    public String eventAction {get; set;}
    public String connexionStatus {get; set;}
    public String pageName {get; set;}
    public String pageType {get; set;}
    public String userStartUrl {get; set;}
    public String devStartUrl {get; set;}  
    public String trackingId {get;set;}
    public String clientId {get;set;}
    public Map<String,String> googleAnalyticsConfig {get; set;}

    // URL PARAMETERS FOR ACTIVATION FORM CONTEXT
    public String accountId {get; set;}
    public String cid {get; set;}
    public String cidUrlEncoded {get; set;}
    public Boolean isTrustOrigin {get; set;}
    public Boolean redirectToLvApp {get; set;}
    public String redirectionDeeplinkValue {get; set;}
    public Boolean isExclusiveOffer {get; set;}
    public String activation_client_encrypted {get; set;}

    // URL PARAMETER FOR WARDROBING CONTEXT
    public String lookId {get; set;}
    public String linkedToLook {get; set;}

    // STATIC VALUES
    public final String DOMAIN = 'Louis Vuitton Domain';
    public final String SECURE_DOMAIN = 'Louis Vuitton Secure Domain';
    public final String ACCOUNT_DOMAIN = 'Account Domain';
    public final String SECURE_DOMAIN_WEB = 'Louis Vuitton Secure Domain Web';

    // MODE
    public final String REGISTRATION { get{ return 'REGISTRATION'; } set; }
    public final String ACTIVATION { get{ return 'ACTIVATION'; } set; }
    public final String SOCIAL_REGISTRATION { get{ return 'SOCIAL_REGISTRATION'; } set; }
    // SUB MODE
    public final String MATCHING { get{ return 'MATCHING'; } set; }
    public final String FULL { get{ return 'FULL'; } set; }
    public final String PARTIAL { get{ return 'PARTIAL'; } set; }
    public final String AUTO { get{ return 'AUTO'; } set; }
    
    // STEP
    public final Integer LOADING_STEP { get{ return -1; } set; }
    public final Integer KISSA_STEP { get{ return 0; } set; }
    public final Integer LOGIN_STEP { get{ return 1; } set; }
    public final Integer PERSONAL_STEP { get{ return 2; } set; }
    public final Integer VERIFICATION_STEP { get{ return 3; } set; }
    public final Integer AUTO_REG_STEP { get{ return 4; } set; }

    // LV CONNECT
    public String clientServicePhoneNumber {get; set;}

    //SOCIAL REGISTRATION
    public final String KAKAOSYNC = 'Kakao';

    /****************  SETUP  ****************/
    
    public Identity_Registration_CTRL() {

        // FOR DEBUG
        System.debug('PARAMS');
        for(String key : ApexPages.currentPage().getParameters().keySet()){
            System.debug(key + ' ' + ApexPages.currentPage().getParameters().get(key));
        }

        // GLOBAL
        getSettings();    
        setCountryMapping();

        // URL PARAMETERS
        setContext();
        setPaths();

        // FORM
        setMode();
        setForm();
        setSubMode();
        setPrivacyPolicyLinkForApp();
        
        // SOCIAL LOGIN 
        getSocialSettings();

        // GG ANALYTICS TRACKING
        setUserTracking();

    }

    /*
    *** DESCRIPTION Add ERROR LOG when laoding the page in the case of a 404 exception or an incorrect country lang.
    *** RETURN      
    */
    public PageReference log (){

        if(ApexPages.currentPage().getParameters().get('defaultCountryLangLog') != null && ApexPages.currentPage().getParameters().get('defaultCountryLangLog') != 'false'){
            new Logs( new Map<String,Object> {
                'level' => 'ERROR', 
                'apexClass' => 'IDENTITY_Registration_CTRL',
                'category' => 'EVENT',
                'message' => Label.IDENTITY_LOG_Lang_Country_Parameter,
                'recordId' => ApexPages.currentPage().getParameters().get('defaultCountryLangLog'),
                'application' => origin
            });
        }

        if(ApexPages.currentPage().getParameters().get('404Log') != null && ApexPages.currentPage().getParameters().get('404Log') == 'true'){


            String details = mode + '\n' + sub_mode + '\n' + browser + '\n' + page;
            new Logs( new Map<String,Object> {
                'level' => 'ERROR', 
                'apexClass' => 'IDENTITY_Registration_CTRL',
                'category' => 'EVENT',
                'status_code' => Label.IDENTITY_LOG_404,
                'message' => String.isNotEmpty(Site.getErrorDescription()) ? Site.getErrorDescription() : Label.IDENTITY_LOG_404,
                'application' => origin,
                'details' => details
            });
        }
        
        return null;
    }

    /*
    *** DESCRIPTION Set mode of the page: standard or social and sub mode: creation or matching 
    ***             Creating Sub Mode: if social params contains email/phone => start the form at step 2, else at step 1.
    ***             Matching Sub Mode: if email/phone input already exist, jump to step 3 that allow the user to login instead of to create a user
    *** RETURN      
    */
    public void setMode(){
        mode = REGISTRATION;
        isSocialLoginVisible = true;

        // SOCIAL LOGIN
        social_id = ApexPages.currentPage().getParameters().get('social_id');

        if(!String.isEmpty(social_id)){
            mode = SOCIAL_REGISTRATION;
            sub_mode = FULL;
            isSocialLoginVisible = false;

            // GET SOCIAL DATA
            Blob social_id_decoded = EncodingUtil.base64Decode(social_id);
            String payload = social_id_decoded.toString();
            Map<String,Object> params = (Map<String,Object>)JSON.deserializeUntyped(payload);
            social_params = new Map<String,String>();
            for(String key : params.keySet()){
                    social_params.put(key, (String)params.get(key));
                    System.debug('<<SOCIAL PARAM:' + key + '  '+ (String)params.get(key));
                }
            
            System.debug('PAYLOAD:' + payload);
        }

        // ACTIVATION FORM 
        cid = ApexPages.currentPage().getParameters().get('cid');
        cidUrlEncoded = cid != null ? EncodingUtil.urlEncode(cid, 'UTF-8') : '';
        accountId = ApexPages.currentPage().getParameters().get('accountId');
        if(!String.isEmpty(accountId)){
            mode = ACTIVATION;
            sub_mode = FULL;            
        }
        if(ApexPages.currentPage().getParameters().get('isTrustOrigin') != null){
            isTrustOrigin = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isTrustOrigin'));
        }
        else{
            isTrustOrigin = false;
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
        
        // WARDROBING
        if(!String.isEmpty(ApexPages.currentPage().getParameters().get('lookId'))){
            lookId = ApexPages.currentPage().getParameters().get('lookId');
        } 

        System.debug('MODE: ' + mode);
        System.debug('SUB_MODE: ' + sub_mode);
    }

    /*
    *** DESCRIPTION Get custom settings values and set settings for the page
    *** RETURN      
    */
    public void getSettings(){
        form_settings = IDENTITY_Registration_Form_Settings__c.getInstance();
        identity_settings = IDENTITY_Settings__c.getInstance();

        isLoading = false;
        isConfirmed = false;
        isValidCaptcha = false;
        isUnverifiedSenderAddress = false;
        isCreated = false;
        registrationException = '';
        korea_lang_country = false;
        koreaAddressFields = false; 
        isNewDesignActive = identity_settings.Activate_New_Design__c;
        isDevMode = form_settings.Is_Developper_Mode_Available__c;
        tealiumEnv = form_settings.Tealium_Environment__c;
        passwordMaxlength = Integer.valueOf(identity_settings.Password_Maxlength__c);

        counter_message = 0;
        if(Test.isRunningTest()){
            verification_codes = new Map<String, Datetime>();
        }

        // USED FOR LOG
        page = JSON.serialize(new Map<String,Object>{
            'url' => ApexPages.currentPage().getUrl(),
            'parameters' => ApexPages.currentPage().getParameters()
        });
    }

    /*
    *** DESCRIPTION Set settings values for social login
    *** RETURN      
    */
    public void getSocialSettings(){
        isSocialLoginActive = false;
        for (AuthProvider provider : [SELECT Id, DeveloperName, FriendlyName FROM AuthProvider]) {
            if(fields.get('Quick Login').get(provider.DeveloperName) != null && !fields.get('Quick Login').get(provider.DeveloperName).Is_Hidden__c){
                isSocialLoginActive = true;
            }
        }

        // WeChat Social Login visibility: desktop / tablet / wechat browser
        String userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        isWeChatVisible = false;
        if( String.isNotEmpty(userAgent) && ( !userAgent.contains('Mobile') || (userAgent.contains('Mobile') && userAgent.contains('iPad')) || (userAgent.contains('Mobile') && userAgent.contains('MicroMessenger')) ) ){
            isWeChatVisible = true;
        }

        // Apple / Google Social Login visibility: desktop / tablet / wechat browser
        isSocialLoginAG = false;
        if( String.isNotEmpty(userAgent) && ( !userAgent.contains('Mobile') || (userAgent.contains('Mobile') && userAgent.contains('iPad')))){
          isSocialLoginAG = true;  
        }
    }

    /*
    *** DESCRIPTION Get custom metadata of country mapping and keep values into map
    *** RETURN      
    */
    public void setCountryMapping(){

        // USED FOR COUNTRY VALUES
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


        // USED FOR CALLING CODES
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
        // ORIGIN
        origin = ApexPages.currentPage().getParameters().get('origin');
        if(origin == null){
            origin = identity_settings.Default_Origin_Parameter__c;
        }

        // DISPATCH- COUNTRY -- for multi-country website
        if(Pattern.compile('[A-Z]{2}').matcher(ApexPages.currentPage().getParameters().get('dispatchCountry') ?? '').matches()) {
            dispatch_country = ApexPages.currentPage().getParameters().get('dispatchCountry');
        }

        // LANG-COUNTRY
        lang_country = ApexPages.currentPage().getParameters().get('lang-country');
        if(lang_country == null){
            lang_country = identity_settings.Default_Language_Country_Parameter__c;
        }

        // COUNTRY
        country_local = lang_country.substringAfter('-');
        
        // SALESFORCE LANGUAGE
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
        korea_lang_country = lang_country == 'kor-kr' ? true : false;
        
        // CSS        
        customCss = 'redesign-2019.css';
        if(origin == 'lvconnect'){
            customCss = 'lv-connect.css';
        }
    }

    /*
    *** DESCRIPTION Gett all relative paths 
    *** RETURN      
    */
    public void setPaths(){
        paths = Identity_Utils.getPaths(lang_country, origin, dispatch_country);

        if(ApexPages.currentPage().getParameters().get('domain') != null){
            paths.put(DOMAIN, ApexPages.currentPage().getParameters().get('domain'));
        }

        // SUCCESS URL
        if(ApexPages.currentPage().getParameters().get('successUrl') != null && IDENTITY_Utils.isAllowedUrl(ApexPages.currentPage().getParameters().get('successUrl'), paths, origin)){
            paths.put('Registration Success URL', ApexPages.currentPage().getParameters().get('successUrl'));
        }
        else {
            paths.put('Registration Success URL', paths.get(SECURE_DOMAIN) + paths.get('Registration Success Path'));
        }

        // ERROR URL
        if(ApexPages.currentPage().getParameters().get('errorUrl') != null && IDENTITY_Utils.isAllowedUrl(ApexPages.currentPage().getParameters().get('errorUrl'), paths, origin)){
            paths.put('Registration Error URL', ApexPages.currentPage().getParameters().get('errorUrl'));
        }
        else {
            paths.put('Registration Error URL', paths.get(SECURE_DOMAIN) + paths.get('Registration Error Path'));
        }

        if(country_local == 'cn'){
            captcha_url = Tencent_API.SETTINGS.get('scriptJS');
            captcha_appId = Tencent_API.SETTINGS.get('CaptchaAppId');
        }

        // FOR DEBUG
        System.debug('PATHS');
        for(String key : paths.keySet()){
            System.debug(key + ' ' + paths.get(key));
        }
    }

    /*
    *** DESCRIPTION Define initialize step. by default 1, for Korean 0 (need of KISA section)
    ***             0 => KISA, 1 => LOGIN, 2 => PERSONAL, 3 => VERIFICATION, -1 => LOADING
    *** RETURN      
    */
    public void setSubMode(){

        if(isAutoRegistration()){
            sub_mode = AUTO; 
        }
        else if(mode == SOCIAL_REGISTRATION || mode == ACTIVATION){
            if( (!fields.get('Login').get('email').Is_Hidden__c && !String.isEmpty(client.login_email)) || (!fields.get('Login').get('mobile_phone').Is_Hidden__c && !String.isEmpty(client.login_international_mobile_phone)) ){
                sub_mode = PARTIAL;
            }
            else {
                sub_mode = FULL;
            }
        }
    }

    private Boolean isAutoRegistration(){
        if( mode == SOCIAL_REGISTRATION &&
            social_params != null &&
            social_params.get('social_media_type') == KAKAOSYNC &&
            !String.isEmpty(client.login_email) && 
            !String.isEmpty(client.firstname) && 
            !String.isEmpty(client.lastname) && 
            !String.isEmpty(client.title)){
                return true;
            }
            return false;
    }

    public void updateSubMode(){
        sub_mode = (sub_mode == MATCHING) ? FULL : MATCHING;
    }

    /*
    *** DESCRIPTION Get fields from custom metadata
    *** RETURN      
    */
    public void setForm(){

        // GET FIELDS CONFIGURATION
        List<IDENTITY_Registration_Form__mdt> metadata = [
            SELECT Form__c, Field__c, Is_Required__c, Section__c, Is_Hidden__c, Value__c 
            FROM IDENTITY_Registration_Form__mdt
            WHERE Context__c =: lang_country
        ];
        
        fields = new Map<String,Map<String,IDENTITY_Registration_Form__mdt>>();
        for(IDENTITY_Registration_Form__mdt field : metadata){
            if(field.Form__c == 'Registration'){
                if(fields.get(field.Section__c) == null){
                    fields.put(field.Section__c, new Map<String,IDENTITY_Registration_Form__mdt>());
                }
                fields.get(field.Section__c).put(field.Field__c, field);
            }
            else if(field.Form__c == 'Login'){
                if(fields.get('Quick Login') == null){
                    fields.put('Quick Login', new Map<String,IDENTITY_Registration_Form__mdt>());
                }
                fields.get('Quick Login').put(field.Field__c, field);
            }
        }

        // Email field visibility
        isEmailFieldVisible = false;
        if(
            (!fields.get('Login').get('email').Is_Hidden__c && country_local != 'cn') || (!fields.get('Login').get('email').Is_Hidden__c && country_local == 'cn' && (origin == 'lvapp' || origin == 'lvconnect') && mode == ACTIVATION)
          ){
            isEmailFieldVisible = true;
        }

        // FOR ACTIVATION MODE - GET ALL FIELDS OF THE CLIENT
        if(mode == ACTIVATION){
            
            List<Account> accounts =  [SELECT Id, Salutation, Firstname, Lastname, FirstName2__pc, LastName2__pc, PrimaryCountry__pc,
                            PersonEmail, LocalLoginPhone__pc, LoginPhoneCallingCode__pc, LoginPhoneCountryCode__pc, LoginPhone__pc, 
                            LocalMobilePhone__pc, MobilePhoneCountryCode__pc, MobilePhoneCountryCallingCode__pc, PersonMobilePhone, SPO_Country_code__pc,
                            Can_Be_Contacted_By_Mail__pc, Can_Be_Contacted_By_Email__pc, Can_Be_Contacted_By_Phone__pc, Can_Be_Contacted_By_SMS__pc, DreamID__c, OwnerId,
                            AttachedStore__pc, AttachedStoreCode__pc, AttachedStoreCountry__pc, Store__pc, TECH_AttachedStoreCountry__c 
                            FROM Account
                            WHERE Id =: accountId
            ];

            if(!accounts.isEmpty()) {
                account_activation = accounts[0];               
            } 
            
            if(origin == 'checkout')
            {
                fields.get('Personal').get('newsletter_agreement').Is_Required__c = false;
                fields.get('Personal').get('newsletter_agreement').Is_Hidden__c = true;

                if(ApexPages.currentPage().getParameters().get('errorUrl') != null && ApexPages.currentPage().getParameters().get('errorUrl').contains('/checkout/identification')){
                    checkoutPreviousPage = 'identification';
                }
            }
            
        }

        // CLIENT CONSTRUCTOR
        client = new Client(fields, social_params, dispatch_country, account_activation);
        client_origin = client;

        if(!String.isEmpty(client.country)){
            client_country = client.country;
        }
        if(!String.isEmpty(client.login_email)){
            client_login_email = isExclusiveOffer == false && mode == ACTIVATION ? IDENTITY_Utils.truncateUsername(client.login_email) : client.login_email;
            }
        if(!String.isEmpty(client.login_international_mobile_phone)){
            client_login_international_mobile_phone = isExclusiveOffer == false && mode == ACTIVATION ? IDENTITY_Utils.truncateUsername(client.login_international_mobile_phone) : client.login_international_mobile_phone;
        }
        
        if(mode == ACTIVATION){
            Map<String,Object> activation_client_map = new Map<String,Object>();
            if(!String.isEmpty(client.lastname)){
                activation_client_map.put('lastname',client.lastname);
            }
            if(!String.isEmpty(client.firstname)){
                activation_client_map.put('firstname',client.firstname);
            }
            if(!String.isEmpty(client.login_email)){
                activation_client_map.put('email',client.login_email);
            }
            if(!String.isEmpty(client.login_international_mobile_phone)){
                activation_client_map.put('mobilephone',client.login_international_mobile_phone);
            }
            activation_client_encrypted =  EncryptUtils.getEncryptedMetadata(activation_client_map);   
        }
        
        System.debug('CLIENT CONSTRUCTOR: ' + JSON.serialize(client));        
    }

    /*
    *** DESCRIPTION Set privacy policy link for lvapp
    *** RETURN      
    */
    public void setPrivacyPolicyLinkForApp(){
        if(origin == 'lvapp'){
          privacyPolicyLink = '<a href="' + paths.get(SECURE_DOMAIN) + 'privacy">';
        }
    }

    /*
    *** DESCRIPTION Set variables for GG Analytics User Tracking (sign_in_succeeded/failed + social_login_succeeded/failed)
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
        if(fields.get('Quick Login').get('Analytics_TID') != null){
            trackingId = fields.get('Quick Login').get('Analytics_TID').Value__c;
        }

        // common values for sign_in_succeeded/failed (Login Popin) || social_login_succeeded/failed event
        eventCategory = 'mylv';
        eventAction = 'create_an_account_form_sf';
        pageName = 'mylv/account_creation';
        pageType = 'account_creation';

        // GA config
        googleAnalyticsConfig = IDENTITY_GoogleAnalytics_Utils.getConfig(origin);

        // sign_in_succeeded/failed event
        if(ApexPages.currentPage().getParameters().get('friendlyUrl') != null){
            currentUrl = paths.get(ACCOUNT_DOMAIN)+ApexPages.currentPage().getParameters().get('friendlyUrl').escapeHtml4();            
        }

        // social_login_succeeded/failed event
        if(mode == SOCIAL_REGISTRATION)
        {
            // userStartUrl
            if(ApexPages.currentPage().getParameters().get('userStartUrl') != null){
                userStartUrl = ApexPages.currentPage().getParameters().get('userStartUrl').escapeHtml4();
            }
            
            // devStartUrl
            if(ApexPages.currentPage().getParameters().get('devStartUrl') != null){
                devStartUrl = ApexPages.currentPage().getParameters().get('devStartUrl').escapeHtml4();
                if(devStartUrl == 'login' || devStartUrl == 'registration'){
                    currentUrl = paths.get(ACCOUNT_DOMAIN) + userStartUrl;                    
                }
                else{ // social login from site (ATG side)
                    currentUrl = paths.get(DOMAIN) + userStartUrl;
                }
            }
        }
            
        System.debug('SET USER TRACKING');
        System.debug('userStartUrl: '+ userStartUrl);
        System.debug('devStartUrl: '+ devStartUrl);
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

    /*
    *** DESCRIPTION Get Picklist options for title
    *** RETURN      ListList<SelectOption> => title / title 
    */
    public List<SelectOption> getTitles() {
        List<SelectOption> options = new List<SelectOption>();
        List<String> labels = System.Label.IDENTITY_Registration_Title_Picklist_Values.split('/');

        // Default value
        options.add(new SelectOption('null', System.Label.IDENTITY_Registration_Title_Placeholder));

        if(country_local == 'jp'){
            options.add(new SelectOption('SM', labels[0]));
            options.add(new SelectOption('SF', labels[1]));
            if(!fields.get('Personal').get('Mx').Is_Hidden__c){
                options.add(new SelectOption('05', labels[2]));
            }
            if(!fields.get('Personal').get('Prefer not to say').Is_Hidden__c){
                options.add(new SelectOption('00', labels[3]));
            }
        }
        else if(country_local == 'de' || country_local == 'cn' || country_local == 'nl' || country_local == 'kr' || country_local == 'ru' || lang_country == 'fra-ca' || lang_country == 'fra-fr' || lang_country == 'ita-it'){
            options.add(new SelectOption('02', labels[0]));
            options.add(new SelectOption('04', labels[1]));
            if(!fields.get('Personal').get('Mx').Is_Hidden__c){
                options.add(new SelectOption('05', labels[2]));
            }
            if(!fields.get('Personal').get('Prefer not to say').Is_Hidden__c){
                options.add(new SelectOption('00', labels[3]));
            }
        }
        else {
            options.add(new SelectOption('02', labels[0]));
            options.add(new SelectOption('03', labels[1]));
            options.add(new SelectOption('04', labels[2]));
            if(!fields.get('Personal').get('Mx').Is_Hidden__c){
                options.add(new SelectOption('05', labels[3]));
            }
            if(!fields.get('Personal').get('Prefer not to say').Is_Hidden__c){
                options.add(new SelectOption('00', labels[4]));
            }
        }
        
        return options;
    }

    /*
    *** DESCRIPTION Get Picklist options for countries
    *** RETURN      ListList<SelectOption> => Country / Country
    */
    public List<SelectOption> getCountries() {
        List<SelectOption> options = new List<SelectOption>();

        options.add(new SelectOption('null', System.Label.IDENTITY_Registration_Country_Default_Value));

        for(String val : country_mapping.keySet()){
            options.add(new SelectOption(val, country_mapping.get(val)));
        }
        return options;
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
    *** DESCRIPTION Check if mobile phone already exist for Identity User
    *** RETURN      Boolean    true => available
    */
    public User getUserByUsername(){
        if(!String.isEmpty(client.login_email)){
            user = IDENTITY_Utils.getUserByUsername(client.login_email);
        }
        else if(!String.isEmpty(client.login_international_mobile_phone)){
            user = IDENTITY_Utils.getUserByUsername(client.login_international_mobile_phone);
        }

        return user;
    }

    /****************  NAVIGATION  ****************/
   
    /*
    *** DESCRIPTION Back step
    *** RETURN      PageReference    always null
    */
    public PageReference cancel() {
        return new PageReference(paths.get(DOMAIN) + paths.get('Registration Cancel Path'));
    }

    /*
    *** DESCRIPTION Forgot Password Link
    *** RETURN      PageReference    External
    */
    public PageReference forgotPassword(){
        if(country_local == 'cn'){
            return new PageReference(paths.get(SECURE_DOMAIN_WEB) + paths.get('Forgot Password Path'));
        }
        
        return new PageReference(paths.get(DOMAIN) + paths.get('Forgot Password Path'));
    }
    
    /*
    *** DESCRIPTION Check business rules of password when mode = activation
    *** RETURN      Boolean    true => available
    */
    @RemoteAction
    global static Boolean onCheckValidationPasswordWhenActivation(String password,String activation_client_encrypted,String firstname,String lastname,String email,String mobilephone) {
        try {
            Account client = new Account();
            Map<String,Object> activation_clientMap = EncryptUtils.getDecryptedMetadata(activation_client_encrypted);
            client.firstname = activation_clientMap.containsKey('firstname') ? activation_clientMap.get('firstname').toString().toLowerCase() : firstname.toLowerCase();
            client.lastname = activation_clientMap.containsKey('lastname') ? activation_clientMap.get('lastname').toString().toLowerCase() : lastname.toLowerCase();
            client.personEmail = activation_clientMap.containsKey('email') ? activation_clientMap.get('email').toString().toLowerCase() : email.toLowerCase();
            client.LoginPhone__pc = activation_clientMap.containsKey('mobilephone') ? activation_clientMap.get('mobilephone').toString() : mobilephone;
            Boolean invalidPassword =  IDENTITY_Utils.invalidPasswordClientName(client,password.toLowerCase());
            return invalidPassword;
            
        } catch (Exception ex) {
            System.debug(ex.getMessage());
            return null;
        }
          
    }

    /****************  SUBMIT  ****************/

    /*
    *** DESCRIPTION Next step is Verification Code.
                    First time, send code, except for CHINA => must validate captcha
    *** RETURN      PageReference    always null
    */
    public PageReference onLoginSubmit() {

        // GET LOG OF VERIFICATION CODE ACCORDING IDENTIFIER - need for limitation of email/sms
        if(counter_message == 0) {
            counter_message = Database.countQuery( 'SELECT COUNT() FROM Logs__c WHERE Level__c = \'INFO\' AND Category__c = \'EVENT\' AND Apex_Class__c = \'IDENTITY_Registration_CTRL\''
                                + ' AND CreatedDate = TODAY'
                                + ' AND ( Status_Code__c = \'' + Label.IDENTITY_LOG_Email_Sent + '\' OR Status_Code__c = \'' + Label.IDENTITY_LOG_SMS_Sent + '\' )'
                                + ' AND ( Record_Id__c = \'' + client.login_email + '\' OR Record_Id__c = \'' + client.login_international_mobile_phone +'\'  )');
        }

        if(mode == SOCIAL_REGISTRATION && sub_mode == MATCHING){
            sendVerificationCode();
        }

        return null;
    }

    /*
    *** DESCRIPTION Next step is Verification Code.
                    First time, send code, except for CHINA => must validate captcha
    *** RETURN      PageReference    always null
    */
    public PageReference onPersonalSubmit() {      

        if(counter_message == 0 && country_local != 'cn'){
            sendVerificationCode();
        }

        return null;
    }

    /*
    *** DESCRIPTION Check input code and set isConfirmed boolean.
                    Need for rendering loading section
    *** RETURN      PageReference    always null
    */
    public PageReference onVerificationSubmit(){
        isConfirmed = isValidCode();
        return null;
    }

    /*
    *** DESCRIPTION Create a log if getHTMLFragment script fails to load
    *** RETURN      PageReference    always null
    */
    public PageReference onScriptError(){
        String src = ApexPages.currentPage().getParameters().get('src');
        String details = mode + '\n' + sub_mode + '\n' + browser + '\n' + page;
        
        new Logs(new Map<String,Object> {
            'level' => 'ERROR', 
            'apexClass' => 'IDENTITY_Registration_CTRL', 
            'category' => 'CALLOUT',
            'message' => 'ERROR LOADING GET HTML FRAGMENT SCRIPT',
            'details' => details,
            'recordId' => src,
            'application' => origin
        });

        return null;
    }

    /****************  HELP METHODS  ****************/

    /*
    *** DESCRIPTION Register the account after checking the input code
    *** RETURN      PageReference    always null
    */
    public PageReference register() {

        System.debug('REGISTER');
        System.debug('MODE: '+mode);
        System.debug('SUB MODE: '+sub_mode);
        
        if( sub_mode == AUTO || isValidCode() || mode == ACTIVATION ){

            if(mode == SOCIAL_REGISTRATION && sub_mode == MATCHING){
                try{
                    user = getUserByUsername();
                    System.debug('User: ' + user);

                    account = getAccount(user.accountId);
                    System.debug('Account: ' + account);

                    setSocialMediaIdentifier();

                    if(!String.isEmpty(lookId)){  
                        linkedToLook = IDENTITY_UTILS.shareLook(lookId, account.Id, origin);
                    }

                    // ACTIVE USER
                    if(!user.IsActive){
                        IDENTITY_UTILS.activeUser(user.Id);
                    }
                    
                    isCreated = true;
                }
                catch(Exception ex){
                    
                    System.debug('An error occured: ' + ex.getMessage() + ex.getStackTraceString());

                    String details = mode + '\n' + sub_mode + '\n' +  client + '\n' + account + '\n' + user + '\n' + browser + '\n' + page;
                    
                    new Logs(new Map<String,Object> {
                        'level' => 'ERROR', 
                        'apexClass' => 'IDENTITY_Registration_CTRL', 
                        'category' => 'APEX CODE',
                        'exception_case' => ex,
                        'details' => details,
                        'application' => origin
                    });

                    isCreated = false;
                    registrationException = ex.getMessage();
                }
            }
            else{
                if(isLoginEmailOrMobileModified()){
                    logErrorLoginEmailOrMobileModified();
                    return logout(); 
                }

                account = getAccountFromForm();
                System.debug('Account From Form: ' + fields.get('Settings').get('Russia creation before SF').Is_Required__c );

                // ATG CREATION or RUSSIA CREATION
                if( (fields.get('Settings').get('ATG createConfirmation').Is_Required__c && fields.get('Settings').get('ATG creation before SF').Is_Required__c)
                    ||
                     fields.get('Settings').get('Russia creation before SF').Is_Required__c                
                  ){

                        System.debug('ATG or Russia Creation Before SF');

                        try{
                            Account acc = IDENTITY_Utils.setupAccount(account);
                            if(String.isNotEmpty(acc.Id)){
                                // Get all fields of the account - needed in the case of matching 
                                acc = getAccount(account.Id);

                                // In case of matching, keep TECH_Email and not PersonEmail - use case for chinese 
                                if(String.isNotEmpty(acc.PersonEmail) && String.isNotEmpty(client.login_email) && acc.PersonEmail != client.login_email){
                                    acc.PersonEmail = client.login_email; 
                                }

                                System.debug('Account For ATG: ' + acc);
                            }

                            // CHINESE CREATION BEFORE SF
                            if(fields.get('Settings').get('ATG createConfirmation').Is_Required__c && fields.get('Settings').get('ATG creation before SF').Is_Required__c){
                                Identity_Utils.createATGClient(account, lang_country, 'false');
                                SF_registration();
                            }
                            // RUSSIAN CREATION BEFORE SF
                            if(fields.get('Settings').get('Russia creation before SF').Is_Required__c){
                                Map<String, String> russianCreation = Identity_Utils.createRussianClient(account);
                                if(russianCreation.get('StatusCode') == '200'){
                                    SF_registration();
                                }
                            }
                            
                        }
                        catch(Exception ex){
                            String details = mode + '\n' + sub_mode + '\n' +  client + '\n' + account + '\n' + user + '\n' + browser + '\n' + page + '\n' + 'ATG or RUSSIA Creation Before SF';   
                            new Logs(new Map<String,Object> { 'level' => 'ERROR', 
                                'apexClass' => 'IDENTITY_Registration_CTRL', 
                                'category' => 'APEX CODE',
                                'exception_case' => ex,
                                'details' => details,
                                'application' => origin
                            });

                            return logout();
                        }
                    
                }
                else{
                    SF_registration();
                }
            }
        }

        return null;
    }

    /*
    *** DESCRIPTION SALESFORCE CREATION
    *** RETURN      PageReference    always null
    */
    public void SF_registration() {
        System.debug('SF REGISTRATION');

        Savepoint sp = Database.setSavepoint();

        try{
           // SALESFORCE CREATION
            if(sub_mode == AUTO && isLoginEmailDifferentFromEncrypted()){
               throw new CustomException('ERROR SELF REGISTRATION - EMAIL');
            }
            
            
            user = sub_mode != AUTO ? Identity_Utils.createMylvClient(account, client.password) : Identity_Utils.createMylvClient(account, null, false);
            System.debug('User: ' + user);
            System.debug('Account: ' + account);
           // RMS Flow control
            List<Pilot_Setting__mdt> virtualSettings = [
                       SELECT Excluded_Countries__c
                       FROM Pilot_Setting__mdt 
                       WHERE QualifiedApiName = 'Identity_RMS_FLOW' LIMIT 1
                ];
            if(mode == SOCIAL_REGISTRATION){
                setSocialMediaIdentifier();
            }
            
            if(!String.isEmpty(lookId)){  
                linkedToLook = IDENTITY_UTILS.shareLook(lookId, account.Id, origin);
            }
            
            isCreated = true;   

            // SEND ACCOUNT TO RMS
            Boolean sendToRMS = false;
            Account accountForRMS = account;
            accountForRMS = IDENTITY_Utils.getAccountForRMS(accountForRMS);
            System.debug('ACCOUNT FOR RMS: '+ accountForRMS);
            
            if(String.IsEmpty(accountForRMS.RMSId__pc) && IDENTITY_Utils.isExistDefaultStoreForRMS(dispatch_country, lang_country)){
                if(String.IsBlank(accountForRMS.AttachedStore__pc)){
                    accountForRMS =  IDENTITY_Utils.getDefaultStoreValuesForRMS(accountForRMS, dispatch_country, lang_country);
                    
                    // update account for RMS needs
                    System.debug('ACCOUNT FOR RMS AFTER DEFAULT STORE: '+ accountForRMS);
                    Database.SaveResult srList = Database.update(accountForRMS, false);
                }                
                sendToRMS = true;
            }
            
            if(sendToRMS && String.IsNotBlank(accountForRMS.AttachedStore__pc) && IDENTITY_Utils.isStoreTypeValidForRMS(accountForRMS)){
                System.debug('SEND TO RMS');
                if(virtualSettings.size()>0 && String.isNotBlank(virtualSettings[0].Excluded_Countries__c)){
                   Pilot_Setting__mdt  valExcludedCount = virtualSettings[0];
                   if(String.isNotBlank(accountForRMS.HomeAddressCountryCode__pc) && !valExcludedCount.Excluded_Countries__c.containsIgnoreCase(accountForRMS.HomeAddressCountryCode__pc)){
                       SO_CreateUpdateRMSClient_Utils.createAccountIntoRMS_WS_v5(accountForRMS.Id);
                     }        
                
                }
                else {
                       SO_CreateUpdateRMSClient_Utils.createAccountIntoRMS_WS_v5(accountForRMS.Id);
                   }      
            }
    } 
        catch(Exception ex){
            Database.rollback(sp);
            
            System.debug('An error occured: ' + ex.getMessage() + ex.getStackTraceString());

            String details = mode + '\n' + sub_mode + '\n' +  client + '\n' + account + '\n' + user + '\n' + browser + '\n' + page;
            
            new Logs(new Map<String,Object> {
                'level' => 'ERROR', 
                'apexClass' => 'IDENTITY_Registration_CTRL', 
                'category' => 'APEX CODE',
                'exception_case' => ex,
                'details' => details,
                'application' => origin
            });

            isCreated = false;
            registrationException = ex.getMessage();
        }
    }

    /*
    *** DESCRIPTION Redirect the user to success or error URL
    *** RETURN      PageReference    External
    */
    public PageReference redirect() {
        try{
            if(isCreated) {
                
                // ATG CREATION
                // HTTP callout is not authorized after DML statement, that's why we need to call ATG API in another method. 
                if(fields.get('Settings').get('ATG createConfirmation').Is_Required__c && 
                    !fields.get('Settings').get('ATG creation before SF').Is_Required__c){
                                        
                    // Get all fields of the account - needed in the case of matching 
                    Account acc = getAccount(account.Id);

                    Identity_Utils.createATGClient(acc, lang_country, user.Id);
                }                

                if(origin == 'lvapp' || origin == 'lvconnect'){
                    username = user.username;
                    return loginPasswordMethod();
                }

                return loginJWTMethod(user.username);
            }
            // IN CASE OF SALESFORCE EXCEPTION, DISPLAY ERRORS IN FORMS
            else {
                return null;
            }
        }
        catch(Exception ex){
            String details = mode + '\n' + sub_mode + '\n' +  client + '\n' + account + '\n' + user + '\n' + browser + '\n' + page;            
            new Logs(new Map<String,Object> {
                'level' => 'ERROR', 
                'apexClass' => 'IDENTITY_Registration_CTRL', 
                'category' => 'APEX CODE',
                'exception_case' => ex,
                'details' => details,
                'application' => origin
            });
        }

        return logout();
    }

    /*
    *** DESCRIPTION Send verification code by SMS or by Email
    *** RETURN      PageReference    always null
    */
    public PageReference sendVerificationCode() {

        try{

            isSentSuccess = true;
            isSentLimitReached = false;

            // For CHINA, the validation by captcha is required
            if((country_local == 'cn' && isValidCaptcha) || country_local != 'cn'){

                // Generate Random VERIFICATION CODE
                String code = String.valueOf(Math.round(Math.random() * 100000));
                verification_codes = new Map<String, Datetime>();
                verification_codes.put(code, Datetime.now());
                //Check Counter_message in Logs Tab
                if(!Test.isRunningTest()){
                counter_message = Database.countQuery( 'SELECT COUNT() FROM Logs__c WHERE Level__c = \'INFO\' AND Category__c = \'EVENT\' AND Apex_Class__c = \'IDENTITY_Registration_CTRL\''
                + ' AND CreatedDate = TODAY'
                + ' AND ( Status_Code__c = \'' + Label.IDENTITY_LOG_Email_Sent + '\' OR Status_Code__c = \'' + Label.IDENTITY_LOG_SMS_Sent + '\' )'
                + ' AND ( Record_Id__c = \'' + client.login_email + '\' OR Record_Id__c = \'' + client.login_international_mobile_phone +'\'  )');
                }
                // Email as LOGIN IDENTIFIER 
                if( !fields.get('Login').get('email').Is_Hidden__c ){
                    if(counter_message < form_settings.Sent_Email_Limit__c){
                        sendByEmail(code);
                    }
                    else{
                        isSentLimitReached = true;
                        new Logs(new Map<String,Object> {
                            'level' => 'ERROR', 
                            'apexClass' => 'IDENTITY_Registration_CTRL', 
                            'category' => 'VALIDATION',
                            'message' => Label.IDENTITY_LOG_Limitation_Send_Email_by_Session,
                            'recordId' => client.login_email,
                            'application' => origin
                        });
                    }
                }
                // MobilePhone as LOGIN IDENTIFIER 
                else if( !fields.get('Login').get('mobile_phone').Is_Hidden__c ){
                    if(counter_message < form_settings.Sent_SMS_Limit__c){
                        sendBySMS(code);
                    }
                    else{
                        isSentLimitReached = true;
                        new Logs(new Map<String,Object> {'level' => 'ERROR', 
                            'apexClass' => 'IDENTITY_Registration_CTRL', 
                            'category' => 'VALIDATION',
                            'message' => Label.IDENTITY_LOG_Limitation_Send_Sms_by_Session,
                            'recordId' => client.login_international_mobile_phone,
                            'application' => origin
                        });
                    }
                }
            }
        }
        catch(Exception ex){
            System.debug('An error occured: ' + ex.getMessage() + ex.getStackTraceString());
            isSentSuccess = false;
        }

        return null;
    }

    /*
    *** DESCRIPTION Send Email
    *** RETURN      
    */
    public void sendByEmail(String code) {

        try{
            // Get Email Template
            String templateId = fields.get('Verification').get('email_template').Value__c;
            EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue 
                                            FROM EmailTemplate 
                                            WHERE Id =: templateId];

            // Replace Dynamic Values
            String htmlBody = emailTemplate.HtmlValue;
            htmlBody = htmlBody.replace('${LastName}', client.lastName);
            htmlBody = htmlBody.replace('${FirstName}', client.firstName);
            htmlBody = htmlBody.replace('${Verification_Code}', code);
            htmlBody = htmlBody.replace('${Default_Site}', fields.get('Verification').get('default_site').Value__c);

            if(mode == ACTIVATION && account_activation.DreamID__c != null){
                htmlBody = htmlBody.replace('${DreamID}', account_activation.DreamID__c);
            }
            else{
                htmlBody = htmlBody.replace('${DreamID}', '');
            }

            if(!String.isEmpty(client.login_email)){
                htmlBody = htmlBody.replace('${Username}', client.login_email);
            }
            else {
                htmlBody = htmlBody.replace('${Username}', client.login_international_mobile_phone);
            }          
            if(client.title == '02' || client.title == 'SM'){
                htmlBody = htmlBody.replace('${Salutation}', Label.IDENTITY_Email_Template_Salutation_for_Men);
            }
            else{
                htmlBody = htmlBody.replace('${Salutation}', Label.IDENTITY_Email_Template_Salutation_for_Women);
            }

            // Get  address
            List<String> toAddresses = new List<String>();
            if(!String.isEmpty(form_settings.Default_To_Email_Address__c)){
                toAddresses.addAll(form_settings.Default_To_Email_Address__c.split(','));
            }
            toAddresses.add(client.login_email);

            // Send Email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setUseSignature(false);
            mail.setHtmlBody(htmlBody);
            mail.setSubject(Label.IDENTITY_EMAIL_TEMPLATE_Subject);
            mail.setCharset('UTF-8');

            if(!String.isEmpty(fields.get('Verification').get('sender_email').Value__c) && !isUnverifiedSenderAddress){
                mail.setOrgWideEmailAddressId(fields.get('Verification').get('sender_email').Value__c);
            }
            else{
                mail.setSenderDisplayName(fields.get('Verification').get('sender_name').Value__c);
            }

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });            

            counter_message++;
            validationCodeEmail = client.login_email;
            String details = 'sent codes: '+verification_codes;
            new Logs(new Map<String,Object> { 'level' => 'INFO', 
                'apexClass' => 'IDENTITY_Registration_CTRL', 
                'category' => 'EVENT',
                'message' => Label.IDENTITY_LOG_Email_Sent,
                'details' => details,
                'recordId' => client.login_email,
                'status_code' => Label.IDENTITY_LOG_Email_Sent,
                'application' => origin
            });
        }
        catch(Exception ex){
            System.debug('An error occured: ' + ex.getMessage());

            if(ex.getMessage().contains('UNVERIFIED_SENDER_ADDRESS')){
                isUnverifiedSenderAddress = true;
                sendByEmail(code);
            }
            else {
                String details = mode + '\n' + sub_mode + '\n' +  client + '\n' + browser + '\n' + page;
                new Logs(new Map<String,Object> {
                    'level' => 'ERROR', 
                    'apexClass' => 'IDENTITY_Registration_CTRL', 
                    'category' => 'CALLOUT',
                    'exception_case' => ex,
                    'details' => details,
                    'recordId' => fields.get('Verification').get('email_template').Value__c,
                    'application' => origin
                });

                throw new CustomException(ex.getMessage());
            }
        }
    }

    /*
    *** DESCRIPTION Send SMS
    *** RETURN      
    */
    public void sendBySMS(String code) {

        try{
            // Get  phones
            List<String> toPhones = new List<String>();
            if(!String.isEmpty(form_settings.Default_To_Mobile_Phone__c)){
                toPhones.addAll(form_settings.Default_To_Mobile_Phone__c.split(','));
            }

            toPhones.add(client.login_international_mobile_phone);

            Fractalist_API.sendVerificationSMS(toPhones, code, origin);
            counter_message++;  
            validationCodeMobile = client.login_international_mobile_phone;            
                      
            String details = 'sent codes: '+verification_codes;
            new Logs( new Map<String,Object> {'level' => 'INFO', 
                'apexClass' => 'IDENTITY_Registration_CTRL',
                'category' => 'EVENT',
                'message' => Label.IDENTITY_LOG_SMS_Sent,
                'details' => details,
                'recordId' => client.login_international_mobile_phone,
                'status_code' => Label.IDENTITY_LOG_SMS_Sent,
                'application' => origin
            });
        } 
        catch(Exception ex){
             System.debug('An error occured: ' + ex.getMessage());
        }
    }

    /*
    *** DESCRIPTION Create Social Media Identifier and Third Party Account LINK
    *** RETURN      
    */
    public void setSocialMediaIdentifier(){
        
        // WECHAT_MOBILE = WECHAT for SMI history
        String social_media_type = social_params.get('social_media_type');
        if(social_media_type == 'WeChat_Mobile'){
            social_media_type = 'WeChat';
        }
        if(!Test.isRunningTest()){
            // INSERT SOCIAL MEDIA IDENTIFIER

            Social_Media_Identifier__c smi = new Social_Media_Identifier__c();
            smi.Client__c = account.Id;
            smi.Social_Id__c = social_params.get('social_id');
            smi.Social_Media_Type__c = social_media_type;
            smi.Nickname__c = social_params.get('nickname');
            smi.Opt_In__c = social_params.get('channel_opted_in') != null ? Boolean.valueOf(social_params.get('channel_opted_in')) : true;
            if(social_params.containsKey('picture')){
                smi.Avatar__c = social_params.get('picture');
            }
            if(social_params.containsKey('connected_at')){
                smi.Follow_Up_Date__c = Date.valueOf(social_params.get('connected_at'));
            }
            insert smi;
         }
        new Logs( new Map<String,Object> { 'level' => 'INFO', 
            'apexClass' => 'IDENTITY_RegistrationHandler',
            'category' => 'EVENT',
            'message' => Label.IDENTITY_Social_Login_Self_Registration,
            'application' => 'SSO',
            'recordId' => user.Id,
            'details' => social_params.get('social_media_type')
        });

        // INSERT THIRD PARTY ACCOUNT LINK
        //String provider = social_params.get('social_media_type');
        //List<AuthProvider> providers = [SELECT Id FROM AuthProvider WHERE FriendlyName =: provider];
        //if(!providers.isEmpty()){
            //insert new ThirdPartyAccountLink(
            //    UserId = user.Id,
            //    SsoProvider = providers[0]
            //);
        //}
    }
    /*
    *** DESCRIPTION Convert form fields to account
    *** RETURN      
    */
    public Account getAccountFromForm(){
        
        System.debug('Form: ' + client);

        Account account = new Account();

        account.Id = client.id;             

        account.Salutation = client.title;
        account.FirstName = client.firstname.trim(); // trim to prevent starting white space (necessary to create SF user alias)
        account.LastName = client.lastname.trim(); // trim to prevent starting white space (necessary to create SF user alias)
        account.FirstName2__pc = client.firstname2;
        account.LastName2__pc = client.lastname2;
        account.SPO_Country_code__pc = country_iso_mapping.get(client.country);
        
        if(client.primary_country != null){
            account.PrimaryCountry__pc = client.primary_country;
        }
        else{
            account.PrimaryCountry__pc = country_mapping.get(client.country);
        }

        if(client.newsletter_agreement != null){
            account.Can_Be_Contacted_By_Email__pc = Boolean.valueOf(client.newsletter_agreement);            
        }               

        // Email as LOGIN IDENTIFIER
        if( !fields.get('Login').get('email').Is_Hidden__c ){
            account.PersonEmail = client.login_email;
        }
        else if( !fields.get('Personal').get('email').Is_Hidden__c ){
            account.PersonEmail = client.email;
        }
        
        // MobilePhone as LOGIN IDENTIFIER
        if( !fields.get('Login').get('mobile_phone').Is_Hidden__c ){
            account.LocalLoginPhone__pc = client.login_mobile_phone;
            account.LoginPhoneCountryCode__pc = client.login_calling_code;
            account.LoginPhoneCallingCode__pc =  code_mapping.get(client.login_calling_code);
            account.LoginPhone__pc = client.login_international_mobile_phone;
        }

        if( !fields.get('Personal').get('mobile_phone').Is_Hidden__c || (social_params != null && social_params.containsKey('phone_number'))){
            account.LocalMobilePhone__pc = client.mobile_phone;
            account.MobilePhoneCountryCode__pc = client.calling_code;
            account.MobilePhoneCountryCallingCode__pc =  code_mapping.get(client.calling_code);
            account.PersonMobilePhone = client.international_mobile_phone;
        }

        if ((fields.get('Personal').get('birthdate') ) != null && !fields.get('Personal').get('birthdate').Is_Hidden__c) {
            if (client.birthdate != '' && client.birthdate != null){
                List<String> birthdateSplited =  client.birthdate.split('\\.');
                String dayAfterSplit = birthdateSplited[2];
                String monthAfterSplit = birthdateSplited[1];
                String yearAfterSplit = birthdateSplited[0];
                client.birthdateDay = dayAfterSplit;
                client.birthdateMonth = monthAfterSplit;
                client.birthdateYear = yearAfterSplit;
            }
        }

        if(client.owner_id != null){
            account.OwnerId = client.owner_id;
        }  
        
        if(client.attached_store != null){
            account.AttachedStore__pc = client.attached_store;
        }
        if(client.attached_store_code != null){
            account.AttachedStoreCode__pc = client.attached_store_code;
        }
        if(client.attached_store_country != null){
            account.AttachedStoreCountry__pc = client.attached_store_country;
        }
        if(client.store != null){
            account.Store__pc = client.store;
        }
        if(client.tech_attached_store_country != null){
            account.TECH_AttachedStoreCountry__c = client.tech_attached_store_country;
        }
        if(client.gender != null){
            account.Gender__pc = client.gender;
            // bug account.Salutation and client.title get empty
            if(sub_mode == AUTO){
            	account.Salutation = IDENTITY_Utils.genderToSalutation(client.gender);
        	}
        }

        if(client.postal_code != null){ account.PrimaryZipCode__pc = client.postal_code; }
        if(client.state != null){ account.PrimaryStateProvince__pc = client.state; }
        if(client.city != null){ account.PrimaryCity__pc = client.city; }
        if(client.address1 != null){ account.PrimaryAddressLine1__pc = client.address1; }
        if(client.address2 != null){ account.PrimaryAddressLine2__pc = client.address2; }
        if(client.address3 != null){ account.PrimaryAddressLine3__pc = client.address3; }
        if(client.mobile_phone != null){ account.PersonMobilePhone = client.mobile_phone; }
        
        if(client.birthdateDay != null){
            account.BirthdateDay__pc = client.birthdateDay;
        }
        if(client.birthdateMonth != null){
            account.BirthdateMonth__pc = client.birthdateMonth;
        }
        if(client.birthdateYear != null){
            account.BirthdateYear__pc = client.birthdateYear;
        }
      
        return account;
    }

    /*
    *** DESCRIPTION Get Account From SOQL
    *** RETURN      
    */
    public Account getAccount(String accountId){

        Account account = [SELECT Id, Salutation, Firstname, Lastname, FirstName2__pc, LastName2__pc, PrimaryCountry__pc,
                            PersonEmail, LocalLoginPhone__pc, LoginPhoneCallingCode__pc, LoginPhoneCountryCode__pc, LoginPhone__pc, 
                            LocalMobilePhone__pc, MobilePhoneCountryCode__pc, MobilePhoneCountryCallingCode__pc, PersonMobilePhone, SPO_Country_code__pc,
                            Can_Be_Contacted_By_Mail__pc, Can_Be_Contacted_By_Email__pc, Can_Be_Contacted_By_Phone__pc, Can_Be_Contacted_By_SMS__pc, OwnerId,
                            PrimaryZipCode__pc, PrimaryAddressLine1__pc, PrimaryAddressLine2__pc, PrimaryAddressLine3__pc, PrimaryStateProvince__pc,
                            PrimaryCity__pc, BirthdateDay__pc, BirthdateMonth__pc, BirthdateYear__pc,
                            AttachedStore__pc, AttachedStoreCode__pc, AttachedStoreCountry__pc, Store__pc, TECH_AttachedStoreCountry__c
                            FROM Account
                            WHERE Id =: accountId
        ];

        return account;
    }

    /*
    *** DESCRIPTION Login with password method
    *** RETURN      PageReference   External
    */
    public PageReference loginPasswordMethod() {
        
        try{

            // GET USERNAME ACCORDING TECH MOBILE PHONE           
            user = IDENTITY_Utils.getUserByUsername(username);
            username = user.Username;

            // GET PASSWORD ACCORDING CLIENT OR LOGIN FORM
            if(String.isEmpty(password) && !String.isEmpty(client.password)){
                password = client.password;
            }

            if(IDENTITY_Utils.passwordTooLong(password)){
               throw new CustomException(Label.EM_password_too_long);
            }

            PageReference loginPage = IDENTITY_Utils.loginOauthUserAgentMethod(username, password, paths.get('Registration Success URL'), origin); 
            System.debug('LOGIN PAGE FOR LV APP: '+loginPage);
            // LOGIN SUCCESS 
            if(loginPage != null || Test.isRunningTest()){

                // GG ANALYTICS
                // sign_in_succeeded in case of Popin Login 
                // social_login_succeeded in case of Social Login
                if(!isCreated ) 
                {
                    userTracking = true;
                    eventLabel = 'sign_in_succeeded';
                }
                
                if(mode == SOCIAL_REGISTRATION && devStartUrl != null && userStartUrl != null)
                {
                    userTracking = true;
                    eventLabel = 'social_login_succeeded';
                }
                
                // SEND LOGIN SUCCESS EVENT TO GG ANALYTICS
                if(userTracking) {
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
                        currentUrl,
                        'logged_user',
                        pageName,
                        pageType);
                }
                
                
                if(!String.isEmpty(lookid)){
                    linkedToLook = IDENTITY_UTILS.shareLook(lookId, user.AccountId, origin);
                }

                // OAUTH USER AGENT REDIRECTION - SCOPE: ACCESS TOKEN, REFRESH TOKEN 
                if(origin == 'lvapp' || origin == 'lvconnect'){
                    return loginPage;
                }
                
                // JWT LOGIN TRANSPARANT REDIRECTION - SCOPE: ACCESS TOKEN
                return loginJWTMethod(username);
            }
            else {
                System.debug('An error occured: Incorrect password');
            }
        }
        catch(Exception ex){
            System.debug('An error occured: ' + ex.getMessage() + ex.getStackTraceString());

            // GG ANALYTICS
            // sign_in_failed in case of Popin Login 
            // social_login_failed in case of Social Login
            if(!isCreated) 
            {
                userTracking = true;
                eventLabel = 'sign_in_failed';
            }
            
            if(mode == SOCIAL_REGISTRATION && devStartUrl != null && userStartUrl != null)
            {
                userTracking = true;
                eventLabel = 'social_login_failed';
            }

            // SEND LOGIN FAIL EVENT TO GG ANALYTICS
            if(userTracking) {
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
                    currentUrl,
                    'not_logged_user',
                    pageName,
                    pageType);
                }
            }

        return null;
    }

    /*
    *** DESCRIPTION Login with JWT method TRANSPARANT REDIRECTION - SCOPE: ACCESS TOKEN
    *** RETURN      PageReference   External
    */
    public PageReference loginJWTMethod(String username) {

        // SET PARAMS
        Map<String,String> params = new Map<String,String>();
        if(!String.isEmpty(lookid)){
            params.put('lookId', linkedToLook);
        }

        return IDENTITY_Utils.loginJWTMethod(username, paths.get('Registration Success URL'), params);
    }

    /*
    *** DESCRIPTION Social Login - redirect to SSO 
    *** RETURN      PageReference   Internal
    */
    public PageReference socialLogin() {
        String social_media = Apexpages.currentPage().getParameters().get('social_media');
        
        PageReference page = new PageReference(paths.get('Account Domain') + paths.get('SSO ' + social_media));
        
        // SUCCESS URL
        if(ApexPages.currentPage().getParameters().get('successUrl') != null && IDENTITY_Utils.isAllowedUrl(ApexPages.currentPage().getParameters().get('successUrl'), paths, origin)){
            page.getParameters().put('successUrl', ApexPages.currentPage().getParameters().get('successUrl'));
        }
        else {
            page.getParameters().put('successUrl', paths.get(SECURE_DOMAIN) + paths.get('Registration Success Path'));
        }

        // ERROR URL
        if(ApexPages.currentPage().getParameters().get('errorUrl') != null && IDENTITY_Utils.isAllowedUrl(ApexPages.currentPage().getParameters().get('errorUrl'), paths, origin)){
            page.getParameters().put('errorUrl', ApexPages.currentPage().getParameters().get('errorUrl'));
        }
        else {
            page.getParameters().put('errorUrl', paths.get(SECURE_DOMAIN) + paths.get('Registration Error Path'));
        }
        
        // FOR GG ANALYTICS NEEDS      
        if(ApexPages.currentPage().getParameters().get('friendlyUrl') != null){
            page.getParameters().put('userStartUrl', ApexPages.currentPage().getParameters().get('friendlyUrl').escapeHtml4());
            page.getParameters().put('devStartUrl', 'registration');
        }

        return page;
    }

    /*
    *** DESCRIPTION Logout - redirect to error URL
    *** RETURN      PageReference   External
    */
    public PageReference logout() {

        return new PageReference(paths.get('Registration Error URL'));
    }

    public void changeKoreaFields() {
        koreaAddressFields = !koreaAddressFields;
    }
    
    /*
    *** DESCRIPTION Check input code
    *** RETURN      Boolean
    */
    public Boolean isValidCode() {
        
        input_code= input_code.replaceAll('\\s+',''); // remove all spaces
        input_code= input_code.replaceAll('\\p{Punct}',''); // remove all dots (and punctation characters)

        if( (!String.isEmpty(String.valueOf(form_settings.Code_Validity_Time__c)) && verification_codes.keySet().contains(input_code) && Datetime.now() < verification_codes.get(input_code).addMinutes(Integer.valueOf(form_settings.Code_Validity_Time__c)) )
            || (!String.isEmpty(form_settings.Default_Code__c) && input_code == form_settings.Default_Code__c)){
            System.debug('isValidCode TRUE');
            return true;
        }

        if(!String.isEmpty(input_code)){
            String details = 'sent code: ' + verification_codes + '\n' + 'input code: ' + input_code + '\n' + mode + '\n' + sub_mode + '\n' +  client + '\n' + browser + '\n' + page;
            new Logs(new Map<String,Object> {
                'level' => 'INFO', 
                'apexClass' => 'IDENTITY_Registration_CTRL', 
                'category' => 'EVENT',
                'message' => Label.IDENTITY_LOG_Verification_Code,
                'details' => details,
                'recordId' => client.login_email,
                'status_code' => Label.IDENTITY_LOG_Verification_Code,
                'application' => origin
            });    
        }        

        System.debug('isValidCode FALSE');
        return false;
    }

    /*
    *** DESCRIPTION Verify Captcha
    *** RETURN      
    */
    public void verifyCaptcha() {
        if(Tencent_API.verifyCaptcha(captcha_ticket, captcha_randstr) == 'OK'){
            isValidCaptcha = true;
            sendVerificationCode();
        }    
    }

    public Boolean isLoginEmailOrMobileModified(){
        if( (String.isNotBlank(validationCodeEmail) && validationCodeEmail != client.login_email) ||
            (String.isNotBlank(validationCodeMobile) && validationCodeMobile != client.login_international_mobile_phone))
        {
            return true;
        }
        return false;
    }
    public void logValidationError(String message, String details){
        Client clonedClient = client.clone();
        clonedClient.password = '*';
        details = details + mode + '\n' + sub_mode + '\n' + clonedClient + '\n' + account + '\n' + user + '\n' + browser + '\n' + page;
        new Logs(new Map<String,Object> {
            'level' => 'ERROR', 
                'apexClass' => 'IDENTITY_Registration_CTRL', 
                'category' => 'VALIDATION',
                'details' => details,
                'message' => message
                });
        System.debug('An error occured: ' + message + ' ' + details);
    }

    public void logErrorLoginEmailOrMobileModified(){
        String details = 'Email for code: '+ validationCodeEmail + ' / ' + 'Email for account: ' + client.login_email + ' / ' +' Mobile for code: '+ validationCodeMobile + ' / ' +' Mobile for account: '+ client.login_international_mobile_phone + '\n';
        String message = 'EMAIL OR MOBILE MODIFIED';
        logValidationError(message, details);
    }

    public Boolean isLoginEmailDifferentFromEncrypted(){
        String decryptedEmail; 
        Map<String,Object> eidMap = EncryptUtils.getDecryptedMetadata(social_params.get('eid'));
        if(eidMap != null){
            decryptedEmail = eidMap.containsKey('email') ? eidMap.get('email').toString() : null ;
        }
        if( decryptedEmail == null || decryptedEmail != account.PersonEmail){
            return true; 
        }
        return false;
    }

    /****************  WRAPPER  ****************/
    public class CustomException extends Exception {}

    public class Client {
        public String id {get;set;}
        public String owner_id {get;set;}

        // LOGIN
        public String login_email {get; set;}
        public String login_email_confirmation {get; set;}
        public String login_mobile_phone {get; set;}
        public String login_calling_code {get; set;}
        public String login_international_mobile_phone {get; set;}
        public String password {get; set;}

        // PERSONAL
        public String title {get; set;}
        public String firstname {get; set;}
        public String lastname {get; set;}
        public String firstname2 {get; set;}
        public String lastname2 {get; set;}
        public String country {get; set;}
        public String primary_country {get; set;}
        public String currency_code {get; set;}
        public String birthdate {get; set;}
        public String postal_code { get; set; }
        public String state { get; set; } // PrimaryStateProvince
        public String city { get; set; }// PrimaryCity
        public String address1 { get; set; }
        public String address2 { get; set; }
        public String address3 { get; set; }

        public String email {get; set;}
        public String mobile_phone {get; set;}
        public String calling_code {get; set;}
        public String international_mobile_phone {get; set;}

        public String privacy_agreement {get; set;}
        public String newsletter_agreement {get; set;}

        public String attached_store {get; set;}
        public String attached_store_code {get; set;}
        public String attached_store_country {get; set;}
        public String store {get; set;}
        public String tech_attached_store_country {get; set;}

        //SOCIAL MEDIA
        public String gender {get; set;}
        public String birthdateDay {get; set;}
        public String birthdateMonth {get; set;}
        public String birthdateYear {get; set;}
       
        public Client(){}

        /*
        *** DESCRIPTION By default, keep value from Custom Metadata
                        For social mode, fill value according the endoded social_id param
                        For my repairs, use existing account values
        *** RETURN      Bollean
        */
        public Client(Map<String,Map<String,IDENTITY_Registration_Form__mdt>> fields, Map<String,String> social_params, String dispatch_country, Account acc){

            // DEFAULT VALUE 
            password = '';
            title = fields.get('Personal').get('title').Value__c;
            privacy_agreement = fields.get('Personal').get('privacy_agreement').Value__c;
            newsletter_agreement = fields.get('Personal').get('newsletter_agreement').Value__c;
            currency_code = fields.get('Personal').get('currency_code').Value__c;
            country = fields.get('Personal').get('country').Value__c;
            calling_code = fields.get('Personal').get('mobile_phone').Value__c;
            login_calling_code = fields.get('Login').get('mobile_phone').Value__c; 
            birthdate = fields.get('Personal').get('birthdate').Value__c;
            postal_code = fields.get('Personal').get('postal_code')?.Value__c;
            state = fields.get('Personal').get('state')?.Value__c;
            city = fields.get('Personal').get('city')?.Value__c;
            address1 = fields.get('Personal').get('address1')?.Value__c;
            address2 = fields.get('Personal').get('address2')?.Value__c;
            address3 = fields.get('Personal').get('address3')?.Value__c;

            // DISPATCH COUNTRY CONTEXT
            if(!String.isEmpty(dispatch_country)){
                country = dispatch_country;
                calling_code = dispatch_country;
                login_calling_code = dispatch_country; 
            }

            // SOCIAL LOGIN CONTEXT
            if(social_params != null){
                login_email = social_params.get('email');
                login_email_confirmation = social_params.get('email');
                
                firstname = social_params.get('firstname');
                lastname = social_params.get('lastname');

                email = social_params.get('email');

                if(social_params.containsKey('phone_number')){ //TO DO 
                    Map<String, String> phoneMap = IDENTITY_Utils.getSplittedPhoneFromFullPhone(social_params.get('phone_number'));
                    if(!phoneMap.isEmpty()){
                        mobile_phone = phoneMap.get('mobilePhone');
                        calling_code = phoneMap.get('iso2Code');
                        international_mobile_phone = phoneMap.get('internationalMobilePhone');
                    }
                }
                if(social_params.containsKey('gender')){
                    gender = social_params.get('gender');
                    title = IDENTITY_Utils.genderToSalutation(gender);
                }
                if(social_params.containsKey('birthdate_day')){  
                    birthdateDay = social_params.get('birthdate_day');
                }if(social_params.containsKey('birthdate_month')){  
                    birthdateMonth = social_params.get('birthdate_month');
                }
                if(social_params.containsKey('birthdate_year')){  
                    birthdateYear = social_params.get('birthdate_year');
                }
                if(social_params.containsKey('base_address')){ 
                    List<string> splitedAddress = social_params.get('base_address').split(' ');
                    state = splitedAddress[0];
                    splitedAddress.remove(0);
                    city = splitedAddress[0];
                    splitedAddress.remove(0);
                    address1 = String.join(splitedAddress, ' ');
                    address3 = '.';
                }
                if(social_params.containsKey('detail_address')){  
                    address2 = social_params.get('detail_address');
                }
                if(social_params.containsKey('zone_number')){  
                    postal_code = social_params.get('zone_number');
                }
                if(social_params.containsKey('newsletter_terms')){  
                    newsletter_agreement = social_params.get('newsletter_terms');
                }
            }

            // ACTIVATION CONTEXT
            if(acc != null){

                id = acc.Id;

                if(!String.isEmpty(acc.Salutation)) {
                    title = acc.Salutation;
                }
                if(!String.isEmpty(acc.Firstname)) {
                    firstname = acc.Firstname;
                }
                if(!String.isEmpty(acc.Lastname)) { 
                    lastname = acc.Lastname;
                }
                if(!String.isEmpty(acc.FirstName2__pc)) {
                    firstname2 = acc.FirstName2__pc;
                }
                if(!String.isEmpty(acc.LastName2__pc)) {
                    lastname2 = acc.LastName2__pc;
                }
                if(!String.isEmpty(acc.SPO_Country_code__pc)) {
                    List<CountryMapping__mdt> iso2 = [SELECT Iso2Code__c FROM CountryMapping__mdt WHERE Iso3Code__c =: acc.SPO_Country_code__pc  AND Iso2Code__c != null];

                    if(!iso2.isEmpty()){
                        country = iso2[0].Iso2Code__c;
                    }
                }
                if(!String.isEmpty(acc.PrimaryCountry__pc)){
                    primary_country = acc.PrimaryCountry__pc;
                }
                if(!String.isEmpty(acc.PersonEmail)) {
                    login_email = acc.PersonEmail;
                    email = acc.PersonEmail; 
                }

                // MOBILE PHONE - If no login phone use the contactability as login phone
                if(String.isEmpty(acc.LoginPhone__pc) && !String.isEmpty(acc.PersonMobilePhone)){
                    acc.LocalLoginPhone__pc = acc.LocalMobilePhone__pc;
                    acc.LoginPhoneCountryCode__pc = acc.MobilePhoneCountryCode__pc;
                    acc.LoginPhone__pc = acc.PersonMobilePhone;
                }

                if(!String.isEmpty(acc.LocalMobilePhone__pc)) {
                    mobile_phone = acc.LocalMobilePhone__pc;
                }
                if(!String.isEmpty(acc.LocalLoginPhone__pc)) {
                    login_mobile_phone = acc.LocalLoginPhone__pc;
                }
                if(!String.isEmpty(acc.MobilePhoneCountryCode__pc)) {
                    calling_code = acc.MobilePhoneCountryCode__pc;
                }  
                if(!String.isEmpty(acc.LoginPhoneCountryCode__pc)) {
                    login_calling_code = acc.LoginPhoneCountryCode__pc;
                } 
                else if(!String.isEmpty(acc.MobilePhoneCountryCode__pc)){
                    login_calling_code = acc.MobilePhoneCountryCode__pc;
                }              
                if(!String.isEmpty(acc.PersonMobilePhone)) {
                    international_mobile_phone = acc.PersonMobilePhone;
                }
                if(!String.isEmpty(acc.LoginPhone__pc)) {
                    login_international_mobile_phone = acc.LoginPhone__pc;
                }

                if(!String.isEmpty(acc.OwnerId)) {
                    owner_id = acc.OwnerId;
                }

                if(!String.isEmpty(acc.AttachedStore__pc)) {
                    attached_store = acc.AttachedStore__pc;
                }
                if(!String.isEmpty(acc.AttachedStoreCode__pc)) {
                    attached_store_code = acc.AttachedStoreCode__pc;
                }
                if(!String.isEmpty(acc.AttachedStoreCountry__pc)) {
                    attached_store_country = acc.AttachedStoreCountry__pc;
                }
                if(!String.isEmpty(acc.Store__pc)) {
                    store = acc.Store__pc;
                }
                if(!String.isEmpty(acc.TECH_AttachedStoreCountry__c)) {
                    tech_attached_store_country = acc.TECH_AttachedStoreCountry__c;
                }

                System.debug('ACCOUNT ACTIVATION: ' + JSON.serialize(acc));
            }
        }        
    }
}