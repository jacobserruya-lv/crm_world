@isTest
private class VO_Template_TEST {
	
	@testSetup
	static void initData()
	{
		Test.loadData(VO_Config__c.sobjectType, 'VO_Config_TestCLS');
	}
	
	@isTest static void templateInit() 
	{
		VO_Template ctrl = new VO_Template();
	}
	
}