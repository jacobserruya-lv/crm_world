@isTest
public class IC_BatchClientListMemberDupliDelete_TEST {
    
    static testMethod void batchCLMDuplicateDeleteTEST(){
        Id batchprocessid;
        //prepareData();
        Account acc = new Account();
        acc = IC_TestFactory.createAccount();
        insert acc;

        Contact contact = [Select Id From Contact WHERE accountId = :acc.Id limit 1];
        System.debug('GGGGGGGGGG contact: ' + contact);

        CLI_CliList__c clientList = new CLI_CliList__c();
        clientList = createClientlist('Test List');
        insert clientList;

        CLM_CliListMember__c clientListMember = new CLM_CliListMember__c();
        clientListMember = createClientlistMember(clientList.Id, contact.Id);
        insert clientListMember;
        
        System.debug('QQQQQQQQQQQ clientListMember: ' + clientListMember);
        
        CLM_CliListMember__c clm = [SELECT Id, TECH_External_Id__c FROM CLM_CliListMember__c limit 1];
        System.debug('TTTTTTTTTTTTTTT clm: ' + clm);

        Test.startTest();    
        IC_BatchClientListMemberDuplicateDelete ba = new IC_BatchClientListMemberDuplicateDelete();
        Database.executeBatch(ba,200);
        Test.stopTest(); 
        
        
    }

    static private void prepareData(){
        // Create 3 client lists
        List<CLI_CliList__c> clientLists = new List<CLI_CliList__c>();
        
        for (Integer i = 0; i < 3; i++) {
            clientLists.add(createClientList('Clien List ' + i));
        }
        insert clientLists;
        
        clientLists = [SELECT Id, NbrClients__c FROM CLI_CliList__c];
        
        // Create 50 Accounts
        List<Account> accounts = new List<Account>();
        
        for (Integer i = 0; i < 50; i++) {
            accounts.add(IC_TestFactory.createAccount());
        }
        insert accounts;
        
        // Retreive PersonContactId field
        accounts = [SELECT Id, PersonContactId FROM Account];
        
        
        // Create 250 clientListMember :
        List<CLM_CliListMember__c> clm = new List<CLM_CliListMember__c>();
        
        for (Integer i = 0; i < 50; i++) {
          // 50 unique clients on first client list
            clm.add(createClientlistMember(clientLists.get(0).Id, accounts.get(i).PersonContactId));
            
          // 50 unique clients on second client list + 50 duplicate of the first client : 100 clientListMembers
            //clm.add(createClientlistMember(clientLists.get(1).Id, accounts.get(i).PersonContactId));
            
          // 50 unique clients on third client list + 1 duplicate of each client (total of 50 duplicate) : 100 clientListMembers
            //clm.add(createClientlistMember(clientLists.get(2).Id, accounts.get(i).PersonContactId));
        }
        
        insert clm;
        System.debug('QQQQQQQQQQQ clm: ' + clm);
    }

    
    static private CLI_CliList__c  createClientlist(string name){
        CLI_CliList__c  clm = new CLI_CliList__c();
        clm.Name = name;
        clm.Description__c ='Description test';
        clm.Active__c = true;
        return clm;
    }
    
    static private CLM_CliListMember__c  createClientlistMember(Id clientListID, Id contactID){
        CLM_CliListMember__c  clm = new CLM_CliListMember__c();
        clm.ClientList__c = clientListID;
        clm.Client__c = contactID;
        clm.TECH_External_Id__c = null;
        return clm;
    }

    public static Contact createContact(Account acc){

		Contact con = new Contact();
		con.AccountId = acc.Id;
		insert con;
		return con;
	}
}