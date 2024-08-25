@RestResource(urlMapping='/PwdlessEmailVerification/Init')
global with sharing class TWIST_PwdlessEmailVerifInitAPI {
    public final static String PWDLESS_EMAIL_VERIFICATION = 'PasswordlessEmailVerification';
    public final static String EMAIL = 'email';
    public final static String IDENTIFIER_ISSUED = 'IDENTIFIER_ISSUED';
    public final static String GENERIC_ERROR = 'GENERIC_ERROR';
    public final static String IDENTIFIER_ERROR = 'IDENTIFIER_ERROR';
    @HttpPost
    global static void doPost() {
        RestRequest request = RestContext.request;
        RestResponse response = RestContext.response;
        Map<String,Object> responseMap = TWIST_Utils.buildSuccessResponseObject();
        TWIST_Settings__c settings = TWIST_Settings__c.getInstance();
        List<String> requiredFields = new List<String>{'username', 'emailtemplate', 'redirecturi', 'locale'};
        try {
            response.addHeader('Content-Type','application/json');
            response.statusCode = 200;
            
            if(String.isBlank(request.requestBody.toString())){
                 throw new CustomException(Label.EM_required_field_missing + ' : EMPTY BODY');
            }
            
            Map<String,Object> body = (Map<String,Object>)JSON.deserializeUntyped(request.requestBody.toString());

            String missingRequiredFields = getMissingRequiredFields(requiredFields, body);
            if(!String.isBlank(missingRequiredFields)){
                throw new CustomException(Label.EM_required_field_missing + ' : ' + missingRequiredFields);
            }

            String userName = String.ValueOf(body.get('username'));
            String emailTemplate = String.ValueOf(body.get('emailtemplate'));
            String redirectUri = String.ValueOf(body.get('redirecturi'));
            String locale = String.ValueOf(body.get('locale'));
            
            String userId = getUserId(username);
            if(userId == null){
                throw new CustomException(Label.EM_User_Not_Found);
            } 

            String emailTemplateId = getEmailTemplateId(emailTemplate);
            if(emailTemplateId == null){
                throw new CustomException(Label.EM_Emailtemplate_Not_Found);
            }       
            
            String identifier = StringUtils.generateRandomString(Integer.valueOf(settings.Email_Token_Size__c), settings.Email_Token_Chars__c);  
            if(identifier == null){
                throw new CustomException(IDENTIFIER_ERROR);
            }
            
            Boolean isEmailSent = System.UserManagement.sendAsyncEmailConfirmation(userId, emailTemplateId, String.valueOf(settings.get('Network_Id__c')),'TWIST_PwdlessEmailVerif?client-id=null&identifier='+identifier+'&redirect-uri='+redirectUri+'&username='+EncodingUtil.urlEncode(userName, 'UTF-8')+'&locale='+locale);
            
            if(isEmailSent){
                upsertPwdlessEmailVerifRequest(username, identifier, redirectUri, locale);
            }
        }
        catch (Exception e) {
            String errorMessage = e.getTypeName().contains('CustomException') ? e.getMessage() : GENERIC_ERROR;
            new Logs.ERROR('TWIST_PwdlessEmailVerifInitAPI', 'API', e.getMessage(), e.getStackTraceString());
            System.debug('An error occured: ' + e.getMessage() + e.getStackTraceString());
            responseMap = TWIST_Utils.buildFailureResponseObject('message', errorMessage);
            response.statusCode = 400;
        }
        response.responseBody = Blob.valueOf(JSON.serialize(responseMap));
    }

    private static String getMissingRequiredFields(List<String> requiredFields, Map<String, Object> body){
        List<String> missingFields = new List<String>();

        for (String key : requiredFields){
            if(!body.containsKey(key) || String.isBlank(String.ValueOf(body.get(key)))){
                missingFields.add(key);
            }
        }


        if(!missingFields.isEmpty()){
            return String.join(missingFields, ' | ');
        }
          
        return null;
    }

    private static String getUserId(String username){
        List<User> users = [SELECT id, UserName from user WHERE UserName =: userName];
        if(!users.isEmpty()){
            return users[0].Id;
        }  
        return null;
    }

    private static String getEmailTemplateId(String emailTemplate){
        List<EmailTemplate> templates = [SELECT Id from EmailTemplate WHERE DeveloperName =: emailTemplate LIMIT 1];
        if(!templates.isEmpty()){
            return templates[0].Id;
        }  
        return null;
    }

    private static void upsertPwdlessEmailVerifRequest(String username, String identifier, String redirectUri, String locale) {
        Headless_Identity_Flow_Instance__c pwdlessEmailVerifRequest = new Headless_Identity_Flow_Instance__c ();
        List<Headless_Identity_Flow_Instance__c> pwdlessEmailVerifRequestList = [	SELECT 	id 
                                                                                	FROM 	Headless_Identity_Flow_Instance__c 
                                                                                	WHERE 	Username__c =: username 
                                                                                	AND 	Flow_Type__c =: PWDLESS_EMAIL_VERIFICATION
                                                                                	AND 	Verification_Method__c =: EMAIL];
        if(!pwdlessEmailVerifRequestList.isEmpty()){
            pwdlessEmailVerifRequest.Id = pwdlessEmailVerifRequestList[0].Id;
        } 
        else{
            pwdlessEmailVerifRequest.Flow_Type__c = PWDLESS_EMAIL_VERIFICATION;
            pwdlessEmailVerifRequest.Username__c = userName; 
            pwdlessEmailVerifRequest.Verification_Method__c = EMAIL;
        }
        pwdlessEmailVerifRequest.Status__c = IDENTIFIER_ISSUED;
        pwdlessEmailVerifRequest.Identifier__c = identifier;
        pwdlessEmailVerifRequest.Redirect_Uri__c = redirectUri;
        pwdlessEmailVerifRequest.Locale__c = locale;
        Database.upsert(pwdlessEmailVerifRequest);
    }

    public class CustomException extends Exception {}
    
}