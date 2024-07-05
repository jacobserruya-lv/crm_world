@isTest
private class Kakao_TEST {
    
    private static Kakao kakao = new Kakao();
    public static  Auth_Provider__mdt authProvider = [
        SELECT User_Info_Endpoint_URL__c, Shipping_Address_Endpoint_URL__c, Channels_Info_Endpoint_URL__c, Kakao_Channel_Id__c,Token_Endpoint_URL__c,Service_Terms_Endpoint_URL__c
        FROM Auth_Provider__mdt
        WHERE DeveloperName = :kakao.authProvider
        LIMIT 1
    ];
    public static Map<String,String> authProviderConfiguration = new Map<String,String> {
        'User_Info_Endpoint_URL__c' => authProvider.User_Info_Endpoint_URL__c,
            'Shipping_Address_Endpoint_URL__c' => authProvider.Shipping_Address_Endpoint_URL__c,
            'Channels_Info_Endpoint_URL__c' => authProvider.Channels_Info_Endpoint_URL__c,
            'Service_Terms_Endpoint_URL__c' => authProvider.Service_Terms_Endpoint_URL__c
            };
                
    public static Map<String, Object> userInfoMap = new Map<String, Object> {
        'sub' => '12345',
            'name' => 'John Doe',
            'nickname' => 'johndoe123',
            'picture' => 'https://example.com/profile.jpg',
            'email' => 'johndoe@example.com',
            'email_verified' => true,
            'gender' => 'Male',
            'birthdate' => '1990-05-15',
            'phone_number' => '+1234567890',
            'phone_number_verified' => true,
            'birthdate_day' => '15',
            'birthdate_month' => '05',
            'birthdate_year' => '1990',
            'fullName' => 'John Doe',
            'firstName' => 'John',
            'lastName' => 'Doe',
            'channel_opted_in' => true,
            'connected_at' => '2023-09-18',
            'base_address' => '123 Main Street',
            'detail_address' => 'Apt 4B',
            'zone_number' => 'Z123',
            'zip_code' => '12345'
            };
                            
       public static Map<String, Object> shippingAddressWrapperMap = new Map<String, Object> {
           'user_id' => 12345,
           'shipping_addresses' => new List<Map<String, Object>> {
            new Map<String, Object> {
                'id' => 1,
                    'name' => 'Home',
                    'is_default' => true,
                    'updated_at' => 1631971200,
                    'type' => 'Residential',
                    'base_address' => '456 Elm Street',
                    'detail_address' => 'Unit 3C',
                    'receiver_name' => 'John Doe',
                    'receiver_phone_number1' => '+1234567890',
                    'receiver_phone_number2' => '+9876543210',
                    'zone_number' => 'Z456',
                    'zip_code' => '67890'
                    },
            new Map<String, Object> {
                'id' => 2,
                    'name' => 'Work',
                    'is_default' => false,
                    'updated_at' => 1631971200,
                    'type' => 'Commercial',
                    'base_address' => '789 Oak Avenue',
                    'detail_address' => 'Suite 101',
                    'receiver_name' => 'Jane Smith',
                    'receiver_phone_number1' => '+1111111111',
                    'receiver_phone_number2' => '+2222222222',
                    'zone_number' => 'Z789',
                    'zip_code' => '54321'
                    }
               },
           'shipping_addresses_needs_agreement' => true
       };
                                
           public static Map<String, Object> channelsInfoWrapperMap = new Map<String, Object> {
               'user_id' => 12345,
               'channels' => new List<Map<String, Object>> {
                   new Map<String, Object> {
                       'channel_uuid' => 'uuid1',
                           'channel_public_id' => 'public_id1',
                           'relation' => 'subscriber',
                           'created_at' => Datetime.now(),
                           'updated_at' => Datetime.now()
                           },
                   new Map<String, Object> {
                          'channel_uuid' => 'uuid2',
                           'channel_public_id' => 'public_id2',
                           'relation' => 'follower',
                           'created_at' => Datetime.now(),
                           'updated_at' => Datetime.now()
                           }
                 }
           };
           public static Map<String, Object> serviceTermsMap = new Map<String, Object> {
               'id' => 12345,
               'service_terms' => new List<Map<String, Object>> {
                   new Map<String, Object> {
                       'tag' => 'newsletter_terms',
                           'required' => true,
                           'agreed' => true,
                           'revocable' => false,
                           'agreed_at' => '2023-09-21'
                           }
               }
           };
                                                
    @isTest
    public static void test_getCustomMetadataType() {
      System.assertEquals('Auth_Provider__mdt', kakao.getCustomMetadataType(), 'error');
    }
    
    @isTest
    public static void test_initiate() {
        // Given
        Auth_Provider__mdt authProvider = [
            SELECT Authorize_Endpoint_URL__c, Callback_URL__c, Consumer_Key__c, Scope__c
            FROM Auth_Provider__mdt
            WHERE DeveloperName = :kakao.authProvider
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
        PageReference pageReference = kakao.initiate(authProviderConfiguration, stateToPropagate);
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
        
        HttpResponseMock mock = new HttpResponseMock().setBody(new Map<String,String> { 'access_token' => oauthToken });
        UnitTestsHelper.setSingleHttpMock(mock);
        
        Map<String,String> authProviderConfiguration = new Map<String,String> {
            'Consumer_Key__c' => '',
                'Consumer_Secret__c' => '',
                'Token_Endpoint_URL__c' => ''
                };
                    Auth.AuthProviderCallbackState state = new Auth.AuthProviderCallbackState(new Map<String,String>(), '', new Map<String,String>());
        
        // When
        Auth.AuthProviderTokenResponse response = kakao.handleCallback(authProviderConfiguration, state);
        
        // Then
        System.assertEquals(kakao.authProvider, response.provider, 'error');
        System.assertEquals(oauthToken, response.oauthToken, 'error');
    }
    
    @isTest
    public static void test_getUserInfo() {
        HttpResponseMock mockUserInfoResponse  = new HttpResponseMock().setBody(userInfoMap);
        HttpResponseMock mockShippingAddressResponse   = new HttpResponseMock().setBody(shippingAddressWrapperMap);
        HttpResponseMock mockChannelsInfoResponse   = new HttpResponseMock().setBody(channelsInfoWrapperMap);
        HttpResponseMock serviceTermsMapResponse   = new HttpResponseMock().setBody(serviceTermsMap);
        String channelId = authProviderConfiguration.get('Kakao_Channel_Id__c'); 
        UnitTestsHelper.setMultipleHttpMocks(new Map<String,HttpResponseMock> {
            authProviderConfiguration.get('User_Info_Endpoint_URL__c') => mockUserInfoResponse.setStatusCode(200),
                authProviderConfiguration.get('Shipping_Address_Endpoint_URL__c') => mockShippingAddressResponse.setStatusCode(200),
                authProviderConfiguration.get('Channels_Info_Endpoint_URL__c') +'?channel_public_ids=' + EncodingUtil.urlEncode('["' + channelId + '"]', 'UTF-8') => mockChannelsInfoResponse.setStatusCode(200),
                 authProviderConfiguration.get('Service_Terms_Endpoint_URL__c') + '?result=app_service_terms' => serviceTermsMapResponse.setStatusCode(200)
                });
        
        Test.startTest();
        // When
        Auth.UserData userInfo = kakao.getUserInfo(
            authProviderConfiguration,
            new Auth.AuthProviderTokenResponse(
                kakao.authProvider,
                'dummy-oauthToken',
                'dummy-oauthSecretOrRefreshToken',
                'dummy-state'
            )
        );
        Test.stopTest();
    }
    @isTest
    public static void test_getUserInfoFailed() {
        //Given
        Auth_Provider__mdt authProvider = [
            SELECT User_Info_Endpoint_URL__c, Consumer_Key__c, Consumer_Secret__c, Token_Endpoint_URL__c
            FROM Auth_Provider__mdt
            WHERE DeveloperName = :kakao.authProvider
            LIMIT 1
        ];
        String accessTokenUrl = authProvider.Token_Endpoint_URL__c;

        
        UnitTestsHelper.setMultipleHttpMocks(new Map<String,HttpResponseMock> {
            authProviderConfiguration.get('User_Info_Endpoint_URL__c') =>  new HttpResponseMock().setStatusCode(503),       
            accessTokenUrl => new HttpResponseMock().setStatusCode(503)
        });

        Auth.AuthProviderCallbackState state = new Auth.AuthProviderCallbackState(new Map<String,String>(), '', new Map<String,String>());
        
        // When
        Test.startTest();
        Auth.UserData userInfo = kakao.getUserInfo(
            authProviderConfiguration,
            new Auth.AuthProviderTokenResponse(
                kakao.authProvider,
                'dummy-oauthToken',
                'dummy-oauthSecretOrRefreshToken',
                'dummy-state'
            )
        );
        Test.stopTest();
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
        UnitTestsHelper.assertFalse(kakao.isFailureResponse(responseSuccess1));
        UnitTestsHelper.assertFalse(kakao.isFailureResponse(responseSuccess2));
        UnitTestsHelper.assertTrue(kakao.isFailureResponse(responseFailure1));
        UnitTestsHelper.assertTrue(kakao.isFailureResponse(responseFailure2));
        UnitTestsHelper.assertTrue(kakao.isFailureResponse(responseFailure3));
    }
    
    @isTest
    static void test_writeCustomLogs() {
        HttpResponse failedResponse = new HttpResponse();
        kakao.writeCustomLog(failedResponse, 'method');
    }
    
}