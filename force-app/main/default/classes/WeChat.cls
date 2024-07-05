/**
    About
    -----
    Description: Auth Provider Flow for WECHAT
    Created for: Identity project
    Create date: Oct 2018

    Details
    -------
    Implement Oauth protocol 
*/
global without sharing class WeChat extends Auth.AuthProviderPluginClass {

	@TestVisible
	private String authProvider = 'WeChat';
	private String customMetadataTypeApiName = 'Auth_Provider__mdt';

	global String getCustomMetadataType() {
		return customMetadataTypeApiName;
	}

	global PageReference initiate(Map<String,String> authProviderConfiguration, String stateToPropagate) {

		String authUrl = authProviderConfiguration.get('Authorize_Endpoint_URL__c');
		String callbackUrl = authProviderConfiguration.get('Callback_URL__c');

		String key = authProviderConfiguration.get('Consumer_Key__c');
		String scope = authProviderConfiguration.get('Scope__c');

		String url = authUrl + 
			'?response_type=code' + 
			'&appid='+ key +
			'&redirect_uri=' + EncodingUtil.urlEncode(callbackUrl, 'UTF-8.') + 
			( !String.isEmpty(scope) ? '&scope=' + EncodingUtil.urlEncode(scope, 'UTF-8.') : '') +
			'&state=' + stateToPropagate + 
			'#wechat_redirect';

		return new PageReference(url); 
	} 

	global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state ) { 
		
		String key = authProviderConfiguration.get('Consumer_Key__c'); 
		String secret = authProviderConfiguration.get('Consumer_Secret__c'); 
		String accessTokenUrl = authProviderConfiguration.get('Token_Endpoint_URL__c');

		Map<String,String> queryParams = state.queryParameters;
		String code = queryParams.get('code');
		String sfdcState = queryParams.get('state');

		String body = 'appid=' + key +
			'&secret=' + secret +
			'&code=' + code +
			'&grant_type=authorization_code';
    
		HttpRequest req = new HttpRequest();
		req.setEndpoint(accessTokenUrl);
		req.setHeader('Content-Type','application/x-www-form-urlencoded');
		req.setMethod('POST');
		req.setBody(body);
		
		Http http = new Http();
		HTTPResponse res = http.send(req);

		String access_token = IDENTITY_AuthProvider.getTokenValue(res.getBody(), 'access_token');
		String openid = IDENTITY_AuthProvider.getTokenValue(res.getBody(), 'openid');
		
		System.debug('BODY: ' + res.getBody());
		System.debug('TOKEN: ' + access_token);
		System.debug('OPENID: ' + openid);

		return new Auth.AuthProviderTokenResponse(authProvider, access_token, openid, sfdcState);
	} 
	       
	global Auth.UserData getUserInfo(Map<String,String> authProviderConfiguration, Auth.AuthProviderTokenResponse response) { 

		String token = response.oauthToken;
		String openid = response.oauthSecretOrRefreshToken;

		String userAPIUrl = authProviderConfiguration.get('User_Info_Endpoint_URL__c');
		userAPIUrl += ('?access_token=' + token + '&openid=' + openid);

		HttpRequest req = new HttpRequest(); 
		req.setEndpoint(userAPIUrl); 
		req.setMethod('GET');

		Http http = new Http();
		HTTPResponse res = http.send(req);

		System.debug('UserInfo: ' + res.getBody());

		return IDENTITY_AuthProvider.getUserData(authProvider, res.getBody(), null);
	}

}