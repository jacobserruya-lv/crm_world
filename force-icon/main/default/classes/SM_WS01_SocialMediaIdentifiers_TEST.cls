@isTest
private with sharing class SM_WS01_SocialMediaIdentifiers_TEST {
	static Map<String,String> identifierMap;
	static Map<String,String> clientMap;
    static Map<String,String> caBindingMap;
	
	@isTest static void querySocialMediaIdentifer () {
  
        setup();

        Test.startTest();

        	// Missing parameters
            setGetRequest(new Map<String,String>());
            SM_WS01_SocialMediaIdentifiers.get();

        	// Missing query type
            setGetRequest(identifierMap);
            SM_WS01_SocialMediaIdentifiers.get();

            // Query Social Media
            identifierMap.put('queryType', Label.SM_Query_Type_Social_Media_Identifier);

            // Query by Social Media - Not found
            setGetRequest(identifierMap);
            SM_WS01_SocialMediaIdentifiers.get();

			init();

			// Query by Social Media - Found
            setGetRequest(identifierMap);
            SM_WS01_SocialMediaIdentifiers.get();

            // Missing requried field
            identifierMap.remove('social_id__c');
            setGetRequest(identifierMap);
            SM_WS01_SocialMediaIdentifiers.get();

        Test.stopTest();
    }
	
	@isTest static void queryClient() {
		setup();

        Test.startTest();

            // Query Client
            clientMap.put('queryType', Label.SM_Query_Type_Client);

            // Query by Client - not found
            setGetRequest(clientMap);
            SM_WS01_SocialMediaIdentifiers.get();

            init();

            // Query by Client - found
            clientMap.remove('mobilephonecountrycallingcode__pc');
            clientMap.remove('localmobilephone__pc');
            setGetRequest(clientMap);
            SM_WS01_SocialMediaIdentifiers.get();

            // Missing requried field
            clientMap.remove('lastname');
            setGetRequest(clientMap);
            SM_WS01_SocialMediaIdentifiers.get();
        

        Test.stopTest();
	}
    @isTest static void lineBindingLink() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        Test.setMock(HttpCalloutMock.class, new SM_WS01_SocialMediaIdentifiers_TEST.BindingHttpCalloutMock()); 
        Test.startTest();
        Map<String, String> params = new Map<String, String> {'client' => acc.Id};
        setGetRequest(params,'/GetLineBindingLink');
        
        SM_WS01_SocialMediaIdentifiers.get();
        Test.stopTest();
        
    }

	@isTest static void upsertData() {
		setup();

        Test.startTest();

        	// No data
        	setPostRequest(null, null, null);
            SM_WS01_SocialMediaIdentifiers.post();

            // Missing Identifier
            setPostRequest(identifierMap, null, null);
            SM_WS01_SocialMediaIdentifiers.post();

            // Create Client and Identifer
            setPostRequest(identifierMap, clientMap, null);
            SM_WS01_SocialMediaIdentifiers.post();
        
          // Create Client JPN and Identifer
            clientMap.put('HomeAddressCountryCode__pc', 'JPN');
            setPostRequest(identifierMap, clientMap, null);
            SM_WS01_SocialMediaIdentifiers.post();
        Test.stopTest();
	}
    
    @isTest static void upsertData1() {
		setup();

        Test.startTest();

            // Update Identifier
            setPostRequest(identifierMap, null, null);
            SM_WS01_SocialMediaIdentifiers.post();
        
        	// With ca_binding
         	Identity_TestFactory.createSettings();
        	User user = Identity_TestFactory.createSimpleUser('John', 'Doe', 'test_sm@test.com', '0655511418');
        	user.WWEmployeeNumber__c = '12345';
        	update user;
        	identifierMap.remove('Opt_In__c');
        	identifierMap.put('Opt_In__c','true');
         	setPostRequest(identifierMap, clientMap, caBindingMap);
         	SM_WS01_SocialMediaIdentifiers.post();

            // Missing requried field
            clientMap.remove('lastname');
            setPostRequest(identifierMap, clientMap, null);
            SM_WS01_SocialMediaIdentifiers.post();

        Test.stopTest();
	}
    
	@isTest static void testGetSocialMediaTypeCorrectCase() {
	
        String socialMedia;
        socialMedia = SM_WS01_SocialMediaIdentifiers_Utils.getSocialMediaTypeCorrectCase('LINE');
        System.AssertEquals('Line', socialMedia);
        socialMedia = SM_WS01_SocialMediaIdentifiers_Utils.getSocialMediaTypeCorrectCase('KAKAO');
        System.AssertEquals('Kakao', socialMedia);
        socialMedia = SM_WS01_SocialMediaIdentifiers_Utils.getSocialMediaTypeCorrectCase('GOOGLE');
        System.AssertEquals('GOOGLE', socialMedia);
    }
    
    @isTest static void testGetQueryException() {
	
        SM_WS01_SocialMediaIdentifiers_Utils.getQueryException('BLOB', 'exceptionType');
        SM_WS01_SocialMediaIdentifiers_Utils.getQueryException('ENTITY_IS_DELETED', 'exceptionType');
        SM_WS01_SocialMediaIdentifiers_Utils.getQueryException(Label.SM_No_records, 'exceptionType');
        SM_WS01_SocialMediaIdentifiers_Utils.getQueryException('something', 'exceptionType');
    }    
    @isTest static void testPUT_updateRelatedClient(){
        setup();
        init();
        Test.startTest();
        setPostRequest(identifierMap, clientMap, null);
        SM_WS01_SocialMediaIdentifiers.put();
        Test.stopTest();
    }
    @isTest static void testDELETE_unbind(){
        setup();
        init();
        Test.startTest();
        setDeleteRequest(identifierMap);
        SM_WS01_SocialMediaIdentifiers.unbind();
        Test.stopTest();
    }

    @isTest static void test2(){
        Test.startTest();
        Account client = IC_TestFactory.createAccount();
		insert client;
		Blob blobValue = Blob.valueOf('Utf3456agjdf5678');
		Social_Media_Identifier__c identifier = new Social_Media_Identifier__c (client__c = client.Id, Social_Media_Type__c = 'LineWorks', social_id__c = 'Utf3456agjdf5678', Social_Enterprise_Id__c =  EncodingUtil.base64Encode(blobValue) );
		insert identifier;
        
    	SM_WS01_SocialMediaIdentifiers_Utils.ResponseBody responseBody = new SM_WS01_SocialMediaIdentifiers_Utils.ResponseBody(identifier);
		SM_WS01_SocialMediaIdentifiers_Utils.ExceptionBody ExcBody = new SM_WS01_SocialMediaIdentifiers_Utils.ExceptionBody();
        SM_WS01_SocialMediaIdentifiers_Utils.createProspect(client);
        SM_WS01_SocialMediaIdentifiers_Utils.upsertSocialMediaIdentifier(identifier,null,true);
        SM_WS01_SocialMediaIdentifiers_Utils.getSocialMediaTypeCorrectCase('WECHAT');
        Test.StopTest();
    }
	static void setup() {

        Blob blobValue = Blob.valueOf('Utf3456agjdf5678');

		identifierMap = new Map<String,String> {
			'social_id__c' => EncodingUtil.base64Encode(blobValue),
			'Social_Media_Type__c' => 'LineWorks'
            //'Opt_In__c' => 'false'
		};

        clientMap = new Map<String,String>{
        	'firstname' => 'Bernard',
			'lastname' => 'Dupont',
			'personemail' => 'bernard@dupont.test',
			'mobilephonecountrycallingcode__pc' => '33',
			'localmobilephone__pc' => '621064418',
            'Gender__pc' => 'Male'
        };
            
            caBindingMap = new Map<String,String> {
			'status__c' => 'bound',
			'employeeId' => '12345'
		};
	}

	static void init() {

		Account client = (Account)JSON.deserialize(JSON.serialize(clientMap), Account.class);
		insert client;

		Social_Media_Identifier__c identifier = new Social_Media_Identifier__c (client__c = client.Id, Social_Media_Type__c = 'LineWorks', social_id__c = 'Utf3456agjdf5678' );//(Social_Media_Identifier__c)JSON.deserialize(JSON.serialize(identifierMap), Social_Media_Identifier__c.class);
		identifier.Client__c = client.Id;
		insert identifier;

        Social_Media_Identifier__c identifier2 = new Social_Media_Identifier__c (client__c = client.Id, Social_Media_Type__c = 'Line', social_id__c = 'testID' );
        insert identifier2;
    
	}

	static void setGetRequest(Map<String,String> parameters) {
		RestRequest request = new RestRequest();
        request.httpMethod = 'GET';
        request.requestURI = '/SocialMediaIdentifiers/';
        request.addHeader('Content-Type', 'application/json');

        for(String key : parameters.keySet()){
        	request.addParameter(key, (String)parameters.get(key));
        }
        
        RestContext.request = request;

        RestContext.response = new RestResponse();
	}
    static void setGetRequest(Map<String,String> parameters, String service) {
		RestRequest request = new RestRequest();
        request.httpMethod = 'GET';
        request.addHeader('Content-Type', 'application/json');

        for(String key : parameters.keySet()){
        	request.addParameter(key, (String)parameters.get(key));
        }
        request.requestURI = '/SocialMediaIdentifiers'+ service;
        RestContext.request = request;

        RestContext.response = new RestResponse();
	}

	static void setPostRequest(Map<String,String> identifier, Map<String,String> client, Map<String,String> ca_binding) {

		Map<String,Object> body = new Map<String,Object> {
			Label.SM_Query_Type_Client => client,
			Label.SM_Query_Type_Social_Media_Identifier => identifier,
            'enterprise_ca_binding' => ca_binding
		};

		RestRequest request = new RestRequest();
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');

        if(identifier != null && client != null) {
        	request.requestBody = Blob.valueOf(JSON.serialize(body));
        }
        
        if(ca_binding != null){
            request.addParameter('isEnterpriseSABinding', 'true');
        }
        RestContext.request = request;

        RestContext.response = new RestResponse();
	}
    static void setDeleteRequest(Map<String,String> identifier) {

		Map<String,Object> body = new Map<String,Object> {
			Label.SM_Query_Type_Social_Media_Identifier => identifier
		};

		RestRequest request = new RestRequest();
        request.httpMethod = 'DELETE';
        request.addHeader('Content-Type', 'application/json');

        if(identifier != null) {
        	request.requestBody = Blob.valueOf(JSON.serialize(body));
        }
        
        RestContext.request = request;

        RestContext.response = new RestResponse();
	}
    public class BindingHttpCalloutMock implements HttpCalloutMock {

        public HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody('{ "direct_url" : "https://tsunagaru036.linebc.jp/lvj/mc/1/111111111111"}');
            response.setStatusCode(200);
            return response; 
        }
    }
    
}