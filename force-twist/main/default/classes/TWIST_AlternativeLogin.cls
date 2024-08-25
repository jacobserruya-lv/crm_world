public without sharing class TWIST_AlternativeLogin {

    public static final String LV_DOMAIN = 'Louis Vuitton Domain';
    public static final String LOGIN_SUCCES_PATH = 'Login Success Path';
    public static final String MULESOFT_VERIFY_PATH = 'Passwordless Verify Mulesoft Path';
    public static final String MULESOFT_VERIFIED_PATH = 'Passwordless Verified Mulesoft Path';
    public static final String EMAILTEMPLATE_VERIFY_PREFIX = 'EmailVerify_';
    public static final String EMAILTEMPLATE_VERIFIED_PREFIX = 'Passwordless_';

    
    public enum ResultStatus {
        EMPTY_EMAIL,
        INVALID_EMAIL,
        EMAIL_NOT_FOUND,
        ERROR_MULESOFT,
        SUCCESS_ALTERNATIVE_LOGIN
    }

     // Called from Alternative Login form
     @AuraEnabled(cacheable=false)
     public static Map<String,Object> requestAlternativeLogin(String userEmail, String language, String langCountry, String dispatchCountry, String origin) {
         List<String> labelsToTranslate = new List<String>{'Twist_Error_Send_Email_Empty_Address', 'Twist_Error_Message_UnknownProfile', 'Twist_Login_Form_TechnicalError'};
         Map<String,Object> labels = TWIST_i18nTranslations.translateLabelsList(labelsToTranslate, language);
         
         try {
             ResultStatus resultStatus = doAlternativeLogin(userEmail, langCountry,dispatchCountry,origin);

             if(resultStatus == TWIST_AlternativeLogin.ResultStatus.EMPTY_EMAIL){
                 return TWIST_Utils.buildFailureResponseObject('form', labels.get('Twist_Error_Send_Email_Empty_Address'));
             }
             if(resultStatus == TWIST_AlternativeLogin.ResultStatus.INVALID_EMAIL){
                 return TWIST_Utils.buildFailureResponseObject('form', labels.get('Twist_Error_Message_UnknownProfile'));
             }
             if(resultStatus == TWIST_AlternativeLogin.ResultStatus.EMAIL_NOT_FOUND){
                 return TWIST_Utils.buildSuccessResponseObject('seenf', ''); // seenf = "Send Event 'Email Not Found'"
             }
             if (resultStatus == TWIST_AlternativeLogin.ResultStatus.ERROR_MULESOFT) {
                 return TWIST_Utils.buildFailureResponseObject('form', labels.get('Twist_Login_Form_TechnicalError'));
             }
             else{
                 return TWIST_Utils.buildSuccessResponseObject('seals', ''); // serps = "Send Event 'Alternative Login Success'"
             }

         }
         catch(Exception e) {
            System.debug('catch exception=>'+e);
             return TWIST_Utils.buildFailureResponseObject('form', labels.get('Twist_Login_Form_TechnicalError'));
         }   
     }
    

    public static ResultStatus doAlternativeLogin(String userEmail, String langCountry, String dispatchCountry, String origin) {
        try {
            Map<String,String> paths = TWIST_Utils.getPaths(langCountry, origin, dispatchCountry); 

            if(String.isBlank(userEmail)) {
                return ResultStatus.EMPTY_EMAIL;
            }

             if(!TWIST_Utils.isValidEmail(userEmail)){
                 return ResultStatus.INVALID_EMAIL;
             }

             Map<String,String> user = TWIST_Utils.getUserByEmail(userEmail);
             if(user == null){
                new Logs(new Map<String,Object> {
                    'level' => 'ERROR',
                    'apexClass' => 'TWIST_AlternativeLogin',
                    'category' => 'VALIDATION',
                    'message' => 'No User found matching this email',
                    'details' => 'Email: ' + userEmail
                });
                return ResultStatus.EMAIL_NOT_FOUND;
            }
        
            Map<String,Object> statusMC = user.get('HasVerifiedEmail__c') == 'true' ? callMulesoftPassworlessVerifiedApi(userEmail,langCountry, paths) : callMulesoftPassworlessVerifyApi(userEmail, langCountry, paths);
            
            if (!Boolean.valueOf(statusMC.get('success'))) {
                return ResultStatus.ERROR_MULESOFT;
            }
            else {
                return ResultStatus.SUCCESS_ALTERNATIVE_LOGIN;
            }
        }
        catch(Exception e) {
           throw new CustomException('Alternative Login failed.');
        }
    }

    public static Map<String,Object> callMulesoftPassworlessVerifyApi(String username, String langCountry, Map<String,String> paths) {

        Map<String, String> body = new Map<String,String> {
            'username' 	                => username,
            'redirect_url' 		        => paths.get(LV_DOMAIN) + paths.get(LOGIN_SUCCES_PATH),
            'emailtemplate' 			=> EMAILTEMPLATE_VERIFY_PREFIX + langCountry.replace('-', '_'),
            'locale' 			        => langCountry
        };
        return callMulesoftPassworlessApi(paths.get(MULESOFT_VERIFY_PATH), JSON.serialize(body));
    }

    public static Map<String,Object> callMulesoftPassworlessVerifiedApi(String username, String langCountry, Map<String,String> paths) {

        Map<String, String> body = new Map<String,String> {
            'username' 	                => username,
            'redirect_url' 		        => paths.get(LV_DOMAIN) + paths.get(LOGIN_SUCCES_PATH),
            'emailtemplate'             => EMAILTEMPLATE_VERIFIED_PREFIX + langCountry.replace('-', '_'),
            'locale'                     => langCountry
        };
        return callMulesoftPassworlessApi(paths.get(MULESOFT_VERIFIED_PATH), JSON.serialize(body));
    }
    
    public static Map<String,Object> callMulesoftPassworlessApi(String path, String body) {
        try {
            Http http = new Http();
    
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:Mulesoft_SFID'+path);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json');
            request.setHeader ('client_id', '{!$Credential.Username}');
            request.setHeader ('client_secret', '{!$Credential.Password}');
            request.setBody(body);
            HttpResponse response = http.send(request);
            if(response.getStatusCode() == 200) {
                return TWIST_Utils.buildSuccessResponseObject('message', 'status: ' + response.getStatus() + ', statusCode: ' + String.valueOf(response.getStatusCode()) + ', responseId: ');
            }
            logResponse( response, 'ERROR');
            return TWIST_Utils.buildFailureResponseObject('form', 'errorCode: ' + String.valueOf(response.getStatusCode()) + ', errorDescription: ' + response.getBody() + ', responseId: ' + ', status: ' + response.getStatus() );
        } catch (Exception e) {
            system.debug('EXCEPTION ==> ' + e);
            new Logs(new Map<String,Object> {
                'level' => 'ERROR',
                'apexClass' => 'TWIST_AlternativeLogin',
                'category' => 'CALLOUT',
                'message' => 'MULESOFT API CALL ERROR',
                'details' => 'ENDPOINT: ' + path + ' ERROR: ' +  e
            });
            throw e;
        }
    }

     //Debug the error
     public static void logResponse(HttpResponse response, String level) {
        new Logs( new Map<String,Object> {
                'level' => level, 
                'apexClass' => 'TWIST_AlternativeLogin', 
                'category' => 'CALLOUT',
                'http' => response
            });
    }
    
    public class CustomException extends Exception {}


}