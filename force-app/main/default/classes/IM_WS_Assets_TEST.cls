@isTest
private class IM_WS_Assets_TEST
{
	@isTest
	static void testPost1()
	{
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		req.requestURI = '/services/apexrest/Assets/';
		req.httpMethod = 'GET';
		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
		IM_WS_Assets.get();
		Test.stopTest();
	}
}