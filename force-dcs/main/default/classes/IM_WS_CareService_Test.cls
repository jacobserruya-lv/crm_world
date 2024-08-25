@isTest
private class IM_WS_CareService_Test {
	
	@isTest static void test_method_one() {

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		Store__c store1= new Store__c(RetailStoreId__c = 'A06');
		insert store1;

		String json = '{'+
					'"Client" : {'+
						'"FirstName" : "TesUSERTECH",'+
						'"LastName" : "TESTLASTTECH"'+
					'},'+
					'"Instructions" : ['+
						'{'+
						'"Approved__c" : true,'+
						'"Description__c" : "bandouliere dechiree",'+
						'"Initial_Price__c" : 150,'+
						'"InstructionCode__c" : "B1152"	'+
						'},{'+
						'"Approved__c" : true,'+
						'"Description__c" : "sac dechiree",'+
						'"Initial_Price__c" : 160.2,'+
						'"InstructionCode__c" : "A1482"'+
						'}],'+
					'"ExternalId__c" : "95TECH955",'+
					'"Status__c" : "New",'+
					'"Red_Code__c" : true,'+
					'"SKU__c" : "M51980",'+
					'"TotalAmount__c" : null,'+
					'"CA_Code__c" : "JM0726",'+
					'"StoreRetailCode__c" : "A06",'+
					'"Delivery_Date__c" : null,'+
					'"MyRepair_CreatedDate__c" : "2016-09-01",'+
					'"Delivery_Address__c" : "test adress USER TECH"'+
				'}';

		req.requestURI = '/services/apexrest/CareService/';
		req.requestBody = Blob.valueOf(json);
		req.httpMethod = 'POST';
		req.addHeader('Content-Type','application/json');
		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
		IM_WS_CareService.post();
		Test.stopTest();
	}

	@isTest static void test_method_two() {

		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();

		Store__c store1= new Store__c(RetailStoreId__c = 'A06');
		insert store1;

		String json = '{'+
					'"Client" : {'+
						'"FirstName" : "TesUSERTECH",'+
						'"LastName" : "TESTLASTTECH"'+
					'},'+
					'"Instructions" : ['+
						'{'+
						'"Approved__c" : true,'+
						'"Description__c" : "bandouliere dechiree",'+
						'"Initial_Price__c" : 150,'+
						'"InstructionCode__c" : "B1152"	'+
						'},{'+
						'"Approved__c" : true,'+
						'"Description__c" : "sac dechiree",'+
						'"Initial_Price__c" : 160.2,'+
						'"InstructionCode__c" : "A1482"'+
						'}],'+
					'"ExternalId__c" : "95TECH955",'+
					'"Status__c" : "New",'+
					'"Red_Code__c" : true,'+
					'"SKU__c" : "M519804",'+
					'"TotalAmount__c" : null,'+
					'"CA_Code__c" : "JM0726",'+
					'"StoreRetailCode__c" : "A96",'+
					'"Delivery_Date__c" : null,'+
					'"MyRepair_CreatedDate__c" : "2016-09-01",'+
					'"Delivery_Address__c" : "test adress USER TECH"'+
				'}';

		req.requestURI = '/services/apexrest/CareService/';
		req.requestBody = Blob.valueOf(json);
		req.httpMethod = 'POST';
		req.addHeader('Content-Type','application/json');
		RestContext.request = req;
		RestContext.response = res;

		Test.startTest();
		IM_WS_CareService.post();
		Test.stopTest();
	}

	
}