/**
 * This is a test class for class SO_BaseController_CTRL
 * @createdBy           Ester Mendelson, 29-12-2015
 * @lastModifiedBy      Ester Mendelson, 10-01-2015
 */

@isTest
private class SO_BaseController_Test {

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
	}

	@isTest static void SO_ProductSpeWithoutQueryString() {
		
		List<Opportunity> opp =[SELECT ID,Name
										,OwnerId
										,StageName
										,AccountId
										,Account.Name
										,Account.LastName
										,toLabel(Account.Salutation)

										,SPO_OpportunityCloning__c
										,SPO_ConcatenateTitle__c
										,SPO_Store__c
										,SPO_Store__r.RetailStoreId__c
										,SPO_DisplayOrder__c
										,SPO_Session_State__c
										,SPO_BaseSKURefmodelSKU__c
										,SPO_BaseSKURefmodelSKU__r.Name
										,SPO_BaseSKURefmodelSKU__r.SKUCode__c
								FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		SO_Session.startSession(opp[0]);
		
        PageReference ref =  new PageReference('/apex/SO_ProductSpe');
		Test.setCurrentPage(ref);

		ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);
		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(sc);
		ctrl.setBreadcrumbsState('test');
	}

	@isTest static void ProductSpeWithIdQueryString() {
		
        PageReference ref =  new PageReference('/apex/SO_ProductSpe?id=');
		Test.setCurrentPage(ref);
		
		List<Opportunity> opp =[SELECT ID,Name
									,OwnerId
									,StageName
									,AccountId
									,Account.Name
									,Account.LastName
									,toLabel(Account.Salutation)

									,SPO_OpportunityCloning__c
									,SPO_ConcatenateTitle__c
									,SPO_Store__c
									,SPO_Store__r.RetailStoreId__c
									,SPO_DisplayOrder__c
									,SPO_Session_State__c
									,SPO_BaseSKURefmodelSKU__c
									,SPO_BaseSKURefmodelSKU__r.Name
									,SPO_BaseSKURefmodelSKU__r.SKUCode__c
							FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		SO_Session.startSession(opp[0]);
		
		ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);
		SO_ProductSpe_CTRL ctrl = new SO_ProductSpe_CTRL(sc);
		ctrl.getBreadcrumb('client');
		ctrl.getBreadcrumb('clientA');
		String pageName = ctrl.pageName;
		
	}

	@isTest static void testQuotationrequested() {
		
        PageReference ref =  new PageReference('/apex/so_quotationrequested');
		Test.setCurrentPage(ref);

		SO_BaseController ctrl = new SO_BaseController();
		String stringVal = ctrl.navActiveTab;
		stringVal  = ctrl.tabView;

		String testBassCon = ctrl.oppAccessory;
		testBassCon = ctrl.prorAccessory;
		testBassCon = ctrl.oppRecTypeNameAccessory;
		testBassCon = ctrl.oppLeatherGood;
		testBassCon = ctrl.prorLeatherGood;
		testBassCon = ctrl.oppRecTypeNameLeatherGood;
		testBassCon = ctrl.oppWatch;
		testBassCon = ctrl.prorWatch;
		testBassCon = ctrl.oppRecTypeNameWatch;

		Boolean isShowMessage = ctrl.showMessageOnTop;
		ctrl.init();
	    String pageName = ctrl.pageName;
	}
}