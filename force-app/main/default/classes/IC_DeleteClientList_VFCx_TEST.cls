/**
    About
    -----
    Description: Test Delete Client Lists 
    Created for: SOW: IC001 ICON project (IC0N Release 2014)
    Create date: May 2014

    Details
    -------
    Test Delete Client List 

    Update History
    --------------
    May 2014 / IC001/ Created by by Pape Babacar DIOUF  - Capgemini (Pape-Babacar.Diouf@capgemini.com)

    --------------
*/


@isTest
private class IC_DeleteClientList_VFCx_TEST {

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
        CLI_CliList__c cli1 = new CLI_CliList__c(Name = 'Test', Description__c = 'My description', Active__c = true, OwnerId = UserInfo.getUserId()); insert cli1;
        
		User usr = IC_TestFactory.createUser('TestCloneClientList@lvtest.com');
		usr.profileId = IC_UTILS.getSAProfile();
		insert usr;
		CLI_CliList__c cli2 = new CLI_CliList__c(Name = 'Test', Description__c = 'My description', Active__c = true, OwnerId = usr.Id); insert cli2;
		
		User usr2 = IC_TestFactory.createUser('Test2CloneClientList@lvtest.com');
		usr2.profileId = IC_UTILS.getSAProfile();
		insert usr2;
		CLI_CliList__c cli3 = new CLI_CliList__c(Name = 'Test', Description__c = 'My description', Active__c = true, OwnerId = usr2.Id); insert cli3;
		
		List<CLI_CliList__c> lstCliList = [select Id from CLI_CliList__c where Name='Test'];
		Integer nbList = lstCliList.size();
		System.assertEquals(nbList, 3); 
		
		ApexPages.currentPage().getParameters().put('id',cli1.Id);
        IC_DeleteClientList_VFCx ctrl = new IC_DeleteClientList_VFCx();
        //ApexPages.currentPage().getParameters().put('id',cli1.Id);
        
        ctrl.lstcUser.add(new IC_DeleteClientList_VFCx.cUser(usr));
        ctrl.lstcUser.add(new IC_DeleteClientList_VFCx.cUser(usr2));
        Ctrl.deleteCL();
        Ctrl.CheckAll();
        ctrl.lstcUser.get(0).selected = true;
        ctrl.lstcUser.get(1).selected = true;
        Ctrl.deleteCL();
        Ctrl.CheckAll();
        
        List<CLI_CliList__c>  lstCliListBis = [select Id from CLI_CliList__c where Name='Test'];
		integer nbListBis = lstCliListBis.size();
		System.assertEquals(nbListBis, 1);
		
        ctrl.cancel();
        
        ctrl.getUserNameLabel();
        ctrl.getUserTitleLabel();
        ctrl.getUserEmailLabel();
        ctrl.getUserDefaultStoreLabel();
        ctrl.getUserRoleNameLabel();
        ctrl.getProfileNameLabel();
        ctrl.getUserIsActiveLabel();
        ctrl.getObjectName('User');
        
        ctrl.getFieldLabel('User', 'Title');
        ctrl.getObjectLabel('UserRole');
        
        
    }
    
    
}