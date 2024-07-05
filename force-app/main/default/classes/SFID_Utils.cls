public with sharing class SFID_Utils {
    /*
   *** DESCRIPTION Get Access Token from JWT 
   *** RETURN      Access token
   */
   public static String getJWTAccessToken(String subject, String issuer, String audience, String certifName, String tokenEndpoint) {

       String accessToken;
       Auth.JWT jwt = new Auth.JWT();
       jwt.setIss(issuer);
       jwt.setSub(subject);
       jwt.setAud(audience);
       Auth.JWS jws = new Auth.JWS(jwt, certifName);

       if(!test.isRunningTest()){
           Auth.JWTBearerTokenExchange bearer = new Auth.JWTBearerTokenExchange(audience + tokenEndpoint, jws);
           accessToken = bearer.getAccessToken();
       }else{
            if(String.isNotBlank(subject)){
                accessToken = UserInfo.getOrganizationId()+'Test-SuccessTEBDJJFKJBKJBQCKBKCJQNLKCNLJCBHF';
            }else{
                accessToken = null;  
            }
       }
       return accessToken;
   }
}