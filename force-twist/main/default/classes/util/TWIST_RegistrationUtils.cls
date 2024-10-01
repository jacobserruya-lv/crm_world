public without sharing class TWIST_RegistrationUtils {

    //TODO: [TWIST-11173] Add social mode
    public enum Mode {PARTIAL_ACTIVATION, FULL_ACTIVATION, REGISTRATION, LOGIN, FULL_SOCIAL_REGISTRATION, PARTIAL_SOCIAL_REGISTRATION,MATCHING_SOCIAL_REGISTRATION}

    public static Mode getRegistrationMode(Id accountId, Map<String,String> socialParams){

        if(!socialParams.isEmpty()){
            String username = String.isNotBlank(socialParams.get('email') ) ? socialParams.get('email') : null;
            if(username == null ) return Mode.FULL_SOCIAL_REGISTRATION;
            if(TWIST_Utils.getUserByUsername(username) != null){
                return Mode.MATCHING_SOCIAL_REGISTRATION;
            }
            return Mode.PARTIAL_SOCIAL_REGISTRATION;
        }

        if(accountId == null) return Mode.REGISTRATION;

        Account client = getClientById(accountId);

        if(client == null) return Mode.REGISTRATION;

        Boolean hasIndentifier = String.isNotBlank(client.PersonEmail ) || String.isNotBlank(client.LoginPhone__pc ); //TODO check according to setting of the country

        if(!hasIndentifier) return Mode.FULL_ACTIVATION;

        Boolean hasMyLVUser = TWIST_Utils.canFindMyLVUserWithEmail(client.PersonEmail); //TODO

        if(!hasMyLVUser) return Mode.PARTIAL_ACTIVATION ;

        return Mode.LOGIN;
    }

    public static Account getClientById(Id accountId){

        List<Account> clients = [
        SELECT Id, LastName,FirstName,PersonContactId, PersonMobilePhone, LocalMobilePhone__pc,Title__pc,DREAMID__c, PersonBirthDate,
        PrimaryCountry__pc, SPO_Country_code__pc,LoginPhone__pc,LocalLoginPhone__pc,PersonEmail, Can_Be_Contacted_By_Email__pc,
        LoginPhoneCallingCode__pc, HomeAddressCountryCode__pc,toLabel(salutation) title, Salutation, MobilePhoneCountryCallingCode__pc
        FROM Account
        WHERE Id =: accountId ];

        return clients.size() > 0 ? clients.get(0) : null ;
    }

    public static Map<String,TWIST_Form_Registration_Settings__mdt> getFormFieldsByContextAndMode(String countryLanguage, Mode actualMode) {

        String mode = actualMode.name();

        Map<String,TWIST_Form_Registration_Fields__mdt> formRegistrationFields = getFieldsRegistrationMode();

        Map<String,TWIST_Form_Registration_Settings__mdt> formFields = new Map<String,TWIST_Form_Registration_Settings__mdt>();
        List<TWIST_Form_Registration_Settings__mdt> fieldsForm = [
        SELECT Field__c, Is_Required__c, Country_Language__c, Validation_Max_Length__c, Options__c, Default_Value__c
        FROM TWIST_Form_Registration_Settings__mdt
        WHERE Country_Language__c =: countryLanguage
        ];
        for (TWIST_Form_Registration_Settings__mdt field: fieldsForm) {

            List<String> modes = formRegistrationFields.get(field.Field__c).Modes__c.split(',') ;

            if(modes.contains(mode)) {
                formFields.put(field.Field__c, field);
            }
        }

        return formFields;
    }

    public static Map<String, TWIST_Form_Registration_Fields__mdt> getFieldsRegistrationMode() {

        Map<String,TWIST_Form_Registration_Fields__mdt> formRegistrationFields = new Map<String,TWIST_Form_Registration_Fields__mdt>();

        for(TWIST_Form_Registration_Fields__mdt field: [SELECT Field__c, Field_Api_Name__c, Modes__c FROM TWIST_Form_Registration_Fields__mdt] ){

            formRegistrationFields.put(field.Field__c, field );
        }

        return formRegistrationFields;
    }


        /**
     * @param identifier the username or the phone number
     * @param state state of the activation code
     * used two timefor the activation and for the confirmation
     */
    public static Boolean validateActivationCode(String activationCode, String identifier, Integer state ) {

        if (!activationCode.isNumeric()) return false;

        List<Registration_Code_Verification_Request__c> codes = [
            SELECT Id, code__c, State__c, CreatedDate
            FROM Registration_Code_Verification_Request__c
            WHERE Record_Id__c = :identifier AND State__c = :String.valueOf(state)
            ORDER BY Createddate DESC
            LIMIT 1
        ];

        TWIST_Registration_Form_Settings__c settings = TWIST_Registration_Form_Settings__c.getInstance();
        Decimal validityTime = settings.Code_Validity_Time__c;
        String defaultCode = settings.Default_activation_code__c;
        if(!codes.IsEmpty() && (codes.get(0).code__c == activationCode || (defaultCode!=null && defaultCode == activationCode)) && state < 2 && (validityTime != null && Datetime.now() < codes.get(0).Createddate.addMinutes(Integer.valueOf(validityTime))) ){

            Registration_Code_Verification_Request__c codeToUpadate = codes.get(0);
            codeToUpadate.State__c = String.valueOf( integer.ValueOf(codeToUpadate.State__c) + 1 ) ;

            Database.update(codeToUpadate, false);
            return true;
        }

        return false;
    }

    public static Boolean validatePassKey(String passKey, String identifier) {
        Map<String,Object> passKeyMap = EncryptUtils.getDecryptedMetadata(passKey);
        if(passKeyMap != null){
            String passKeyDecrypted = passKeyMap.containsKey('email') ? passKeyMap.get('email').toString() : null ;
            if(passKeyDecrypted == identifier){
                return true;
            }
        }
        return false;
    }

    public static boolean validateForm( Map<String,Object> form, String countrylanguage,Mode actualMode ) {

        for (TWIST_Form_Registration_Settings__mdt setting : getFormFieldsByContextAndMode(countrylanguage, actualMode).values()) {
            Boolean isFieldRequired = setting.Is_Required__c && (!form.containsKey(setting.Field__c) || form.get(setting.Field__c) == null);
            if(isFieldRequired) {
                throw new CustomException('MISSING FIELD REQUIRED');
            }

            Boolean isFieldMaxLength = setting.Validation_Max_Length__c != null && String.valueOf(form.get(setting.Field__c)).length() > setting.Validation_Max_Length__c;
            if(isFieldMaxLength) {
                throw new CustomException('MAX LENGHT OUTMODED');
            }

            Boolean isValidateInFrom = validateFormData(setting.Field__c, form, countrylanguage);
            if(isValidateInFrom) {
                throw new CustomException('FORM NOT VALID');
            }
        }
        return true;
    }

    public static Boolean validateFormData(String field, Map<String,Object> form, String langCountry) {

        String fieldValue;
        if (form.get(field)  != null){
            fieldValue = form.get(field) instanceof String ?  String.valueOf(form.get(field)).trim() :  String.valueOf(form.get(field));
        }
        switch on field {
            when 'password' {
                Map<String,String> user = new Map<String,String> {'FirstName' => (string) form.get('firstname'), 'LastName' => (string) form.get('lastname') };
                return !TWIST_Utils.doesPasswordMatchStringPattern(fieldValue) || TWIST_Utils.doesPasswordContainUserFirstNameOrLastName(fieldValue, user) ;
            }
            when 'passwordconfirmation' {
                return !TWIST_Utils.doPasswordsMatch((String)form.get('password'), fieldValue );
            }
            when 'email' {
                return !TWIST_Utils.isValidEmail(fieldValue) || isUserIdentity(fieldValue);
            }
            when 'emailconfirmation' {
                return fieldValue != (String)form.get('email') ;
            }
            when 'birthdate' {
                Map <String,Object> settings = getSettingsForAgeRestriction(fieldValue, langCountry);
                if (settings != null){
                    String email = (String) form.get('email');
                    if (TWIST_Utils.isUserBlocked(email, langCountry)){
                        throw new CustomException(TWIST_i18nTranslations.translateSingleLabel('Twist_Account_Creation_Age_Legal_Reached', TWIST_login.getLanguage(langCountry)));
                    }
                    if (TWIST_Utils.isFutureDate(fieldValue)){
                        throw new CustomException(TWIST_i18nTranslations.translateSingleLabel('Twist_Account_Creation_BirthDate_Inconsistent', TWIST_login.getLanguage(langCountry)));
                    }
                    if ((Boolean) settings.get('isMinAge')){
                        TWIST_Utils.blockUser(settings, email, fieldValue, langCountry);
                    }
                }
                return false;
            }
            when else {
                return false;
            }
        }
    }

    public static Map<String,Object> getSettingsForAgeRestriction(String value, String locale){
        List<TWIST_Form_Registration_Settings__mdt> settings = [
            SELECT Options__c, Country_Language__c, Display_Birthday_Help_Text__c
            FROM TWIST_Form_Registration_Settings__mdt
            WHERE Options__c != NULL
            AND Field__c = 'birthdate'
            AND Country_Language__c = :locale];
       	if (!settings.isEmpty()){
            String optionsString = (String) settings[0].get('Options__c');
            String langCountry = (String) settings[0].get('Country_Language__c');
            Boolean displayBirthdayHelpText = (Boolean) settings[0].Display_Birthday_Help_Text__c;
            Map<String, Object> optionsMap = (Map<String,Object>) JSON.deserializeUntyped(optionsString);
            Integer legalAge = (Integer) optionsMap.get('minAge');
            return new Map<string, Object> {
                'legalAge' => legalAge,
                'timeBlockValue' => (Integer) optionsMap.get('timeBlock'),
                'langCountry' => langCountry,
                'isMinAge' => Twist_Utils.isMinimumAge(value, legalAge),
                'displayBirthdayHelpText' => displayBirthdayHelpText
            };
        }
        return null;
    }

    public static boolean isUserIdentity(string email){
        return TWIST_Utils.canFindMyLVUserWithEmail(email);
    }

    public static Map<String,Object> extractAccountId(String encryptedAccountId){
        if(encryptedAccountId != null) {
            Map<String,Object> cidMap = EncryptUtils.getDecryptedMetadata(encryptedAccountId);
            if(cidMap != null){
                return cidMap;
            }
            try{

                String accountId;
                Blob key = EncodingUtil.base64Decode(IDENTITY_Settings__c.getOrgDefaults().AES_Key__c);
                if(!Test.isRunningTest()){
                    accountId = Crypto.decryptWithManagedIV('AES128', key, EncodingUtil.base64Decode(encryptedAccountId)).toString();
                }else{
                    accountId = 'TWISTTESTID | true';
                }
                Boolean isTrustOrigin = false;

                if(accountId.contains('|')){
                    List<String> accountIdWithTrustOrigin = accountId.split('\\|'); // escape special character pipe
                    accountId = accountIdWithTrustOrigin[0];
                    isTrustOrigin = Boolean.valueOf(accountIdWithTrustOrigin[1]);
                }

                return new Map<String,Object>{
                    'accountId' => accountId,
                    'isTrustOrigin' => isTrustOrigin
                };
            }
            catch (Exception ex) {
                System.debug(ex.getMessage());
            }
        }
        return new Map<String,Object>();

    }

    public static Map<String,String> convertAccountToMap(Mode currentMode, String accountId){

        Map<String,String> form = new Map<String,String>();

        if(currentMode == TWIST_RegistrationUtils.Mode.PARTIAL_ACTIVATION ) { // in oder to send email

            Account client = TWIST_RegistrationUtils.getClientById(accountId);
            form = new Map<String,String>{
                'email' => client.PersonEmail,
                'firstname' => client.FirstName,
                'lastname' => client.LastName,
                'mobile_phone'=> client.PersonMobilePhone,
                'title' => client.Salutation,
                'dreamID' => client.DREAMID__c,
                'login_international_mobile_phone' => client.LoginPhone__pc
            };
        }

        return form;

    }

    public static Map<String,TWIST_Default_Settings__mdt> getDefaultSettings(String countryLanguage) {
        Map<String ,TWIST_Default_Settings__mdt> result = new Map<String ,TWIST_Default_Settings__mdt>();
        List<TWIST_Default_Settings__mdt> settings = [
            SELECT Id ,Setting__c,Default_Value__c
            FROM TWIST_Default_Settings__mdt
            WHERE Country_Language__c = :countryLanguage
        ];
        for (TWIST_Default_Settings__mdt setting : settings) {
            result.put(setting.Setting__c, setting);
        }
        return result;
    }

    public static Map<String,Object> convertAccountToForm(Account client, Mode currentMode, String countryLanguage){
        Map<String,Object> formData = new Map<String, Object> ();
        Map<String,TWIST_Form_Registration_Fields__mdt> fieldsRegistrationMode = TWIST_RegistrationUtils.getFieldsRegistrationMode();
        Map<String,TWIST_Form_Registration_Settings__mdt> formFieldsByContextAndMode = TWIST_RegistrationUtils.getFormFieldsByContextAndMode(countryLanguage, currentMode);
        for(String key : formFieldsByContextAndMode.keySet()){
            if(fieldsRegistrationMode.containsKey(key) && fieldsRegistrationMode.get(key).Field_Api_Name__c != null) {
                String field = fieldsRegistrationMode?.get(key)?.Field_Api_Name__c;
                formData.put(key, String.valueOf(client?.get(field)));
            }
        }
        return formData;
    }

    public static Map<String,Object> setSocialData(String base64SocialId){
        // GET SOCIAL DATA
        Map<String,Object> socialData = new Map<String,Object>();
        if(String.isNotEmpty(base64SocialId) && StringUtils.isValidBase64(base64SocialId)){
            Blob decodedSocialId = EncodingUtil.base64Decode(base64SocialId);
            String payload = decodedSocialId.toString();
            Map<String,Object> jsonElements = (Map<String,Object>) JSON.deserializeUntyped(payload);
            if(jsonElements.containsKey('passKey')){
                socialData.put('passKey', ((String) jsonElements.get('passKey')).trim());
            }
            if(jsonElements.containsKey('data')){
                Map<String, Object> data = (Map<String, Object>)jsonElements.get('data');
                Map<String,String> socialParams = new Map<String,String>();
                for (String key : data.keySet()){
                    String cleanedValue = ((String) data.get(key)).trim();
                    socialParams.put(key, cleanedValue);
                    System.debug('<<SOCIAL PARAM:' + key + '  '+ (String)data.get(key));
                }
                socialData.put('data', socialParams);
            }
        }
        return socialData;
    }

    /*
    *** DESCRIPTION Create Social Media Identifier
    *** RETURN
    */
    public static void setSocialMediaIdentifier(Account client, Map<String,String> socialParams, String userId){
        Map<String,Object> authDataMap = EncryptUtils.getDecryptedMetadata(socialParams.get('authData'));
        if(authDataMap == null){
            return;
        }
        // INSERT SOCIAL MEDIA IDENTIFIER
        Social_Media_Identifier__c smi = new Social_Media_Identifier__c();
        smi.Client__c = client.Id;
        smi.Social_Id__c = authDataMap.get('social_id').toString();
        smi.Social_Media_Type__c = getSocialMediaTypeByAuthProvider(authDataMap.get('social_media_type').toString());
        smi.Nickname__c = socialParams.get('nickname');
        smi.Opt_In__c = socialParams.get('channel_opted_in') != null ? Boolean.valueOf(socialParams.get('channel_opted_in')) : true;
        if(socialParams.containsKey('picture')){
            smi.Avatar__c = socialParams.get('picture');
        }
        if(socialParams.containsKey('connected_at')){
            smi.Follow_Up_Date__c = Date.valueOf(socialParams.get('connected_at'));
        }

        insert smi;

        new Logs( new Map<String,Object> {
            'level' => 'INFO',
            'apexClass' => 'TWIST_Registration',
            'category' => 'EVENT',
            'message' => Label.IDENTITY_Social_Login_Self_Registration,
            'application' => 'SSO',
            'recordId' => userId,
            'details' => authDataMap.get('social_media_type')
        });
    }

    public static String getSocialMediaTypeByAuthProvider(String authProvider) {
        try {
            return [
                SELECT id, Page_Key__c, Social_Media_Type__c
                FROM TWIST_Social_Media__mdt
                WHERE Auth_Provider_Name__c = :authProvider
            ].Social_Media_Type__c;
        }
        catch (Exception e) {
            return null;
        }
    }

    public class CustomException extends Exception {}

}