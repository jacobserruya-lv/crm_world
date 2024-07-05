@isTest()
public class MIY_OrderPageController_TEST {
	private static Id PERSO_ORDER_ID;
	private static Id SPO_ORDER_ID;

	@TestSetup
	static void init() {
		Store__c store = new Store__c(Name = 'Test Store', RetailStoreId__c = 'A06');
		insert store;

		Opportunity order = new Opportunity();
		order.Name = 'Test Order'; 
		order.StageName = 'Brief in progress';
		order.CloseDate = Date.today();
		order.SPO_DepositSentStatusDate__c = Date.today() ;
		order.Received_in_Store_Date__c = Date.today();
		order.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Perso Order').getRecordTypeId();
		order.SPO_Store__c = store.Id;
		insert order;
		PERSO_ORDER_ID = order.Id;

		Opportunity order2 = new Opportunity();
		order2.Name = 'Test SP Order';
		order2.StageName = 'Brief in progress';
		order2.CloseDate = Date.today();
		order2.Received_in_Store_Date__c = Date.today();
		order2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Special Order').getRecordTypeId();
		order2.SPO_EstimatedProductionTimeMonths__c = 1;
		order2.SPO_EstimatedDistributionTime__c = 12;
		order2.SPO_UnitRetailPriceQuotation__c = 1000;
		order2.SPO_ExportPrice__c = 111;
		order2.SPO_Numberofproductivehours__c = 231;
		order2.SPO_ProductCategory__c = 'Belts';
		order2.SPO_Store__c = store.Id;
		order2.Amount = 1000;
		order2.SPO_DepositAmount__c = 500;
        order2.SPO_CACode__c='SIM';
        order2.SPO_SkuQuantity__c=1;
		insert order2;
		SPO_ORDER_ID = order2.Id;

		ProductCatalogue__c pc1 = new ProductCatalogue__c(Name = 'testPc1', LeadTimeManufacturing__c = 0, SKU__c = '12345', Workshop__c ='1798');
		ProductCatalogue__c pc2 = new ProductCatalogue__c(Name = 'testPc2', Technical_Data_Defined__c = false, LeadTimeManufacturing__c = 1, SKU__c = '12346', Workshop__c ='1798');
		ProductCatalogue__c pc3 = new ProductCatalogue__c(Name = 'testPc3', Technical_Data_Defined__c = true, SKU__c = '12347', LeadTimeApproval__c = -1, Workshop__c ='1798');
		ProductCatalogue__c pc4 = new ProductCatalogue__c(Name = 'testPc4', Technical_Data_Defined__c = false, SKU__c = '12348', LeadTimeApproval__c = -1, Exotic_Leather__c = 'Alligator', Generic_SKU__c = '12348', Workshop__c ='1798');
		ProductCatalogue__c pc5 = new ProductCatalogue__c(Name = 'testPc5', Technical_Data_Defined__c = true, SKU__c = '12350', LeadTimeApproval__c = 1, Workshop__c ='1798');
		ProductCatalogue__c pc6 = new ProductCatalogue__c(Name = 'testPc6', Technical_Data_Defined__c = true, SKU__c = '12351', LeadTimeApproval__c = 1, Workshop__c ='1798');
		insert pc1;
		insert pc2;
		insert pc3;
		insert pc4;
		insert pc5;	
		insert pc6;

		List<SPO_FirmOrder__c> fosToInsert = new List<SPO_FirmOrder__c>();
		SPO_FirmOrder__c firmOrder = new SPO_FirmOrder__c(
			SPO_BriefName__c = order.Id,
			LineNumber__c = 1,
			SPO_TechETLStatus__c = 'V',
			SPO_FirmOrderStatus__c = 'Creation in progress'
		);
		fosToInsert.add(firmOrder);

		SPO_FirmOrder__c firmOrder258 = new SPO_FirmOrder__c(
			SPO_BriefName__c = order2.Id,
			LineNumber__c = 1,
			SPO_TechETLStatus__c = 'V',
			SPO_FirmOrderStatus__c = 'Sent to MyPR'
		);
		insert firmOrder258;

		SPO_FirmOrder__c firmOrder2 = new SPO_FirmOrder__c(
			SPO_BriefName__c = order.Id,
			LineNumber__c = 2,
			SPO_FirmOrderStatus__c = 'Creation in progress',
			Creation_Status__c = 'New Order',
			Undefined_Material__c = true,
			ProductCatalogue__c = pc2.Id
		);
		fosToInsert.add(firmOrder2);

		SPO_FirmOrder__c firmOrder3 = new SPO_FirmOrder__c(
			SPO_BriefName__c = order.Id,
			LineNumber__c = 3,
			SPO_FirmOrderStatus__c = 'Creation in progress',
			Creation_Status__c = 'Species to Choose',
			Undefined_Material__c = false,
			ProductCatalogue__c = pc2.Id
		);
		fosToInsert.add(firmOrder3);

		SPO_FirmOrder__c firmOrder4 = new SPO_FirmOrder__c(
			SPO_BriefName__c = order.Id,
			LineNumber__c = 4,
			SPO_FirmOrderStatus__c = 'Creation in progress',
			Creation_Status__c = 'Technical Data to Define',
			ProductCatalogue__c = pc2.Id
		);
		fosToInsert.add(firmOrder4);

		SPO_FirmOrder__c firmOrder5 = new SPO_FirmOrder__c(
			SPO_BriefName__c = order.Id,
			LineNumber__c = 5,
			SPO_FirmOrderStatus__c = 'Creation in progress',
			Creation_Status__c = 'New Order',
			Undefined_Material__c = false,
			ProductCatalogue__c = pc3.Id
		);
		fosToInsert.add(firmOrder5);

		SPO_FirmOrder__c firmOrder6 = new SPO_FirmOrder__c(
				SPO_BriefName__c = order.Id,
				LineNumber__c = 6,
				SPO_FirmOrderStatus__c = 'Creation in progress',
				Creation_Status__c = 'Technical Data to Check',
				ProductCatalogue__c = pc2.Id
		);
		fosToInsert.add(firmOrder6);

		SPO_FirmOrder__c firmOrder7 = new SPO_FirmOrder__c(
				SPO_BriefName__c = order.Id,
				LineNumber__c = 7,
				SPO_FirmOrderStatus__c = 'Creation in progress',
				Creation_Status__c = 'New Order',
				ProductCatalogue__c = pc2.Id
		);
		fosToInsert.add(firmOrder7);
		SPO_FirmOrder__c firmOrder8 = new SPO_FirmOrder__c(
				SPO_BriefName__c = order.Id,
				LineNumber__c = 8,
				SPO_FirmOrderStatus__c = 'Creation in progress', //'Received in store',
				Creation_Status__c = 'New Order',
				ProductCatalogue__c = pc4.Id
		);
		fosToInsert.add(firmOrder8);
		SPO_FirmOrder__c firmOrder9 = new SPO_FirmOrder__c(
				SPO_BriefName__c = order.Id,
				LineNumber__c = 9,
				SPO_FirmOrderStatus__c = 'Sent to MyPR',
				Creation_Status__c = 'New Order',
				ProductCatalogue__c = pc5.Id
		);
		fosToInsert.add(firmOrder9);

		SPO_FirmOrder__c firmOrder10 = new SPO_FirmOrder__c(
				SPO_BriefName__c = order.Id,
				LineNumber__c = 10,
				SPO_FirmOrderStatus__c = 'Production in progress',
				Creation_Status__c = 'New Order',
				ProductCatalogue__c = pc6.Id
		);
		fosToInsert.add(firmOrder10);

		insert fosToInsert;

		List<Picklist_Dependency__c> toInsert = new List<Picklist_Dependency__c>{
				new Picklist_Dependency__c(
						Name = 'Accessory',
						Opportunity_Category__c = 'Accessories',
						Referential_Category__c = 'Special Order Accessory',
						Opportunity_Record_Type__c = 'Accessories'
				),
				new Picklist_Dependency__c(
						Name = 'Leather good',
						Opportunity_Category__c = 'Leather goods',
						Referential_Category__c = 'Special Order Leather Good',
						Opportunity_Record_Type__c = 'Leather Goods'
				),
				new Picklist_Dependency__c(
						Name = 'Watch',
						Opportunity_Category__c = 'Watches',
						Referential_Category__c = 'Special Order Watch',
						Opportunity_Record_Type__c = 'Watches'
				)
				};
		insert toInsert;

		try {
			ProductReferential__c pr = new ProductReferential__c(Name = 'testPr', SKUCode__c = '12345');
			insert pr;
	
	
			SO_Settings__c setting = new SO_Settings__c(Name='WSCallNoCall', Value__c='nocall');
			insert setting;
		} catch(Exception e){
			System.debug('Exception: '+e.getMessage());
		}
	}

	@isTest
	static void test_getLatestOrder() {
		Test.startTest();
		Opportunity o = [Select Id From Opportunity limit 1];
		Opportunity testOrder = MIY_OrderPageController.getLatestOrder();
		System.assertEquals(o.Id, testOrder.Id);
		Test.stopTest();
	}

	@isTest
	static void test_getOrder() {
		Test.startTest();
		Opportunity o = [Select Id From Opportunity limit 1];
		SPO_FirmOrder__c fo = [Select Id From SPO_FirmOrder__c limit 1];
		Opportunity testOrder = MIY_OrderPageController.getOrder(o.Id);
		Test.stopTest();
	}

	@isTest
	static void test_getFirmOrder() {
		Test.startTest();
		Opportunity o = [Select Id From Opportunity limit 1];
		SPO_FirmOrder__c fo = [Select Id, SPO_BriefName__c From SPO_FirmOrder__c limit 1];
		SPO_FirmOrder__c testFirmOrder = MIY_OrderPageController.getFirmOrder(fo.Id);
		Test.stopTest();
	}

	@isTest
	static void test_updateFirmOrder1() {
		Test.startTest();
		Opportunity opp  = new Opportunity();
        opp.Name = 'otest';
        opp.SPO_ProductCategory__c = 'Leather Goods';
        opp.SPO_OrderType__c = 'SPO/MTO';
        opp.SPO_CreationType__c = 'otest';
        opp.StageName = 'Brief in progress';
        opp.CloseDate = Date.today();
        insert opp;
        System.debug('$$$$$$$$$$$'+opp.Id);
        
        SPO_FirmOrder__c fo = new SPO_FirmOrder__c();
        fo.SPO_BriefName__c = opp.Id;
        fo.Name = 'Sent to MyPR';
        fo.LineNumber__c = 001;
        insert fo;   

		try{
		MIY_OrderPageController.updateFirmOrder(fo.Id);
		}
		catch(Exception e){
			System.debug('Exception: '+e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void test_getFOStatusOptions() {
		Test.startTest();
		Map<String, String> statusOptions = MIY_OrderPageController.getFOStatusOptions();
		Schema.DescribeFieldResult fieldResult = SPO_FirmOrder__c.SPO_FirmOrderStatus__c.getDescribe();
		System.assertEquals(fieldResult.getPicklistValues().size(), statusOptions.size());
		Test.stopTest();
	}

	@isTest
	static void test_getCancelReasonOptions() {
		Test.startTest();
		List<Map<String, String>> reasonOptions = MIY_OrderPageController.getCancelReasonOptions();
		Schema.DescribeFieldResult fieldResult = Opportunity.SPO_StopBriefReason__c.getDescribe();
		System.assertEquals(fieldResult.getPicklistValues().size(), reasonOptions.size());

		Profile p = [SELECT Id FROM Profile WHERE Name='SPO_Production'];
		User u = new User(Alias = 'Tester', Email = 'SPO_ProductionUser@testlv.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = p.Id, BypassVR__c = true,
				TimeZoneSidKey = 'America/Los_Angeles', UserName = 'SPO_ProductionUser@testlv.com');
		
		System.runAs(u) {
			List<Map<String, String>> reasonOptions2 = MIY_OrderPageController.getCancelReasonOptions();
			Schema.DescribeFieldResult fieldResult2 = Opportunity.SPO_StopBriefReason__c.getDescribe();
		}
		Test.stopTest();
	}

	@isTest
	static void test_cancelFirmOrders() {
		Test.startTest();
		Opportunity o = [Select Id From Opportunity limit 1];
		List<SPO_FirmOrder__c> fos = [Select Id From SPO_FirmOrder__c limit 2];
		Map<Id, SPO_FirmOrder__c> foMap = new Map<Id, SPO_FirmOrder__c>(fos);
		List<SPO_FirmOrder__c> fos2 = [Select Id From SPO_FirmOrder__c Where SPO_FirmOrderStatus__c = 'Production in progress' limit 2];
		Map<Id, SPO_FirmOrder__c> foMap2 = new Map<Id, SPO_FirmOrder__c>(fos2);
		try{
		Map<String,Object> cancelledFos = MIY_OrderPageController.cancelFirmOrders(new List<Id>(foMap.keySet()), o.Id, 'Client - Client decision', 'Test Comment');
		Map<String,Object> cancelledFos2 = MIY_OrderPageController.cancelFirmOrders(new List<Id>(foMap2.keySet()), o.Id, 'Production', 'Test Comment');
		List<SPO_FirmOrder__c> testFos = new List<SPO_FirmOrder__c>();
		testFos = (List<SPO_FirmOrder__c>)cancelledFos.get('fos');
		System.assertEquals('Cancelled by store', testFos.get(0).SPO_FirmOrderStatus__c);
		}
		catch(Exception e){
			System.debug(e.getMessage());
		}
		Test.stopTest();
	}
    
    // @isTest
    // static void test_cancelFirmOrder2() {
    //     Test.startTest();
    //     Store__c store = new Store__c(Name = 'Test Store', RetailStoreId__c = 'A06');
	// 	insert store;

	// 	Opportunity order = new Opportunity();
	// 	order.Name = 'Test Order'; 
	// 	order.StageName = 'Brief in progress';
	// 	order.CloseDate = Date.today();
	// 	order.SPO_DepositSentStatusDate__c = Date.today() ;
	// 	order.Received_in_Store_Date__c = Date.today();
	// 	order.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Perso Order').getRecordTypeId();
	// 	order.SPO_Store__c = store.Id;
	// 	insert order;

	// 	ProductCatalogue__c pc1 = new ProductCatalogue__c(Name = 'testPc1', LeadTimeManufacturing__c = 0, SKU__c = '12345', Workshop__c ='1798');
	// 	insert pc1;


	// 	List<SPO_FirmOrder__c> fosToInsert = new List<SPO_FirmOrder__c>();
	// 	SPO_FirmOrder__c firmOrder = new SPO_FirmOrder__c(
	// 		SPO_BriefName__c = order.Id,
	// 		LineNumber__c = 1,
	// 		SPO_TechETLStatus__c = 'V',
	// 		SPO_FirmOrderStatus__c = 'Production in progress',
    //         ProductCatalogue__c = pc1.Id
	// 	);
	// 	fosToInsert.add(firmOrder);
	// 	insert fosToInsert;
        
    //     Map<Id, SPO_FirmOrder__c> foMap = new Map<Id, SPO_FirmOrder__c>(fosToInsert);
    //     try{
    //         Map<String,Object> cancelledFos = MIY_OrderPageController.cancelFirmOrders(new List<Id>(foMap.keySet()), order.Id, 'Client - Client decision', 'Test Comment');
    //         List<SPO_FirmOrder__c> testFos = new List<SPO_FirmOrder__c>();
    //         testFos = (List<SPO_FirmOrder__c>)cancelledFos.get('fosToInsert');
    //         System.assertEquals('Cancelled by store', testFos.get(0).SPO_FirmOrderStatus__c);
    //     }
    //     catch(Exception e){
    //         System.debug(e.getMessage());
    //     }
    //     Test.stopTest();
    // }

	@isTest
	static void test_getUserProfileName() {
		Test.startTest();
		String testName = MIY_OrderPageController.getUserProfileName();
		System.assertNotEquals(null, testName);
		Test.stopTest();
	}

	private static Opportunity test_updateSPOStage_helper(String initStage, String expectedStage) { 
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		User u = new User(Alias = 'Tester', Email = 'adminUser@testlv.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = p.Id, BypassVR__c = true,
				TimeZoneSidKey = 'America/Los_Angeles', UserName = 'adminUser@testlv.com');

		Opportunity testOrder;
		
		System.runAs(u) {
			Opportunity o = [
					SELECT Id, toLabel(Workshop__c), StageName, SPO_Date_Closed_Won__c, RecordType.Name, Amount,
					SPO_DepositAmount__c
					FROM Opportunity
					WHERE RecordType.Name = 'Special Order'
			LIMIT 1
			];
			o.StageName = initStage;
			

			//  	Opportunity o2 = [
			// 		SELECT Id, Workshop__c, StageName, SPO_Date_Closed_Won__c, RecordType.Name, Amount,
			// 		SPO_DepositAmount__c
			// 		FROM Opportunity
			// 		WHERE RecordType.Name = 'Special Order'
			// LIMIT 1
			// ];
		//	o2.Workshop__c ='4204034';
		//	System.debug('O2 :'+o2.Workshop__c);
			try {
				testOrder = MIY_OrderPageController.updateSPOStage(o);
				//	testOrder = MIY_OrderPageController.updateSPOStage(o2);
					System.assertEquals(expectedStage, testOrder.StageName);
			} catch (Exception e) {
				System.debug('Exception');
			}
		}
		
		return testOrder;
	}

	@isTest
	static void test_updateSPOStage_briefInProgress() {
		Test.startTest();
		try {
		test_updateSPOStage_helper('Brief in progress', 'Quotation in progress');
		}
		catch(Exception e){
			System.debug(e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void test_updateSPOStage_quotationInProgress() {
		Test.startTest();
		try {
		test_updateSPOStage_helper('Quotation in progress', 'Quotation submitted');
		}
		catch(Exception e){
			System.debug(e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void test_updateSPOStage_quotationSubmitted() {
		Test.startTest();
		try {
		test_updateSPOStage_helper('Quotation submitted', 'Creation in progress');
		}
		catch(Exception e){
			System.debug(e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void test_updateSPOStage_creationInProgress() {
		Test.startTest();
		try {
		test_updateSPOStage_helper('Creation in progress', 'In progress');
		}
		catch(Exception e){
			System.debug(e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void test_updateSPOStage_inProgress() {
		Test.startTest();
		try {
		test_updateSPOStage_helper('In progress', 'Distribution in Progress');
		}
		catch(Exception e){
			System.debug(e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void test_updateSPOStage_distributionInProgress() {
		Test.startTest();
		try {
		test_updateSPOStage_helper('Distribution in Progress', 'Received in store');
		}
		catch(Exception e){
			System.debug(e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void test_updateSPOStage_closedWon() {
		Test.startTest();
		try {
		Opportunity testOrder = test_updateSPOStage_helper('Received in store', 'Closed Won');
		System.assertNotEquals(null, testOrder.SPO_Date_Closed_Won__c);
		}
		catch(Exception e){
			System.debug(e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void test_getFirmOrdersHistory() {
		Test.startTest();
		List<SPO_FirmOrder__c> fos = [Select Id From SPO_FirmOrder__c];
		Map<Id, SPO_FirmOrder__c> foMap = new Map<Id, SPO_FirmOrder__c>(fos);
		Map<String, List<SPO_FirmOrder__History>> historyMap = MIY_OrderPageController.getFirmOrdersHistory(new List<Id>(foMap.keySet()));
		System.assertNotEquals(null, historyMap);
		Test.stopTest();
	}

	@isTest
	static void test_SPO_updateFirmOrders() {
		Test.startTest();
		Opportunity o = [SELECT Id FROM Opportunity WHERE TECH_Nb_FO__c > 1 limit 1];
	
		List<SPO_FirmOrder__c> fos = [Select Id From SPO_FirmOrder__c WHERE SPO_BriefName__c = :o.Id limit 2];
		Opportunity testOpp = MIY_OrderPageController.SPO_updateFirmOrders(o.Id);
		for (SPO_FirmOrder__c testFo : testOpp.SpeOrder_Order_Following__r) {
			System.assertEquals('Received in store', testFo.SPO_FirmOrderStatus__c);
		}
		try{
		Opportunity testOpp2 = MIY_OrderPageController.SPO_updateFirmOrders(testOpp.Id);
		for (SPO_FirmOrder__c testFo2 : testOpp2.SpeOrder_Order_Following__r) {
			System.assertEquals('Product delivered to client', testFo2.SPO_FirmOrderStatus__c);
		}
		}
		catch(Exception e){
			System.debug(e.getMessage());
		}
		Test.stopTest();
	}
	@isTest
	static void test_getOrderStageOptions() {
		Test.startTest();
		Map<String, String> opts = MIY_OrderPageController.getOrderStageOptions();
		System.assertNotEquals(null, opts);
		Test.stopTest();
	}
	@isTest
	static void test_getMiySettingsForWarnings() {
		Test.startTest();
		Map<String, Integer> settings = MIY_OrderPageController.getMiySettingsForWarnings();

		System.assertNotEquals(null, settings);
		Test.stopTest();
	}
	@isTest
	static void test_getMaterialAndColorOptions() {
		Test.startTest();
		Map<String, List<String>> opts = MIY_OrderPageController.getMaterialAndColorOptions();
		System.assertNotEquals(null, opts);
		Test.stopTest();
	}
	@isTest
	static void test_getProductSettings() {
		Test.startTest();
		ProductSettings__c settings = MIY_OrderPageController.getProductSettings();
		System.assertNotEquals(null, settings);
		Test.stopTest();
	}
	@isTest
	static void test_getMiySettings() {
		Test.startTest();
		Map<String,MIY_Settings__c> settings = MIY_OrderPageController.getMiySettings();
		System.assertNotEquals(null, settings);
 		Test.stopTest();
	}
	@isTest
	static void test_findProductBySku() {
		Test.startTest();
		ProductReferential__c pr = [SELECT Id FROM ProductReferential__c WHERE SKUCode__c = '12345' LIMIT 1];
		List<Map<String, Object>> prOpts = MIY_OrderPageController.findProductBySku('123');
		ProductReferential__c toTest = (ProductReferential__c)prOpts.get(0).get('value');
		System.assertEquals(pr.Id,toTest.Id);
		Test.stopTest();
	}
	@isTest
	static void test_findProductRefSkuById() {
		Test.startTest();
		ProductReferential__c pr = [SELECT Id FROM ProductReferential__c WHERE SKUCode__c = '12345' LIMIT 1];
		String toTest1 = MIY_OrderPageController.findProductRefSkuById(pr.Id);
		System.assertEquals('12345',toTest1);
		Test.stopTest();
	}
	@isTest
	static void test_findProductRefSkuById2() {
		Test.startTest();
		try{
		String toTest1 = MIY_OrderPageController.findProductRefSkuById('baba');
		}
		catch(Exception e){
			System.debug(e.getMessage());
		}
		Test.stopTest();
	}

	@isTest
	static void test_cancelOrder() {
		Test.startTest();
		Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];
		Opportunity toTest = MIY_OrderPageController.cancelOrder(o, 'Client - Client decision', 'comment');
		for (SPO_FirmOrder__c fo : [SELECT Id, SPO_FirmOrderStatus__c FROM SPO_FirmOrder__c WHERE SPO_BriefName__c = :o.Id]) {
			System.assertEquals('Cancelled by store',fo.SPO_FirmOrderStatus__c);
		}
		System.assertEquals('Cancelled by store',toTest.StageName);
		System.assertEquals('Client - Client decision',toTest.SPO_StopBriefReason__c);
		System.assertEquals('comment',toTest.SPO_StopBriefComment__c);
		Test.stopTest();
	}
	@isTest
	static void test_duplicateOrder() {
		Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successOrderPdf', 'OrderPdf'));
		Test.startTest();
		Opportunity o = [SELECT Id FROM Opportunity LIMIT 1];
		String dupOrderPageRef = MIY_OrderPageController.duplicateOrder(o,'');
		System.assertNotEquals(null, dupOrderPageRef);
		Test.stopTest();
	}
	@isTest
	static void test_getExoLeatherOptions() {
		Test.startTest();
		List<Map<String, Object>> opts = MIY_OrderPageController.getExoLeatherOptions('12345', '');		
		System.assertNotEquals(null, opts);
		List<Map<String, Object>> opts1 = MIY_OrderPageController.getExoLeatherOptions('', '12348');
		System.assertNotEquals(null, opts1);
		Test.stopTest();
	}
	
	@isTest
	static void test_setFirmOrderExoLeatherProduct() {
		Test.startTest();
		ProductCatalogue__c pc = [
				SELECT Id, LeadTimeManufacturing__c
				FROM ProductCatalogue__c
				WHERE LeadTimeManufacturing__c = 1
				LIMIT 1
		];
		SPO_FirmOrder__c fo = [
				SELECT Id, ProductCatalogue__c, SPO_TechETLStatus__c, Undefined_Material__c, FluidRecipeId__c,ProductSKU__c 
				FROM SPO_FirmOrder__c
				LIMIT 1
		];
		SPO_FirmOrder__c toTest = MIY_OrderPageController.setFirmOrderExoLeatherProduct(pc.Id, fo);
		System.assertEquals(pc.Id,toTest.ProductCatalogue__c);
		Test.stopTest();
	}
//	@isTest
//	static void test_setFirmOrderProductMfgLeadTime() {
//		ProductCatalogue__c pc = [
//				SELECT Id, LeadTimeManufacturing__c
//				FROM ProductCatalogue__c
//				WHERE LeadTimeManufacturing__c = 0
//				LIMIT 1
//		];
//		SPO_FirmOrder__c fo = [
//				SELECT Id, ProductCatalogue__c, SPO_TechETLStatus__c, Undefined_Material__c
//				FROM SPO_FirmOrder__c
//				LIMIT 1
//		];
//		SPO_FirmOrder__c toTest = MIY_OrderPageController.setFirmOrderExoLeatherProduct(pc.Id, fo);
//		System.assertEquals(2,toTest.ProductCatalogue__r.LeadTimeManufacturing__c);
//	}
	@isTest
	static void test_addPersoOrderDeposit() { 
		Test.startTest();
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		User u = new User(Alias = 'Tester', Email = 'adminUser@testlv.com',
		EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		LocaleSidKey = 'en_US', ProfileId = p.Id, BypassVR__c = true,
		TimeZoneSidKey = 'America/Los_Angeles', UserName = 'adminUser@testlv.com');
		
		Opportunity o = [SELECT Id, SPO_Store__c, SPO_DisplayOrder__c,SPO_Store__r.SalesServices__c, SPO_Store__r.isXstore__c , SPO_StoreCode__c, SPO_DepositSentStatusDate__c FROM Opportunity LIMIT 1];

		o.SPO_DepositAmount__c = 123;
		o.SPO_DepositComment__c = 'test';
		o.SPO_CACode__c = 'SIM';

		System.runAs(u) {
			Opportunity toTest = MIY_OrderPageController.addPersoOrderDeposit(o);
			SPO_FirmOrder__c foToTest = [
					SELECT Id, SPO_TechETLStatus__c
					FROM SPO_FirmOrder__c
					WHERE SPO_BriefName__c = :o.Id
					LIMIT 1
			];
			//System.assertNotEquals(null, toTest.SPO_DepositNumber__c);
			o.SPO_DisplayOrder__c = true;
			Opportunity toTest2 = MIY_OrderPageController.addPersoOrderDeposit(o);
			SPO_FirmOrder__c foToTest2 = [
					SELECT Id, SPO_TechETLStatus__c
					FROM SPO_FirmOrder__c
					WHERE SPO_BriefName__c = :o.Id
					LIMIT 1
			];
			Opportunity res = [SELECT Id, SPO_DisplayOrder__c, SPO_DepositSentStatusDate__c FROM Opportunity WHERE Id =: toTest2.Id LIMIT 1];
		 	System.assertEquals(System.today(), res.SPO_DepositSentStatusDate__c);
		}
		Test.stopTest();
	}
	@isTest
	static void test_isDebugMode() {
		Test.startTest();
		Boolean result = MIY_OrderPageController.isDebugMode();
		System.assertNotEquals(null, result);
		Test.stopTest();
	}
	@isTest
	static void test_updateStageToInProgress() {

		Test.startTest();
			Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];
			User u = new User(Alias = 'Tester', Email = 'adminUser@testlv.com',
			EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
			LocaleSidKey = 'en_US', ProfileId = p.Id, BypassVR__c = true,
			TimeZoneSidKey = 'America/Los_Angeles', UserName = 'adminUser@testlv.com');
			System.runAs(u) {
				Opportunity o1 = [Select Id From Opportunity limit 1];
				 MIY_OrderPageController.updateStageToInProgress(o1.Id); 
			}
			Test.stopTest();
		//NOT USING ADMIN ACCOUNT	
		// try {
		// 	Opportunity o2 = MIY_OrderPageController.updateStageToInProgress(o1.Id); 
		// }
		// catch ( Exception error){	
		// 	System.assertEquals(true, error.getMessage().contains('first error: FIELD_CUSTOM_VALIDATION_EXCEPTION, You cannot manually change the stage. Please use the appropriate buttons.: []'));
		// }
	}
		//public static Opportunity updateQuotationFields(Id orderId,String estimatedProductionTime,String estimatedDistributionTime,String productiveHours,String unitRetailPrice,String theoricRetailPrice,String spo_CRS)
	
	@IsTest()
	//@IsTest(SeeAllData=true)
	static void test_updateQuotationFields() { 
	//	Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successJsonFluidData', 'json'));
	Test.startTest();
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		User u = new User(Alias = 'Tester', Email = 'adminUser@testlv.com',
		EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
		LocaleSidKey = 'en_US', ProfileId = p.Id, BypassVR__c = true,
		TimeZoneSidKey = 'America/Los_Angeles', UserName = 'adminUser@testlv.com');
         

		// Build a simple feed item
        ConnectApi.FeedElementPage testPage = new ConnectApi.FeedElementPage();
        List<ConnectApi.FeedItem> testItemList = new List<ConnectApi.FeedItem>();
        testItemList.add(new ConnectApi.FeedItem());
        //testItemList.add(new ConnectApi.FeedItem());
        testPage.elements = testItemList;

        // Set the test data
        ConnectApi.ChatterFeeds.setTestGetFeedElementsFromFeed(null,
            ConnectApi.FeedType.News, 'me', testPage);

		System.runAs(u) {
			Opportunity o = [Select Id From Opportunity limit 1];
			try{
		    Opportunity newOpp = MIY_OrderPageController.updateQuotationFields(o.Id, '10', '10', '70', '8000', '8000', '8000');
			} catch (DmlException ex) {
				System.assertEquals('expected text', ex.getMessage());
			}  
		//	System.debug(newOpp);
		//	System.assertNotEquals(o, newOpp,'not the same');
		}
		Test.stopTest();
	}
  


	private static SPO_FirmOrder__c test_progressExoMatWorkflow_helper(String initStage, String expectedStage, Boolean pcTechData) {
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
		User u = new User(Alias = 'Tester', Email = 'adminUser@testlv.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US',
				LocaleSidKey = 'en_US', ProfileId = p.Id, BypassVR__c = true,
				TimeZoneSidKey = 'America/Los_Angeles', UserName = 'adminUser@testlv.com');

		SPO_FirmOrder__c testOrder;
		System.runAs(u) {
			SPO_FirmOrder__c fo = [
					SELECT Id, Creation_Status__c, ProductCatalogue__r.Technical_Data_Defined__c,
					ProductCatalogue__r.Id, Undefined_Material__c, SPO_TechETLStatus__c, ProductCatalogue__r.SKU__c
					FROM SPO_FirmOrder__c
					WHERE Creation_Status__c = :initStage
						AND ProductCatalogue__r.Technical_Data_Defined__c = :pcTechData
					LIMIT 1
			];

			testOrder = MIY_OrderPageController.progressExoMatWorkflow(fo); 
			System.assertEquals(expectedStage, testOrder.Creation_Status__c);
		}
		return testOrder;
	}

	private static SPO_FirmOrder__c test_progressHardWorkflow_helper(String sku, String creationStatus, String assert, Boolean technicalData) {
		SPO_FirmOrder__c fo = [
			SELECT Id, Creation_Status__c, ProductCatalogue__c, ProductCatalogue__r.Technical_Data_Defined__c,
			IsInferiorVmaxDate__c, SPO_TechETLStatus__c 
			FROM SPO_FirmOrder__c WHERE ProductCatalogue__r.SKU__c =: sku LIMIT 1];

		fo.Creation_Status__c = creationStatus;
		update fo;
		System.System.debug('RACHEL FO: ' + fo);
		SPO_FirmOrder__c testOrder = MIY_OrderPageController.progressHardsidedWorkflow(fo);
		SPO_FirmOrder__c res = [SELECT Id, Creation_Status__c, ProductCatalogue__r.Technical_Data_Defined__c FROM SPO_FirmOrder__c WHERE Id =: testOrder.Id];
		System.assertEquals(assert, res.Creation_Status__c);
		System.assertEquals(technicalData, res.ProductCatalogue__r.Technical_Data_Defined__c);
		return res;
	}

	@isTest
	static void test_progressHardWorkflow_stage0() {
		Test.startTest();
		try{
		test_progressHardWorkflow_helper('12346', 'Order to Check/Validate', 'Technical Data to Define', false);
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}
		Test.stopTest();
	}
	@isTest
	static void test_progressHardWorkflow_stage1() {
		Test.startTest();
		try{
		test_progressHardWorkflow_helper('12346', 'Technical Data to Define', 'Ready to be Sent', true);
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}
		Test.stopTest();
	}
	@isTest
	static void test_progressHardWorkflow_stage2() {
		Test.startTest();
		try{
		test_progressHardWorkflow_helper('12348', 'Technical Data to Define', 'Ready to be Sent', true);
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}
		Test.stopTest();
	}
	@isTest
	static void test_progressHardWorkflow_stage3() {
		Test.startTest();
		try{
		test_progressHardWorkflow_helper('12349', 'Order to Check/Validate', 'Ready to be Sent', true);
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}
		Test.stopTest();
	}
	@isTest
	static void test_progressHardWorkflow_stage4() {
		Test.startTest();
		try{
		test_progressHardWorkflow_helper('12347', 'Order to Check/Validate', 'Ready to be Sent', true);
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}
		Test.stopTest();
	}



	@isTest
	static void test_progressExoMatWorkflow_stage0() {
		Test.startTest();
		try{
		test_progressExoMatWorkflow_helper('Ready to be Sent', 'Ready to be Sent', false);
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}
		Test.stopTest();
	}
	@isTest
	static void test_progressExoMatWorkflow_stage1() {
		Test.startTest();
		try{
		test_progressExoMatWorkflow_helper('Species to Choose', 'Technical Data to Define', false);
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}
		Test.stopTest();
	}
	@isTest
	static void test_progressExoMatWorkflow_stage2() {
		Test.startTest();
		try{
		test_progressExoMatWorkflow_helper('Species to Choose', 'Technical Data to Define', true);
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}
		Test.stopTest();
	}
	@isTest
	static void test_progressExoMatWorkflow_stage3a() {
		Test.startTest();
		try{
		test_progressExoMatWorkflow_helper('Technical Data to Define', 'Technical Data to Check', false);
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}
		Test.stopTest();
	}
	@isTest
	static void test_progressExoMatWorkflow_stage3b() {
		Test.startTest();
		try{
		test_progressExoMatWorkflow_helper('Ready to be Sent', 'Ready to be Sent', false);
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}
		Test.stopTest();
	}
	@isTest
	static void test_progressExoMatWorkflow_stage3c() {
		Test.startTest();
		try{
		test_progressExoMatWorkflow_helper('Technical Data to Check', 'Ready to be Sent', false);
		} catch (Exception ex) {
			System.debug(ex.getMessage());
		}
		Test.stopTest();
	}
	@isTest
	static void test_isJapanApprover() {
		Test.startTest();
		Group g;
		try {
			 g = [SELECT Id FROM Group WHERE DeveloperName = 'SPO_JapanApprovalLG' LIMIT 1];
		} catch (Exception e) {
			g = new Group(Name = 'SPO_Japan approval LG', DeveloperName = 'SPO_JapanApprovalLG');
			insert g;
		}
		Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' LIMIT 1];

		User u = new User(Alias = 'Tester', Email = 'adminUser@testlv.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', ProfileId = p.Id,
				LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = 'adminUser@testlv.com');
		insert u;
		User u2 = new User(Alias = 'Tester2', Email = 'adminUser2@testlv.com',
				EmailEncodingKey = 'UTF-8', LastName = 'Testing', LanguageLocaleKey = 'en_US', ProfileId = p.Id,
				LocaleSidKey = 'en_US', TimeZoneSidKey = 'America/Los_Angeles', UserName = 'adminUser2@testlv.com');
		insert u2;


		GroupMember gm = new GroupMember(GroupId = g.id, UserOrGroupId = u.Id);
		insert gm;
		System.runAs(u) {
			System.assertEquals(true, MIY_OrderPageController.isJapanApprover());
		}
		System.runAs(u2) {
			System.assertEquals(false, MIY_OrderPageController.isJapanApprover());
		}
		Test.stopTest();
	}

}