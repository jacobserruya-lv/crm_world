public without sharing class TWIST_Account_Confirmation {
    
    @AuraEnabled
    public static Map<String,Object> createMyLvUserAndRedirect(String activationCode, String identifier, Map<String,Object> formData, Map<String,Object> queryParams, Map<String,String> socialParams, String passKey) {
        Map<String,Object> form = new  Map<String,Object>();

        String countryLanguage =  queryParams?.containsKey(TWIST_QueryParamKey_CONST.LANG_COUNTRY) ? (String) queryParams.get(TWIST_QueryParamKey_CONST.LANG_COUNTRY) : 'eng-e1' ;
        String language = TWIST_login.getLanguage(countryLanguage);
        
        String password = (String) formData.get('password');
        String cid = queryParams?.containsKey(TWIST_QueryParamKey_CONST.CID) ? (String)queryParams.get(TWIST_QueryParamKey_CONST.CID) : null;

        Map<String, Object> cidMap = TWIST_RegistrationUtils.extractAccountId(cid);
        String accountId = cidMap.containsKey('accountId') ? (string) cidMap.get('accountId') : null ;

        String errorLabel = TWIST_i18nTranslations.translateSingleLabel('Twist_Account_Creation_Form_AccountCreationProcessError', language);
        
        try {
            
            TWIST_RegistrationUtils.Mode currentMode = TWIST_RegistrationUtils.getRegistrationMode(accountId, socialParams);
            if(currentMode == TWIST_RegistrationUtils.Mode.PARTIAL_ACTIVATION ){ // fill the form when coming from a parial activation in order to send the mail
                
                Account client = TWIST_RegistrationUtils.getClientById(accountId);
                form = new Map<String,Object>{
                    'email' => client.PersonEmail,
                    'firstname'   => client.FirstName,
                    'lastname'    => client.LastName,
                    'mobile_phone'=> client.PersonMobilePhone,
                    'title'       => client.Salutation
                };
                identifier =  client.PersonEmail ;//TODO: according to country
            }
            form.putAll(formData);
            
            if(String.isNotEmpty(passKey)){
                Boolean isPassKeyValid = TWIST_RegistrationUtils.validatePassKey(passKey, identifier);
                if(!isPassKeyValid) throw new CustomException('PASSKEY NOT VALID')  ;
            }
            else{
                Boolean isCodeValid = String.isNotEmpty(activationCode) && TWIST_RegistrationUtils.validateActivationCode(activationCode ,identifier ,1);
                if(!isCodeValid) throw new CustomException('CODE NOT VALID')  ;
            }
            
            Boolean isFormValid = TWIST_RegistrationUtils.validateForm(form, countryLanguage, currentMode);
            if(!isFormValid) throw new CustomException('FORM NOT VALID') ;
            
            Account client = convertFormDataToAccount(form ,accountId , currentMode ,countryLanguage);
            
            if(currentMode == TWIST_RegistrationUtils.Mode.PARTIAL_SOCIAL_REGISTRATION && String.isEmpty(password)) {
     
                password = TWIST_Utils.createRandomPassword(); 
            }
 
            Id userId = userCreation(client ,password ,queryParams , currentMode );
            if(userId == null) throw new CustomException('USER CREATION ERROR') ;
            
            
            if(getSocialMode(currentMode)){
                TWIST_RegistrationUtils.setSocialMediaIdentifier(client, socialParams, userId);
            }
            
            sendMarketingCloudEmail(client.Id, countryLanguage);
            
            return doSalesforceLogin(identifier, password, queryParams ,language) ;
        }
        catch (Exception ex) {
            String origin = (String) queryParams.get(TWIST_QueryParamKey_CONST.ORIGIN);
            new Logs(new Map<String,Object> {
                'level' => 'ERROR',
                'apexClass' => 'TWIST_Registration',
                'category' => 'VALIDATION',
                'exception_case' => ex,
                'details' => ex.getMessage(),
                'application' => origin
            });
            
            return  TWIST_Utils.buildFailureResponseObject('form', errorLabel) ;
        }
    }
    //TODO: TO MOVE REGISTRATION CLASS
    @AuraEnabled
    public static boolean isUserIdentity(string email){
        return TWIST_Utils.canFindMyLVUserWithEmail(email);
    }

    @AuraEnabled
    public static Map<String,Object> socialMediaCreationAndLogin(string email, string password, Map<String,String> socialParams, Map<String,Object> queryParams){

        TWIST_Settings__c settings = TWIST_Settings__c.getInstance();
        String langCountry = (String) settings.get('Default_Language_Country_Parameter__c');

        String countryLanguage =  queryParams?.containsKey(TWIST_QueryParamKey_CONST.LANG_COUNTRY) ? (String) queryParams.get(TWIST_QueryParamKey_CONST.LANG_COUNTRY) : langCountry;
        String language = TWIST_login.getLanguage(countryLanguage);
        User user = IDENTITY_Utils.getUserByUsername(email);
        Account client = new Account(id=user.AccountId);
        TWIST_RegistrationUtils.setSocialMediaIdentifier(client, socialParams, user.Id);
         
        return doSalesforceLogin(user.Username, password, queryParams, language);
    }

    public static Account convertFormDataToAccount(Map<String,Object> formData ,String accountId , TWIST_RegistrationUtils.Mode currentMode ,String countryLanguage){
        
        if(currentMode == TWIST_RegistrationUtils.Mode.PARTIAL_ACTIVATION) return TWIST_RegistrationUtils.getClientById(accountId);

        Account account = new Account();
        
        if(currentMode == TWIST_RegistrationUtils.Mode.FULL_ACTIVATION) account.id = accountId;

        // if(currentMode == TWIST_RegistrationUtils.Mode.MATCHING_SOCIAL_REGISTRATION )return TWIST_Utils.findAccountsByEmail((String) formData.get('email'))[0];
                
        Map<String ,TWIST_Form_Registration_Fields__mdt> fieldsRegistrationMode = TWIST_RegistrationUtils.getFieldsRegistrationMode();
        
        Map<String, Schema.SobjectField> accountfields = Schema.SObjectType.Account.fields.getMap();
        
        for(string key: formData.keySet()){
            
            if(fieldsRegistrationMode.containsKey(key) && fieldsRegistrationMode.get(key).Field_Api_Name__c != null && String.isNotEmpty((String) formData.get(key))) {
                
                String fieldApiName = fieldsRegistrationMode.get(key).Field_Api_Name__c ;
                
                //get type of the field
                Schema.SObjectField field = accountfields.get(fieldApiName);
                Schema.DisplayType type = field.getDescribe().getType();
                
                if (type == Schema.DisplayType.DATE ){
                    account.put( fieldApiName, Date.valueOf((String)formData.get(key)));
                }
                else if (type == Schema.DisplayType.BOOLEAN ){
                    account.put( fieldApiName, Boolean.valueOf(formData.get(key)));
                }else{
                    account.put( fieldApiName, formData.get(key));
                }
                
            }
        }
        
        Map<String ,TWIST_Default_Settings__mdt> settingMap = TWIST_RegistrationUtils.getDefaultSettings(countryLanguage);
        account.TECH_Currencies__pc = settingMap.containsKey('Currency Code') ?  settingMap.get('Currency Code')?.Default_Value__c : '';
        
        
        String countryCode = formData.containsKey('country') ? (String) formData.get('country') : '' ;
        
        List<CountryMapping__mdt> countryInfo = [SELECT PicklistValueSet__c, Iso2Code__c, Iso3Code__c , Calling_Code__c
        FROM CountryMapping__mdt
        WHERE Iso3Code__c =: countryCode AND HasOtherValue__c = false
        LIMIT 1];
        
        if(!countryInfo.IsEmpty()){
            
            account.PrimaryCountry__pc = countryInfo.get(0).PicklistValueSet__c;
            account.MobilePhoneCountryCallingCode__pc = String.ValueOf(countryInfo.get(0).Calling_Code__c);
            account.LoginPhoneCallingCode__pc = String.ValueOf(countryInfo.get(0).Calling_Code__c);
            account.LoginPhoneCountryCode__pc =  countryInfo.get(0).Iso2Code__c;
            account.MobilePhoneCountryCode__pc = countryInfo.get(0).Iso2Code__c;
        }
        if(account.Newsletter__c == true){
            
            account.Can_Be_Contacted_By_Email__pc = true;
        }
        /*
        if (formData.containsKey('mobile_phone')){
            account.LoginPhone__pc = 'international_mobile_phone';
            account.LocalLoginPhone__pc = 'local phone' ;
            account.LocalMobilePhone__pc =  'local Phone' ;
            account.PersonMobilePhone  = 'international_mobile_phone';
        }
        */
        
        return account;
    }
    
    
    
    public static Map<String,Object> doSalesforceLogin( String identifier, String password, Map<String,Object> queryParams, String language){
        Pagereference page = TWIST_LoginService.doSalesforceLogin(
            identifier,
            password,
            String.valueOf(queryParams.get(TWIST_QueryParamKey_CONST.STATE)),
            String.valueOf(queryParams.get(TWIST_QueryParamKey_CONST.CODE_CHALLENGE)),
            String.valueOf(queryParams.get(TWIST_QueryParamKey_CONST.CLIENT_ID)),
            String.valueOf(queryParams.get(TWIST_QueryParamKey_CONST.REDIRECT_URI))
        );
        if (page == null) {
            return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nCustomLabels.translateSingleLabel('Twist_Login_Form_LoginProcessError', language));
        }
        return TWIST_Utils.buildSuccessResponseObject('redirectUrl', page.getUrl());
    }
    
    public static Id userCreation( Account client  , String password , Map<String ,Object> queryParams , TWIST_RegistrationUtils.Mode currentMode ) {
        
        Id userId;
        
        switch on currentMode {
            
            when REGISTRATION, FULL_SOCIAL_REGISTRATION, PARTIAL_SOCIAL_REGISTRATION {
                Database.insert(client);
                client = TWIST_RegistrationUtils.getClientById(client.id);
                userId = createUser(client , password);
            }
            when FULL_ACTIVATION {
            
                Database.update(client);
                client = TWIST_RegistrationUtils.getClientById(client.id);
                userId = createUser(client , password);
            }
            when PARTIAL_ACTIVATION {
                userId =  createUser(client , password);
            }
            when MATCHING_SOCIAL_REGISTRATION{
                userId = TWIST_Utils.getUserByUsername(client.PersonEmail).Id;
                //if(!String.isEmpty(password)) System.setPassword(userId, password);//TODO A VOIR AVEC LE BUSINESS
            }
            when else {
                throw new AuraHandledException('error');
            }
        }
        sendClientRMS(client ,queryParams);
        
        return userId;
    }
    
    //TODO: TO MOVE TO UTILS CLASS
    private static Id createUser(Account client , string password) {
        User userExt =  TWIST_Utils.createExternalMyLVUser( client ,  password) ;
        return userExt.id;
    }

    //TODO: TO MOVE TO UTILS CLASS
    public static void sendClientRMS(Account client , Map<String ,Object> queryParam) {
        
        Boolean sendToRms = false ;
        String dispatchCountry = (String) queryParam.get(TWIST_QueryParamKey_CONST.DISPATCH_COUNTRY);
        String langCountry = (String)queryParam.get(TWIST_QueryParamKey_CONST.LANG_COUNTRY);


        try{
            
            List<Pilot_Setting__mdt> virtualSettings =[
            SELECT Excluded_Countries__c
            FROM Pilot_Setting__mdt
            WHERE QualifiedApiName = 'Identity_RMS_FLOW' LIMIT 1
            ];
            
            Account accountForRMS = IDENTITY_Utils.getAccountForRMS(client);
            
            if(String.IsEmpty(accountForRMS.RMSId__pc) && IDENTITY_Utils.isExistDefaultStoreForRMS(dispatchCountry, langCountry) && String.IsBlank(accountForRMS.AttachedStore__pc)){
                
                accountForRMS =  IDENTITY_Utils.getDefaultStoreValuesForRMS(accountForRMS, dispatchCountry, langCountry);
                Database.SaveResult srList = Database.update(accountForRMS, false);
                
                sendToRms = true;
            }
            
            if(sendToRMS && String.IsNotBlank(accountForRMS.AttachedStore__pc) && IDENTITY_Utils.isStoreTypeValidForRMS(accountForRMS)){
                
                if(virtualSettings.size() > 0 && String.isNotBlank(virtualSettings.get(0).Excluded_Countries__c)){
                    
                    Pilot_Setting__mdt  valExcludedCount = virtualSettings.get(0);
                    if(String.isNotBlank(accountForRMS.HomeAddressCountryCode__pc) && !valExcludedCount.Excluded_Countries__c.containsIgnoreCase(accountForRMS.HomeAddressCountryCode__pc)){
                        SO_CreateUpdateRMSClient_Utils.createAccountIntoRMS_WS_v5(accountForRMS.Id);
                    }

                } else {
                    SO_CreateUpdateRMSClient_Utils.createAccountIntoRMS_WS_v5(accountForRMS.Id);
                }
            }
            
        }catch(Exception ex){

            String origin = (String)queryParam.get(TWIST_QueryParamKey_CONST.ORIGIN);

            new Logs(new Map<String,Object> {
                'level' => 'ERROR',
                'apexClass' => 'TWIST_Account_Confirmation',
                'category' => 'EVENT',
                'message' => 'XXXX',
                'details' => ex.getMessage(),
                'application' => origin
            });
        }
    }
    
    
    @future(callout=true)
    public static void sendMarketingCloudEmail(String accountId, String language) {
        Account client = TWIST_RegistrationUtils.getClientById(accountId);
        String countryCode = [SELECT Iso2Code__c FROM Country__c WHERE Iso3Code__c =: client.SPO_Country_code__pc LIMIT 1]?.Iso2Code__c;
        sendMarketingCloudEmail(client.PersonEmail, client.LastName, client.FirstName, client.Salutation, countryCode, language);
    }
    
    private static void sendMarketingCloudEmail(String email, String lastName, String firstName, String civility, String countryCode, String language) {
        
        Map<String,String> settings = TWIST_Utils.getAccountCreationdEmailSettings();
        List <String> splitLangCountry = language.split('-');
        String preferredLanguage = splitLangCountry[0].substring(0,2).toUpperCase();
        String body = MarketingCloudEmails_API.getBody(null, email, settings.get('definitionKey'), lastName, firstName, civility, countryCode, language, null, preferredLanguage);

        HTTP_Utils request = new HTTP_Utils()
        .post(settings.get('endpoint'))
        .header('Content-Type', 'application/json')
        .header('client_id', settings.get('client_id'))
        .header('client_secret', settings.get('client_secret'))
        .body(body)
        .call();
        
        //Map<String,String> response = request.getParameters();
        
        if(request.statusCode() == 202) {
            MarketingCloudEmails_API.logResponse( request, 'INFO');
        } else {
            MarketingCloudEmails_API.logResponse( request, 'ERROR');
        }
    }
    
    private static Boolean getSocialMode(TWIST_RegistrationUtils.Mode currentMode){
    
        return new List<String>{
            TWIST_RegistrationUtils.Mode.PARTIAL_SOCIAL_REGISTRATION.name(),
            TWIST_RegistrationUtils.Mode.FULL_SOCIAL_REGISTRATION.name(),
            TWIST_RegistrationUtils.Mode.MATCHING_SOCIAL_REGISTRATION.name()}.contains(currentMode.name());
    }

        
    public class CustomException extends Exception {}
}