@isTest
private class IM_WSRemoveCLMembers_TEST {
	@isTest static void test_method_one() {
        
		Account a =new Account(FirstName='koko', LastName='test');
		insert a;
        String accList=a.Id+';';
		Account a2 =new Account(FirstName='koko2', LastName='test2');
		insert a2;
        accList+=a2.Id;
		CLI_CliList__c cl = new CLI_CliList__c(Name='test');
		insert cl;
		List<Contact> contacts =[select id from contact where accountid=:a.Id Or accountid=:a2.Id];
		CLM_CliListMember__c clm = new CLM_CliListMember__c(ClientList__c=cl.Id, Client__c= contacts[0].Id);
		insert clm;
        String accList2='';


        test.startTest();
        RestRequest request = new RestRequest();
        request.requestUri =
            'https://louisvuitton--devrelease.cs11.my.salesforce.com/services/apexrest/RemoveCLMember';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        RestContext.request = request;
        System.RestContext.response = new RestResponse();
        IM_WSRemoveCLMembers.RemoveCLMember(cl.Id,accList);
        IM_WSRemoveCLMembers.RemoveCLMember(cl.Id,accList2);
        IM_WSAddCLMembers.AddCLMembers('a01Z000000555IT',accList);
        test.stopTest();
    }
	
}