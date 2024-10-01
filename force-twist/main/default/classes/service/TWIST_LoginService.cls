public with sharing class TWIST_LoginService {
    
    /**
    * @return {Pagereference|null} null if login failed, a PageReference object otherwise
    */
    public static Pagereference doSalesforceLogin(String username,  String password, String state, String codeChallenge, String clientId, String redirectUri) {
        Pagereference loginPage = null;
        Boolean isAnyQueryParamMissing = false;
        try {
            if (!String.isEmpty(state) && !String.isEmpty(codeChallenge) && !String.isEmpty(clientId) && !String.isEmpty(redirectUri)) {
                // Important note: Site.login() automatically activates a user who'd be inactive
                loginPage = Site.login(username, password, TWIST_Utils.buildGetAuthorizationCodeUrl(state, codeChallenge, clientId, redirectUri));
            }
        }
        catch(SecurityException ex){
            System.debug('> SecurityException caught in Twist_LoginService.doSalesforceLogin(): ' + ex);
        }
        return loginPage;
    }
    
}