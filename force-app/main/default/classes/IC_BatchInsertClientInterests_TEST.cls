@isTest
private class IC_BatchInsertClientInterests_TEST {
	
	@isTest static void test_method_one() {
		Account acc = new Account(FirstName = 'Test',LastName = 'Test2',DREAMID__c = '123456');
		insert acc;
		List<Folder> folder = [Select Id From Folder where Name ='Shared Documents'];
		Document doc = new Document(Name = 'interests Test', Body = Blob.valueOf('DREAMID,Categories__c,\r\n123456,Jewelry,\r\n123456,Men RTW'),FolderId = folder.get(0).Id);
		insert doc;

		IC_Config__c interestConfig = new IC_Config__c(Name = 'InterestsFiledHeaders',Value__c='DREAMID;Categories__c');
		IC_Config__c InterestMail = new IC_Config__c(Name = 'InterestMail',Value__c='dev@balink.net');
		insert interestConfig;

		Test.startTest();
			IC_BatchInsertClientInterests bat = new IC_BatchInsertClientInterests();	
			Database.executeBatch(bat,10000);  
		Test.stopTest();

	}
	
	
}