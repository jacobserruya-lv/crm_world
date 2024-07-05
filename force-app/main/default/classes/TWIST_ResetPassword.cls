public without sharing class TWIST_ResetPassword {
    
    // Called from Forgot Password form
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> initForgotPasswordComponentConfig(Map<String,Object> queryParams) {
        return TWIST_Utils.getForgotPasswordFormSettings(queryParams);
    }
    
    // Called from Forgot Password form
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> requestResetPassword(String userEmail, String language, String langCountry, String dispatchCountry, String origin,String sessionInfo) {
       
        try {
            TWIST_ResetPasswordService.ResultStatus resultStatus = TWIST_ResetPasswordService.requestResetPassword(userEmail, langCountry,dispatchCountry,origin,sessionInfo);
            if(resultStatus == TWIST_ResetPasswordService.ResultStatus.EMPTY_EMAIL){
                return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Error_Send_Email_Empty_Address', language));
            }
            if(resultStatus == TWIST_ResetPasswordService.ResultStatus.INVALID_EMAIL){
                return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Error_Message_UnknownProfile', language));
            }
            if(resultStatus == TWIST_ResetPasswordService.ResultStatus.EMAIL_NOT_FOUND){
                return TWIST_Utils.buildSuccessResponseObject('seenf', ''); // seenf = "Send Event 'Email Not Found'"
            }
            if(resultStatus == TWIST_ResetPasswordService.ResultStatus.SUCCESS_EMAIL){
                return TWIST_Utils.buildSuccessResponseObject();
            }
            if(resultStatus == TWIST_ResetPasswordService.ResultStatus.ERROR_TOKEN) {
                return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel(String.valueOf(TWIST_ResetPasswordService.statusToken.get('error')), language));
            }
            if (resultStatus == TWIST_ResetPasswordService.ResultStatus.ERROR_MARKETING_CLOUD) {
                return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', language));
            }
            else{
                return TWIST_Utils.buildSuccessResponseObject('serps', ''); // serps = "Send Event 'Reset Password Success'"
            }
        }
        catch(Exception e) {
            return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', language));
        }   
    }
    
    // Called from Reset Password form
    @AuraEnabled(cacheable=true)
    public static Map<String,Object> validateToken(String language, Map<String,Object> queryParams) {
        try {
            String tokenStatus = TWIST_ResetPasswordTokenService.validate((String) queryParams.get(TWIST_QueryParamKey_CONST.TOKEN));
            if (!TWIST_ResetPasswordTokenService.isTokenValid(tokenStatus)) {
                queryParams.put(TWIST_QueryParamKey_CONST.TOKEN_INVALID_ERROR_MESSAGE, 'true');
                return TWIST_Utils.buildFailureResponseObject(
                'redirectUrl',
                TWIST_Utils.buildTwistPageUrl(TWIST_IdentityPathsMdt_CONST.FORGOT_PASSWORD_FORM, queryParams, new List<String> { TWIST_QueryParamKey_CONST.TOKEN }
                ));
            }
            return TWIST_Utils.buildSuccessResponseObject();
        }
        catch(Exception e) {
            return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', language));
        }
    }
    
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> getUserByResetPasswordToken(String token, String language) {
        try {
            Reset_Password_Request__c request = TWIST_ResetPasswordTokenService.getResetPasswordRequest(token);
            if (request == null) {
                return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', language));
            }
            String userEmail = (String) request.Email__c;
            Map<String,String> user = TWIST_Utils.getUserByEmail(userEmail);
            List<Account> accounts = new List<Account>();
            if (user == null) {
                if(TWIST_Settings__c.getInstance().Is_Active_User_Creation__c && request.isAccountActivation__c){
                    accounts = TWIST_Utils.findAccountsByEmail(userEmail);
                    if(accounts.Size() == 1) {
                        user = new Map<String,String> {
                            'firstName' => accounts[0].FirstName,
                            'lastName' => accounts[0].LastName
                        };
                    } else {
                        return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', language));
                    }
                } else {
                    return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', language));
                }
            }
            return TWIST_Utils.buildSuccessResponseObject(new Map<String,Object> {
                'email' => userEmail,
                'firstName' => user.get('FirstName'),
                'lastName' => user.get('LastName')
            });
        }
        catch (Exception e) {
            return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', language));
        }
    }
    
    // Called from Reset Password form
    @AuraEnabled(cacheable=false)
    public static Map<String,Object> doResetPassword(String password, String confirmPassword, String language, Map<String,Object> queryParams) {
        String requestPasswordChangeToken = (String) queryParams.get(TWIST_QueryParamKey_CONST.TOKEN);
        try {
            // Request password token validation
            String tokenStatus = TWIST_ResetPasswordTokenService.validate(requestPasswordChangeToken);
            if (!TWIST_ResetPasswordTokenService.isTokenValid(tokenStatus)) {
                queryParams.put(TWIST_QueryParamKey_CONST.TOKEN_INVALID_ERROR_MESSAGE, 'true');
                return TWIST_Utils.buildFailureResponseObject(
                'redirectUrl',
                TWIST_Utils.buildTwistPageUrl(TWIST_IdentityPathsMdt_CONST.FORGOT_PASSWORD_FORM, queryParams, new List<String> { TWIST_QueryParamKey_CONST.TOKEN })
                );
            }
            // User asking for password reset validation
            Reset_Password_Request__c request = TWIST_ResetPasswordTokenService.getResetPasswordRequest(requestPasswordChangeToken);
            String userEmail = (String) request.Email__c;
            Map<String,String> user = TWIST_Utils.getUserByEmail(userEmail);
            User userExt = new User();
            List<Account> accounts = new List<Account>();
            if (user == null) {
                if(TWIST_Settings__c.getInstance().Is_Active_User_Creation__c && request.isAccountActivation__c){
                    accounts = TWIST_Utils.findAccountsByEmail(userEmail);
                    if(accounts.Size() == 1) {
                        userExt = TWIST_Utils.createExternalMyLVUser(accounts[0],null);
                        Database.SaveResult sr = Database.Insert(userExt, false);
                        if(sr.isSuccess()) {
                            user = TWIST_Utils.convertUserToMap(userExt);
                        } else {
                            String logError = '';
                            for(Database.Error err : sr.getErrors()) {
                                logError += err.getMessage() + ' ';
                            }
                            new Logs( new Map<String,Object> {
                                'level' => 'ERROR',
                                'apexClass' => 'TWIST_ResetPassword',
                                'category' => 'DATABASE',
                                'message' => logError,
                                'details' => 'Email: ' + userEmail
                            });
                            return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', language));      
                        }
                    } else {
                        new Logs( new Map<String,Object> {
                            'level' => 'ERROR',
                            'apexClass' => 'TWIST_ResetPassword',
                            'category' => 'VALIDATION',
                            'message' => 'No User found matching this email',
                            'details' => 'Email: ' + userEmail
                        });
                        return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', language));    
                    }
                } else {
                    new Logs( new Map<String,Object> {
                        'level' => 'ERROR',
                        'apexClass' => 'TWIST_ResetPassword',
                        'category' => 'VALIDATION',
                        'message' => 'No User found matching this email',
                        'details' => 'Email: ' + userEmail
                    });
                    return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', language));
                }
            }
            // New password validation
            if (!TWIST_Utils.doPasswordsMatch(password, confirmPassword)) { // JSI si ce check est inutile, virer param  confirmPassword + MAJ appel au service depuis LWC
                return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', language));
            }
            if (TWIST_Utils.isPasswordTooLong(password)) {
                return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', language));
            }
            if (!TWIST_Utils.doesPasswordMatchStringPattern(password)) {
                return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', language));
            }
            if (TWIST_Utils.doesPasswordContainUserFirstNameOrLastName(password, user)) {
                new Logs(new Map<String,Object> {
                    'level' => 'INFO',
                    'apexClass' => 'TWIST_Utils',
                    'category' => 'EVENT',
                    'message' => Label.EM_password_too_easy_contains_name,
                    'details' => 'Do reset password for user: ' + JSON.serialize(user),
                    'status_code' => 'Label.EM_password_too_easy_contains_name'
                });
                return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Reset_Password_Form_Validation_PasswordContainsFirstOrLastNames', language));
            }
            
            try {
                if(user.get('IsActive') != 'true') {
                    TWIST_Utils.activateUser(user.get('Id'));
                }
                System.setPassword(user.get('Id'), password);
            }
            catch(Exception e) {
                return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Reset_Password_Form_Validation_RepeatedPassword', language));
            }
            
            Pagereference page = TWIST_LoginService.doSalesforceLogin(
            user.get('Username'),
            password,
            (String) queryParams.get(TWIST_QueryParamKey_CONST.STATE),
            (String) queryParams.get(TWIST_QueryParamKey_CONST.CODE_CHALLENGE),
            (String) queryParams.get(TWIST_QueryParamKey_CONST.CLIENT_ID),
            (String) queryParams.get(TWIST_QueryParamKey_CONST.REDIRECT_URI)
            );
            TWIST_ResetPasswordTokenService.setTokenStatusToUsed(requestPasswordChangeToken);
            return TWIST_Utils.buildSuccessResponseObject('redirectUrl', page.getUrl());
        }
        catch(Exception e) {
            System.debug('Exception Error '+ e);
            return TWIST_Utils.buildFailureResponseObject('form', TWIST_i18nTranslations.translateSingleLabel('Twist_Login_Form_TechnicalError', language));
        }
    }
    
}