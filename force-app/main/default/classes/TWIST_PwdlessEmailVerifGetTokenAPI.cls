@RestResource(urlMapping='/PwdlessEmailVerification/GetAccessToken')
global with sharing class TWIST_PwdlessEmailVerifGetTokenAPI {
    
   	public final static String PWDLESS_EMAIL_VERIFICATION = 'PasswordlessEmailVerification';
    public final static String EMAIL = 'email';
    
    public final static String IDENTIFIER_ISSUED = 'IDENTIFIER_ISSUED';
    public final static String IDENTIFIER_USED = 'IDENTIFIER_USED';
    
    public final static String IDENTIFIER_STATUS_UNKNOWN = 'IDENTIFIER_STATUS_UNKNOWN';
    public final static String IDENTIFIER_STATUS_EXPIRED = 'IDENTIFIER_STATUS_EXPIRED';
    public final static String IDENTIFIER_STATUS_USED = 'IDENTIFIER_STATUS_USED';
    public final static String IDENTIFIER_STATUS_VALID = 'IDENTIFIER_STATUS_VALID';
    
    public final static String LOGIN_ERROR = 'LOGIN_ERROR';
    public final static String GENERIC_ERROR = 'GENERIC_ERROR';

    @HttpPost
    global static void doPost() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        response.addHeader('Content-Type','application/json');
        Map<String,Object> responseMap = new Map<String,Object>();
        
        
        try {
            TWIST_Settings__c settings = TWIST_Settings__c.getInstance();
            
            
            if(String.isBlank(request.requestBody.toString())){
                 throw new CustomException(Label.EM_required_field_missing + ' : EMPTY BODY');
            }
            
            Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(request.requestBody.toString());

            String identifier = String.ValueOf(body.get('code'));
            if(String.isBlank(identifier)){
                throw new CustomException(Label.EM_required_field_missing + ' : code');
            }

            Headless_Identity_Flow_Instance__c pwdlessEmailVerifRequest = getPwdlessEmailVerifRequest(identifier);
            
            String identifierStatus = validateIdentifier(pwdlessEmailVerifRequest, identifier, settings);
            
            if (!isIdentifierValid(identifierStatus)) {
                throw new CustomException(identifierStatus);
            }

            String accessToken = getJWTAccessToken(pwdlessEmailVerifRequest.Username__c, settings); 

            if(!isStatusUnknownOrUsed(identifierStatus)){
                updateStatusPwdlessEmailVerifRequest(pwdlessEmailVerifRequest);
                TWIST_Utils.updateUserVerifiedEmail(pwdlessEmailVerifRequest.Username__c);
            }

            if(accessToken == null){
                throw new CustomException(LOGIN_ERROR);
            }

            response.statusCode = 200;
            responseMap = TWIST_Utils.buildSuccessResponseObject('access_token', accessToken);
            
        }
        catch (Exception e) {
            String errorMessage = e.getTypeName().contains('CustomException') ? e.getMessage() : GENERIC_ERROR;
            new Logs.ERROR('TWIST_PwdlessEmailVerifGetTokenAPI', 'API', e.getMessage(), e.getStackTraceString());
            System.debug('An error occured: ' + e.getMessage() + e.getStackTraceString());
            responseMap = TWIST_Utils.buildFailureResponseObject('message', errorMessage);
            response.statusCode = 400;
        }

        response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
    }

    
    // PRIVATE FUNCTIONS

    private static Headless_Identity_Flow_Instance__c getPwdlessEmailVerifRequest(String identifier) {
        if (!String.isEmpty(identifier)) {
        	List<Headless_Identity_Flow_Instance__c> pwdlessEmailVerifRequests = [	SELECT 	Id, Username__c, Status__c, Redirect_Uri__c, Locale__c, LastModifiedDate 
                                                                        			FROM 	Headless_Identity_Flow_Instance__c 
                                                                        			WHERE 	Identifier__c =: identifier 
                                                                        			AND 	Flow_Type__c =: PWDLESS_EMAIL_VERIFICATION
                                                                        			AND 	Verification_Method__c =: EMAIL];  
            if(!pwdlessEmailVerifRequests.isEmpty()){
                return pwdlessEmailVerifRequests[0];
            }
        }
        return null;
    }
    
    private static String validateIdentifier(Headless_Identity_Flow_Instance__c pwdlessEmailVerifRequest, String identifier, TWIST_Settings__c twist_settings) {
        if (!String.isEmpty(identifier)) {
            if(pwdlessEmailVerifRequest != null) {
                    if(pwdlessEmailVerifRequest.Status__c != IDENTIFIER_USED) {
                        if(!isIdentifierExpired((DateTime)pwdlessEmailVerifRequest.LastModifiedDate, twist_settings)){
                        	return IDENTIFIER_STATUS_VALID;
                        } return IDENTIFIER_STATUS_EXPIRED;
                    } return IDENTIFIER_STATUS_USED;
            }
        }
        return IDENTIFIER_STATUS_UNKNOWN;
    }
    
    private static Boolean isIdentifierExpired(DateTime identifierDate, TWIST_Settings__c twist_settings) {
        return identifierDate.addMinutes(Integer.valueOf(twist_settings.get('Pwdless_Email_Verif_Identifier_Validity__c'))).getTime() < DateTime.now().getTime();
    }

     private static Boolean isIdentifierValid(String identifierStatus) {
        return identifierStatus == IDENTIFIER_STATUS_VALID;
    }
    
    private static void updateStatusPwdlessEmailVerifRequest(Headless_Identity_Flow_Instance__c pwdlessEmailVerifRequest){
        pwdlessEmailVerifRequest.Status__c = IDENTIFIER_USED;
        update pwdlessEmailVerifRequest;
    }
    
    private static Boolean isStatusUnknownOrUsed(String identifierStatus) {
        return new List<String>{ IDENTIFIER_STATUS_UNKNOWN, IDENTIFIER_STATUS_USED }.contains(identifierStatus);
    }
    
    private static String getJWTAccessToken(String username, TWIST_Settings__c settings) {
        try {
            return SFID_Utils.getJWTAccessToken(username, settings.AOB_Client_Id__c, settings.AOB_Site_URL__c, settings.AOB_Cert_Name__c, settings.Auth_Path__c);
        }
        catch (Exception e) {
            new Logs.ERROR('TWIST_PwdlessEmailVerif_CTRL', 'APEX CODE', e.getMessage(), e.getStackTraceString());
            System.debug('An error occured: ' + e.getMessage() + e.getStackTraceString());
            return null;
        }
    }

   

    public class CustomException extends Exception {}
    
}