@isTest
private class GoogleLV_TEST {

    private static GoogleLV googleLV = new GoogleLV();

    @isTest
    public static void test_getCustomMetadataType() {
        System.assertEquals('Auth_Provider__mdt', googleLV.getCustomMetadataType(), 'error');
    }

    @isTest
    public static void test_initiate() {
        // Given
        Auth_Provider__mdt authProvider = [
        SELECT Authorize_Endpoint_URL__c, Callback_URL__c, Consumer_Key__c, Scope__c
        FROM Auth_Provider__mdt
        WHERE DeveloperName = :googleLV.authProvider
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
        PageReference pageReference = googleLV.initiate(authProviderConfiguration, stateToPropagate);
        Map<String,String> pageReferenceMap = pageReference.getParameters();
        String pageReferenceUrlDomain = pageReference.getUrl().split('\\?')[0];

        // Then
        System.assertEquals(authProviderConfiguration.get('Authorize_Endpoint_URL__c'), pageReferenceUrlDomain, 'error');
        System.assertEquals('code', pageReferenceMap.get('response_type'), 'error');
        System.assertEquals(authProviderConfiguration.get('Consumer_Key__c'), pageReferenceMap.get('client_id'), 'error');
        System.assertEquals(authProviderConfiguration.get('Callback_URL__c'), pageReferenceMap.get('redirect_uri'), 'error');
        System.assertEquals(authProviderConfiguration.get('Scope__c'), pageReferenceMap.get('scope'), 'error');
        System.assertEquals(stateToPropagate, pageReferenceMap.get('state'), 'error');
    }

    @isTest
    public static void test_handleCallback() {
        // Given
        String oauthToken = 'dummy-oauth-token';
        String oauthSecretOrRefreshToken = 'dummy-oauth-secret-or-refresh-token';

        HttpResponseMock mock = new HttpResponseMock().setBody(new Map<String,String> { 'access_token' => oauthToken, 'id_token' => oauthSecretOrRefreshToken });
        UnitTestsHelper.setSingleHttpMock(mock);

        Map<String,String> authProviderConfiguration = new Map<String,String> {
            'Consumer_Key__c' => '',
            'Consumer_Secret__c' => '',
            'Token_Endpoint_URL__c' => ''
        };
        Auth.AuthProviderCallbackState state = new Auth.AuthProviderCallbackState(new Map<String,String>(), '', new Map<String,String>());

        // When
        Auth.AuthProviderTokenResponse response = googleLV.handleCallback(authProviderConfiguration, state);

        // Then
        System.assertEquals(googleLV.authProvider, response.provider, 'error');
        System.assertEquals(oauthToken, response.oauthToken, 'error');
        System.assertEquals(oauthSecretOrRefreshToken, response.oauthSecretOrRefreshToken, 'error');
    }

    @isTest
    public static void test_getUserInfo() {
        // Given
        String identifier = 'dummy-identifier';
        String userName = 'dummy-user-name';
        String email = 'dummy-email';

        Test.startTest();
        UnitTestsHelper.setSingleHttpMock(new HttpResponseMock());
        Test.stopTest();

        Auth.UserData expectedUserInfo = new Auth.UserData(
            identifier, // identifier
            null, // firstName
            null, // lastName
            userName, // fullName
            email, // email
            null, // link
            userName, // userName
            null, // locale
            googleLV.authProvider, // provider
            null, // siteLoginUrl
            new Map<String,String>() // attributeMap
        );

        String payload = JSON.serialize(new Map<String,String> {
            'sub' => identifier,
            'name' => userName,
            'email' => email
        });
        String dummyOauthSecretOrRefreshToken = 'dummy-value.' + EncodingUtil.base64Encode(Blob.valueOf(EncodingUtil.urlEncode(payload, 'UTF-8')));

        // When
        Auth.UserData userInfo = googleLV.getUserInfo(
            new Map<String,String> { 'User_Info_Endpoint_URL__c' => 'dummy-url' },
            new Auth.AuthProviderTokenResponse(
                googleLV.authProvider,
                'dummy-oauthToken',
                dummyOauthSecretOrRefreshToken,
                'dummy-state'
            )
        );

        // Then
        System.assertEquals(expectedUserInfo.attributeMap, userInfo.attributeMap, 'err');
        System.assertEquals(expectedUserInfo.firstName, userInfo.firstName, 'err');
        System.assertEquals(expectedUserInfo.identifier, userInfo.identifier, 'err');
        System.assertEquals(expectedUserInfo.lastName, userInfo.lastName, 'err');
        System.assertEquals(expectedUserInfo.link, userInfo.link, 'err');
        System.assertEquals(expectedUserInfo.locale, userInfo.locale, 'err');
        System.assertEquals(expectedUserInfo.provider, userInfo.provider, 'err');
        System.assertEquals(expectedUserInfo.siteLoginUrl, userInfo.siteLoginUrl, 'err');
    }

}