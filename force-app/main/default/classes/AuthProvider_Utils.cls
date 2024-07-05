public with sharing class AuthProvider_Utils {
   
    public static Map<String,Object> mapping;
    public static Map<String,Object> result;

    /*
    *** DESCRIPTION Get a token value according attribute name
    *** RETURN      Value
    */
    public static String getTokenValue(String body, String tokenKey) {
        try{
            Map<String,Object> fields = (Map<String,Object>)JSON.deserializeUntyped(body);   
            return (String)fields.get(tokenKey);
        }
        catch(exception e) {
            return null;
        }
    }

    /*
    *** DESCRIPTION Convert JSON social media user data (body and JWT) to Auth.UserData 
    *** RETURN      Auth.UserData
    */
    public static Auth.UserData getUserData(String provider, String body, String jwtToken){

        // GET MAPPING FIELDS
        mapping = getMapping(provider);

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
        if(!String.isEmpty(jwtToken)){
            getFields(jwtToken);
        }
        
        return toAuthUserData(provider, result);
    }

    /*
    *** DESCRIPTION Get Mapping between social media fields and salesforce Auth.UserData fields
                    Based on IDENTITY_AuthProvider_Mapping__mdt references
    *** RETURN      
    */
    public static void getFields(String jsonString){

        Map<String,Object> fields = (Map<String,Object>)JSON.deserializeUntyped(jsonString);
            
        for(String field : fields.keySet()){                

            if(mapping.get(field) != null){
                IDENTITY_AuthProvider_Mapping__mdt salesforceField = (IDENTITY_AuthProvider_Mapping__mdt)mapping.get(field);

                if(salesforceField != null){
                    // If the field is Standard, add it to Auth.UserData field that corresponds
                    if(salesforceField.Is_Standard__c){
                        result.put(salesforceField.Field__c, fields.get(field));
                    }
                    // Else add it to the other map attributes of the Auth.UserData
                    else{
                        ((Map<String,Object>)result.get('others')).put(salesforceField.Field__c, fields.get(field));
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
        
        List<IDENTITY_AuthProvider_Mapping__mdt> mappingList = [
            SELECT Field__c, Value__c, Is_Standard__c, Type__c
            FROM IDENTITY_AuthProvider_Mapping__mdt 
            WHERE AuthProvider__c =: provider
        ];
        
        for(IDENTITY_AuthProvider_Mapping__mdt mdt : mappingList){
            mapping.put(mdt.Value__c, mdt);
        }

        return mapping;
    }

    public static Auth.UserData toAuthUserData(String provider, Map<String,Object> fields){
        return new Auth.UserData(
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
    }
}