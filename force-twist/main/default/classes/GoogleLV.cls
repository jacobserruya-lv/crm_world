/**
 * Description: custom authentication plug-in dedicated to Google Authentication Provider
 */
global without sharing class GoogleLV extends Auth.AuthProviderPluginClass {

    @TestVisible
    private String authProvider = 'GoogleLV';
    private String customMetadataTypeApiName = 'Auth_Provider__mdt';

    global String getCustomMetadataType() {
        return customMetadataTypeApiName;
    }

    global PageReference initiate(Map<String,String> authProviderConfiguration, String stateToPropagate) {

        System.debug('GOOGLE LV INITIATE');
        System.debug('STATE: ' + stateToPropagate);

        String authUrl = authProviderConfiguration.get('Authorize_Endpoint_URL__c');
        String callbackUrl = authProviderConfiguration.get('Callback_URL__c');

        String key = authProviderConfiguration.get('Consumer_Key__c');
        String scope = authProviderConfiguration.get('Scope__c');

        String url = authUrl +
            '?response_type=code' +
            '&client_id=' + key +
            '&redirect_uri=' + EncodingUtil.urlEncode(callbackUrl, 'UTF-8.') +
            ( !String.isEmpty(scope) ? '&scope=' + EncodingUtil.urlEncode(scope, 'UTF-8.') : '') +
            '&state=' + stateToPropagate;
        System.debug('url: ' + url);

        return new PageReference(url);
    }

    global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state ) {

        String key = authProviderConfiguration.get('Consumer_Key__c');
        String secret = authProviderConfiguration.get('Consumer_Secret__c');

        String accessTokenUrl = authProviderConfiguration.get('Token_Endpoint_URL__c');
        String callbackUrl = authProviderConfiguration.get('Callback_URL__c');

        Map<String,String> queryParams = state.queryParameters;
        String code = queryParams.get('code');
        String sfdcState = queryParams.get('state');

        String body = 'client_id=' + key +
          '&client_secret=' + secret +
          '&code=' + code +
          '&grant_type=authorization_code' +
          '&redirect_uri=' + callbackUrl;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(accessTokenUrl);
        req.setHeader('Content-Type','application/x-www-form-urlencoded');
        req.setMethod('POST');
        req.setBody(body);

        Http http = new Http();
        HTTPResponse res = http.send(req);

        String token = IDENTITY_AuthProvider.getTokenValue(res.getBody(), 'access_token');
        String id_token = IDENTITY_AuthProvider.getTokenValue(res.getBody(), 'id_token');

        System.debug('BODY: ' + res.getBody());
        System.debug('TOKEN: ' + token);
        System.debug('ID_TOKEN: ' + id_token);

        return new Auth.AuthProviderTokenResponse(authProvider, token, id_token, sfdcState);
    }

    global Auth.UserData getUserInfo(Map<string,string> authProviderConfiguration, Auth.AuthProviderTokenResponse response) {

        System.debug('getUserInfo()');
        String token = response.oauthToken;
        System.debug('token: ' + token);
        String id_token = response.oauthSecretOrRefreshToken;
        System.debug('id_token: ' + id_token);

        // GET ID TOKEN
        String payload_json;
        if(!String.isEmpty(id_token)){
            List<String> id_token_split = id_token.split('\\.');
            try{
                String payload_decoded = EncodingUtil.base64Decode(id_token_split[1]).toString();
                payload_json = EncodingUtil.urlDecode(payload_decoded, 'UTF-8');
            }
            catch(Exception ex){}
        }

        // GET USER DATA
        String userAPIUrl = authProviderConfiguration.get('User_Info_Endpoint_URL__c');

        HttpRequest req = new HttpRequest();
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setEndpoint(userAPIUrl);
        req.setMethod('GET');

        Http http = new Http();
        HTTPResponse res = http.send(req);
        System.debug('UserInfo: ' + res.getBody());

        Auth.UserData userData = IDENTITY_AuthProvider.getUserData(authProvider, res.getBody(), payload_json);
        System.debug('getUserInfo() returned value: ' + JSON.serialize(userData));
        return userData;
    }
}