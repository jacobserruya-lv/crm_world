@isTest
private class IC_BatchUpdateClientListMember_TEST {
	
	@isTest static void test_method_one() {

		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
		
		Id batchprocessid;
		//Account acc1 = IC_Test_Common.createAccount('123456');
		//Account acc2 = IC_Test_Common.createAccount('456789');
		//Account acc3 = IC_Test_Common.createAccount('789123');

		Account acc1 = IC_Test_Common.createPersonAccount('123456');
		Account acc2 = IC_Test_Common.createPersonAccount('456789');
		Account acc3 = IC_Test_Common.createPersonAccount('789123');
		
		//Contact con1 = createContact(acc1);
		//Contact con2 = createContact(acc2);
		//Contact con3 = createContact(acc3);

		CLI_CliList__c clientList = IC_Test_Common.createClientList();

		Contact contact1 = [Select Id From Contact WHERE accountId = :acc1.Id limit 1];
		Contact contact2 = [Select Id From Contact WHERE accountId = :acc2.Id limit 1];
		Contact contact3 = [Select Id From Contact WHERE accountId = :acc3.Id limit 1];

		CLM_CliListMember__c member1 = new CLM_CliListMember__c(ClientList__c = clientList.id, Client__c= contact1.Id);
		insert member1;
		System.debug('member1: '+ member1);
		CLM_CliListMember__c member2 = new CLM_CliListMember__c(ClientList__c = clientList.id, Client__c = contact2.Id);
		insert member2;
		CLM_CliListMember__c member3 = new CLM_CliListMember__c(ClientList__c = clientList.id, Client__c = contact3.Id);
		insert member3;

		Test.startTest();
		IC_BatchUpdateClientListMember myBatch = new IC_BatchUpdateClientListMember();
		batchprocessid = Database.executeBatch(myBatch,1000);
		Test.stopTest();

	}

	public static Contact createContact(Account acc){

		Contact con = new Contact();
		con.AccountId = acc.Id;
		insert con;
		return con;
	}
	
	
}