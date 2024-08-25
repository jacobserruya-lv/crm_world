public without sharing class TWIST_ResetPasswordService {
    
    public enum ResultStatus {
        EMPTY_EMAIL,
        INVALID_EMAIL,
        SUCCESS_EMAIL,
        EMAIL_NOT_FOUND,
        ERROR_TOKEN,
        ERROR_MARKETING_CLOUD,
        SUCCESS_RESET_PASSWORD
    }
    public static Map<String,Object> statusToken = new  Map<String,String>();
    
    public static ResultStatus requestResetPassword(String userEmail, String langCountry, String dispatchCountry, String origin, String sessionInfo) {
        Boolean isAccountActivation = false;
        User userExt = new User();
        try {
            System.debug('userEmail : '+userEmail);
            if(String.isBlank(userEmail)) {
                return ResultStatus.EMPTY_EMAIL;
            }
            system.debug(TWIST_Utils.isValidEmail(userEmail));
            if(!TWIST_Utils.isValidEmail(userEmail)){
                return ResultStatus.INVALID_EMAIL;
            }
            Map<String,String> user = TWIST_Utils.getUserByEmail(userEmail);
            if(user == null){
                if(TWIST_Settings__c.getInstance().Is_Active_User_Creation__c){
                    List<Account> accts = TWIST_Utils.findAccountsByEmail(userEmail);
                    if(accts.size() == 1) {
                        userExt = TWIST_Utils.createExternalMyLVUser(accts[0],null);
                        isAccountActivation = true;
                        user = TWIST_Utils.convertUserToMap(userExt);
                    } else {
                        new Logs(new Map<String,Object> {
                            'level' => 'ERROR',
                            'apexClass' => 'TWIST_ResetPassword',
                            'category' => 'VALIDATION',
                            'message' => 'No User found matching this email',
                            'details' => 'Email: ' + userEmail
                        });
                        return ResultStatus.EMAIL_NOT_FOUND;
                    }
                } else {
                    new Logs(new Map<String,Object> {
                        'level' => 'ERROR',
                        'apexClass' => 'TWIST_ResetPassword',
                        'category' => 'VALIDATION',
                        'message' => 'No User found matching this email',
                        'details' => 'Email: ' + userEmail
                    });
                    return ResultStatus.SUCCESS_EMAIL;
                }
            }
            statusToken = TWIST_ResetPasswordTokenService.getToken(userEmail, langCountry);
            if (!Boolean.valueOf(statusToken.get('success'))) {
                return ResultStatus.ERROR_TOKEN;
            }
            String token = (String)statusToken.get('token');
            //send the email
            String iso2CountryCode = TWIST_Utils.getLangCountryISO2CountryCode(langCountry); //TWIST-13831
            Map<String,Object> statusMC = MarketingCloudEmails_API.sendEmailMC(langCountry, dispatchCountry, origin, token, userEmail, user.get('LastName'), user.get('FirstName'), user.get('Title'), iso2CountryCode, user.get('MobilePhone')); //TWIST-4342
            TWIST_ResetPasswordTokenService.createResetPasswordRequest(userEmail, token, langCountry, origin, sessionInfo,isAccountActivation);
            if (!Boolean.valueOf(statusMC.get('success'))) {
                return ResultStatus.ERROR_MARKETING_CLOUD;
            }
            else {
                return ResultStatus.SUCCESS_RESET_PASSWORD;
            }
        }
        catch(Exception e) {
            throw new CustomException('Reset Password failed.');
        }
        
    }
    public class CustomException extends Exception {}
}