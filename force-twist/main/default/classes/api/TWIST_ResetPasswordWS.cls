@RestResource(urlMapping='/forgotPassword/*')
global with sharing class TWIST_ResetPasswordWS {
    
    
    @HttpPost
    global static void urlMC(){
        RestRequest req = RestContext.request;
        RestResponse res = RestContext.response;
        String requestBody = req.requestBody.toString();
        Map<String, Object> requestMap = (Map<String, Object>) JSON.deserializeUntyped(requestBody);
        
        String userEmail = (String) requestMap.get('userEmail');
        String langCountry = (String) requestMap.get('langCountry');
        String origin = (String) requestMap.get('origin');
        String dispatchCountry = (String) requestMap.get('dispatchCountry');
        String sessionInfo = (String) requestMap.get('sessionInfo');
        
        if (String.isEmpty(userEmail) || String.isEmpty(langCountry) || String.isEmpty(origin)){
            throw new CustomException('Some of these paramters are missing : userEmail/langCountry/origin');
        }
        res.responseBody = Blob.valueOf(JSON.serialize(requestResetPassword(userEmail,langCountry,dispatchCountry,origin,sessionInfo)));
    }
    
    public static Map<String,Object> requestResetPassword(String userEmail, String langCountry, String dispatchCountry, String origin, String sessionInfo) {
        try {
            TWIST_ResetPasswordService.ResultStatus resultStatus = TWIST_ResetPasswordService.requestResetPassword(userEmail,langCountry,dispatchCountry,origin,sessionInfo);
            if(resultStatus == TWIST_ResetPasswordService.ResultStatus.EMPTY_EMAIL){
                return TWIST_Utils.buildFailureResponseObject('message', TWIST_ResetPasswordService.ResultStatus.EMPTY_EMAIL);
            }
            if(resultStatus == TWIST_ResetPasswordService.ResultStatus.INVALID_EMAIL){
                return TWIST_Utils.buildFailureResponseObject('message', TWIST_ResetPasswordService.ResultStatus.INVALID_EMAIL);
            }
            if(resultStatus == TWIST_ResetPasswordService.ResultStatus.EMAIL_NOT_FOUND){
                return TWIST_Utils.buildFailureResponseObject('message', TWIST_ResetPasswordService.ResultStatus.EMAIL_NOT_FOUND);
            }
            if(resultStatus == TWIST_ResetPasswordService.ResultStatus.ERROR_TOKEN) {
                return TWIST_Utils.buildFailureResponseObject('message', String.valueOf(TWIST_ResetPasswordService.statusToken.get('error')));
            }
            if (resultStatus == TWIST_ResetPasswordService.ResultStatus.ERROR_MARKETING_CLOUD) {
                return TWIST_Utils.buildFailureResponseObject('message',TWIST_ResetPasswordService.ResultStatus.ERROR_MARKETING_CLOUD);
            }
            else {
                return TWIST_Utils.buildSuccessResponseObject('message',TWIST_ResetPasswordService.ResultStatus.SUCCESS_RESET_PASSWORD);
                
            }
        }
        catch(Exception e) {
            return TWIST_Utils.buildFailureResponseObject('message', e.getMessage());
        }
    }
    class CustomException extends Exception {}
    
}