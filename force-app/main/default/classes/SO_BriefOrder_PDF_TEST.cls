/**
 * This is a test class for class SO_BriefOrder_PDF_CTRL
 * @createdBy           Ester Mendelson, 29-12-2015
 * @lastModifiedBy      Ester Mendelson, 29-12-2015
 */

@isTest
private class SO_BriefOrder_PDF_TEST {

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
		dataModel.customSettingForClientSearchInit(); 
		Store__c store = new Store__c(Currency__c='USD',RetailStoreId__c ='12334');
		insert store;

		List<Opportunity> opp =[SELECT ID FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		opp[0].SPO_ExteriorMaterialColor1__c = '#ffff';
		update opp[0];

		SPO_Colors__c colore = new SPO_Colors__c (Name ='#ffff');
		insert colore;
	}
	
	@isTest static void testOppCm() {

		PageReference ref =  new PageReference('/apex/SO_BriefOrder_PDF');
		Test.setCurrentPage(ref);

		List<ProductReferential__c> proList = [SELECT ID,SKUCode__c FROM ProductReferential__c WHERE name ='PR-001' LIMIT 1];
		List<Store__c > storList = [SELECT ID FROM Store__c WHERE RetailStoreId__c ='12334' LIMIT 1];
		List<Opportunity> opp =[SELECT ID FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		opp[0].SPO_ProductCategory__c = SO_PicklistDependency.OPP_WATCH;
		opp[0].SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_SPO_MTO;
		opp[0].SPO_Exo__c ='Yes';
		opp[0].SPO_ExteriorMaterialColor1__c ='test';
		opp[0].SPO_ExteriorMaterial1__c ='test';
    	opp[0].SPO_LiningInteriorMaterial1__c ='test';
    	opp[0].SPO_LiningInteriorColor1__c ='test'; 
    	opp[0].SPO_ColorMetalicparts__c ='test';
    	opp[0].SPO_LockNumber__c ='123';
    	opp[0].SPO_Painting__c ='test';
    	opp[0].SPO_BeltSize__c ='test';
    	opp[0].SPO_DestinationWatch__c =proList[0].id;
    	opp[0].SPO_StrapMaterial__c ='test';
    	opp[0].SPO_StrapColor__c ='test';
    	opp[0].SPO_WristSize__c ='test';
    	opp[0].SPO_SizeUnit__c='Cm';
    	opp[0].SPO_SkuQuantity__c =5;
    	opp[0].SPO_UnitRetailPriceQuotation__c =2.1;
    	opp[0].SPO_Store__c =storList[0].id;
		update opp[0];

		ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);
		SO_BriefOrder_PDF_CTRL ctrl= new SO_BriefOrder_PDF_CTRL(sc);
	}
	@isTest static void testOppInch() {

		PageReference ref =  new PageReference('/apex/SO_BriefOrder_PDF');
		Test.setCurrentPage(ref);

		List<Store__c > storList = [SELECT ID FROM Store__c WHERE RetailStoreId__c ='12334' LIMIT 1];
		List<ProductReferential__c> proList = [SELECT ID,SKUCode__c FROM ProductReferential__c WHERE name ='PR-001' LIMIT 1];
		List<Opportunity> opp =[SELECT ID FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];

		opp[0].SPO_ProductCategory__c = SO_PicklistDependency.OPP_WATCH;
		opp[0].SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_SPO_MTO;
		opp[0].SPO_Exo__c ='Yes';
		opp[0].SPO_ExteriorMaterialColor1__c ='#ffff';
		opp[0].SPO_ExteriorMaterial1__c ='#ffff';
    	opp[0].SPO_LiningInteriorMaterial1__c ='#ffff';
    	opp[0].SPO_LiningInteriorColor1__c ='#ffff'; 
    	opp[0].SPO_ColorMetalicparts__c ='test';
    	opp[0].SPO_LockNumber__c ='123';
    	opp[0].SPO_Painting__c ='test';
    	opp[0].SPO_BeltSize__c ='test';
    	opp[0].SPO_DestinationWatch__c =proList[0].id;
    	opp[0].SPO_StrapMaterial__c ='test';
    	opp[0].SPO_StrapColor__c ='test';
    	opp[0].SPO_WristSize__c ='test';
    	opp[0].SPO_SizeUnit__c ='Inch';
    	opp[0].SPO_SkuQuantity__c =5;
    	opp[0].SPO_UnitRetailPrice__c = 2.4;
    	opp[0].SPO_Store__c = storList[0].id;
		update opp[0];

		ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);

		SO_BriefOrder_PDF_CTRL ctrl= new SO_BriefOrder_PDF_CTRL(sc);
		ctrl.init();

		SPO_Colors__c colore = [SELECT Id From SPO_Colors__c WHERE Name ='#ffff' LIMIT 1];
		colore.SPO_CodeCouleur__c = 'test';
		update colore;

		ctrl.init();
	}
}