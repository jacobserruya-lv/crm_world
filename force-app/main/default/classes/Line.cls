/**
    About
    -----
    Description: Auth Provider Flow for LINE
    Created for: Identity project
    Create date: Oct 2018

    Details
    -------
    Implement Oauth protocol 
*/
global without sharing class Line extends Auth.AuthProviderPluginClass {
  
    @TestVisible
    private String authProvider = 'Line';
    private String customMetadataTypeApiName = 'Auth_Provider__mdt';
    
    @TestVisible
    private String customLogsAccessToken;

    global String getCustomMetadataType() {
        return customMetadataTypeApiName;
    }

    global PageReference initiate(Map<String,String> authProviderConfiguration, String stateToPropagate) {

        System.debug('LINE INITIATE');
        System.debug('STATE: ' + stateToPropagate);

        String authUrl = authProviderConfiguration.get('Authorize_Endpoint_URL__c');
        String callbackUrl = authProviderConfiguration.get('Callback_URL__c');

        String key = authProviderConfiguration.get('Consumer_Key__c');
        String scope = authProviderConfiguration.get('Scope__c');

        String url = authUrl + 
            '?response_type=code' + 
            '&client_id='+ key +
            '&redirect_uri=' + EncodingUtil.urlEncode(callbackUrl, 'UTF-8.') + 
            ( !String.isEmpty(scope) ? '&scope=' + EncodingUtil.urlEncode(scope, 'UTF-8.') : '') +
            '&state=' + stateToPropagate +
            '&bot_prompt=normal';  
        
        System.debug('url: ' + url);
        return new PageReference(url); 
    }
    

    global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state ) { 
        System.debug('>>> LINE CALLBACK');

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
        
        
        if (isFailureResponse(res)) {
            insertCustomLogsViaHttpRequest(res, 'handleCallback');
            if (Test.isRunningTest()) {
                return null; // No need to test further in this methode when isFailureResponse(res) is true
            }
        }

        
        String token = IDENTITY_AuthProvider.getTokenValue(res.getBody(), 'access_token');
        String id_token = IDENTITY_AuthProvider.getTokenValue(res.getBody(), 'id_token');

        System.debug('BODY: ' + res.getBody());
        System.debug('TOKEN: ' + token);
        System.debug('ID_TOKEN: ' + id_token);

        return new Auth.AuthProviderTokenResponse(authProvider, token, id_token, sfdcState); 
    }
    

    global Auth.UserData getUserInfo(Map<string,string> authProviderConfiguration, Auth.AuthProviderTokenResponse response) { 
        
        System.debug('LINE USER INFO');

        String token = response.oauthToken;
        String id_token = response.oauthSecretOrRefreshToken;

        // GET ID TOKEN 
        String payload_json;
        if(!String.isEmpty(id_token)){
            List<String> id_token_split = id_token.split('\\.');

            try{
                String payload_decoded = EncodingUtil.base64Decode( id_token_split[1] ).toString();
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

        if (isFailureResponse(res)) {
            insertCustomLogsViaHttpRequest(res, 'getUserInfo');
            if (Test.isRunningTest()) {
                return null; // No need to test further in this methode when isFailureResponse(res) is true
            }
        }

        return IDENTITY_AuthProvider.getUserData(authProvider, res.getBody(), payload_json);
    }
    
    private void insertCustomLogsViaHttpRequest(HTTPResponse httpResponse, String methodName) {
        System.debug('>>> call to insertCustomLogsViaHttpRequest()');
        try {
            if (String.isEmpty(this.customLogsAccessToken)) {
                this.getSalesforceAccessToken();
            }
			this.writeCustomLog(httpResponse, methodName);
        }
        catch(Exception e) {
            System.debug('>>> exception:  ' + e.getMessage());
        }
    }
    
    private void getSalesforceAccessToken() {
        System.debug('>>> call to getSalesforceAccessToken()');

        User TechBatchUser = [SELECT Username FROM User WHERE Name = 'Batch Tech' LIMIT 1][0];
        String username = TechBatchUser.Username;
            System.debug('>>> myresponse()'+username); 
        this.customLogsAccessToken = IDENTITY_Utils.getJWTAccessToken(username);
       // System.debug('mytoken1:'+this.customLogsAccessToken.SubString(15));
    }
    
    @TestVisible
    private void writeCustomLog(HttpResponse failedResponse, String methodName) {
        System.debug('>>> call to writeCustomLog()');
        
        String endpoint = IDENTITY_Settings__c.getInstance().Community_URL__c + '/services/data/v53.0/sobjects/Logs__c/';
        System.debug('>>> endpoint: ' + endpoint);
        
        
        Map<String,Object> failedResponseHeadersMap = new Map<String,Object>();
        for (String key: failedResponse.getHeaderKeys()) {
            if (!String.isEmpty(key)) {
                failedResponseHeadersMap.put(key, failedResponse.getHeader(key));
            }
        }
        System.debug('>>> failedResponseHeadersMap: ' + JSON.serializePretty(failedResponseHeadersMap));

        Map<String,Object> logsMap = new Map<String,Object> {
            'Level__c' => 'DEBUG',
            'Apex_Class__c' => this.authProvider,
            'Category__c' => 'APEX CODE',
            'Message__c' => 'HTTP request called from method ' + methodName + '() failed!',
            'Status_Code__c' => failedResponse.getStatusCode(),
            'Other_Details__c' => JSON.serialize(new Map<String,Object> {
                'status' => failedResponse.getStatus(),
                'statusCode' => failedResponse.getStatusCode(),
                'headers' => failedResponseHeadersMap,
                'body' => failedResponse.getBody()
            })
        };
		System.debug('>>> logsMap ' + JSON.serializePretty(logsMap));
        
        callHttpRequestForCustomLogs(endpoint, this.customLogsAccessToken, JSON.serialize(logsMap));
    }
    
    global static void callHttpRequestForCustomLogs(String endpoint, String token, String logsJson) {
        new HTTP_Utils()
            .post(endpoint)
            .header('Authorization', 'Bearer ' + token)
            .header('Content-Type', 'application/json')
            .body(logsJson)
            .call();
    }    

    @TestVisible
    private Boolean isFailureResponse(HttpResponse response) {
        return (response.getStatusCode() != 200 && response.getStatusCode() != 201);
    }
    
    
    
}