public with sharing class IC_Test_Common {
	
    public static User createTestUser() {
        return prepareTestUser('System Administrator');    
    }
    
	public static User prepareTestUser(string profileName) {
		User u=new User();
        u.Username= Datetime.now().getTime()+'testUser@tsystems.com';
        u.LastName= 'test';
        u.FirstName= 'test';
        u.BypassWF__c = true;
        u.BypassVR__c = true;
        u.Email= u.Username;
        u.Alias= 'TST';
        u.TimeZoneSidKey = 'America/Los_Angeles';  
        u.LocaleSidKey = 'en_US';
        u.EmailEncodingKey='ISO-8859-1';
        u.ProfileId = [Select p.Name, p.Id From Profile p where name =: profileName].id;
        u.LanguageLocaleKey = 'en_US';
        u.isActive=true;
        u.IsTechnicalUser__c = false;
        
        return u;  
	}
	
	public static Account createAccount(string dreamId){
        Account myAccount = new Account();
        myAccount.LastName = 'TCLTest';
        myAccount.FirstName='TCLTest';
        myAccount.DREAMID__c = dreamId;
        myAccount.LastTrans__pc = System.Today();
        myAccount.Segmentation__pc = 'VIC';
        myAccount.PersonDoNotCall = true;
        myAccount.PersonHasOptedOutOfEmail = true;
        myAccount.DoNotSMS__pc = true;
        myAccount.DoNotContactbyPost__pc = true;
        myAccount.BirthdateMonth__pc = '1';
        myAccount.Gender__pc = 'Male';
        myAccount.HistoricalSpendEUR__pc = 250000;

        insert myAccount;
        return myAccount;
    }
    
    public static Account createPersonAccount(string dreamId){
    	RecordType personAccRT = GetPersonAccountRT();
        
        Account myAccount = new Account();
        myAccount.LastName = 'TCLTest';
        myAccount.FirstName='TCLTest';
        myAccount.DREAMID__c = dreamId;
        myAccount.LastTrans__pc = System.Today();
        myAccount.Segmentation__pc = 'VIC';
        myAccount.PersonDoNotCall = true;
        myAccount.PersonHasOptedOutOfEmail = true;
        myAccount.DoNotSMS__pc = true;
        myAccount.DoNotContactbyPost__pc = true;
        myAccount.BirthdateMonth__pc = '1';
        myAccount.Gender__pc = 'Male';
        myAccount.HistoricalSpendEUR__pc = 250000;
		myAccount.recordType = personAccRT;
        
        insert myAccount;
        return myAccount;
    }
    
    public static CLI_CliList__c createClientList(){
    	CLI_CliList__c cli = new CLI_CliList__c();
    	cli.TECH_LaunchAddMembersBatch__c = true;
    	
    	insert cli;
    	return cli;
    }
    
    public static RecordType GetPersonAccountRT(){
    	RecordType personAccountRecordType =  [SELECT Id FROM RecordType WHERE Name = 'Person Account' and SObjectType = 'Account'];
    	return personAccountRecordType;
    }
    
}