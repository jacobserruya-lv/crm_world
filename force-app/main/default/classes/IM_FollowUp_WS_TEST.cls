@isTest
private class IM_FollowUp_WS_TEST {
	    @isTest static void test_method_one() {
	        // Implement test code
	        Account acc = IC_TestFactory.createAccount();
	        insert acc;
	        Event evt = IC_TestFactory.createEvent(acc);
	        evt.Currency__c='USD';
	        insert evt;
	        Task tsk =IC_TestFactory.createTask(acc);
	        tsk.IsWardrobing__c = true;
	        insert tsk;
	        System.debug('AAAAAAAAAAAAAAAAAAAAAA   tsk: ' + tsk);
	        test.startTest();
	        RestRequest request = new RestRequest();
	        request.requestUri =
	            'https://louisvuitton--devrelease.cs11.my.salesforce.com/services/apexrest/GetFollowUpObject';
	        request.httpMethod = 'POST';
	        request.addHeader('Content-Type', 'application/json');
	        RestContext.request = request;
	        System.RestContext.response = new RestResponse();
			request.requestBody = Blob.valueOf('{"days":"week","teamIds":""}');
	        IM_FollowUp_WS.GetFollowUpObject();
	        test.stopTest();
    }
}