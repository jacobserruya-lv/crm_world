public without sharing class ATG_API {

    public static Integer COUNTER_ATG_CALL;
    public final static Integer MAX_ATG_CALL;
    public static List<Logs> logs; 
    private static Integer timeoutMilliseconds = 25000;

	/*
    *** DESCRIPTION Create account in ATG. Mapping in Identity_Utils class
    *** RETURN     
    */
	public static void createMyLVClient(Account acc, String lang_country, String userId){
        String addressIp;
        try{
            Map<String,Object> parameters;
            if(!Test.isRunningTest()){
             	parameters = getSessionId(lang_country);
            }
            else{
                parameters = new Map<String,Object>{ SESSION_CONFIRMATION_PARAM_VALUE => '123654', SESSION_PARAM => '865132' };
            } 

            String end_point = getEndPoint(SETTINGS.get(CREATE_ACCOUNT), parameters, lang_country);

            // Get some fields from user instead of from account
            // Note: If the ATG API is called before the SF creation, the userId = false
            if(userId != 'false'){
                User user = [SELECT Id, TECH_Email__c FROM User WHERE Id =: userId];
                acc.PersonEmail = user.TECH_Email__c;
            }
            Map<String,Object> body = Identity_Utils.toATGParameters(acc);
            body.put(COUNTRY_PARAM, lang_country);

            // Encode USER ID in RSA algorithm for security point
            if(!String.isEmpty(userId)){
                String encoded_id = getRSAEncryptedId(userId);
                body.put(ENCRYPTED_ID_PARAM, encoded_id);
                body.put(USER_ID_PARAM, userId);
            }

            HTTP_Utils response = new HTTP_Utils()
                .post(end_point)
                .header('Authorization', 'Basic ' + getBasicAuthentication(lang_country))
                .header('Content-Type', 'application/json;charset=UTF-8')
                .body(JSON.serialize(body))
                .timeout(timeoutMilliseconds)
                .call();
        
            System.debug('REQUEST BODY: ' + JSON.serialize(body));
            
            Map<String,Object> resp = (Map<String,Object>)JSON.deserializeUntyped(response.responseBody());
            if(response.statusCode() != 200 || (resp.get('status') != null && resp.get('status') != 'success')){
                
                String message =  getErrorCode(response.responseBody(), resp.get('errorList'));

                logs.add(new Logs(new Map<String,Object> {
                    'level' => 'ERROR', 
                    'apexClass' => 'ATG_API', 
                    'category' => 'CALLOUT',
                    'isFuture' => true,
                    'http' => response,
                    'message' => message
                }));

                throw new CustomException('ATG creationAccount failed.');
            }
        }
        catch(Exception ex){
            // ADD EXCEPTION TO LOG
            if(!ex.getTypeName().contains('CustomException')){
                logs.add(new Logs(new Map<String,Object> {
                    'level' => 'ERROR', 
                    'apexClass' => 'ATG_API', 
                    'category' => 'CALLOUT',
                    'isFuture' => true,
                    'exception_case' => ex
                }));
            }

            // RETRY 3 TIMES
            if(COUNTER_ATG_CALL < MAX_ATG_CALL){
                COUNTER_ATG_CALL++;
                createMyLVClient(acc, lang_country, userId);
            }
            else{
                for(Logs log : logs) {
                    log.insertLog();
                }
                throw new CustomException(ex.getMessage());
            }
        }
	}

    /*
    *** DESCRIPTION GET Error Code
    *** RETURN      Message
    */
    public static String getErrorCode(String body, Object errorList){
        String message = body;
        
        if(errorList != null){
            List<Map<String, Object>> errors = new List<Map<String, Object>>();
            List<Object> errorsObjects = (List<Object>) errorList;
            for (Object obj : errorsObjects) {
                errors.add((Map<String, Object>)obj);
            }

            message = (String)errors[0].get('errorCode');
        }

        return message;
    }

    /*
    *** DESCRIPTION Encrypt the account Id with RSA algorithm
    *** RETURN      Encrypted account Id
    */
    public static String getRSAEncryptedId(String id){
        String algorithmName = 'RSA';
        String key = SETTINGS.get(RSA);
        Blob privateKey = EncodingUtil.base64Decode(key);

        Blob input = Blob.valueOf(id);
        Blob output = Crypto.sign(algorithmName, input, privateKey);

        return EncodingUtil.base64Encode(output);
    }

    /*
    *** DESCRIPTION Encrypt the account Id with RSA algorithm
    *** RETURN      Encrypted account Id
    */
    public static String getBasicAuthentication(String lang_country){
        if(lang_country.contains('cn') && SETTINGS.get(PASSWORD_CHINA) != null){
            String payload = SETTINGS.get(USERNAME) + ':' + SETTINGS.get(PASSWORD_CHINA);
            return EncodingUtil.base64Encode(Blob.valueOf(payload));
        }

        String payload = SETTINGS.get(USERNAME) + ':' + SETTINGS.get(PASSWORD);
        return EncodingUtil.base64Encode(Blob.valueOf(payload));
    }

    /*
    *** DESCRIPTION GET Session number and its confirmation, need to call other API
    *** RETURN      Map of session parameters
    */
    public static Map<String,Object> getSessionId(String lang_country){
        String end_point = getDomain(lang_country) + SETTINGS.get(GET_SESSION);

        HTTP_Utils response = new HTTP_Utils()
            .get(end_point)
            .header('Authorization', 'Basic ' + getBasicAuthentication(lang_country))
            .call();

        if(response.statusCode() == 200){
            return (Map<String,Object>)JSON.deserializeUntyped(response.responseBody());
        }
        
        throw new CustomException('Get ATG Session Id failed.');
    }

    /*
    *** DESCRIPTION GET Endpoint: URL + session parameters
    *** RETURN      String endpoint 
    */
    public static String getEndPoint(String path, Map<String,Object> parameters, String lang_country){
        String end_point = getDomain(lang_country) + path;

        end_point += (';' + SESSION_PARAM + '=' + parameters.get(SESSION_PARAM));
        end_point += ('?' + SESSION_CONFIRMATION_PARAM + '=' + parameters.get(SESSION_CONFIRMATION_PARAM_VALUE));
        end_point += ('&' + COUNTRY_PARAM + '=' + lang_country);

        return end_point;
    }

    /*
    *** DESCRIPTION GET Endpoint: URL + session parameters
    *** RETURN      String endpoint 
    */
    public static String getDomain(String lang_country){
        return (lang_country.contains('cn') ? SETTINGS.get(ENDPOINT_CHINA) : SETTINGS.get(ENDPOINT));
    }

    public class CustomException extends Exception {}

	public static Map<String,String> SETTINGS;
    public final static String ENDPOINT;
    public final static String ENDPOINT_CHINA;
    public final static String USERNAME;
    public final static String PASSWORD;
    public final static String PASSWORD_CHINA;
    public final static String RSA;
    public final static String CREATE_ACCOUNT;
    public final static String GET_SESSION;

    public final static String COUNTRY_PARAM;
    public final static String SESSION_PARAM;
    public final static String SESSION_CONFIRMATION_PARAM;
    public final static String SESSION_CONFIRMATION_PARAM_VALUE;
    public final static String ENCRYPTED_ID_PARAM;
    public final static String USER_ID_PARAM;

	static {
        SETTINGS = ThirdParty_Utils.getSettings('ATG');

        COUNTRY_PARAM = 'countryLang';
        SESSION_PARAM = 'jsessionid';
        SESSION_CONFIRMATION_PARAM_VALUE = 'sessionConfirmationNumber';
        SESSION_CONFIRMATION_PARAM = '_dynSessConf';
        ENCRYPTED_ID_PARAM = 'sfSuffix';
        USER_ID_PARAM = 'UserIdSF';
        
        ENDPOINT = 'endpoint';
        ENDPOINT_CHINA = 'endpoint_china';
        USERNAME = 'username';
        PASSWORD = 'password';
        PASSWORD_CHINA = 'password_china';
        RSA = 'RSA';
        CREATE_ACCOUNT = 'createConfirmation';
        GET_SESSION = 'getSessionConfirmationNumber';

        COUNTER_ATG_CALL = 1;
        MAX_ATG_CALL = 3;
        logs = new List<Logs>();
	}
}