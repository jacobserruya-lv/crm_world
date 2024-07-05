/*******************************************************************************************************
** - Author : Stéphanie Tinseau
** - Description : This Class contains the testMethods for the class IC_ObjectHistoryComponent_COM
** - Delivery Date : 23/05/2014
** - Modifications :
**    
** - Governor informations :
*******************************************************************************************************/

@isTest
private class IC_ObjectHistoryComponent_COM_TEST {

    static testMethod void myAccountHistoryTest() {
		Account myAccount = IC_TestFactory.createAccount();
		insert myAccount;
	
		myAccount.PrimaryZipCode__pc = '75005';
		update myAccount;
		
		IC_ObjectHistoryComponent_COM controller = new IC_ObjectHistoryComponent_COM();
		controller.myObject = myAccount;
		controller.recordLimit = 50;
		
		controller.objectHistory = controller.getObjectHistory();

    }

    static testMethod void myAccountHistoryOwnerTest() {
		Account myAccount = IC_TestFactory.createAccount();
		insert myAccount;

		String identityProfile = [SELECT Id FROM Profile WHERE Name = 'Identity User'][0].Id;
        insert new IC_Config__c(
            Name = 'Identity User',
            Value__c = identityProfile
        );
	
		User usr = IC_TestFactory.createUser('Test@lv.com.test');
		usr.ProfileId = IC_Utils.getSAProfile();
		insert usr;
		
		myAccount.OwnerId = usr.Id;
		update myAccount;
		
		IC_ObjectHistoryComponent_COM controller = new IC_ObjectHistoryComponent_COM();
		controller.myObject = myAccount;
		controller.recordLimit = 50;
		
		controller.objectHistory = controller.getObjectHistory();

    }

	/********************************************************************************
		We have to do one test with real data as history table is not fulfilled by test class
		so that we can get higher code coverage
		
		SFDC Force.com Apex Code Dev :
		Records that are created only after related records are committed to the database, like 
		tracked changes in Chatter. Tracked changes for a record (FeedTrackedChange records) in 
		Chatter feeds aren't available when test methods modify the associated record. 
		FeedTrackedChange records require the change to the parent record they're associated 
		with to be committed to the database before they're created. Since test methods don't 
		commit data, they don't result in the creation of FeedTrackedChange records. Similarly, 
		field history tracking records (such as AccountHistory) can't be created in test methods 
		because they require other sObject records to be committed first (for example, Account).
		
	********************************************************************************/
	
	@isTest(SeeAllData=true)
    static void myAccountHistoryAllDataTest() {
    	Account myAccount = [select Id from Account LIMIT 1];
		
		if(myAccount != null){
			IC_ObjectHistoryComponent_COM controller = new IC_ObjectHistoryComponent_COM();
			controller.myObject = myAccount;
			controller.recordLimit = 50;
			
			controller.objectHistory = controller.getObjectHistory();
		}    	
    }

}