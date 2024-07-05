/**
    About
    -----
    Description: Test Clone Client Lists 
    Created for: SOW: IC001 ICON project (IC0N Release 2014)
    Create date: May 2014

    Details
    -------
    Test Clone Client List 

    Update History
    --------------
    May 2014 / IC001/ Created by by Pape Babacar DIOUF  - Capgemini (Pape-Babacar.Diouf@capgemini.com)

    --------------
*/
@isTest
private class IC_CloneClientList_VFCx_TEST {

    @TestSetup
    public static void setup() {
        String identityProfile = [SELECT Id FROM Profile WHERE Name = 'Identity User'][0].Id;
        insert new IC_Config__c(
            Name = 'Identity User',
            Value__c = identityProfile
        );
    }

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        
        CLI_CliList__c cli = new CLI_CliList__c(
			Name = 'Test',
			Description__c = 'My description',
			Active__c = true,
            ExpirationDate__c = System.Today().addYears(1),
			OwnerId = UserInfo.getUserId()
		);
		insert cli;
		
		User usr = IC_TestFactory.createUser('TestCloneClientList@lvtest.com');
		usr.profileId = IC_UTILS.getSAProfile();
		insert usr;
		User usr2 = IC_TestFactory.createUser('Test2CloneClientList@lvtest.com');
		usr2.profileId = IC_UTILS.getSAProfile();
		insert usr2;
		
		ApexPages.currentPage().getParameters().put('id',cli.Id);
        IC_CloneClientList_VFCx ctrl = new IC_CloneClientList_VFCx();
        ctrl.lstCliList.get(0).TECH_UserId__c = usr.Id;
        ctrl.lstCliList.get(1).TECH_UserId__c = usr2.Id;
        ctrl.save();
        
		List<CLI_CliList__c> lstCliList = [select Id from CLI_CliList__c where Name='Test'];
		Integer nbList = lstCliList.size();

		System.assertEquals(nbList, 3);
        
        ctrl.cancel();
        
    }
}