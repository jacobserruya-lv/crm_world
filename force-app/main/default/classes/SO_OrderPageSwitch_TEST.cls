/**
 * This is a test class for class SO_OrderPageSwitch_CTRL
 * @createdBy           Ester Mendelson, 28-12-2015
 * @lastModifiedBy      Ester Mendelson, 28-12-2015
 */

 @isTest
private class SO_OrderPageSwitch_TEST {
	
	/**
	* [Set database]
	* @scenario    		[insert objects to the system]
	* @result           [database to work with]
	* @createdBy      
    * @lastModifiedBy 	 Ester Mendelson, 28-12-2015
	*/
	
	@testSetup static void setUp() {

		SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true,true);
		List<Opportunity> opp =[SELECT ID FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		SPO_FirmOrder__c firmOrder = new SPO_FirmOrder__c (SPO_BriefName__c = opp[0].id,SPO_Substatus__c = 'Codification',SPO_FirmOrderStatus__c = 'Creation in progress',LineNumber__c = 18);
		insert firmOrder; 
	}
	
	@isTest static void orderPageSwitchPage() {
		List<Opportunity> opp =[SELECT ID,SPO_DisplayOrder__c,AccountId,Account.Name
										,Account.LastName,toLabel(Account.Salutation),SPO_OpportunityCloning__c
										,SPO_Store__c,SPO_Store__r.RetailStoreId__c,SPO_Session_State__c,SPO_BaseSKURefmodelSKU__c
										,SPO_BaseSKURefmodelSKU__r.Name,SPO_BaseSKURefmodelSKU__r.SKUCode__c,StageName,OwnerId
 		FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];

		Test.startTest();
		SO_OrderPageSwitch orderPS = new SO_OrderPageSwitch();
		orderPS.buildTargetPageMap(opp);

		opp[0].StageName = 'In progress';
		SO_Session.startSession(opp[0]);
		SPO_FirmOrder__c testfo = orderPS.actualOrder; 
		SO_OrderPageSwitch.isReadonlyMode();

		system.assertEquals(SO_OrderPageSwitch.isReadonlyMode(),true);

		orderPS.buildTargetPageMap(opp);
		String testString = orderPS.sfoUserRoleName;

		SO_OrderPageSwitch.retPermissionByUserMap();

		SPO_FirmOrder__c firmOrder = [SELECT Id ,SPO_FirmOrderStatus__c FROM SPO_FirmOrder__c WHERE SPO_BriefName__c =:opp[0].id LIMIT 1];

		system.assertEquals(SO_OrderPageSwitch.retActualOrder(new List<SPO_FirmOrder__c>{new SPO_FirmOrder__c()}) ,new SPO_FirmOrder__c());
        
		firmOrder.SPO_FirmOrderStatus__c = 'Production in progress';
		update firmOrder;

		orderPS.buildTargetPageMap(opp);
		firmOrder.SPO_FirmOrderStatus__c = 'Distribution in progress';
		update firmOrder;

		orderPS.buildTargetPageMap(opp);

		Boolean bool = SO_OrderPageSwitch.isWithoutQuotation();
        Test.stopTest();
	}
}