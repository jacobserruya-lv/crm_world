@isTest
private class IM_WSAddCLMembers_TEST {
	@isTest static void test_method_one() {
		Account a =new Account(FirstName='koko', LastName='test');
		insert a;
		String accList=a.Id+';';
		Account a2 =new Account(FirstName='koko2', LastName='test2');
		insert a2;
		accList+=a2.Id;
		CLI_CliList__c cl = new CLI_CliList__c(Name='test');
		insert cl;
		String accList2='';

		test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://louisvuitton--devrelease.cs11.my.salesforce.com/services/apexrest/AddCLMembers';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        System.RestContext.response = new RestResponse();
        IM_WSAddCLMembers.AddCLMembers(cl.Id,accList);
        IM_WSAddCLMembers.AddCLMembers(cl.Id,accList2);
        IM_WSAddCLMembers.AddCLMembers('a01Z000000555IT',accList);
        test.stopTest();
    }
	
}