public without sharing class TWIST_Registration {
    
    public static final String PICKLIST_COUNTRIES = 'Countries';
    public static final String CL_TITLE_02 = 'Twist_Account_Creation_Title_Picklist_Value_02';
    public static final String CL_TITLE_03 = 'Twist_Account_Creation_Title_Picklist_Value_03';
    public static final String CL_TITLE_04 = 'Twist_Account_Creation_Title_Picklist_Value_04';
    public static final String CL_TITLE_05 = 'Twist_Account_Creation_Title_Picklist_Value_05';
    public static final String CL_TITLE_00 = 'Twist_Account_Creation_Title_Picklist_Value_00';

    private static Map<String,Object> registrationComponentConfig = new Map<String,Object>();
    private static Map<String,TWIST_Form_Registration_Settings__mdt> formFields = new Map<String,TWIST_Form_Registration_Settings__mdt>();

    //private static String subMode;
    //private static Client client;
    //private static Account account_activation;
    //private static Map<String,Map<String,IDENTITY_Registration_Form__mdt>> fields = new Map<String,Map<String,IDENTITY_Registration_Form__mdt>>();
    private static String mode;

    private static Integer counter_message;
    private static Boolean isUnverifiedSenderAddress;

    @AuraEnabled(cacheable=true)
    public static Map<String,Object> initComponentConfig(Map<String,Object> queryParams) {

        String origin = (String) queryParams.get(TWIST_QueryParamKey_CONST.ORIGIN);
        String langCountry = (String) queryParams.get(TWIST_QueryParamKey_CONST.LANG_COUNTRY);
        String dispatchCountry = (String) queryParams.get(TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY);
        String errorUrl = queryParams.get(TWIST_QueryParamKey_CONST.ERROR_URL) != null ? (String)queryParams.get(TWIST_QueryParamKey_CONST.ERROR_URL) : null;
        String socialId = queryParams.get(TWIST_QueryParamKey_CONST.SOCIAL_ID) != null ? (String)queryParams.get(TWIST_QueryParamKey_CONST.SOCIAL_ID) : null;
        String cid = queryParams.get(TWIST_QueryParamKey_CONST.CID) != null ? (String)queryParams.get(TWIST_QueryParamKey_CONST.CID) : null;
        String utmCampaign = (String) queryParams.get(TWIST_QueryParamKey_CONST.UTM_CAMPAIGN) != null ? (String)queryParams.get(TWIST_QueryParamKey_CONST.UTM_CAMPAIGN) : null;
        Map<String, Object> cidMap = TWIST_RegistrationUtils.extractAccountId(cid);
        String accountId = cidMap.containsKey('accountId') ? (string) cidMap.get('accountId') : null ;
        Boolean isTrustOrigin = cidMap.containsKey('isTrustOrigin') ? (Boolean) cidMap.get('isTrustOrigin') : false ;

        String language = TWIST_login.getLanguage(langCountry);

        registrationComponentConfig.put('isTrustOrigin', isTrustOrigin);

        getSettings();
        setMode(accountId, socialId);
        setContext(origin,langCountry, dispatchCountry);
        setFormFields(langCountry, TWIST_RegistrationUtils.Mode.ValueOf(mode));
        setCountryList(langCountry, dispatchCountry, language);
        setTitles(langCountry, language);
        setLoginBaseUrl(langCountry, origin);
        setPrefilledValues(langCountry, accountId, utmCampaign);
        setShowKanaFields(langCountry);
        setLegalAge(langCountry);
        setCalendarDateFormat(langCountry);
        getSocialSettings(langCountry, queryParams);
        setForgotPasswordUrl(langCountry, origin, queryParams);
        writeLogs(queryParams);
        setFeaturesFlags(langCountry, origin);
        
        return registrationComponentConfig;
    }

    @AuraEnabled(cacheable=true)
    public static string getTermConditionLink(String langCountry){
        try {
            List<Twist_Legacity_Link__mdt> link  = [SELECT link__c FROM Twist_Legacity_Link__mdt WHERE local__c = :langCountry];
            return link.isEmpty() ? String.format('{0}/{1}/legal-privacy', new List<String> { TWIST_UrlUtils.getLvSiteBaseUrl(langCountry), langCountry }) : link[0].link__c;
        }
        catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled(cacheable=false)
    public static Map<String,Object> submitRegistrationForm(Map<String,String> formData, Map<String,Object> queryParams, Map<String,String> socialParams, Boolean doNeedVerificationCode) {
        Map<String,String> form = new  Map<String,String>();
        String langCountry = (String) queryParams.get(TWIST_QueryParamKey_CONST.LANG_COUNTRY);

        try {
            String cid = queryParams.get(TWIST_QueryParamKey_CONST.CID) != null ? (String)queryParams.get(TWIST_QueryParamKey_CONST.CID) : null;
            Map<String, Object> cidMap = TWIST_RegistrationUtils.extractAccountId(cid);
            String accountId = cidMap.containsKey('accountId') ? (string) cidMap.get('accountId') : null ;
        
            TWIST_RegistrationUtils.Mode currentMode = TWIST_RegistrationUtils.getRegistrationMode(accountId, socialParams);
            
            form.putAll(formData);
            Map<String,String> convertedAccount = TWIST_RegistrationUtils.convertAccountToMap(currentMode, accountId);
            
            form.putAll(convertedAccount);

            Boolean isFormValid = TWIST_RegistrationUtils.validateForm(form, langCountry,currentMode);
            if(!isFormValid) return  TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Account_Creation_Form_AccountCreationProcessError', 'en')) ;
          
            if(doNeedVerificationCode){
                sendVerificationCode(form, queryParams);
            }
            
            return TWIST_Utils.buildSuccessResponseObject();
 
        } catch (Exception ex) {

            String origin = (String) queryParams.get(TWIST_QueryParamKey_CONST.ORIGIN);


            new Logs(new Map<String,Object> {
                'level' => 'ERROR',
                'apexClass' => 'TWIST_Registration',
                'category' => 'CALLOUT',
                'exception_case' => ex,
                'details' => 'details',
                'application' => origin
            });

            return  TWIST_Utils.buildFailureResponseObject('form', ex.getMessage());
        }
    }

    public static Map<String,Object> sendVerificationCode(Map<String,String> formData, Map<String,Object> queryParams ) {
            String langCountry = (String)queryParams.get('langCountry');
            String language = TWIST_login.getLanguage(langCountry);
            String origin = (String) queryParams.get('origin');
            List<IDENTITY_Registration_Form__mdt> verificationFieldsList = [
                SELECT Is_Required__c, Is_Hidden__c, Value__c, Field__c
                FROM IDENTITY_Registration_Form__mdt
                WHERE Context__c = :langCountry and Form__c ='Registration' and Section__c = 'Verification'
            ];

            Map<string, IDENTITY_Registration_Form__mdt> verificationFields = getMapFromList(verificationFieldsList);
            Map<String,Object> registrationComponentConfig  = TWIST_Utils.getAccountSettings();
            
            // Generate Random VERIFICATION CODE
            String code = String.valueOf(Math.round(Math.random() * 100000));
            counter_message = TWIST_Utils.countVerificationCodes(formData.get('email'), formData.get('mobile_phone'));
            String errorMessage;
            if( formData.containsKey('email') ) {
                if(counter_message < (Double)registrationComponentConfig.get('SentEmailLimit')) {
                    sendByEmail(code, origin, language, formData, verificationFields);
                    createCodeRequest(code, langCountry, origin, formData.get('email'));

                }
                else {
                    errorMessage = TWIST_i18nTranslations.translateSingleLabel('TWIST_Registration_Verification_Code_Limit', language);
                    new Logs(new Map<String,Object> {
                        'level' => 'ERROR',
                        'apexClass' => 'TWIST_Registration',
                        'category' => 'VALIDATION',
                        'message' => Label.IDENTITY_LOG_Limitation_Send_Email_by_Session,
                        'application' => origin,
                        'recordId' => formData.get('email')
                    });
                    throw new CustomException(errorMessage);
                    //TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('TWIST_Registration_Verification_Code_Limit', language));
                }
            }
            else if(formData.containsKey('mobile_phone')) {
                if(counter_message < (Double) registrationComponentConfig.get('SentSMSLimit')){
                    sendBySMS(code, origin, counter_message, formData, verificationFields);
                    createCodeRequest(code, langCountry, origin, formData.get('mobile_phone'));
                }
                else {
                    errorMessage = TWIST_i18nTranslations.translateSingleLabel('TWIST_Registration_Verification_Code_Limit', language);
                    new Logs(new Map<String,Object> {'level' => 'ERROR',
                        'apexClass' => 'TWIST_Registration',
                        'category' => 'VALIDATION',
                        'message' => Label.IDENTITY_LOG_Limitation_Send_Sms_by_Session,
                        'recordId' => formData.get('email'),
                        'application' => origin
                    });
                    throw new CustomException(errorMessage);
                }
            }
            return TWIST_Utils.buildSuccessResponseObject();
    }

    @AuraEnabled(cacheable=false)
    public static Boolean isValidCode(String language, String activationCode, String identifier, Map<String,Object> queryParams, Map<String,String> socialParams ) {
        String langCountry = (String) queryParams.get(TWIST_QueryParamKey_CONST.LANG_COUNTRY);

        String cid = queryParams.get(TWIST_QueryParamKey_CONST.CID) != null ? (String)queryParams.get(TWIST_QueryParamKey_CONST.CID) : null;
        Map<String, Object> cidMap = TWIST_RegistrationUtils.extractAccountId(cid);
        String accountId = cidMap.containsKey('accountId') ? (string) cidMap.get('accountId') : null ;

        TWIST_RegistrationUtils.Mode currentMode = TWIST_RegistrationUtils.getRegistrationMode(accountId, socialParams);

        if(currentMode == TWIST_RegistrationUtils.Mode.PARTIAL_ACTIVATION ){
            Account client = TWIST_RegistrationUtils.getClientById(accountId);
            identifier = client.PersonEmail;
        }

        return TWIST_RegistrationUtils.validateActivationCode(activationCode, identifier, 0);
    }

   

    /** PRIVATE METHODS *********************************************************************************************** */

    private static Map<string, IDENTITY_Registration_Form__mdt> getMapFromList(List<IDENTITY_Registration_Form__mdt> settingList){
        Map<string, IDENTITY_Registration_Form__mdt> settingMap = new Map<string, IDENTITY_Registration_Form__mdt>();
        for (IDENTITY_Registration_Form__mdt setting : settingList) {
            settingMap.put(setting.Field__c, setting);
        }
        return settingMap;
    }

    private static void sendByEmail(String code, String origin, String language, Map<string, string> client, Map<string, IDENTITY_Registration_Form__mdt> verificationFields) {
        try{
            // Get Email Template
            String templateId = verificationFields.get('email_template').Value__c;
            EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue FROM EmailTemplate WHERE Id =: templateId];

            // Replace Dynamic Values
            String htmlBody = emailTemplate.HtmlValue;
            htmlBody = htmlBody.replace('${LastName}', client.get('lastname'));
            htmlBody = htmlBody.replace('${FirstName}', client.get('firstname'));
            htmlBody = htmlBody.replace('${Verification_Code}', code);
            htmlBody = htmlBody.replace('${Default_Site}', verificationFields.get('default_site').Value__c);

            if(client.containsKey('dreamID') && String.IsNotEmpty(client.get('dreamID'))){
               htmlBody = htmlBody.replace('${DreamID}', client.get('dreamID'));
            } else{
                htmlBody = htmlBody.replace('${DreamID}', '');
            }
            if( client.containsKey('email') && String.IsNotEmpty(client.get('email'))){
                htmlBody = htmlBody.replace('${Username}', client.get('email'));
            }
            else if( client.containsKey('login_international_mobile_phone')) {
                htmlBody = htmlBody.replace('${Username}', client.get('login_international_mobile_phone'));
            }

            // get Title by picklist
            if(client.get('title') == '02' || client.get('title') == 'SM'){
                htmlBody = htmlBody.replace('${Salutation}', Label.IDENTITY_Email_Template_Salutation_for_Men);
            }
            else{
                htmlBody = htmlBody.replace('${Salutation}', Label.IDENTITY_Email_Template_Salutation_for_Women);
            }

            // Get  address
            List<String> toAddresses = new List<String>();
            toAddresses.add(client.get('email'));

            // Send Email
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(toAddresses);
            mail.setUseSignature(false);
            mail.setHtmlBody(htmlBody);
            mail.setSubject(TWIST_i18nTranslations.translateSingleLabel('IDENTITY_EMAIL_TEMPLATE_Subject', language));
            mail.setCharset('UTF-8');

            if(!String.isEmpty(verificationFields.get('sender_email').Value__c) ){//&& !isUnverifiedSenderAddress
                mail.setOrgWideEmailAddressId(verificationFields.get('sender_email').Value__c);
            }
            else{
                mail.setSenderDisplayName(verificationFields.get('sender_name').Value__c);
            }

            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            counter_message++;

            new Logs(new Map<String,Object> { 'level' => 'INFO',
                'apexClass' => 'TWIST_Registration',
                'category' => 'EVENT',
                'message' => Label.IDENTITY_LOG_Email_Sent,
                'details' => 'sent codes: ' + code,
                'recordId' => client.get('email'),
                'status_code' => Label.IDENTITY_LOG_Email_Sent,
                'application' => origin
            });
        }
        catch(Exception ex){
            System.debug('An error occured: ' + ex.getMessage());

            if(ex.getMessage().contains('UNVERIFIED_SENDER_ADDRESS')){
                // isUnverifiedSenderAddress = true;
                sendByEmail(code, origin, language, client, VerificationFields);
            }
            else {
                new Logs(new Map<String,Object> {
                    'level' => 'ERROR',
                    'apexClass' => 'TWIST_Registration',
                    'category' => 'CALLOUT',
                    'exception_case' => ex,
                    'details' => 'details',
                    'recordId' => verificationFields.get('email_template').Value__c,
                    'application' => origin
                });
               // TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_LoginProcessError', language));
               // throw new CustomException('error email sender');
            }
        }
    }

    private static void sendBySMS(String code, String origin, Integer counter_message, Map<string, string> client, Map<string, IDENTITY_Registration_Form__mdt> verificationFields) {
        try{
            // Get  phones
            List<String> toPhones = new List<String>();
            toPhones.add(client.get('login_international_mobile_phone'));

            Fractalist_API.sendVerificationSMS(toPhones, code, origin);
            counter_message++;
                        
            new Logs( new Map<String,Object> {'level' => 'INFO',
                'apexClass' => 'TWIST_Registration',
                'category' => 'EVENT',
                'message' => Label.IDENTITY_LOG_SMS_Sent,
                'details' => 'sent code: ' + code,
                'recordId' => client.get('login_international_mobile_phone'),
                'status_code' => Label.IDENTITY_LOG_SMS_Sent,
                'application' => origin
            });
        }
        catch(Exception ex){
                System.debug('An error occured: ' + ex.getMessage());
        }
    }

    private static void createCodeRequest(String code, String langCountry, String origin, String emailOrPhonenumber) {
        Registration_Code_Verification_Request__c request;
        try {
            request = new Registration_Code_Verification_Request__c (
                Code__c = code,
                Lang_Country__c = langCountry,
                Origin__c = origin,
                Record_Id__c = emailOrPhonenumber
            );
            insert request;
        }
        catch(Exception e) {
            System.debug('> Error in method createCodeRequest(): ' + e.getMessage());
        }
    }

    private static void getSettings() {
        isUnverifiedSenderAddress = false;
        registrationComponentConfig.putAll(TWIST_Utils.getAccountSettings());
    }

    private static void setContext(String origin, String langCountry, String dispatchCountry){
        TWIST_Utils.setContext(origin, langCountry, dispatchCountry, registrationComponentConfig);
    }

    private static void setFormFields(String langCountry, TWIST_RegistrationUtils.Mode currentMode ){
        formFields = TWIST_RegistrationUtils.getFormFieldsByContextAndMode(langCountry, currentMode);
        registrationComponentConfig.put('form',formFields);
    }

    private static void setCountryList(String lang_country, String dispatch_country, String language) {
        Boolean showCountryList = true;
        String countryListType;
        List<CountryLanguage__c> countriesPerCountryLang = new List<CountryLanguage__c>();
        List<String> dispatchCountries = new List<String>();
        List<String> countriesWithCountryLang = new List<String>();

        if(formFields.containsKey('country')) { // not needed in Partial

            if( !String.isEmpty(formFields.get('country').Default_Value__c)){
                if(String.isEmpty(dispatch_country)){
                    countryListType = 'SPECIFIC';
                    showCountryList = false;
                }
                else{
                    countriesPerCountryLang = [SELECT Dispatch_Country__c FROM CountryLanguage__c WHERE ATG_LOCALE__c =: lang_country AND Dispatch_Country__c != null];
                    if(countriesPerCountryLang.isEmpty() || countriesPerCountryLang.size() == 1){
                        countryListType = 'SPECIFIC';
                        showCountryList = false;
                    }
                    else{
                        countryListType = 'DISPATCH';
                        for(CountryLanguage__c c : countriesPerCountryLang){
                            if(!String.isBlank(c.Dispatch_Country__c)){
                                dispatchCountries.add(String.valueOf(c.Dispatch_Country__c));
                            }
                        }
                    }
                }
            }
            else{
                countryListType = 'ALL';
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
            List<CountryMapping__mdt> clist = [SELECT Picklist__c, Iso2Code__c, Iso3Code__c FROM CountryMapping__mdt WHERE Picklist__c != null];
            for(CountryMapping__mdt mdt: clist) {
                //only one country for lang_country
                if(countryListType == 'SPECIFIC'){
                    if(mdt.Iso3Code__c == formFields.get('country').Default_Value__c){
                        country_picklist.put(mdt.Picklist__c, mdt.Iso3Code__c);
                        registrationComponentConfig.put('client_country', formFields.get('country').Default_Value__c);
                    }
                }
                //multiple countries for lang_country (param dispatchCountry)
                else if(countryListType == 'DISPATCH'){
                    if(dispatchCountries.contains(mdt.Iso2Code__c)){
                        country_picklist.put(mdt.Picklist__c, mdt.Iso3Code__c);
                        if(mdt.Iso2Code__c == dispatch_country){
                            registrationComponentConfig.put('client_country', mdt.Iso3Code__c);
                        }
                    }
                
                }
                //default: all countries besides specific ones
                else{
                    if(!countriesWithCountryLang.contains(mdt.Iso2Code__c)){
                        country_picklist.put(mdt.Picklist__c, mdt.Iso3Code__c);
                    }
                }
            }
            Map<String,Object> countryListTranslated = TWIST_i18nTranslations.translatePicklist(PICKLIST_COUNTRIES, language);
            List <Map<String, String>> countryList = new List <Map<String, String>>();
            List<String> keys = new List<String>();
            keys.addAll(country_picklist.keySet());
            keys.sort();
            for(String key: keys){
                countryList.add(new Map<String, String> {
                    'label'=>countryListTranslated.get(key).toString(),
                    'value'=>country_picklist.get(key)
                });
            }
            registrationComponentConfig.put('countryList', countryList);
            registrationComponentConfig.put('showCountryList', showCountryList);
       }
    }

    private static void setTitles(String lang_country, String language) {
        List<String> customLabels = new List<String> {CL_TITLE_02, CL_TITLE_03, CL_TITLE_04, CL_TITLE_05, CL_TITLE_00};
 		Map<String,Object> titlesTranslated = TWIST_i18nTranslations.translateLabelsList(customLabels, language);
        Map<String, String> titleMapping = new Map<String, String> {
            '02'=>titlesTranslated.get(CL_TITLE_02).toString(),
            '03'=>titlesTranslated.get(CL_TITLE_03).toString(),
            '04'=>titlesTranslated.get(CL_TITLE_04).toString(),
            '05'=>titlesTranslated.get(CL_TITLE_05).toString(),
            '00'=>titlesTranslated.get(CL_TITLE_00).toString()
        };
        List <Map<String, String>> titleList = new List <Map<String, String>>();

        if(formFields.containsKey('title') ) {

            if(!String.isEmpty(formFields.get('title').Options__c)){
                List<String> titleValues = formFields.get('title').Options__c.split('/');
                for(String titleValue : titleValues){
                titleList.add(new Map<String, String>{'value'=>titleValue, 'label'=>titleMapping.get(titleValue)});
                }
            }
            registrationComponentConfig.put('titleList', titleList);
        }
    }

    private static void setMode(String accountId, String socialId) {
        Map<String,Object> socialData = new Map<String,Object>();
        Map<String,String> socialParams = new Map<String,String>();
        Boolean doNeedVerificationCode = true;
        if(String.isNotEmpty(socialId)){
            socialData = TWIST_RegistrationUtils.setSocialData(socialId);
            socialParams =  (Map<String,String>)socialData.get('data');
            registrationComponentConfig.put('socialParams', socialParams);
            if(socialData.containsKey('passKey')){
                registrationComponentConfig.put('passKey',socialData.get('passKey').toString());
                doNeedVerificationCode = false;
            }
        }
        TWIST_RegistrationUtils.Mode currentMode = TWIST_RegistrationUtils.getRegistrationMode(accountId, socialParams);
        
        mode = currentMode.name();
        registrationComponentConfig.put('mode', mode);

        registrationComponentConfig.put('modeInfo', new Map<String,Boolean> {
            'isRegistrationMode' => new List<TWIST_RegistrationUtils.Mode> { TWIST_RegistrationUtils.Mode.FULL_ACTIVATION, TWIST_RegistrationUtils.Mode.REGISTRATION, TWIST_RegistrationUtils.Mode.PARTIAL_SOCIAL_REGISTRATION, TWIST_RegistrationUtils.Mode.FULL_SOCIAL_REGISTRATION }.contains(currentMode),
            'isPartialActivationMode' => currentMode == TWIST_RegistrationUtils.Mode.PARTIAL_ACTIVATION ,
            'isEmailReadOnly' => currentMode == TWIST_RegistrationUtils.Mode.PARTIAL_SOCIAL_REGISTRATION ,
            'isSocialLogin' => new List<TWIST_RegistrationUtils.Mode> { TWIST_RegistrationUtils.Mode.PARTIAL_SOCIAL_REGISTRATION, TWIST_RegistrationUtils.Mode.FULL_SOCIAL_REGISTRATION }.contains(currentMode),
            'doNeedVerificationCode' => doNeedVerificationCode
        });
        
    }

    private static void setLoginBaseUrl(String langCountry, String origin){
        registrationComponentConfig.put('loginBaseUrl', TWIST_Utils.getLoginFormBaseUrl(langCountry, origin));
    }

    private static void setShowKanaFields(String langCountry){
        registrationComponentConfig.put('showKanaFields', langCountry =='jpn-jp');
    }

    private static void setLegalAge(String langCountry){
        Map<String,Object> settings = TWIST_RegistrationUtils.getSettingsForAgeRestriction(null, langCountry);
        registrationComponentConfig.put('legalAge', settings == null ? 0 : (Integer) settings.get('legalAge'));
    }
    private static void setCalendarDateFormat(String langCountry) {
        registrationComponentConfig.put('calendarDateFormat', TWIST_DateUtils.getDateFormatByLangCountry(langCountry));
    }

    private static void setPrefilledValues(String langCountry, String accountId, String utmCampaign){
        Account client = TWIST_RegistrationUtils.getClientById(accountId);
        Boolean isExclusiveOffer = TWIST_Utils.IsUtmCampaignValid(utmCampaign);
        if(mode == 'PARTIAL_ACTIVATION'){
            String identifier = client.PersonEmail; // TODO: Check according to country
            String identifierTruncated =  TWIST_Utils.truncateIdentifier(identifier);
            registrationComponentConfig.put('identifier', isExclusiveOffer ? identifier : identifierTruncated);
        }

        if(mode == 'FULL_ACTIVATION'){
       
            Map<String, Object> formData = TWIST_RegistrationUtils.convertAccountToForm(client, TWIST_RegistrationUtils.Mode.valueOf(mode), langCountry);
            registrationComponentConfig.put('formData', formData);
        }
    }

    private static void getSocialSettings(String langCountry, Map<String,Object> queryParams){
        registrationComponentConfig.put('socialMediaProviders', TWIST_Utils.getSocialProvidersByLangCountry(langCountry, queryParams));
    }

    private static void setForgotPasswordUrl(String langCountry, String origin, Map<String,Object> queryParams) {
        registrationComponentConfig.put('forgotPasswordUrl', TWIST_Utils.buildTwistPageUrl(TWIST_IdentityPathsMdt_CONST.FORGOT_PASSWORD_FORM, queryParams));
    }

    @testVisible
    private static void writeLogs(Map<String,Object> queryParams) {
        TWIST_Utils.writeErrorLogs(queryParams, 'TWIST_Registration');
    }

    private static void setFeaturesFlags(String langCountry, String origin) {
        if(origin != 'mylv'){
            registrationComponentConfig.put(TWIST_FlaggedFeatureUtils.FEATURE_KEY_LINE_SOCIAL_LOGIN, false);
            registrationComponentConfig.put(TWIST_FlaggedFeatureUtils.FEATURE_KEY_GOOGLE_SOCIAL_LOGIN, false);
        }
        else{
            TWIST_FlaggedFeatureUtils flags = new TWIST_FlaggedFeatureUtils( 
            new List<String> {
                TWIST_FlaggedFeatureUtils.FEATURE_KEY_LINE_SOCIAL_LOGIN,
                TWIST_FlaggedFeatureUtils.FEATURE_KEY_GOOGLE_SOCIAL_LOGIN
            },
            langCountry
            );
            registrationComponentConfig.put(TWIST_FlaggedFeatureUtils.FEATURE_KEY_LINE_SOCIAL_LOGIN,flags.isLineSocialLoginEnabled());
            registrationComponentConfig.put(TWIST_FlaggedFeatureUtils.FEATURE_KEY_GOOGLE_SOCIAL_LOGIN,flags.isGoogleSocialLoginEnabled());
        }
      
    }

    public class CustomException extends Exception {}
}


 /*

     private static void setMode(String social_id, String cid, String accountId, String utm_campaign, String campaign) {
        mode = TWIST_Mode_CONST.REGISTRATION;
        Boolean isSocialLoginVisible = true;

        // SOCIAL LOGIN
        if(!String.isEmpty(social_id)){
            mode = TWIST_Mode_CONST.SOCIAL_REGISTRATION;
            subMode = TWIST_Mode_CONST.FULL;
            isSocialLoginVisible = false;

            // GET SOCIAL DATA
            Blob social_id_decoded = EncodingUtil.base64Decode(social_id);
            String payload = social_id_decoded.toString();
            Map<String,Object> params = (Map<String,Object>)JSON.deserializeUntyped(payload);
            socialParams = new Map<String,String>();
            for(String key : params.keySet()){
                socialParams.put(key, (String)params.get(key));
            }

            System.debug('PAYLOAD:' + payload);
        }
        registrationComponentConfig.put('isSocialLoginVisible', isSocialLoginVisible);
        registrationComponentConfig.put('socialParams', socialParams);

        // ACTIVATION FORM
        registrationComponentConfig.put('cidUrlEncoded', cid != null ? EncodingUtil.urlEncode(cid, 'UTF-8') : '');
        if(!String.isEmpty(accountId)){
            mode = TWIST_Mode_CONST.ACTIVATION;
            subMode = TWIST_Mode_CONST.FULL;
        }

        // CARE SERVICE + EXCLUSIVE EXPERIENCE FLOWS HAS TO BE REDIRECTED TO LV APP
        Boolean redirectToLvApp = false;
        String redirectionDeeplinkValue = 'mylv';
        // Exclusive Experience
        Schema.DescribeFieldResult XXPR_OfferCode = Exclusive_Experience__c.Offer_Code__c.getDescribe();
        Schema.sObjectField fieldOfferCode = XXPR_OfferCode.getSObjectField();
        List<PicklistEntry> picklistValuesOfferCode = fieldOfferCode.getDescribe().getPicklistValues();
        List<String> picklistValuesOfferCodeString = new List<String>();
        for(PicklistEntry pe : picklistValuesOfferCode){
            picklistValuesOfferCodeString.add(pe.getValue());
        }
        if(utm_campaign != null && picklistValuesOfferCodeString.contains(utm_campaign)){
            redirectToLvApp = true;
            redirectionDeeplinkValue = 'myexclusive';
        }
        // Care Service
        if(campaign != null && campaign.contains('careService')){
            redirectToLvApp = true;
            redirectionDeeplinkValue = 'mycareservice';
        }
        System.debug('NEED REDIRECTION TO LV APP: '+redirectToLvApp);
        registrationComponentConfig.put('redirectToLvApp', redirectToLvApp);
        registrationComponentConfig.put('redirectionDeeplinkValue', redirectionDeeplinkValue);

        System.debug('MODE: ' + mode);
        System.debug('SUB_MODE: ' + subMode);
        registrationComponentConfig.put('mode', mode);
        registrationComponentConfig.put('subMode', subMode);
    }

    //return true if form is valid, false otherwise
    private static Boolean validateFormData(String email, String password) {
        //TODO Check all Form
        return !String.isEmpty(email) && !String.isEmpty(password) && !IDENTITY_Utils.passwordTooLong(password);
    }

   

    private static void setForm(String langCountry, String accountId, String origin, String errorUrl, String dispatch_country){

        // GET FIELDS CONFIGURATION
        List<IDENTITY_Registration_Form__mdt> metadata = [
            SELECT Form__c, Field__c, Is_Required__c, Section__c, Is_Hidden__c, Value__c
            FROM IDENTITY_Registration_Form__mdt
            WHERE Context__c =: langCountry
        ];
        
        //Map<String,Map<String,IDENTITY_Registration_Form__mdt>> fields = new Map<String,Map<String,IDENTITY_Registration_Form__mdt>>();
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
        registrationComponentConfig.put('fields', fields);

        // Email field visibility
        Boolean isEmailFieldVisible = false;
        String country_local = (String)registrationComponentConfig.get(TWIST_QueryParamKey_CONST.COUNTRY_LOCAL);
        if(
            (!fields.get('Login').get('email').Is_Hidden__c && country_local != 'cn') || (!fields.get('Login').get('email').Is_Hidden__c && country_local == 'cn' && (origin == 'lvapp' || origin == 'lvconnect') && mode == TWIST_Mode_CONST.ACTIVATION)
            ){
            isEmailFieldVisible = true;
        }
        registrationComponentConfig.put('isEmailFieldVisible', isEmailFieldVisible);

        // FOR ACTIVATION MODE - GET ALL FIELDS OF THE CLIENT
        if(mode == TWIST_Mode_CONST.ACTIVATION){
            
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
                

                if(errorUrl != null && errorUrl.contains('/checkout/identification')){
                    // checkoutPreviousPage = 'identification';
                    registrationComponentConfig.put('checkoutPreviousPage', 'identification');

                }
            }
        }

        // CLIENT CONSTRUCTOR
        client = new Client(fields, socialParams, dispatch_country, account_activation);
        Client client_origin = client;
 
        if(!String.isEmpty(client.country)){
            registrationComponentConfig.put('client_country', client.country);
        }
        if(!String.isEmpty(client.email)){
            registrationComponentConfig.put('client_email', client.email.substring(0,3)+'***');

        }
        if(!String.isEmpty(client.login_international_mobile_phone)){
            registrationComponentConfig.put('client_login_international_mobile_phone', client.login_international_mobile_phone.substring(0,3)+'***');

        }
        String client_type;
        if(!String.isEmpty(client.email) || !String.isEmpty(client.login_international_mobile_phone) || !String.isEmpty(client.firstname) || !String.isEmpty(client.lastname)){
            client_type = 'exists';
        }
        else{
            client_type = 'new';
        }
        registrationComponentConfig.put('client_type', client_type);

        System.debug('CLIENT CONSTRUCTOR: ' + JSON.serialize(client));
        registrationComponentConfig.put('client', client);
        // registrationComponentConfig.put('client_origin', client_origin);
    }

    // DESCRIPTION Define initialize step. by default 1, for Korean 0 (need of KISA section)
    //            0 => KISA, 1 => LOGIN, 2 => PERSONAL, 3 => VERIFICATION, -1 => LOADING
    // RETURN
    private static void setSubMode(){

        if(mode == TWIST_Mode_CONST.SOCIAL_REGISTRATION || mode == TWIST_Mode_CONST.ACTIVATION){
            Map<String,Map<String,IDENTITY_Registration_Form__mdt>> fields = (Map<String,Map<String,IDENTITY_Registration_Form__mdt>>) registrationComponentConfig.get('fields');
            if( (!fields.get('Login').get('email').Is_Hidden__c && !String.isEmpty(client.email)) || (!fields.get('Login').get('mobile_phone').Is_Hidden__c && !String.isEmpty(client.login_international_mobile_phone)) ){
                subMode = TWIST_Mode_CONST.PARTIAL;
            }
            else {
                subMode = TWIST_Mode_CONST.FULL;
            }
        registrationComponentConfig.put('subMode', subMode);
        }
    }

    public static void onPersonalSubmit() {
        if(counter_message == 0) {
            //sendVerificationCode(); //TODO
        }
    }
    
    public static void onPersonalSubmit(Map<String,String> formData, String recaptchaToken, Map<String,Object> queryParams, String language) {
        counter_message = TWIST_Utils.countVerificationCodes(formData.get('email'), formData.get('mobile_phone'));
        if(counter_message == 0) {
            // sendVerificationCode(formData, recaptchaToken, queryParams, language);
        }
    }
    
 
    public static void onLoginSubmit(String mode, String subMode, Map<String,String> formData, String recaptchaToken, Map<String,Object> queryParams, String language) {
        if(mode == TWIST_Mode_CONST.SOCIAL_REGISTRATION && subMode == TWIST_Mode_CONST.MATCHING){
            // sendVerificationCode(formData, recaptchaToken, queryParams, language);
        }
    }

    public static void onVerificationSubmit(){
        // isConfirmed = isValidCode();
    }
    public static Boolean onVerificationSubmit(String recaptchaToken, String language, String activationCode, String identifer, Integer state) {
    return isValidCode(recaptchaToken, language, activationCode, identifer, state);
    }


    @AuraEnabled(cacheable=false)
    public static Map<String,Object> createAccount(Map<String,String> accountInfo, String recaptchaToken, Map<String,Object> queryParams, String language) {
        try {
            Map<String,Object> verifyResult = TWIST_RecaptchaUtils.verifyRecaptchaToken(recaptchaToken, language, 'Email: ' + accountInfo.get('email'));
            if (!Boolean.valueOf(verifyResult.get('success'))) {
                return TWIST_Utils.buildFailureResponseObject('form', String.valueOf(verifyResult.get('error')));
            }

            // JSI implement rest of Business Logic here...
            
            return TWIST_Utils.buildSuccessResponseObject('redirectUrl', 'https://www.google.com'); // JSI change this temporary return value
        }
        catch(Exception e) {
            new Logs(new Map<String,Object> {
                'level' => 'ERROR',
                'apexClass' => 'TWIST_Registration',
                'category' => 'SYSTEM',
                'message' => e.getMessage()
            });
        }
        return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_LoginProcessError', language)); // JSI change as per Business needs
    }
*/