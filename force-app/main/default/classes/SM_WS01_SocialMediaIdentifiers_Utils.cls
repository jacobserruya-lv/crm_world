public without sharing class SM_WS01_SocialMediaIdentifiers_Utils {

    static List<String> fieldsIdentifier = new List<String> {'Social_Media_Type__c', 'Social_Id__c', 'Opt_In__c', 'Nickname__c'};
    static List<String> fieldsClient = new List<String> {'Id', 'DREAMID__c'};

    class CustomException extends Exception {}  

    /*
    *** DESCRIPTION Get query type and throw error in exception case
                    Possible type value: social-media-identifier or client
    *** EXCEPTION   1. Missing Data 
                    2. Invalid query type 
    *** RETURN      String - query type
    */
    public static String getQueryType(Map<String,String> params) {
        // NO DATA
            if(params.isEmpty()) {
                throw new CustomException(Label.SM_Missing_Data);
            }

            String queryType = params.get('queryType');

            // MISSING TYPE OR INVALID TYPE
            if(String.isEmpty(queryType) || (queryType != Label.SM_Query_Type_Social_Media_Identifier && queryType != Label.SM_Query_Type_Client) ) {
                throw new CustomException(Label.SM_Required_Query_Type);
            }

            return queryType;
    }

    /*
    *** DESCRIPTION Get valid parameters, check required fields, and arrange fields if need
    *** RETURN      Map<String,String> - params
    */
    public static Map<String,String> getValidParams(String queryType, Map<String,String> params) {

        if(queryType == Label.SM_Query_Type_Social_Media_Identifier) {
            Social_Media_Identifier__c identifier = (Social_Media_Identifier__c)RestResource_Utils.parseJSON(params, Social_Media_Identifier__c.class);

            // REQUIRED FIELDS
            if(String.isEmpty(identifier.Social_id__c) || String.isEmpty(identifier.Social_media_type__c)) {
                throw new CustomException(Label.SM_Required_Fields_SM_Identifier);
            }

            // DECRYPT SOCIAL_ID AND REPLACE IT (WARN TO INSENSITIVE CASE)
            Blob blobValue = EncodingUtil.base64Decode(identifier.Social_id__c);
            for(String key : params.keySet()){
                if(params.get(key) == identifier.Social_id__c){
                    params.put(key, blobValue.toString());
                }
            }
        }
        else {
            Account client = (Account)RestResource_Utils.parseJSON(params, Account.class);

            // REQUIRED FIELDS
            if(client.Lastname == null || client.Firstname == null || 
                (client.PersonEmail == null && (client.LocalMobilePhone__pc == null || client.MobilePhoneCountryCallingCode__pc == null) && client.DREAMID__c == null)) {
                throw new CustomException(Label.SM_Required_Fields_Client);
            }
     
            // BUILD INTERNATIONAL MOBILE PHONE 
            if(client.LocalMobilePhone__pc != null && client.MobilePhoneCountryCallingCode__pc != null) {
                String personMobilePhone = System.UserManagement.formatPhoneNumber(client.MobilePhoneCountryCallingCode__pc, client.LocalMobilePhone__pc);
                personMobilePhone = personMobilePhone.deleteWhitespace();
                params.put('PersonMobilePhone', personMobilePhone);

                for(String key : params.keySet()) {
                    if(key.toLowerCase() == 'localmobilephone__pc' || key.toLowerCase() == 'mobilephonecountrycallingcode__pc') {
                        params.remove(key);
                    }
                }
            }
        }

        return params;
    }

    /*
    *** DESCRIPTION Build dynamic query based on query type and list of conditions.
                    Only AND operator is supported and field type STRING
    *** RETURN      String - query
    */
    public static String getDynamicQuery(String queryType, Map<String,String> parameters) {

        String dynamicQuery = 'SELECT ';

        // Add query fields
        if(queryType == Label.SM_Query_Type_Social_Media_Identifier) {
            for(String field : fieldsIdentifier) {
                dynamicQuery += (field + ', ');
            }
            for(String field : fieldsClient) {
                dynamicQuery += ('Client__r.' + field + ', ');
            }
        }
        else {
            for(String field : fieldsClient) {
                dynamicQuery += (field + ', ');
            }
        }

        dynamicQuery = dynamicQuery.removeEnd(', ');
        dynamicQuery += (queryType == Label.SM_Query_Type_Social_Media_Identifier ? ' FROM Social_Media_Identifier__c WHERE ' : ' FROM Account WHERE ');

        // Get fields set of sObject 
        Set<String> fields = (queryType == Label.SM_Query_Type_Social_Media_Identifier ? 
            Schema.SObjectType.Social_Media_Identifier__c.fields.getMap().keySet() 
            : 
            Schema.SObjectType.Account.fields.getMap().keySet());

        // Mapping of parameters
        for(String key : parameters.keySet()) {
            // Support only string condition
            String condition = key + ' = \'' +  parameters.get(key) + '\' AND ';
            if(fields.contains(key.toLowerCase())) {
                dynamicQuery += condition;
            }
        }

        dynamicQuery = dynamicQuery.removeEnd(' AND ');
        dynamicQuery += ' ORDER BY LastModifiedDate DESC ';

        System.debug(dynamicQuery);

        return dynamicQuery;
    }

    /*
    *** DESCRIPTION Upsert a social media identifier 
    *** RETURN      Social media identifier 
    */
    public static Social_Media_Identifier__c upsertSocialMediaIdentifier(Social_Media_Identifier__c identifier, String clientId, Boolean isEntrepriseBinding) {

        // DECRYPT SOCIAL_ID
        Blob blobValue = EncodingUtil.base64Decode(identifier.Social_id__c); 
        identifier.Social_id__c = blobValue.toString();
        
        if (identifier.Social_Enterprise_Id__c != null){
            blobValue = EncodingUtil.base64Decode(identifier.Social_Enterprise_Id__c); 
            identifier.Social_Enterprise_Id__c = blobValue.toString();
        }

        System.debug('upsertSocialMediaIdentifier - clientId : ' + clientId);
        System.debug(identifier);
        // case clientId is NOT null
        if (clientId != null && clientId != ''){
            System.debug('case clientId is NOT null');
            // CHECK IF THERE IS AN EXISTING SMI FOR THE CLIENT WE WANT TO UPDATE
            List<Social_Media_Identifier__c> existingIdentifierForClients = [
                SELECT Id
                FROM Social_Media_Identifier__c
                WHERE Client__c =: clientId AND Social_Media_Type__c =: identifier.Social_Media_Type__c
            ];
            if (!existingIdentifierForClients.isEmpty()){
                System.debug('Existing identifier for Client ' + clientId + ' : ' + existingIdentifierForClients[0].Id);
                identifier.Id = existingIdentifierForClients[0].Id;
            }
            identifier.Client__c = clientId;
        } 
        // case clientId is null
        else {
            System.debug('case clientId is null');
            String externalId = identifier.Social_Media_Type__c + '_' + identifier.Social_id__c;
            List<Social_Media_Identifier__c> identifiersByExternalId = [
                SELECT Id, Client__c
                FROM Social_Media_Identifier__c
                WHERE Social_SF_External_Id__c =: externalId
            ];
            if(!identifiersByExternalId.isEmpty()) {
                System.debug('Existing identifier for externalId : ' + externalId);
                identifier.Id = identifiersByExternalId[0].Id;
                // Need for response object
                identifier.Client__c = identifiersByExternalId[0].Client__c;
            }
        }
        upsert identifier;
        return identifier;
    }
    
    public static Boolean isSourceAuthorizedForRMSConso(String miniprogramCode, String socialMediaType){
        String correctCaseSocialMediaType = getSocialMediaTypeCorrectCase(socialMediaType);
        Social_Media_Source__mdt[] sms = [SELECT Send_to_conso__c FROM Social_Media_Source__mdt WHERE Program_Id__c = :miniprogramCode AND Type__c = :correctCaseSocialMediaType];
        return !sms.isEmpty() && sms[0].Send_to_conso__c;
    } 

    public static String getSocialMediaTypeCorrectCase(String type){
        String upperType = type.toUpperCase();
        switch on upperType {
            when 'WECHAT' {
               return 'WeChat';
            }
            when 'KAKAO' {
               return 'Kakao';
            }
            when 'LINE' {
               return 'Line';
            }
            when else {
                return type;    
            }
        }
    }

    public static ExceptionBody getQueryException(String message, String exceptionType) {
        if(message.contains('BLOB')) {
            return new ExceptionBody('504', Label.SM_Encryption_value_not_valid);
        }
        else if(message.contains('ENTITY_IS_DELETED')) {
            return new ExceptionBody('505', Label.SM_No_records);
        }
        else if(message.contains(Label.SM_Missing_Data)) {
            return new ExceptionBody('501', message);
        }
        else if(message.contains(Label.SM_Required_Query_Type)){
            return new ExceptionBody('502', message);
        }
        else if(message.contains(Label.SM_Required_Fields_SM_Identifier) || message.contains(Label.SM_Required_Fields_Client)) {
            return new ExceptionBody('503', message);
        }
        else if(message.contains(Label.SM_No_records)) {
            return new ExceptionBody('505', message);
        }

        return new ExceptionBody('506', Label.SM_Other);
    }

    public static ExceptionBody getUpsertException(String message, String exceptionType) {
        if(message.contains('ENTITY_IS_DELETED')) {
            return new ExceptionBody('505', Label.SM_No_records);
        }
        else if(message.contains('MALFORMED_ID')) {
            return new ExceptionBody('505', Label.SM_No_records);
        }
        else if(message.contains('BLOB')) {
            return new ExceptionBody('504', Label.SM_Encryption_value_not_valid);
        }
        else if(message.contains('REQUIRED_FIELD_MISSING')) {
            return new ExceptionBody('503', Label.SM_Required_Fields_SM_Identifier);
        }
        else if(message.contains(Label.SM_Missing_Data)) {
            return new ExceptionBody('501', message);
        }
        else if(message.contains(Label.SM_Required_Fields_SM_Identifier) || message.contains(Label.SM_Required_Fields_Client)) {
            return new ExceptionBody('503', message);
        }
        else if(message.contains(Label.SM_No_records)) {
            return new ExceptionBody('505', message);
        }
        else if(message.contains('NOT ENOUGH CLIENT INFORMATION')) {
            return new ExceptionBody('505', message);
        }
        return new ExceptionBody('506', Label.SM_Other);
    }

    public static Account getProspect(Account client, Social_Media_Identifier__c identifier) {
        System.debug('client : '     + client.FirstName);
        // if there is a social media identifier, we try first to match the client through it
        if (identifier != null){
            System.debug('identifier : ' + identifier.Social_id__c);
            if(identifier.Social_id__c == null){
                throw new CustomException(Label.SM_Required_Fields_SM_Identifier);
            }
            // DECRYPT SOCIAL_ID
            Blob blobValue = EncodingUtil.base64Decode(identifier.Social_id__c); 
            String socialId = blobValue.toString();
            // search for an existing SMI
            String externalId = identifier.Social_Media_Type__c + '_' + socialId;
            List<Social_Media_Identifier__c> existingSMIs = [
                SELECT Id, Client__r.Id, Client__r.DREAMID__c, Client__c
                FROM Social_Media_Identifier__c
                WHERE Social_SF_External_Id__c =: externalId
            ];            
            if (!existingSMIs.isEmpty()){
                System.debug('Existing SMI for externalId: ' + externalId);
                return new Account(Id = existingSMIs[0].Client__c);
            }
        }
        // ELSE
        String personPhone = client.MobilePhoneCountryCallingCode__pc + client.LocalMobilePhone__pc;
        // MISSING IDENTIFIER
        if(((String.isEmpty(client.MobilePhoneCountryCallingCode__pc) || String.isEmpty(client.LocalMobilePhone__pc)) && String.isEmpty(client.PersonEmail) && String.isEmpty(client.DREAMID__c)) || String.isEmpty(client.LastName) || String.isEmpty(client.FirstName)){
            system.debug('here');
            throw new CustomException('NOT ENOUGH CLIENT INFORMATION');
            // return null;
        }

        List<Account> clients;

        String condition_name = '';
        String condition_identifier = '';
        String condition_identity = '';
        
        // IDENTIFIER
        if(!String.isEmpty(client.PersonEmail) && !String.isEmpty(personPhone)){
            condition_identifier = ' AND (PersonEmail = \'' + client.PersonEmail + '\' OR (MobilePhoneCountryCallingCode__pc = \'' + client.MobilePhoneCountryCallingCode__pc + '\' AND LocalMobilePhone__pc = \'' + client.LocalMobilePhone__pc + '\'))';
        }
        else if(!String.isEmpty(client.PersonEmail)){
            condition_identifier = ' AND PersonEmail = \'' + client.PersonEmail + '\'';
        }
        else if(!String.isEmpty(client.MobilePhoneCountryCallingCode__pc) && !String.isEmpty(client.LocalMobilePhone__pc)){
            condition_identifier = ' AND MobilePhoneCountryCallingCode__pc = \'' + client.MobilePhoneCountryCallingCode__pc + '\' AND LocalMobilePhone__pc = \'' + client.LocalMobilePhone__pc + '\'';
        }
        
		//DREAMID
		else if(!String.isEmpty(client.DREAMID__c)){
            condition_identifier = ' AND DREAMID__c = \'' +client.DREAMID__c+'\'';
        }
       
        // NAME
        condition_name = ' LastName = \'' + String.escapeSingleQuotes(client.LastName) + '\' AND FirstName = \'' + String.escapeSingleQuotes(client.FirstName) + '\' ';

        String query = 'SELECT Id, PersonContactId, PersonMobilePhone, LocalMobilePhone__pc ' +
                        'FROM Account ' + 
                        'WHERE ' + condition_name + condition_identifier + condition_identity + 
                        'ORDER BY LastTrans__pc, LastModifiedDate DESC';

        System.debug('QUERY: ' + query);
        clients = Database.query(query);

        if(!clients.isEmpty()){
            return clients[0];
        }
        
        return null;
    }

      /*
    *** DESCRIPTION Create / update a new prospect account
    *** RETURN      Account
    */
    public static Account createProspect(Account client) {

        // International mobile phone number
        if( !String.isEmpty(client.MobilePhoneCountryCallingCode__pc) && !String.isEmpty(client.LocalMobilePhone__pc)){
            client.PersonMobilePhone = IDENTITY_Utils.getMobilePhone(client.MobilePhoneCountryCallingCode__pc, client.LocalMobilePhone__pc);
        }

        // International login phone number
       if(String.isEmpty(client.LoginPhone__pc) && !String.isEmpty(client.LocalLoginPhone__pc) && !String.isEmpty(client.LoginPhoneCallingCode__pc)){ // TODO bloc not coverd by unit tests
            client.LoginPhone__pc = IDENTITY_Utils.getMobilePhone(client.LoginPhoneCallingCode__pc, client.LocalLoginPhone__pc);
        }

        client.IsProspect__pc = true;
        client.ProspectForDream__c = true;

        if(String.isEmpty(client.OwnerId)){
            // Owner of portal account must have Role - fix it in the case of GUEST USER
            if(UserInfo.getUserId() == IDENTITY_Settings__c.getInstance().Guest_User_Id__c){ // TODO bloc not coverd by unit tests
                client.OwnerId = IDENTITY_Settings__c.getInstance().Integration_User_Id__c;
            }
        }        

        if(client.DREAMID__c != null){ // TODO bloc not coverd by unit tests
            Database.upsert(client, Account.Fields.DREAMID__c, false);
        }
        else {
            Database.upsert(client);
        }
        
        return client;
    }


    public class ResponseBody {
        List<Map<String,Object>> social_media_identifiers {get;set;}
        Map<String,Object> client {get;set;}

        public ResponseBody() {}

        public ResponseBody(Social_Media_Identifier__c identifier) {
            // ENCRYPT SOCIAL_ID
            Blob blobValue = Blob.valueOf(identifier.Social_id__c);
            identifier.Social_id__c = EncodingUtil.base64Encode(blobValue); 

            this.social_media_identifiers = new List<Map<String,Object>> { RestResource_Utils.prettyJSON(identifier, SM_WS01_SocialMediaIdentifiers_Utils.fieldsIdentifier) };
            this.client = RestResource_Utils.prettyJSON(identifier.Client__r, SM_WS01_SocialMediaIdentifiers_Utils.fieldsClient);
        }

        public ResponseBody(List<Social_Media_Identifier__c> identifiers) {
            // ENCRYPT ALL SOCIAL_IDs
            for(Social_Media_Identifier__c identifier: identifiers){
                Blob blobValue = Blob.valueOf(identifier.Social_id__c);
                identifier.Social_id__c = EncodingUtil.base64Encode(blobValue); 
            }

            this.social_media_identifiers = RestResource_Utils.prettyJSON(identifiers, SM_WS01_SocialMediaIdentifiers_Utils.fieldsIdentifier);
            this.client = RestResource_Utils.prettyJSON(identifiers[0].Client__r, SM_WS01_SocialMediaIdentifiers_Utils.fieldsClient);
        }

        public ResponseBody(Account client, List<Social_Media_Identifier__c> identifiers) {
            // ENCRYPT ALL SOCIAL_IDs
            for(Social_Media_Identifier__c identifier: identifiers){
                Blob blobValue = Blob.valueOf(identifier.Social_id__c);
                identifier.Social_id__c = EncodingUtil.base64Encode(blobValue); 
            }

            this.social_media_identifiers = RestResource_Utils.prettyJSON(identifiers, SM_WS01_SocialMediaIdentifiers_Utils.fieldsIdentifier);
            this.client = RestResource_Utils.prettyJSON(client, SM_WS01_SocialMediaIdentifiers_Utils.fieldsClient);
        }

        public ResponseBody(Account client) {
            this.client = RestResource_Utils.prettyJSON(client, SM_WS01_SocialMediaIdentifiers_Utils.fieldsClient);
        }
    }

    public class ExceptionBody {
        public String code {get;set;}
        public String errorMessage {get;set;}

        public ExceptionBody() {}

        public ExceptionBody(String code, String message) {
            this.code = code;
            this.errorMessage = message;
        }
    }
}