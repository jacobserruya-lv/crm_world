/**
    About
    -----
    Description: Auth Provider Flow for KakaoTalk then updated for KakoSync
    Created for: Identity project
    Create date: Feb 2019
    Update date: Nov 2023

    Details
    -------
    Implement Oauth protocol 
*/
global without sharing class Kakao extends Auth.AuthProviderPluginClass {
  
    @TestVisible 
    private String authProvider = 'Kakao';
    private String customMetadataTypeApiName = 'Auth_Provider__mdt';

    class CustomException extends Exception {}
    
    @TestVisible
    private String customLogsAccessToken;

    global String getCustomMetadataType() {
        return customMetadataTypeApiName;
    }

    global PageReference initiate(Map<String,String> authProviderConfiguration, String stateToPropagate) {
 		System.debug('KAKAO INITIATE');
        String authUrl = authProviderConfiguration.get('Authorize_Endpoint_URL__c');
        String callbackUrl = authProviderConfiguration.get('Callback_URL__c');

        String key = authProviderConfiguration.get('Consumer_Key__c');
        String scope = authProviderConfiguration.get('Scope__c');

        String url = authUrl + 
            '?response_type=code' + 
            '&client_id='+ key +
            '&redirect_uri=' + EncodingUtil.urlEncode(callbackUrl, 'UTF-8.') + 
            ( !String.isEmpty(scope) ? '&scope=' + EncodingUtil.urlEncode(scope, 'UTF-8.') : '') +
            '&state=' + stateToPropagate;

        return new PageReference(url);
    } 

    global Auth.AuthProviderTokenResponse handleCallback(Map<string,string> authProviderConfiguration, Auth.AuthProviderCallbackState state ) { 
        System.debug('>>> KAKAO CALLBACK');
        String key = authProviderConfiguration.get('Consumer_Key__c'); 
        String secret = authProviderConfiguration.get('Consumer_Secret__c'); 

        String accessTokenUrl = authProviderConfiguration.get('Token_Endpoint_URL__c');
        String callbackUrl = authProviderConfiguration.get('Callback_URL__c');

        Map<String,String> queryParams = state.queryParameters; 
        String code = queryParams.get('code'); 
        String sfdcState = queryParams.get('state');

        accessTokenUrl = accessTokenUrl + '?client_id=' + key + 
          '&client_secret=' + secret +
          '&code=' + code + 
          '&grant_type=authorization_code' + 
          '&redirect_uri=' + callbackUrl;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(accessTokenUrl); 
        req.setMethod('POST');

        Http http = new Http(); 
        HTTPResponse res = http.send(req);
        
        if (isFailureResponse(res)) {
            insertCustomLogsViaHttpRequest(res, 'handleCallback');
            if (Test.isRunningTest()) {
                return null; // No need to test further in this methode when isFailureResponse(res) is true
            }
        }

        String token = IDENTITY_AuthProvider.getTokenValue(res.getBody(), 'access_token');

        return new Auth.AuthProviderTokenResponse(authProvider, token, '', sfdcState); 
    }

    global Auth.UserData getUserInfo(Map<string,string> authProviderConfiguration, Auth.AuthProviderTokenResponse response) { 
        // TODO: Update Auth_Provider__mdt as follows:
        //      1. Change the User_Info_Endpoint_URL__c to OpenID Connect user info endpoint [ https://kapi.kakao.com/v1/oidc/userinfo ]
        //      2. Add new fields:
        //              (1) Shipping_Address_Endpoint_URL__c [ https://kapi.kakao.com/v1/user/shipping_address ]
        //              (2) Add Channels_Info_Endpoint_URL__c [ https://kapi.kakao.com/v1/api/talk/channels ]
        //              (3) Add Kakao_Channel_Id__c [ _ABCdef ] --> channel Id of LV Kakao Channel
        //              (4) Add Service_Terms_Endpoint_URL__c [ https://kapi.kakao.com/v2/user/service_terms ]
        String token = response.oauthToken;
        String userInfoUrl = authProviderConfiguration.get('User_Info_Endpoint_URL__c');
        String shippingAddressUrl = authProviderConfiguration.get('Shipping_Address_Endpoint_URL__c');
        String channelsInfoUrl = authProviderConfiguration.get('Channels_Info_Endpoint_URL__c');
        String channelId = authProviderConfiguration.get('Kakao_Channel_Id__c');
        String serviceTermsUrl = authProviderConfiguration.get('Service_Terms_Endpoint_URL__c');
        
        // GET USER INFO
        HttpRequest req = new HttpRequest(); 
        req.setHeader('Authorization', 'Bearer ' + token);
        req.setEndpoint(userInfoUrl);
        req.setMethod('GET');
        
        Http http = new Http(); 
        HTTPResponse res = http.send(req);
        
        // in case of error code, this function will provide an empty UserInfo
        UserInfoWrapper userInfo = new UserInfoWrapper();
        if (!isFailureResponse(res)) {
            userInfo = (UserInfoWrapper) JSON.deserialize(res.getBody(), UserInfoWrapper.class);
            userInfo.splitFullName();
            
            // GET DEFAULT SHIPPING ADDRESS
            req.setEndpoint(shippingAddressUrl);
            res = http.send(req);
            if(!isFailureResponse(res)) {
                ShippingAddressWrapper addressInfo = (ShippingAddressWrapper) JSON.deserialize(res.getBody(), ShippingAddressWrapper.class);
                List<ShippingAddress> addresses = addressInfo.shipping_addresses;
                
                if(addresses != null && !addresses.isEmpty()) {
                    for(ShippingAddress addr : addresses) {
                        if(addr.is_default) {
                            userInfo.setAddress(addr);
                            break;
                        }
                    }
                }
            } 
            else{
                insertCustomLogsViaHttpRequest(res, 'getShippingAddress');
                if (Test.isRunningTest()) {
                    return null; // No need to test further in this methode when isFailureResponse(res) is true
                }
            }
            
            // GET CHANNEL SUBSCRIPTION STATUS
            String channelParams = '?channel_public_ids=' + EncodingUtil.urlEncode('["' + channelId + '"]', 'UTF-8');
            req.setEndpoint(channelsInfoUrl + channelParams);
            res = http.send(req);
            
            if (!isFailureResponse(res)) {
                ChannelsInfoWrapper channelsInfo = (ChannelsInfoWrapper) JSON.deserialize(res.getBody(), ChannelsInfoWrapper.class);
                
                if(channelsInfo.channels != null && !channelsInfo.channels.isEmpty()) {
                    userInfo.setChannelSubscription(channelsInfo.channels.get(0));
                }
            } 
            else{
                insertCustomLogsViaHttpRequest(res, 'channelsInfo');
                if (Test.isRunningTest()) {
                    return null; // No need to test further in this methode when isFailureResponse(res) is true
                }
            }
            
            // GET SERVICE TERMS CONSENT (NEWSLETTER TERMS)
            String serviceTermsParams = '?result=app_service_terms';
            req.setEndpoint(serviceTermsUrl + serviceTermsParams);
            res = http.send(req);
            
            if (!isFailureResponse(res)) {
                ServiceTermsWrapper serviceTermsWrapper = (ServiceTermsWrapper) JSON.deserialize(res.getBody(), ServiceTermsWrapper.class);
                List<ServiceTerm> serviceTerms = serviceTermsWrapper.service_terms;
                if (!serviceTerms.isEmpty()) {
                    userInfo.setNewsletterTerms(serviceTerms);
                    if(checkPersonDataAddTerms(serviceTerms)){
                        userInfo.splitBirthdate();
                    }
                }
            }
            else{
                insertCustomLogsViaHttpRequest(res, 'serviceTerms');
                if (Test.isRunningTest()) {
                    return null; // No need to test further in this methode when isFailureResponse(res) is true
                }
            }
            
        } 
        else {
            insertCustomLogsViaHttpRequest(res, 'getUserInfo');
            if (Test.isRunningTest()) {
                return null; // No need to test further in this methode when isFailureResponse(res) is true
            }
        }
        
        String serializedUserInfo = JSON.serialize(userInfo);
        system.debug('KAKAO serializedUserInfo : '+ serializedUserInfo);
        return IDENTITY_AuthProvider.getUserData(authProvider, serializedUserInfo, null);
    }
    
        public Boolean checkPersonDataAddTerms(List<ServiceTerm> serviceTerms) {
        Boolean persondata_add_terms = false;
        for (ServiceTerm serviceTerm : serviceTerms) {
            if (serviceTerm.tag.toLowerCase() == 'personal_additional_info_terms') {
                persondata_add_terms =  serviceTerm.agreed;
                break;
            }
        }
        return persondata_add_terms;
    }


    /***************************\
              WRAPPERS 
    \***************************/

    // User Info
    private class UserInfoWrapper {
        // Fields from Kakao
        public String sub;
        public String name;
        public String nickname;
        public String picture;
        public String email;
        public Boolean email_verified;
        public String gender {
            get;
            set {
                if(String.isBlank(value)) {
                    gender = 'Other';
                } else {
                    // MALE --> Male
                    // FEMALE --> Female
                    gender = value.substring(0, 1).toUpperCase() + value.substring(1).toLowerCase();
                }
            }
        }
        public String birthdate;
        public String phone_number;
        public Boolean phone_number_verified;

        // Additional custom fields
        // birthdate
        public String birthdate_day;
        public String birthdate_month;
        public String birthdate_year;
        // name
        public String fullName;
        public String firstName;
        public String lastName;
        // channel subscription
        public Boolean channel_opted_in;
        public Date connected_at;
        // address
        public String base_address;
        public String detail_address;
        public String zone_number;
        public String zip_code;
        // newsletter
        public Boolean newsletter_terms;

        public void setChannelSubscription(Channel channel) {
            /*
                Possible values: ADDED, BLOCKED, NONE  
                If ADDED, then channel_opted_in = true 
            */
            this.channel_opted_in = channel.relation == 'ADDED';
            
            if(!this.channel_opted_in || channel.created_at == null) {
                return;
            }

            this.connected_at = channel.created_at.date();
        }

        public void setAddress(ShippingAddress address) {
            this.base_address = address.base_address;
            this.detail_address = address.detail_address;
            this.zone_number = address.zone_number;
            this.zip_code = address.zip_code;
        }
        
        public void setNewsletterTerms(List<ServiceTerm> serviceTerms) {
            for (ServiceTerm serviceTerm : serviceTerms) {
                if (serviceTerm.tag.toLowerCase() == 'newsletter_terms') {
                    this.newsletter_terms = serviceTerm.agreed;
                    return;
                }
            }
        }

        public void splitFullName() {
            if(String.isBlank(this.name)) {
                return;
            }
    
            this.name = this.name.trim();
            this.fullName = this.name;

            /**
             * In case if:
             *  1. Name consists of only one Korean syllable.
             *  2. Name consists of only one English word without spaces.
             * Populate the first and last names with the same value.
             */
            this.firstName = this.fullName;
            this.lastName = this.fullName;

            // Korean names
            if(Pattern.matches('^[가-힣]*$', this.fullName)) {
                if(this.fullName.length() > 1) {
                    /*  Korean names are split in the first syllable.
                        Example:
                            fullName = 홍길동
                            lastName = 홍
                            firstName = 길동
                    */
                    this.lastName = this.fullName.substring(0, 1);
                    this.firstName = this.fullName.substring(1);
                }

                return;
            }
            
            // Non-Korean names
            if(this.fullName.contains(' ')) {
                /*  English names are split by first space.
                    Example: 
                        fullName = WATSON MARY JANE 
                        lastName = WATSON
                        firstName = MARY JANE
                */
                this.lastName = this.fullName.substringBefore(' ');
                this.firstName = this.fullName.substringAfter(' ');
            }
        }

        public void splitBirthdate() {
            if(String.isBlank(this.birthdate)) {
                return;
            }

            List<String> birthdateComponents = this.birthdate.split('-');

            /* 
                Date Format: YYYY-MM-DD
            */
            if(birthdateComponents.size() == 3) {
                if (birthdateComponents[0] != '0000') {
                    this.birthdate_year = birthdateComponents[0];
                }
                this.birthdate_month = birthdateComponents[1];
                this.birthdate_day = birthdateComponents[2];
            }
            /* 
                Date Format: YYYY
            */
            else if (birthdateComponents.size() == 1 && birthdateComponents[0] != '0000') {
                this.birthdate_year = birthdateComponents[0];
            }
        }
    }

    // Shipping Address
    private class ShippingAddressWrapper {
        public Long user_id;
        public List<ShippingAddress> shipping_addresses;
        public Boolean shipping_addresses_needs_agreement;
    }

    private class ShippingAddress {
        public Integer id;
        public String name;
        public Boolean is_default;
        public Integer updated_at;
        public String type;
        public String base_address;
        public String detail_address;
        public String receiver_name;
        public String receiver_phone_number1;
        public String receiver_phone_number2;
        public String zone_number;
        public String zip_code;
    }

    // Channels Info
    private class ChannelsInfoWrapper {
        public Long user_id;
        public List<Channel> channels;
    }

    private class Channel {
        public String channel_uuid;
        public String channel_public_id;
        public String relation;
        public Datetime created_at;
        public Datetime updated_at;
    }
    
    // Service Terms
    private class ServiceTermsWrapper {
        public Long id;
        public List<ServiceTerm> service_terms; 
    }

    private class ServiceTerm {
		public String tag;
		public Boolean required;
		public Boolean agreed;
		public Boolean revocable;
		public String agreed_at;
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
        this.customLogsAccessToken = IDENTITY_Utils.getJWTAccessToken(username);
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
        //return (response.getStatusCode() == 200);
    }
}