public without sharing class TWIST_ResetPasswordTokenService {

    public final static String TOKEN_STATUS_UNKNOWN = 'TOKEN_STATUS_UNKNOWN';
    public final static String TOKEN_STATUS_USER_UNKNOWN = 'TOKEN_STATUS_USER_UNKNOWN';
    public final static String TOKEN_STATUS_EXPIRED = 'TOKEN_STATUS_EXPIRED';
    public final static String TOKEN_STATUS_USED = 'TOKEN_STATUS_USED';
    public final static String TOKEN_STATUS_VALID = 'TOKEN_STATUS_VALID';

    public final static String TOKEN_ISSUED = 'TOKEN_ISSUED';
    public final static String TOKEN_USED = 'TOKEN_USED';
    public final static String SESSION_INFO_RETRIEVED = 'SESSION_INFO_RETRIEVED';

    /**
     * @description attempts a reset password request; eventually create an entry into the ResetPasswordRequest__c object
     *
     * @param (String) email: user's email address
     * @param (String) state: query param of the "forgot your password?" page
     * @param (String) codeChallenge: query param of the "forgot your password?" page
     * @param (String) redirectUri: query param of the "forgot your password?" page
     * @return { {success: Boolean, error: String} }
     */

    public static Map<String,Object> getToken(String email, String langCountry) {
        if(!String.isEmpty(email) && !String.isEmpty(langCountry)){
            if(canRequestAdditionalResetPassword(email)){
                TWIST_Settings__c settings = TWIST_Settings__c.getInstance();
                String token = StringUtils.generateRandomString(Integer.valueOf(settings.Email_Token_Size__c), settings.Email_Token_Chars__c);
                return TWIST_Utils.buildSuccessResponseObject('token', token);
            }
            else{
                return TWIST_Utils.buildFailureResponseObject('error', 'Twist_Too_many_Reset_Password_Requests');
            }
        }
        else{
            return TWIST_Utils.buildFailureResponseObject('error', 'Missing fields');
        }
    }

    public static Reset_Password_Request__c createResetPasswordRequest(String email, String token, String countryLang, String origin, String sessionInfo, Boolean isAccountActivation){
        Reset_Password_Request__c request;
        try {
            request = new Reset_Password_Request__c (
                Email__c = email,
                Token__c = token,
                LangCountry__c = countryLang.escapeHtml4(),
                Origin__c = origin.escapeHtml4(),
                SessionInfo__c = sessionInfo != null ? sessionInfo.escapeHtml4() : '',
                Status__c = TWIST_ResetPasswordTokenService.TOKEN_ISSUED,
                isAccountActivation__c = isAccountActivation
            );
            insert request;
        }
        catch(Exception e) {
            System.debug('> Error in method TWIST_ResetPasswordTokenService.createResetPasswordRequest(): ' + e.getMessage());
        }
        return request;
    }

    public static Reset_Password_Request__c getResetPasswordRequest(String token){
        List<Reset_Password_Request__c> request = [
            SELECT LangCountry__c, Origin__c, Email__c, Status__c,isAccountActivation__c
            FROM Reset_Password_Request__c
            WHERE Token__c = :token
            ORDER BY CreatedDate DESC
            LIMIT 1
        ];
        return request.isEmpty() ? null : request[0];
    }

    /**
     * @return {String} one of the final statuses written on top
     */

    public static Boolean isTokenValid(String tokenStatus) {
        return new List<String>{ TWIST_ResetPasswordTokenService.TOKEN_STATUS_USER_UNKNOWN, TWIST_ResetPasswordTokenService.TOKEN_STATUS_VALID }.contains(tokenStatus);
    }
    
    public static String validate(String token) {
        if (!String.isEmpty(token)) {
            List<Reset_Password_Request__c> resetPasswordRequest = [SELECT Email__c, CreatedDate, Status__c,isAccountActivation__c FROM Reset_Password_Request__c WHERE Token__c =: token LIMIT 1];
            if(!resetPasswordRequest.isEmpty()) {
                    if(resetPasswordRequest[0].get('Status__c') != TWIST_ResetPasswordTokenService.TOKEN_USED) {
                        DateTime tokenDate = (DateTime)resetPasswordRequest[0].get('CreatedDate');
                        if(wasTokenIssuedLessThanOneHourAgo(tokenDate) && resetPasswordRequest[0].get('Status__c') == TWIST_ResetPasswordTokenService.TOKEN_ISSUED) {
                            if(TWIST_Utils.canFindMyLVUserWithEmail((String)resetPasswordRequest[0].get('Email__c')) || resetPasswordRequest[0].isAccountActivation__c) {
                                return TOKEN_STATUS_VALID;
                            } return TOKEN_STATUS_USER_UNKNOWN;
                        } return TOKEN_STATUS_EXPIRED;
                    } return TOKEN_STATUS_USED;
            }
        }
        return TOKEN_STATUS_UNKNOWN;
    }

    public static void setTokenStatusToUsed(String token) { 
        Reset_Password_Request__c[] resetPasswordRequest = [SELECT Id, Token__c, Status__c FROM Reset_Password_Request__c WHERE Token__c =: token ORDER BY CreatedDate DESC LIMIT 1];

        Reset_Password_Request__c request = resetPasswordRequest[0];
        if(!resetPasswordRequest.isEmpty() && request.get('Status__c') == TWIST_ResetPasswordTokenService.TOKEN_ISSUED) {
            request.Status__c = TWIST_ResetPasswordTokenService.TOKEN_USED;
            update request;
        }
    }

    /* PRIVATE METHODS ***************************************************************************************/ 

    private static Boolean wasTokenIssuedLessThanOneHourAgo(DateTime tokenDate) {
        return tokenDate.addHours(1).getTime() >= DateTime.now().getTime();
    }

    private static Boolean canRequestAdditionalResetPassword(String email){
        return getTotalResetPasswordRequestsToday(email) < getMaxRequests();
    }
    
    private static Integer getTotalResetPasswordRequestsToday(String email){
        try {
                DateTime before24Hours = System.Now().addHours(-24);
                List<AggregateResult> aggregateResults = [SELECT COUNT(Id) totalRequests FROM Reset_Password_Request__c WHERE Email__c =: email AND CreatedDate >: before24Hours];
                AggregateResult requests;
                if(!aggregateResults.isEmpty() ){
                    requests = aggregateResults[0];
                    return (Integer) requests.get('totalRequests');
                }
        }
        catch(Exception e) {
            System.debug('> Error in method TWIST_ResetPasswordTokenService.getTotalResetPasswordRequestsToday(): ' + e.getMessage());
        }
        return 0;
    }

    private static Integer getMaxRequests() {
        return (Integer) TWIST_Settings__c.getInstance().Reset_Password_Max_Requests__c;
    }

}