/**
    About
    -----
    Description: Registration Handler for Auth Providewr (Social Login)
    Created for: Twist project
    Create date: JAN 2024

    Details
    -------
    Create or Upate a user according social data in social login flow
*/
global without sharing class TWIST_RegistrationHandler implements Auth.RegistrationHandler{

    class CustomException extends Exception {}

    global User createUser(String portalId, Auth.UserData data){
        User uIdentity;
        String dataJson = JSON.serialize(data);

        System.debug('REGISTRATION HANDLER: CREATE USER');
        System.debug('User Data: ' + dataJson);


        // RULE 1: SOCIAL ID
        if(!String.isEmpty(data.identifier)){
            uIdentity = getUserBySocialId(data.identifier);
            if(uIdentity != null){
                if(data.provider.toUpperCase() == 'KAKAO') {
                    updateAccountFromKakao(uIdentity.Id, dataJson);
                    updateSocialIdFromKakao(uIdentity.Id, dataJson);
                }
                setLog(uIdentity.Id, data.provider, Label.IDENTITY_Social_Login_Social_Id_Matching);
                TWIST_Utils.activateUser(uIdentity.Id);
                return uIdentity;
            }
        }

        // RULE 2: EMAIL
        if(!String.isEmpty(data.email)){
            uIdentity = getUserByEmail(data.email);
            if(uIdentity != null){
                if(data.provider.toUpperCase() == 'KAKAO') {
                    updateAccountFromKakao(uIdentity.Id, dataJson);
                }
                setSocialMediaIdentifier(dataJson, JSON.serialize(uIdentity));
                setLog(uIdentity.Id, data.provider, Label.IDENTITY_Social_Login_Email_Matching);
                TWIST_Utils.activateUser(uIdentity.Id);
                return uIdentity;
            }
        }

        // RULE 3: MOBILE PHONE
        if(!String.isEmpty(data.attributeMap.get('login_international_mobile_phone'))){
            uIdentity = getUserByMobilePhone(data.attributeMap.get('login_international_mobile_phone'));
            if(uIdentity != null){
                if(data.provider.toUpperCase() == 'KAKAO') {
                    updateAccountFromKakao(uIdentity.Id, dataJson);
                }
                setSocialMediaIdentifier(dataJson, JSON.serialize(uIdentity));
                setLog(uIdentity.Id, data.provider, Label.IDENTITY_Social_Login_Mobile_Matching);
                TWIST_Utils.activateUser(uIdentity.Id);
                return uIdentity;
            }
        }

        // RULE 4: AUTOMATIC SOCIAL REGISTRATION VIA KAKAO
        /*if(data.provider.toUpperCase() == 'KAKAO') {
            uIdentity = createUserFromKakao(data);
            setSocialMediaIdentifier(dataJson, JSON.serialize(uIdentity));
            setLog(uIdentity.Id, data.provider,'AFTER CREATION ');
            return uIdentity;
        }*/

        // RULE 5: NEED SOCIAL REGISTRATION
        throw new CustomException(setPayload(data));
    }

    global void updateUser(Id userId, Id portalId, Auth.UserData data){
        System.debug('REGISTRATION HANDLER: UPDATE USER from Twist');
        System.debug('User Id: ' + userId);
        System.debug('data: ' + json.serializePretty(data));
        String dataJson = JSON.serialize(data);

        if(data.provider.toUpperCase() == 'KAKAO') {
            updateAccountFromKakao(userId, dataJson);
            updateSocialIdFromKakao(userId, dataJson);
        }
        setLog(userId, data.provider, Label.IDENTITY_Social_Login_Already_Logged);
            TWIST_Utils.activateUser(userId);
    }

    /****************  HELP METHODS  ****************/

    /*
    *** DESCRIPTION Get user according social id
    *** RETURN      User
    */
    global User getUserBySocialId(String socialId){
        // GET SMI
        List<Id> contacts = new List<Id>();
        for (Social_Media_Identifier__c SMIresult : [SELECT Id, Client__r.PersonContactId FROM Social_Media_Identifier__c WHERE Social_Id__c =: socialId] ){
            contacts.add(SMIresult.Client__r.PersonContactId);
        }

        // GET USER
        User[] users = [SELECT Id FROM User WHERE ContactId IN : contacts AND (IsActive = true OR IsActive = false) AND Is_Identity_User__c = true LIMIT 1];
        if(!users.IsEmpty()){
            return users[0];
        }

        return null;
    }

    /*
    *** DESCRIPTION Get user according email
    *** RETURN      User
    */
    global User getUserByEmail(String email){
        User[] users = [SELECT Id, AccountId FROM User WHERE TECH_Email__c =: email AND (IsActive = true OR IsActive = false) AND Is_Identity_User__c = true LIMIT 1];
        if(!users.IsEmpty()){
            return users[0];
        }

        return null;
    }

    /*
    *** DESCRIPTION Get user according mobile phone
    *** RETURN      User
    */
    global User getUserByMobilePhone(String mobile){
        User[] users = [SELECT Id, AccountId FROM User WHERE TECH_MobilePhone__c =: mobile AND (IsActive = true OR IsActive = false) AND Is_Identity_User__c = true LIMIT 1];
        if(!users.IsEmpty()){
            return users[0];
        }

        return null;
    }

    /*
    *** DESCRIPTION Set payload
    *** RETURN      Base64 Encoded payload
    */
    global String setPayload(Auth.UserData data){
        TWIST_Settings__c settings = TWIST_Settings__c.getInstance();
        String payload = '{'
                +  (!String.isEmpty(data.email) ? ('"passKey": "' + EncryptUtils.getEncryptedMetadata(new Map<String,Object>{'email'=>data.email, 'rand'=>stringUtils.generateRandomString(10,settings.Email_Token_Chars__c)}) + '",') : '')
                +  '"data": {'
                +  '"authData": "' + EncryptUtils.getEncryptedMetadata(new Map<String,Object>{'social_id'=>data.identifier, 'social_media_type'=>data.provider, 'rand'=>stringUtils.generateRandomString(10,settings.Email_Token_Chars__c)}) + '",'
                +  (!String.isEmpty(data.email) ? ('"email": "' + data.email + '",') : '')
                +  (!String.isEmpty(data.firstname) ? ('"firstname": "' + data.firstname + '",') : '')
                +  (!String.isEmpty(data.lastname) ? ('"lastname": "' + data.lastname + '",') : '')
                +  (!String.isEmpty(data.username) ? ('"nickname": "' + data.username + '",') : '');
                //+  '"others": "' + data.attributeMap + '",'

        if(!data.attributeMap.IsEmpty()){
               for(String key : data.attributeMap.keySet()){
                   if(data.attributeMap.get(key) != null){
                		payload = payload  + '"' + key + '": "' + (String)data.attributeMap.get(key) + '",';
                   }
            }
        }
        payload = payload  + '}';
        payload = payload  + '}';
        payload = payload.replace(',}', '}');

        System.debug('PAYLOAD: ' + payload);

        String payload_encoded = EncodingUtil.base64Encode(Blob.valueOf(payload));

        return payload_encoded;
    }

    /*
    *** DESCRIPTION Create SMI
    *** RETURN
    */
    @future
    global static void setSocialMediaIdentifier(String dataJSON, String uIdentityJSON){

        Auth.UserData data = (Auth.UserData)JSON.deserialize(dataJSON, Auth.UserData.Class);
        User uIdentity = (User)JSON.deserialize(uIdentityJSON, User.Class);

        String accountId = uIdentity.AccountId;
        if(accountId == null){
            List<User> users = new List<User>();
            users = [SELECT AccountId FROM User WHERE Id =: uIdentity.Id LIMIT 1];
            if(!users.isEmpty()){
                User user = users[0];
                accountId = user.AccountId;
            }
        }

        Social_Media_Identifier__c smi = new Social_Media_Identifier__c(
            Client__c = accountId,
            Social_Id__c = data.identifier,
            Social_Media_Type__c = TWIST_RegistrationUtils.getSocialMediaTypeByAuthProvider(data.provider),
            Nickname__c = data.username,
            Opt_In__c = true
        );


        if(data.provider.toUpperCase() == 'KAKAO') {
            checkSmiUpdates(smi, data.attributeMap);
        }

        insert smi;
    }

    @future
    global static void setLog(String userId, String provider, String message){
        new Logs( new Map<String,Object> {
            'level' => 'INFO',
            'apexClass' => 'IDENTITY_RegistrationHandler', // TODO change class prefix for Twist
            'category' => 'EVENT',
            'message' => message,
            'application' => 'SSO',
            'recordId' => userId,
            'details' => provider
        });
    }

    /**
     * Kakao Methods
     */

/*global static User createUserFromKakao(Auth.UserData data) {
        Map<String, String> attributeMap = data.attributeMap;
        String fullPhone = attributeMap.get('phone_number');

        Map<String, String> genderToSalutation = new Map<String, String> {
            'Male' => '02',
            'Female' => '04',
            'Other' => '02'
        };
        Account acc = new Account();
        if(fullPhone != null){
            String localPhone = fullPhone.substring(3);
            String countryCode = fullPhone.replace('+', '').substring(0, 2);
            acc.LocalLoginPhone__pc = localPhone;
            acc.LocalMobilePhone__pc = localPhone;
            acc.LoginPhone__pc = fullPhone;
            acc.LoginPhoneCallingCode__pc = countryCode;
            acc.MobilePhoneCountryCallingCode__pc = countryCode;
            acc.PersonMobilePhone = fullPhone;
        }

        acc.FirstName = data.firstname;
        acc.LastName = data.lastname;
        acc.PersonEmail = data.email;
        acc.Gender__pc = attributeMap.get('gender');
        acc.Salutation = genderToSalutation.get(acc.Gender__pc);
        acc.BirthdateDay__pc = attributeMap.get('birthdate_day');
        acc.BirthdateMonth__pc = attributeMap.get('birthdate_month');
        acc.BirthdateYear__pc = attributeMap.get('birthdate_year');
        acc.PrimaryAddressLine1__pc = attributeMap.get('base_address');
        acc.PrimaryAddressLine2__pc = attributeMap.get('detail_address');
        // acc.Source__c = 'Kakao';
        return IDENTITY_Utils.createMylvClient(acc, null,false);
    }*/

    @future

    global static void updateAccountFromKakao(Id userId, String dataJson) {
        Auth.UserData data = (Auth.UserData)JSON.deserialize(dataJSON, Auth.UserData.Class);

        Account[] accounts = [
            SELECT Id,LocalMobilePhone__pc,PersonMobilePhone,MobilePhoneCountryCallingCode__pc,MobilePhoneCountryCode__pc, Gender__pc, Salutation, PersonEmail,
            PrimaryAddressLine1__pc, PrimaryAddressLine2__pc, PrimaryZipCode__pc, BirthdateDay__pc, BirthdateMonth__pc, BirthdateYear__pc,
            Can_Be_Contacted_By_Email__pc
            FROM Account
            WHERE Id IN (
                SELECT AccountId FROM User WHERE Id = :userId
            )
        ];

        if(accounts.isEmpty()) {
            return;
        }

        Account acc = accounts.get(0);
        Boolean updateAccount = false;

        // EMAIL
        if(
            String.isBlank(acc.PersonEmail) &&
            data.attributeMap.get('email_verified') != null &&
            Boolean.valueOf(data.attributeMap.get('email_verified'))
        ) {
            acc.PersonEmail = data.email;
            updateAccount = true;
        }

        // PHONE NUMBER
        if(
            String.isBlank(acc.LocalMobilePhone__pc) &&
            String.isBlank(acc.PersonMobilePhone) &&
            data.attributeMap.get('phone_number') != null &&
            data.attributeMap.get('phone_number_verified') != null &&
            Boolean.valueOf(data.attributeMap.get('phone_number_verified'))
        ) {
            Map<String, String> phoneMap = TWIST_Utils.getSplittedPhoneFromFullPhone(data.attributeMap.get('phone_number'));
            if(!phoneMap.isEmpty()){
                acc.LocalMobilePhone__pc = phoneMap.get('mobilePhone'); //01050394146
                acc.MobilePhoneCountryCode__pc = phoneMap.get('iso2Code');//KR
                acc.MobilePhoneCountryCallingCode__pc =  phoneMap.get('callingCode');//82
                acc.PersonMobilePhone = phoneMap.get('internationalMobilePhone');//+821050394146
            }
            updateAccount = true;
        }

        // SHIPPING ADDRESS
        if(
            String.isBlank(acc.PrimaryAddressLine1__pc) &&
            data.attributeMap.get('base_address') != null
        ) {
            acc.PrimaryAddressLine1__pc = data.attributeMap.get('base_address');
            acc.PrimaryAddressLine2__pc = data.attributeMap.get('detail_address');
            acc.PrimaryZipCode__pc = data.attributeMap.get('zone_number');
            updateAccount = true;
        }

         // BIRTH DAY
        if(
            String.isBlank(acc.BirthdateDay__pc) &&
            String.isBlank(acc.BirthdateMonth__pc) &&
            data.attributeMap.get('birthdate_day') != null &&
            data.attributeMap.get('birthdate_month') != null
        ) {
            acc.BirthdateDay__pc = data.attributeMap.get('birthdate_day');
            acc.BirthdateMonth__pc = data.attributeMap.get('birthdate_month');
            updateAccount = true;
        }

        // BIRTH YEAR
        if (
            String.isBlank(acc.BirthdateYear__pc) &&
            data.attributeMap.get('birthdate_year') != null
        ) {
            acc.BirthdateYear__pc = data.attributeMap.get('birthdate_year');
            updateAccount = true;
        }

        // GENDER
        if (
            String.isBlank(acc.Gender__pc) && String.isBlank(acc.Salutation) &&
            data.attributeMap.get('gender') != null
        ) {
            acc.Gender__pc = data.attributeMap.get('gender');
            acc.Salutation = TWIST_Utils.genderToSalutation(acc.Gender__pc);
            updateAccount = true;
        }

		//NEWSLETTER
        if (
            acc.Can_Be_Contacted_By_Email__pc != true &&
            data.attributeMap.get('newsletter_terms') != null
        ) {
            acc.Can_Be_Contacted_By_Email__pc = Boolean.valueOf(data.attributeMap.get('newsletter_terms'));
            updateAccount = true;
        }


        if(updateAccount) {
            update acc;
        }
    }

    @future
    global static void updateSocialIdFromKakao(Id userId, String dataJson) {
        Auth.UserData data = (Auth.UserData)JSON.deserialize(dataJSON, Auth.UserData.Class);

        Social_Media_Identifier__c[] identifiers = [
            SELECT Id, Nickname__c, Opt_In__c, Avatar__c, Follow_Up_Date__c
            FROM Social_Media_Identifier__c
            WHERE Client__c IN (
                SELECT AccountId FROM User WHERE Id=:userId
            )
            AND Social_Id__c = :data.identifier
            AND Social_Media_Type__c = :data.provider
        ];

        if(identifiers.isEmpty()) {
            return;
        }

        Social_Media_Identifier__c smi = identifiers.get(0);
        Map<String, String> dataAttributes = data.attributeMap;
        Boolean updateSmi = checkSmiUpdates(smi, dataAttributes);

        // NICKNAME/USERNAME
        if(String.isNotBlank(data.username) && data.username != smi.Nickname__c) {
            smi.Nickname__c = data.username;
            updateSmi = true;
        }

        if(updateSmi) {
            update smi;
        }

    }

    private static Boolean checkSmiUpdates(Social_Media_Identifier__c smi, Map<String, String> dataAttributes) {
        Boolean updateSmi = false;
        String pictureUrl = dataAttributes.get('picture');
        String optIn = dataAttributes.get('channel_opted_in');
        String connectedAt = dataAttributes.get('connected_at');

        // PICTURE URL
        if(String.isNotBlank(pictureUrl) && pictureUrl != smi.Avatar__c) {
            smi.Avatar__c = pictureUrl;
            updateSmi = true;
        }

        // CHANNEL SUBSCRIPTION STATUS
        if(String.isNotBlank(optIn) && Boolean.valueOf(optIn) != smi.Opt_In__c) {
            smi.Opt_In__c = Boolean.valueOf(optIn);
            updateSmi = true;
        }

        // CHANNEL SUBSCRIPTION DATE
        if(String.isNotBlank(connectedAt) && Date.valueOf(connectedAt) != smi.Follow_Up_Date__c) {
            smi.Follow_Up_Date__c = Date.valueOf(connectedAt);
            updateSmi = true;
        }

        return updateSmi;
    }
}