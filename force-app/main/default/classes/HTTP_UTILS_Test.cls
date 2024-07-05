@isTest
private class HTTP_UTILS_Test {

	private static String baseUrl = 'https://jsonplaceholder.typicode.com/';
	
	@isTest
	public static void testMethodGet() {
		// Given
		HTTP_UTILS httpUtils = new HTTP_UTILS();

		// When
		httpUtils.get(baseUrl);
		HttpRequest request = httpUtils.getRequest();

		// Then
		System.assertEquals('GET', request.getMethod(), 'ERROR');
		System.assertEquals(baseUrl, request.getEndpoint(), 'ERROR');
	}

	@isTest
	public static void testMethodPut() {
		// Given
		HTTP_UTILS httpUtils = new HTTP_UTILS();

		// When
		httpUtils.put(baseUrl);
		HttpRequest request = httpUtils.getRequest();

		// Then
		System.assertEquals('PUT', request.getMethod(), 'ERROR');
		System.assertEquals(baseUrl, request.getEndpoint(), 'ERROR');
	}

	@isTest
	public static void testMethodPost() {
		// Given
		HTTP_UTILS httpUtils = new HTTP_UTILS();

		// When
		httpUtils.post(baseUrl);
		HttpRequest request = httpUtils.getRequest();

		// Then
		System.assertEquals('POST', request.getMethod(), 'ERROR');
		System.assertEquals(baseUrl, request.getEndpoint(), 'ERROR');
	}

	@isTest
	public static void testMethodPatch() {
		// Given
		HTTP_UTILS httpUtils = new HTTP_UTILS();

		// When
		httpUtils.patch(baseUrl);
		HttpRequest request = httpUtils.getRequest();

		// Then
		System.assertEquals('PUT', request.getMethod(), 'ERROR');
		System.assertEquals(baseUrl, request.getEndpoint(), 'ERROR');
	}

	@isTest
	public static void testMethodDel() {
		// Given
		HTTP_UTILS httpUtils = new HTTP_UTILS();

		// When
		httpUtils.del(baseUrl);
		HttpRequest request = httpUtils.getRequest();

		// Then
		System.assertEquals('DELETE', request.getMethod(), 'ERROR');
		System.assertEquals(baseUrl, request.getEndpoint(), 'ERROR');
	}

	@isTest
	public static void testMethodHeaders() {
		// Given
		String key1 = 'key1';
		String key2 = 'key2';
		String value1 = 'VALUE 1';
		String value2 = 'VALUE 2';

		// When
		HTTP_UTILS httpUtils = new HTTP_UTILS()
			.header(key1, value1)
			.header(key2, value2);

		// Then
		Map<String, String> headers = httpUtils.getHeaders();
		System.assertEquals(false, headers.isEmpty(), 'ERROR');
		System.assertEquals(2, headers.size(), 'ERROR');
		System.assertEquals(true, headers.containsKey(key1), 'ERROR');
		System.assertEquals(true, headers.containsKey(key2), 'ERROR');
		System.assertEquals(value1, headers.get(key1), 'ERROR');
		System.assertEquals(value2, headers.get(key2), 'ERROR');
	}
	
	@isTest
	public static void testHeadersAreEmptyByDefault() {
		// Given
		HTTP_UTILS httpUtils = new HTTP_UTILS();

		// Then
		System.assertEquals(true, httpUtils.getHeaders().isEmpty(), 'ERROR');
	}

	@isTest
	public static void testMethodAddHeadersWhithNonEmptyHeaders() {
		// Given
		String key1 = 'key1';
		String key2 = 'key2';
		String value1 = 'VALUE 1';
		String value2 = 'VALUE 2';
		Map<String, String> originalHeaders = new Map<String, String>();
		originalHeaders.put(key1, value1);
		originalHeaders.put(key2, value2);

		// When
		HTTP_UTILS httpUtils = new HTTP_UTILS().addHeaders(originalHeaders);

		// Then
		Map<String, String> headers = httpUtils.getHeaders();
		System.assertEquals(false, headers.isEmpty(), 'ERROR');
		System.assertEquals(2, headers.size(), 'ERROR');
		System.assertEquals(true, headers.containsKey(key1), 'ERROR');
		System.assertEquals(true, headers.containsKey(key2), 'ERROR');
		System.assertEquals(value1, headers.get(key1), 'ERROR');
		System.assertEquals(value2, headers.get(key2), 'ERROR');
	}

	@isTest
	public static void testMethodAddHeadersWhithNullHeaders() {
		// Given
		Map<String, String> originalHeaders = null;

		// When
		HTTP_UTILS httpUtils = new HTTP_UTILS().addHeaders(originalHeaders);

		// Then
		System.assertEquals(true, httpUtils.getHeaders().isEmpty(), 'ERROR');
	}

	@isTest
	public static void testMethodAddHeadersWhithEmptyHeaders() {
		// Given
		Map<String, String> originalHeaders = new Map<String, String>();

		// When
		HTTP_UTILS httpUtils = new HTTP_UTILS().addHeaders(originalHeaders);

		// Then
		System.assertEquals(true, httpUtils.getHeaders().isEmpty(), 'ERROR');
	}

	@isTest
	public static void testMethodBody() {
		// Given
		String body = 'My request body';
		HTTP_UTILS httpUtils = new HTTP_UTILS();

		// When
		httpUtils.body(body);
		
		// Then
		HttpRequest request = httpUtils.getRequest();
		System.assertEquals(body, request.getBody(), 'ERROR');
	}

	@isTest static void testMethodCall() {
		// Given
		Map<String, String> originalHeaders = new Map<String, String>();
		originalHeaders.put('key1', 'VALUE 1');
		HTTP_UTILS httpUtils = new HTTP_UTILS().addHeaders(originalHeaders);
		Identity_TestFactory.createSettings();

		// When
		Test.startTest();
			httpUtils.get(baseUrl);
			httpUtils.header('Content-Type', 'application/json');
			httpUtils.body('body');
			httpUtils.addHeaders(new Map<String, String>());
			httpUtils.timeout(1);
			httpUtils.call();
			HttpResponse response = httpUtils.getResponse();
		Test.stopTest();

		System.assertEquals(null, httpUtils.status(), 'ERR');
		System.assertEquals(0, httpUtils.statusCode(), 'ERR');
	}

	@isTest
	public static void testMethodGetParameters() {
		// Given
		HTTP_UTILS httpUtils = new HTTP_UTILS();
		Map<String,String> mapBody = new Map<String,String>();
		String parameterKey1 = 'key1';
		String parameterKey2 = 'key2';
		String parameterKey3 = 'key3';
		String parameterValue1 = 'value 1';
		String parameterValue2 = String.valueOf(123);
		String parameterValue3 = String.valueOf(false);
		mapBody.put(parameterKey1, parameterValue1);
		mapBody.put(parameterKey2, parameterValue2);
		mapBody.put(parameterKey3, parameterValue3);
		httpUtils.response = new HttpResponse();
		httpUtils.response.setBody(JSON.serialize(mapBody));

		// When
		Map<String,String> parameters = httpUtils.getParameters();

		// Then
		System.assertEquals(mapBody.size(), parameters.size(), 'ERR');
		System.assertEquals(mapBody.keySet(), parameters.keySet(), 'ERR');

		List<String> parametersValues = parameters.values();
		System.assertEquals(true, parametersValues.contains(mapBody.get(parameterKey1)), 'ERR');
		System.assertEquals(true, parametersValues.contains(mapBody.get(parameterKey2)), 'ERR');
		System.assertEquals(true, parametersValues.contains(mapBody.get(parameterKey3)), 'ERR');
	}

	@isTest
	public static void testMethodGetBodyResponse() {
		// Given
		HTTP_UTILS httpUtils = new HTTP_UTILS();
		Map<String,Object> mapBody = new Map<String,Object>();
		String parameterKey1 = 'key1';
		String parameterKey2 = 'key2';
		String parameterKey3 = 'key3';
		String parameterValue1 = 'value 1';
		Integer parameterValue2 = 123;
		Boolean parameterValue3 = false;
		mapBody.put(parameterKey1, parameterValue1);
		mapBody.put(parameterKey2, parameterValue2);
		mapBody.put(parameterKey3, parameterValue3);
		httpUtils.response = new HttpResponse();
		httpUtils.response.setBody(JSON.serialize(mapBody));

		// When
		Map<String,Object> bodyResponse = httpUtils.getBodyResponse();

		// Then
		System.assertEquals(mapBody.size(), bodyResponse.size(), 'ERR');
		System.assertEquals(mapBody.keySet(), bodyResponse.keySet(), 'ERR');

		List<Object> bodyResponseValues = bodyResponse.values();
		System.assertEquals(true, bodyResponseValues.contains(mapBody.get(parameterKey1)), 'ERR');
		System.assertEquals(true, bodyResponseValues.contains(mapBody.get(parameterKey2)), 'ERR');
		System.assertEquals(true, bodyResponseValues.contains(mapBody.get(parameterKey3)), 'ERR');
	}

	@isTest
	public static void testMethodGetBasicAuthentication() {
		// Given
		String username = 'username';
		String password = 'password';
		String expectedResponse = EncodingUtil.base64Encode(Blob.valueOf(username + ':' + password));

		// When
		String actualReponse = HTTP_Utils.getBasicAuthentication(username, password);

		// Then
		System.assertEquals(expectedResponse, actualReponse, 'Wrong expected response');
	}

}