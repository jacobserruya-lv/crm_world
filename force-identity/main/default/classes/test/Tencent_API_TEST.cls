@isTest
private class Tencent_API_TEST {
	
	@isTest static void test_all() {
		Test.startTest();
       
			RestRequest request = new RestRequest();
	    	RestResponse response = new RestResponse();
	    	request.requestURI = '/services/apexrest/SampleAPI';
	    	request.httpMethod = 'POST';
	    	request.addParameter('test', 'test');

	    	RestContext.request = request;
	    	RestContext.response = response;

			Tencent_API.verifyCaptcha('ticket','randstr');

		Test.stopTest();
	}
}