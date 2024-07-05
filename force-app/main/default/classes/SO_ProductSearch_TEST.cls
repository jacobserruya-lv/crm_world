@isTest
private class SO_ProductSearch_TEST {
	
	@testSetup static void setUp() {
		SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true,true);
	}

	@isTest static void testInitProductSearch() {
		
		PageReference ref =  new PageReference('/apex/so_productsearch');
        Test.setCurrentPage(ref);
		SO_ProductSearch_CTRL ctrl = new SO_ProductSearch_CTRL();
		system.assertEquals(ctrl.searchAvailable,true);
	}

	@isTest static void testInitProductSearchWithSession() {

		List<Opportunity> opp =[SELECT ID,SPO_ProductCategory__c,OwnerId,SPO_BaseSKURefmodelSKU__c FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		PageReference ref =  new PageReference('/apex/so_productsearch');
        ApexPages.currentPage().getParameters().put('bid', opp[0].id);
		ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);
        Test.setCurrentPage(ref);
		SO_ProductSearch_CTRL ctrl = new SO_ProductSearch_CTRL();

	}
	
	@isTest static void retTemplate() {
		List<ProductReferential__c> proList = [SELECT ID,SKUCode__c FROM ProductReferential__c WHERE name ='PR-001' LIMIT 1];
		Test.setFixedSearchResults(new List<Id>{proList[0].Id});
		List<Opportunity> opp =[SELECT ID FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		PageReference ref =  new PageReference('/apex/so_productsearch');
        ref.getParameters().put('bid',opp[0].id);
        Test.setCurrentPage(ref);

		SO_ProductSearch_CTRL ctrl = new SO_ProductSearch_CTRL();
		ctrl.search();
		ctrl.onCategoryChange();
		ctrl.retColumns(null);
		List<Map<String, Object>> objMapList = ctrl.retQueryResult(null,1,1,'','');

		ctrl.getCurrentPosition(null,1,1,1,1,1,1);
		ctrl.retTotalCount('');
		ctrl.clear();
		ctrl.retTotalCount('');

		system.assertEquals(ctrl.getIdOfProductNotFound(),'');
		ctrl.updateBriefAndRedirectToProductSpec();
		
		for(Map<String, Object> objMap : objMapList){
			
			ctrl.retTemplate(null,'Actions',objMap);
			ctrl.retTemplate(null,'SKU',objMap);
			ctrl.retTemplate(null,'Category',objMap);
			ctrl.retTemplate(null,'CommercialName',objMap);
			ctrl.retTemplate(null,'Dimensions',objMap);
			ctrl.retTemplate(null,'Image',objMap);
		}
		
	}
	@isTest static void OrderTypeSPO() {
		List<ProductReferential__c> proList = [SELECT ID,SKUCode__c FROM ProductReferential__c WHERE name ='PR-001' LIMIT 1];
		Test.setFixedSearchResults(new List<Id>{proList[0].Id});
		List<Opportunity> opp =[SELECT ID FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];

		PageReference ref =  new PageReference('/apex/so_productsearch');
        ref.getParameters().put('bid',opp[0].id);
        Test.setCurrentPage(ref);

		SO_ProductSearch_CTRL ctrl = new SO_ProductSearch_CTRL();
		opp[0].SPO_ProductCategory__c = SO_PicklistDependency.OPP_WATCH;
		opp[0].SPO_OrderType__c =SO_PicklistDependency.ORDER_TYPE_SPO_MTO;
		ctrl.entryOpportunity = opp[0];
		ctrl.search();
		ctrl.onCategoryChange();
		ctrl.retColumns(null);
		List<Map<String, Object>> objMapList = ctrl.retQueryResult(null,1,1,'','');

		ctrl.getCurrentPosition(null,1,1,1,1,1,1);
		ctrl.retTotalCount('');
		ctrl.clear();
		ctrl.retTotalCount('');
		system.assertEquals(ctrl.getIdOfProductNotFound(),'');
		ctrl.updateBriefAndRedirectToProductSpec();
	}

	@isTest static void testOrderTypeSPO1() 
	{
		List<ProductReferential__c> proList = [SELECT ID,Name,SKUCode__c,ProductCategory__c FROM ProductReferential__c WHERE Name ='PR-001' LIMIT 1];
		Test.setFixedSearchResults(new List<Id>{proList[0].Id});
		List<Opportunity> opp =[SELECT ID FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];

		PageReference ref =  new PageReference('/apex/so_productsearch');
        ref.getParameters().put('bid',opp[0].id);
        Test.setCurrentPage(ref);

		SO_ProductSearch_CTRL ctrl = new SO_ProductSearch_CTRL();
		ctrl.nameOrSKU = 'PR-001';
 		ctrl.entryOpportunity.SPO_ProductCategory__c 	= SO_PicklistDependency.OPP_LEATHER_GOOD;
		ctrl.entryOpportunity.SPO_OrderType__c 			= SO_PicklistDependency.ORDER_TYPE_SPO_MTO;

		opp[0].SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		opp[0].SPO_OrderType__c =SO_PicklistDependency.ORDER_TYPE_SPO_MTO;
		update opp;
		ctrl.entryOpportunity = opp[0];
		ctrl.search();
		ctrl.onCategoryChange();
		ctrl.retColumns(null);
		System.debug('testOrderTypeSPO1 PP1: ' + proList[0]);
		proList[0].ProductCategory__c = SO_PicklistDependency.PROR_LEATHER_GOOD;
		proList[0].SKUCode__c = 'PRTEST';
		proList[0].Status__c = '40';
		proList[0].SubFamily__c  = 'TRUNKS';
		proList[0].Length__c = 10;
		proList[0].Witdth__c = 10;
		proList[0].Height__c = 10;
		System.debug('testOrderTypeSPO1 PP2: ' + proList[0]);
		update proList;
		System.debug('testOrderTypeSPO1 PP3-Search:');
		ctrl.search();
		List<Map<String, Object>> objMapList = ctrl.retQueryResult(null,1,1,'','');

		for(Map<String, Object> objMap : objMapList){
			ctrl.retTemplate(null,'Actions',objMap);
			ctrl.retTemplate(null,'Image',objMap);
			ctrl.retTemplate(null,'SKU',objMap);
			ctrl.retTemplate(null,'Category',objMap);
			ctrl.retTemplate(null,'Name',objMap);
			ctrl.retTemplate(null,'CommercialName',objMap);
			ctrl.retTemplate(null,'Dimensions',objMap);
		}
		ctrl.setDefaultValuesForOrderType();
		SO_ProductSearch_CTRL.ProdCatDependency pd= new SO_ProductSearch_CTRL.ProdCatDependency('','');
		
	}

	@isTest static void testOrderTypeHardsided() {
		List<ProductReferential__c> proList = [SELECT ID,SKUCode__c FROM ProductReferential__c WHERE name ='PR-001' LIMIT 1];
		Test.setFixedSearchResults(new List<Id>{proList[0].Id});
		List<Opportunity> opp =[SELECT ID FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];

		PageReference ref =  new PageReference('/apex/so_productsearch');
        ref.getParameters().put('bid',opp[0].id);
        Test.setCurrentPage(ref);

		SO_ProductSearch_CTRL ctrl = new SO_ProductSearch_CTRL();
		SO_ProductSearch_CTRL contr = ctrl.contr;
		List<ProductReferential__c> prodReferentialList = ctrl.prodReferentialList;
		opp[0].SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
		opp[0].SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_MTO_ON_CATALOG;
		ctrl.nameOrSKU = 'testSKU';
		ctrl.selectedProductRef = 'Test';
		ctrl.entryOpportunity = opp[0];
		ctrl.search();
		ctrl.onCategoryChange();
		ctrl.retColumns(null);
		List<Map<String, Object>> objMapList = ctrl.retQueryResult(null,1,1,'','');

		ctrl.getCurrentPosition(null,1,1,1,1,1,1);
		ctrl.retTotalCount('');
		ctrl.clear();
		ctrl.retTotalCount('');
		ctrl.getIdOfProductNotFound();
		ctrl.updateBriefAndRedirectToProductSpec();

	}
	
}