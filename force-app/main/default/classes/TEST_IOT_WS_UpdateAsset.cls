@isTest
private class TEST_IOT_WS_UpdateAsset {
	
	@isTest static void test_method_one() {
		test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://louisvuitton--eco.cs26.my.salesforce.com/services/apexrest/UpdateAsset';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        System.RestContext.response = new RestResponse();
        Account acc= new Account(LastName='acctest',FirstName='dsaas');
        insert acc;
        Asset astoIn= new Asset(Name='test1', AccountId=acc.Id);
    	insert astoIn;
        IOT_WS_UpdateAsset.UpdateAsset('5454545','test2');
        IOT_WS_UpdateAsset.UpdateAsset(astoIn.Id,'test3');
        
    test.stopTest();
	}
	
	
}