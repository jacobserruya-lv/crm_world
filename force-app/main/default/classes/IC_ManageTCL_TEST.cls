@isTest
public class IC_ManageTCL_TEST {

	Static testMethod void pageRefTest(){

	PageReference pageRef1 = new PageReference('/apex/IC_TargetedClientLists_New?action=target');
	PageReference pageRef2 = new PageReference('/apex/IC_DeactivateLists?action=target');
	PageReference pageRef3 = new PageReference('/apex/IC_MassTransferClients?action=reassign');

	Test.startTest();

	System.assertNotEquals(null,IC_ManageTCLTabs.RedirectToTCLPage());
	System.assertNotEquals(null,IC_ManageTCLTabs.RedirectToDesactivateTCLPage());
	System.assertNotEquals(null,IC_ManageTCLTabs.RedirectToMassReassignTCLPage());

	Test.stopTest();
}
}