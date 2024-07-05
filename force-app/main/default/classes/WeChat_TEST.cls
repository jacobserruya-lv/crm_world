@isTest
private class WeChat_TEST {
    
    private static WeChat weChat = new WeChat();
    
    @isTest
    public static void test_getCustomMetadataType() {
        System.assertEquals('Auth_Provider__mdt', weChat.getCustomMetadataType(), 'error');
    }
    
    @isTest
    public static void test_initiate() {
        // Given
        Auth_Provider__mdt authProvider = [
        SELECT Authorize_Endpoint_URL__c, Callback_URL__c, Consumer_Key__c, Scope__c
        FROM Auth_Provider__mdt
        WHERE DeveloperName = :weChat.authProvider
        LIMIT 1
        ];
        Map<String,String> authProviderConfiguration = new Map<String,String> {
            'Authorize_Endpoint_URL__c' => authProvider.Authorize_Endpoint_URL__c,
            'Callback_URL__c' => authProvider.Callback_URL__c,
            'Consumer_Key__c' => authProvider.Consumer_Key__c,
            'Scope__c' => authProvider.Scope__c
        };
        String stateToPropagate = 'dummy-state';
        
        // When
        PageReference pageReference = weChat.initiate(authProviderConfiguration, stateToPropagate);
        Map<String,String> pageReferenceMap = pageReference.getParameters();
        String pageReferenceUrlDomain = pageReference.getUrl().split('\\?')[0];
        
        // Then
        System.assertEquals(authProviderConfiguration.get('Authorize_Endpoint_URL__c'), pageReferenceUrlDomain, 'error');
        System.assertEquals('code', pageReferenceMap.get('response_type'), 'error');
        System.assertEquals(authProviderConfiguration.get('Consumer_Key__c'), pageReferenceMap.get('appid'), 'error');
        System.assertEquals(authProviderConfiguration.get('Callback_URL__c'), pageReferenceMap.get('redirect_uri'), 'error');
        System.assertEquals(authProviderConfiguration.get('Scope__c'), pageReferenceMap.get('scope'), 'error');
        System.assertEquals(stateToPropagate, pageReferenceMap.get('state'), 'error');
        System.assertEquals('wechat_redirect', pageReference.getAnchor(), 'error');
    }
    
    @isTest
    public static void test_handleCallback() {
        // Given
        String oauthToken = 'dummy-oauth-token';
        String oauthSecretOrRefreshToken = 'dummy-oauth-secret-or-refreshToken';

        HttpResponseMock mock = new HttpResponseMock().setBody(new Map<String,String> {
            'access_token' => oauthToken,
            'openid' => oauthSecretOrRefreshToken
        });
        UnitTestsHelper.setSingleHttpMock(mock);

        Map<String,String> authProviderConfiguration = new Map<String,String> {
            'Consumer_Key__c' => '',
            'Consumer_Secret__c' => '',
            'Token_Endpoint_URL__c' => ''
        };
        Auth.AuthProviderCallbackState state = new Auth.AuthProviderCallbackState(new Map<String,String>(), '', new Map<String,String>());
        
        // When
        Auth.AuthProviderTokenResponse response = weChat.handleCallback(authProviderConfiguration, state);
        
        // Then
        System.assertEquals(weChat.authProvider, response.provider, 'error');
        System.assertEquals(oauthToken, response.oauthToken, 'error');
        System.assertEquals(oauthSecretOrRefreshToken, response.oauthSecretOrRefreshToken, 'error');
    }

    @isTest
    public static void test_getUserInfo() {
        // Given
        String identifier = 'dummy-identifier';
        String userName = 'dummy-user-name';
        String locale = 'dummy-locale';
        
        // As a reminder: SELECT Field__c, Is_Standard__c, Value__c FROM IDENTITY_AuthProvider_Mapping__mdt WHERE AuthProvider__c = 'WeChat'
        HttpResponseMock mock = new HttpResponseMock().setBody(new Map<String,String> {
            'unionid' => identifier,
            'nickname' => userName,
            'country' => locale
        });
        UnitTestsHelper.setSingleHttpMock(mock);
        
        Auth.UserData expectedUserInfo = new Auth.UserData(
            identifier, // identifier
            null, // firstName
            null, // lastName
            null, // fullName
            null, // email
            null, // link
            userName, // userName
            locale, // locale
            weChat.authProvider, // provider
            null, // siteLoginUrl
            new Map<String,String>() // attributeMap
        );
        
        // When
        Auth.UserData userInfo = weChat.getUserInfo(
            new Map<String,String> { 'User_Info_Endpoint_URL__c' => 'dummy-url' },
            new Auth.AuthProviderTokenResponse(
                weChat.authProvider,
                'dummy-oauthToken',
                'dummy-oauthSecretOrRefreshToken',
                'dummy-state'
            )
        );
        
        // Then
        System.assertEquals(expectedUserInfo.attributeMap, userInfo.attributeMap, 'err');
        System.assertEquals(expectedUserInfo.firstName, userInfo.firstName, 'err');
        System.assertEquals(expectedUserInfo.fullName, userInfo.fullName, 'err');
        System.assertEquals(expectedUserInfo.identifier, userInfo.identifier, 'err');
        System.assertEquals(expectedUserInfo.lastName, userInfo.lastName, 'err');
        System.assertEquals(expectedUserInfo.link, userInfo.link, 'err');
        System.assertEquals(expectedUserInfo.locale, userInfo.locale, 'err');
        System.assertEquals(expectedUserInfo.provider, userInfo.provider, 'err');
        System.assertEquals(expectedUserInfo.siteLoginUrl, userInfo.siteLoginUrl, 'err');
        System.assertEquals(expectedUserInfo.username, userInfo.username, 'err');
    }
    
}