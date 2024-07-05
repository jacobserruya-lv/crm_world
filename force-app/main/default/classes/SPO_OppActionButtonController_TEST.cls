@isTest
public class SPO_OppActionButtonController_TEST {


	@isTest static void Test_getUser(){
		Profile p = [SELECT Id FROM Profile WHERE Name = 'MIY_Admin' LIMIT 1];
		User usr = IC_TestFactory.createUser('utest@test.fr',p.Id);
		insert usr;
		User u = SPO_OpportunityActionButtonController.getUser();
        System.assertNotEquals(null, u);
	}

	@isTest static void Test_findOpportunityById(){

		Opportunity opp                 = new Opportunity();
		opp.Name = 'otest';
		opp.SPO_ProductCategory__c = 'Leather Goods';
		opp.SPO_OrderType__c = 'SPO/MTO';
		opp.SPO_CreationType__c = 'otest';
		opp.StageName = 'Brief in progress';
		opp.CloseDate = Date.today();
		insert opp;
		System.debug('$$$$$$$$$$$'+opp.Id);

		Opportunity o = SPO_OpportunityActionButtonController.findOpportunityById(opp.Id);

		System.assertEquals(opp.Id,o.Id);

	}

	// also test addDeposit private method
	@isTest static void Test_updateOpportunity(){

		SO_Settings__c st = new SO_Settings__c();
		st.Name= 'WSCallNoCall';
		st.Value__c = 'nocall';

		insert st;

		//SO_Settings__c mySO_Settings1 = [SELECT Id , Name, Value__c FROM SO_Settings__c WHERE Name = 'WSCallNoCall'];
		//insert mySO_Settings1;

		System.debug('#########################'+st.Name);

		//mySO_Settings1.Value__c ='NoCall';

		//update mySO_Settings1;

		//System.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'+ mySO_Settings1);
		// Map<string, Picklist_Dependency__c> picklistDependencyByName;
		Picklist_Dependency__c leather_good = new Picklist_Dependency__c();
		leather_good.Opportunity_Category__c = 'Leather goods';
		leather_good.Name = 'Leather good';
		insert leather_good;

		Picklist_Dependency__c Accessory = new Picklist_Dependency__c();
		Accessory.Opportunity_Category__c = 'Accessories';
		Accessory.Name = 'Accessory';
		insert Accessory;

		Picklist_Dependency__c Watch = new Picklist_Dependency__c();
		Watch.Opportunity_Category__c = 'Watches';
		Watch.Name = 'Watch';
		insert Watch;
		//picklistDependencyByName = Picklist_Dependency__c.getAll();
		// System.debug('^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'+picklistDependencyByName);


		String OPP_LEATHER_GOOD                                = leather_good.Opportunity_Category__c;
		String ORDER_TYPE_MTO_ON_CATALOG                               = 'MTO on Catalog (Hardsided)';
		String ORDER_TYPE_CREATION = 'Creation (Hardsided & Soft)';

		Store__c s = new Store__c();
		s.RetailStoreId__c = 'N23';
		insert s;
		ProductReferential__c pRef=new ProductReferential__c();
		pRef.Name='ABCD';
		pRef.SKUCode__c='M04558';
		insert pRef;


		Opportunity opp                 = new Opportunity();
		opp.Name = 'otest';
		//opp.SPO_ProductCategory__c = 'Leather goods';
		//opp.SPO_OrderType__c = 'MTO on Catalog (Hardsided)';
		opp.SPO_CreationType__c = 'otest';
		opp.SPO_ProductCategory__c = OPP_LEATHER_GOOD;
		opp.SPO_OrderType__c = 'MTO on Catalog (Hardsided)';
		opp.StageName = 'Deposit sent';
		opp.SPO_Free__c = false;
		opp.SPO_DepositAmount__c = 1000;
		opp.SPO_UnitRetailPrice__c = 1000;
		opp.SPO_UnitRetailPriceQuotation__c = 1000;
		opp.SPO_SkuQuantity__c = 2;
		opp.SPO_DisplayOrder__c = false;
		opp.CloseDate = Date.today();
		opp.SPO_CACode__c='AWA';
		opp.SPO_Store__c = s.id;
		opp.Amount=1000;
		opp.SPO_DepositSentStatusDate__c =Date.today();
		opp.Send_to_ERP__c = false;
		opp.SPO_SpecialOrderSKUCodeRef__c=pRef.id;

		insert opp;
		opp.recalculateFormulas();
		Opportunity opp1        = new Opportunity();
		opp1.Name = 'otest2';
		//opp.SPO_ProductCategory__c = 'Leather goods';
		//opp.SPO_OrderType__c = 'MTO on Catalog (Hardsided)';
		opp1.SPO_CreationType__c = 'otest2';
		opp1.SPO_ProductCategory__c = OPP_LEATHER_GOOD;
		opp1.SPO_OrderType__c = ORDER_TYPE_CREATION;
		opp1.StageName = 'Closed Won';
		opp1.SPO_Free__c = false;
		opp1.SPO_DepositAmount__c = 1000;
		opp1.SPO_UnitRetailPrice__c = 1000;
		opp1.SPO_UnitRetailPriceQuotation__c = 1000;
		opp1.SPO_SkuQuantity__c = 2;
		opp1.SPO_DisplayOrder__c = true;
		opp1.CloseDate = Date.today();
		opp1.SPO_CACode__c='AWA';
		opp1.SPO_Store__c = s.id;
		opp1.Amount=1000;
		opp1.SPO_DepositSentStatusDate__c =Date.today();
		opp1.Send_to_ERP__c = true;
		opp1.SPO_SpecialOrderSKUCodeRef__c=pRef.id;
		insert opp1;
		opp1.recalculateFormulas();



		System.debug('$$$$$$$$$$$$$$'+opp.SPO_TotalAmount__c);
		System.debug('$$$$$$$$$$$$$$'+opp.SPO_StoreCode__c);
		System.debug('$$$$$$$$$$$$$$'+opp.hasQuotation__c);
		System.debug('$$$$$$$$$$$$$$'+opp.Name);

		Opportunity o = [SELECT Id,Amount,SPO_StoreCode__c,Send_to_ERP__c,SPO_DepositSentStatusDate__c, SPO_CreationType__c,  SPO_ProductCategory__c, SPO_OrderType__c,
		                 StageName, SPO_CACode__c, SPO_SkuQuantity__c, SPO_UnitRetailPriceQuotation__c, SPO_UnitRetailPrice__c,
		                 SPO_DepositAmount__c, SPO_DisplayOrder__c, CloseDate, SPO_Free__c FROM Opportunity WHERE id=:opp.id];

		Opportunity o2 = [SELECT Id,Amount,Send_to_ERP__c,SPO_StoreCode__c,SPO_DepositSentStatusDate__c, SPO_CreationType__c,  SPO_ProductCategory__c, SPO_OrderType__c,
		                  StageName, SPO_CACode__c, SPO_SkuQuantity__c, SPO_UnitRetailPriceQuotation__c, SPO_UnitRetailPrice__c,
		                  SPO_DepositAmount__c, SPO_DisplayOrder__c, CloseDate, SPO_Free__c FROM Opportunity WHERE id=:opp1.id];

		System.debug('$$$$$$$$$$$$$$'+o.SPO_StoreCode__c);


		o.Name = 'OOOtest';
		o2.Name='oooTest2';
		try{
			Test.startTest();
			SPO_OpportunityActionButtonController.updateOpportunity(o);
			SPO_OpportunityActionButtonController.updateOpportunity(o2);
		}
		catch(AuraHandledException e)
		{
			System.debug(e.getMessage());
		}
		Test.stopTest();



		System.assertEquals('OOOtest', o.Name);
		System.assertEquals('Creation in progress', o.StageName);



	}

	@isTest static void Test_UpdateOpportunity_Error() {

		Opportunity opp                 = new Opportunity();
		opp.Name = 'otest';
		//opp.SPO_ProductCategory__c = 'Leather goods';
		//opp.SPO_OrderType__c = 'MTO on Catalog (Hardsided)';
		opp.SPO_CreationType__c = 'otest';
		opp.SPO_ProductCategory__c = 'Leather goods';
		opp.SPO_OrderType__c = 'Creation (Hardsided & Soft)';
		opp.StageName = 'Brief in progress';
		opp.CloseDate = Date.today();

		insert opp;


		Opportunity o = [SELECT Id, Name FROM Opportunity WHERE id=:opp.id];


		o.Name = 'OOOtest';

		Test.startTest();
		SPO_OpportunityActionButtonController.updateOpportunity(o);
		Test.stopTest();


		System.assertEquals('OOOtest', o.Name);


	}

	@isTest
	public static void Test_updateFirmOrders(){

		Opportunity opp         = new Opportunity();
		opp.Name = 'otest';
		//opp.SPO_ProductCategory__c = 'Leather goods';
		//opp.SPO_OrderType__c = 'MTO on Catalog (Hardsided)';
		opp.SPO_CreationType__c = 'otest';
		opp.SPO_ProductCategory__c = 'Leather goods';
		opp.SPO_OrderType__c = 'Creation (Hardsided & Soft)';
		opp.StageName = 'Brief in progress';
		opp.CloseDate = Date.today();

		insert opp;


		List<SPO_FirmOrder__c> foList = new List<SPO_FirmOrder__c>();
		foList.add(new SPO_FirmOrder__c(
				   SPO_BriefName__c = opp.id,
				   Name = 'Test FO 1',
				   LineNumber__c = 001));
		foList.add(new SPO_FirmOrder__c(
				   SPO_BriefName__c = opp.id,
				   Name = 'Test FO 2',
				   LineNumber__c = 002));

		insert foList;

		SPO_OpportunityActionButtonController.updateFirmOrderDB(opp.id);

		list<SPO_FirmOrder__c> newFoList = [SELECT id, SPO_FirmOrderStatus__c FROM SPO_FirmOrder__c WHERE SPO_BriefName__c = :opp.id];

		for (SPO_FirmOrder__c fo : newFoList) {
			System.assertEquals('Received in store', fo.SPO_FirmOrderStatus__c);
		}
	}

	@isTest
	public static void Test_duplicateOrder() {
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successOrderPdf', 'OrderPdf'));

		/*ProductCatalogue__c product = new ProductCatalogue__c();
		   product.Name='product test';
		   product.ProductGroup__c = 'Leather Goods';
		   product.SKU__c = '123';
		   insert product;*/

		Opportunity opp         = new Opportunity();
		//opp.Name = 'otest';
		//opp.SPO_ProductCategory__c = 'Leather goods';
		opp.SPO_OrderType__c = 'MTO on Catalog (Hardsided)';
		opp.SPO_ProductCategory__c = 'Leather goods';
		opp.StageName = 'Production in progress';
		opp.Name = 'test1';
		opp.CloseDate = Date.today();

		insert opp;

		List<SPO_FirmOrder__c> foList = new List<SPO_FirmOrder__c>();
		foList.add(new SPO_FirmOrder__c(
				   SPO_BriefName__c = opp.id,
				   Name = 'Test FO 1',
				   LineNumber__c = 001,
				   DistributionStatus__c = 'Sent from workshop',
				   SPO_TechETLStatus__c = 'Perso order validated',
				   SPO_FirmOrderStatus__c = 'Distribution in progress'));
		foList.add(new SPO_FirmOrder__c(
				   SPO_BriefName__c = opp.id,
				   Name = 'Test FO 2',
				   LineNumber__c = 002,
				   DistributionStatus__c = 'Sent from workshop',
				   SPO_TechETLStatus__c = 'Perso order validated',
				   SPO_FirmOrderStatus__c = 'Distribution in progress'));

		insert foList;

		Test.startTest();
		ApexPages.StandardController order = new ApexPages.standardController(opp);
		SPO_OppStandardControllerExtension oppSC = new SPO_OppStandardControllerExtension(order);
		oppSC.duplicateOrder();
		Test.stopTest();

		list<SPO_FirmOrder__c> linesOrder = [SELECT id, SPO_TechETLStatus__c, SPO_FirmOrderStatus__c FROM SPO_FirmOrder__c ORDER BY CreatedDate];
		System.assertEquals('Creation in progress', linesOrder[2].SPO_FirmOrderStatus__c);
	}

	@isTest
	public static void Test_updateFirmOrderReceivedInStore() {
		// Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successOrderPdf', 'OrderPdf'));

		/*ProductCatalogue__c product = new ProductCatalogue__c();
		   product.Name='product test';
		   product.ProductGroup__c = 'Leather Goods';
		   product.SKU__c = '123';
		   insert product;*/

		Opportunity opp         = new Opportunity();
		//opp.Name = 'otest';
		//opp.SPO_ProductCategory__c = 'Leather goods';
		opp.SPO_OrderType__c = 'MTO on Catalog (Hardsided)';
		opp.SPO_ProductCategory__c = 'Leather goods';
		opp.StageName = 'Production in progress';
		opp.Name = 'test1';
		opp.CloseDate = Date.today();
		opp.Received_in_Store_Date__c = Date.today();

		insert opp;

		List<SPO_FirmOrder__c> foList = new List<SPO_FirmOrder__c>();
		foList.add(new SPO_FirmOrder__c(
				   SPO_BriefName__c = opp.id,
				   Name = 'Test FO 1',
				   LineNumber__c = 001,
				   DistributionStatus__c = 'Sent from workshop',
				   SPO_TechETLStatus__c = 'Perso order validated',
				   SPO_FirmOrderStatus__c = 'Distribution in progress'));
		foList.add(new SPO_FirmOrder__c(
				   SPO_BriefName__c = opp.id,
				   Name = 'Test FO 2',
				   LineNumber__c = 002,
				   DistributionStatus__c = 'Sent from workshop',
				   SPO_TechETLStatus__c = 'Perso order validated',
				   SPO_FirmOrderStatus__c = 'Distribution in progress'));

		insert foList;
		Test.startTest();
		SPO_FirmOrder__c testFo = SPO_OpportunityActionButtonController.updateFirmOrderReceivedInStore(foList[0].id);
		Test.stopTest();

		System.assertEquals('Received in store', testFo.SPO_FirmOrderStatus__c);
	}
	@isTest
	public static void Test_cancelFirmOrder() {
		Profile p = [SELECT Id FROM Profile WHERE Name = 'MIY_Admin' LIMIT 1];
		User usr = IC_TestFactory.createUser('utest@test.fr',p.Id);
		usr.BypassVR__c=true;
		insert usr;
		system.runAs(usr){
			Opportunity opp         = new Opportunity();
			//opp.Name = 'otest';
			//opp.SPO_ProductCategory__c = 'Leather goods';
			opp.SPO_OrderType__c = 'MTO on Catalog (Hardsided)';
			opp.SPO_ProductCategory__c = 'Leather goods';
			opp.StageName = 'Cancelled by production';
			opp.Name = 'test1';
			// opp.TECH_Nb_FO_not_cancelled__c=1;
			opp.CloseDate = Date.today();
			opp.SPO_StopBriefComment__c='Test';
			opp.SPO_StopBriefReason__c='Production - Reject by supply-chain';
			insert opp;

			SPO_FirmOrder__c fo         = new SPO_FirmOrder__c();
			fo.SPO_BriefName__c = opp.id;
			fo.Name = 'Test FO 1';
			fo.LineNumber__c = 001;
			fo.DistributionStatus__c = 'Sent from workshop';
			fo.SPO_TechETLStatus__c = 'Perso order validated';
			fo.SPO_FirmOrderStatus__c = 'Cancelled by production';
			fo.Cancellation_Reason__c='Production - Reject by supply-chain';
			insert fo;

			Test.startTest();
			SPO_OpportunityActionButtonController.updateStopOrderField(opp);
			SPO_FirmOrder__c testFo = SPO_OpportunityActionButtonController.cancelFirmOrderDB(fo.id,opp);
			System.assertEquals('Cancelled by store', testFo.SPO_FirmOrderStatus__c);
			Test.stopTest();
		}
	}
	@isTest
	public static void Test_getOpportunityByFirmOrder() {
		Opportunity opp         = new Opportunity();
		//opp.Name = 'otest';
		//opp.SPO_ProductCategory__c = 'Leather goods';
		opp.SPO_OrderType__c = 'MTO on Catalog (Hardsided)';
		opp.SPO_ProductCategory__c = 'Leather goods';
		opp.StageName = 'Production in progress';
		opp.Name = 'test1';
		// opp.TECH_Nb_FO_not_cancelled__c=1;
		opp.CloseDate = Date.today();
		insert opp;
		SPO_FirmOrder__c fo         = new SPO_FirmOrder__c();
		fo.SPO_BriefName__c = opp.id;
		fo.Name = 'Test FO 1';
		fo.LineNumber__c = 001;
		fo.DistributionStatus__c = 'Sent from workshop';
		fo.SPO_TechETLStatus__c = 'Perso order validated';
		fo.SPO_FirmOrderStatus__c = 'Distribution in progress';
		insert fo;
		Test.startTest();
		SPO_FirmOrder__c testFo = SPO_OpportunityActionButtonController.getOpportunityByFirmOrder(fo.id);
		System.assertNotEquals(null, testFo);
		Test.stopTest();
	}
}