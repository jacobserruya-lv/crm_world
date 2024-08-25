public without sharing class IDENTITY_AuthProvider {

    public static Map<String,Object> mapping;
    public static Map<String,Object> result;

    /*
    *** DESCRIPTION Get a token value according attribute name
    *** RETURN      Value
    */
    public static String getTokenValue(String body, String token) {
        Map<String,Object> fields = (Map<String,Object>)JSON.deserializeUntyped(body);
        return (String)fields.get(token);
    }

    /*
    *** DESCRIPTION Convert JSON social media user data (body and JWT) to Auth.UserData 
    *** RETURN      Auth.UserData
    */
    public static Auth.UserData getUserData(String provider, String body, String jwt_token){
        System.debug('>>> getUserData() method');

        // GET MAPPING FIELDS
        mapping = getMapping(provider);
        System.debug('> provider: ' + provider);
        System.debug('> body: ' + body);
        System.debug('> jwt_token: ' + jwt_token);
        System.debug('> mapping: ' + JSON.serialize(mapping));

        // SETUP RESULT
        result = new Map<String,Object>();
        result.put('others', new Map<String,String>());

        // GET AUTH PROVIDER FIELDS FROM BODY
        if(!String.isEmpty(body)){
            if(provider == 'Kakao'){
                Map<String,Object> fields = (Map<String,Object>)JSON.deserializeUntyped(body);

                if(fields.get('properties') != null) {
                    Map<String,Object> properties = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(fields.get('properties')));
                    fields.putAll(properties);
                    fields.remove('properties');
                }
                if(fields.get('kakao_account') != null) {
                    Map<String,Object> kakao_account = (Map<String,Object>)JSON.deserializeUntyped(JSON.serialize(fields.get('kakao_account')));
                    fields.putAll(kakao_account);
                    fields.remove('kakao_account');
                }

                getFields(JSON.serialize(fields));
            }
            else {
                getFields(body);
            }
        }

        // GET AUTH PROVIDER FIELDS FROM JWT TOKEN
        if(!String.isEmpty(jwt_token)){
            getFields(jwt_token);
        }
        
        return toAuthUserData(provider, result);
    }

    /*
    *** DESCRIPTION Get Mapping between social media fields and salesforce Auth.UserData fields
                    Based on IDENTITY_AuthProvider_Mapping__mdt references
    *** RETURN
    */
    public static void getFields(String json_string){
        System.debug('>>> getFields() method');
        Map<String,Object> fields = (Map<String,Object>)JSON.deserializeUntyped(json_string);
            
        for(String field : fields.keySet()){
            System.debug('getFields() - field: ' + field);
            if(mapping.get(field) != null){
                IDENTITY_AuthProvider_Mapping__mdt salesforce_field = (IDENTITY_AuthProvider_Mapping__mdt)mapping.get(field);
                
                if(salesforce_field != null){
                    // If the field is Standard, add it to Auth.UserData field that corresponds
                    if(salesforce_field.Is_Standard__c){
                        result.put(salesforce_field.Field__c, fields.get(field));
                        System.debug('getFields() - add to result: ' + field + ' > ' + fields.get(field));
                    }
                    // Else add it to the other map attributes of the Auth.UserData
                    else{
                        ((Map<String,Object>)result.get('others')).put(salesforce_field.Field__c, String.valueOf(fields.get(field)));
                    }
                }
            }
        }
    }

    /*
    *** DESCRIPTION Get Mapping between social media fields and salesforce Auth.UserData fields
                    Based on IDENTITY_AuthProvider_Mapping__mdt references
    *** RETURN
    */
    public static Map<String,Object> getMapping(String provider){
        Map<String,Object> mapping = new Map<String,Object>();
        
        List<IDENTITY_AuthProvider_Mapping__mdt> mapping_list = [
            SELECT Field__c, Value__c, Is_Standard__c, Type__c
            FROM IDENTITY_AuthProvider_Mapping__mdt
            WHERE AuthProvider__c =: provider
        ];
        
        for(IDENTITY_AuthProvider_Mapping__mdt mdt : mapping_list){
            mapping.put(mdt.Value__c, mdt);
        }

        return mapping;
    }

    public static Auth.UserData toAuthUserData(String provider, Map<String,Object> fields){
        Auth.UserData userData = new Auth.UserData(
            String.valueOf(fields.get('id')),
            String.valueOf(fields.get('firstName')),
            String.valueOf(fields.get('lastName')),
            String.valueOf(fields.get('fullName')),
            String.valueOf(fields.get('email')),
            String.valueOf(fields.get('link')),
            String.valueOf(fields.get('userName')),
            String.valueOf(fields.get('locale')),
            provider,
            String.valueOf(fields.get('siteLoginUrl')),
            (Map<String,String>)fields.get('others')
        );
        System.debug('toAuthUserData() result: ' + JSON.serializePretty(userData));
        return userData;
    }

    public static Account toAccount(Auth.UserData data){

        Account new_account = new Account();
        new_account.PersonEmail = data.email;
        new_account.LastName = data.firstname;
        new_account.FirstName = data.lastname;
        new_account.PrimaryCountry__pc = data.locale;
        new_account.PersonMobilePhone = data.attributeMap.get('login_international_mobile_phone');

        return new_account;
    }
}