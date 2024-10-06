@isTest
private class Line_TEST {
    
    private static Line line = new Line();
    
    @isTest
    public static void test_getCustomMetadataType() {
        System.assertEquals('Auth_Provider__mdt', line.getCustomMetadataType(), 'error');
    }
    
    @isTest
    public static void test_initiate() {
        // Given
        Auth_Provider__mdt authProvider = [
            SELECT Authorize_Endpoint_URL__c, Callback_URL__c, Consumer_Key__c, Scope__c
            FROM Auth_Provider__mdt
            WHERE DeveloperName = :line.authProvider
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
        PageReference pageReference = line.initiate(authProviderConfiguration, stateToPropagate);
        Map<String,String> pageReferenceMap = pageReference.getParameters();
        String pageReferenceUrlDomain = pageReference.getUrl().split('\\?')[0];
        
        // Then
        System.assertEquals(authProviderConfiguration.get('Authorize_Endpoint_URL__c'), pageReferenceUrlDomain, 'error');
        System.assertEquals('code', pageReferenceMap.get('response_type'), 'error');
        System.assertEquals('normal', pageReferenceMap.get('bot_prompt'), 'error');
        System.assertEquals(authProviderConfiguration.get('Consumer_Key__c'), pageReferenceMap.get('client_id'), 'error');
        System.assertEquals(authProviderConfiguration.get('Callback_URL__c'), pageReferenceMap.get('redirect_uri'), 'error');
        System.assertEquals(authProviderConfiguration.get('Scope__c'), pageReferenceMap.get('scope'), 'error');
        System.assertEquals(stateToPropagate, pageReferenceMap.get('state'), 'error');
    }
    
    @isTest
        public static void test_handleCallback_success() {
        // Given
        String oauthToken = 'dummy-oauth-token';
        String oauthSecretOrRefreshToken = 'dummy-oauth-secret-or-refresh-token';

        HttpResponseMock mock = new HttpResponseMock().setBody(new Map<String,String> {
            'access_token' => oauthToken,
            'id_token' => oauthSecretOrRefreshToken
        });
        UnitTestsHelper.setSingleHttpMock(mock);

        Map<String,String> authProviderConfiguration = new Map<String,String> {
            'Consumer_Key__c' => '',
            'Consumer_Secret__c' => '',
            'Token_Endpoint_URL__c' => ''
        };
        Auth.AuthProviderCallbackState state = new Auth.AuthProviderCallbackState(new Map<String,String>(), '', new Map<String,String>());
        
        // When
        Auth.AuthProviderTokenResponse response = line.handleCallback(authProviderConfiguration, state);
        
        // Then
        System.assertEquals(line.authProvider, response.provider, 'error');
        System.assertEquals(oauthToken, response.oauthToken, 'error');
        System.assertEquals(oauthSecretOrRefreshToken, response.oauthSecretOrRefreshToken, 'error');
    }

    @isTest
    static void test_handleCallback_failure() {
        //Given
        Auth_Provider__mdt authProvider = [
            SELECT User_Info_Endpoint_URL__c, Consumer_Key__c, Consumer_Secret__c, Token_Endpoint_URL__c
            FROM Auth_Provider__mdt
            WHERE DeveloperName = :line.authProvider
            LIMIT 1
        ];
        String accessTokenUrl = authProvider.Token_Endpoint_URL__c;

        String dummyAccessToken = '12456789';
        
        UnitTestsHelper.setMultipleHttpMocks(new Map<String,HttpResponseMock> {
            accessTokenUrl => new HttpResponseMock().setStatusCode(503)
        });

        Map<String,String> authProviderConfiguration = new Map<String,String> {
            'Consumer_Key__c' => '',
            'Consumer_Secret__c' => '',
            'Token_Endpoint_URL__c' => authProvider.Token_Endpoint_URL__c
        };
        Auth.AuthProviderCallbackState state = new Auth.AuthProviderCallbackState(new Map<String,String>(), '', new Map<String,String>());
        
        // When
        Test.startTest();
        Auth.AuthProviderTokenResponse response = line.handleCallback(authProviderConfiguration, state);
        
        Test.stopTest();

        // Then
        //System.assertEquals(dummyAccessToken, line.customLogsAccessToken, 'ERROR');
    }

    @isTest
    public static void test_getUserInfo() {
        // Given
        String identifier = 'dummy-identifier';
        String userName = 'dummy-user-name';
        String email = 'dummy-email';
        
        HttpResponseMock mock = new HttpResponseMock().setBody(new Map<String,String> {
            'userId' => identifier,
            'displayName' => userName,
            'email' => email
        });
        UnitTestsHelper.setSingleHttpMock(mock);
        
        Auth.UserData expectedUserInfo = new Auth.UserData(
            identifier, // identifier
            null, // firstName
            null, // lastName
            null, // fullName
            email, // email
            null, // link
            userName, // userName
            null, // locale
            line.authProvider, // provider
            null, // siteLoginUrl
            new Map<String,String>() // attributeMap
        );
        
        // When
        Auth.UserData userInfo = line.getUserInfo(
            new Map<String,String> { 'User_Info_Endpoint_URL__c' => 'dummy-url' },
            new Auth.AuthProviderTokenResponse(
                line.authProvider,
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

    @isTest
    static void test_isFailureResponse() {
        // Given
        HttpResponse responseSuccess1 = new HttpResponse();
        responseSuccess1.setStatusCode(200);
        HttpResponse responseSuccess2 = new HttpResponse();
        responseSuccess2.setStatusCode(201);
        HttpResponse responseFailure1 = new HttpResponse();
        responseFailure1.setStatusCode(300);
        HttpResponse responseFailure2 = new HttpResponse();
        responseFailure2.setStatusCode(400);
        HttpResponse responseFailure3 = new HttpResponse();
        responseFailure3.setStatusCode(500);

        // Then
        UnitTestsHelper.assertFalse(Line.isFailureResponse(responseSuccess1));
        UnitTestsHelper.assertFalse(Line.isFailureResponse(responseSuccess2));
        UnitTestsHelper.assertTrue(Line.isFailureResponse(responseFailure1));
        UnitTestsHelper.assertTrue(Line.isFailureResponse(responseFailure2));
        UnitTestsHelper.assertTrue(Line.isFailureResponse(responseFailure3));
    }
    
    @isTest
    static void test_writeCustomLogs() {
        HttpResponse failedResponse = new HttpResponse();
        line.writeCustomLog(failedResponse, 'method');
    }
    

}