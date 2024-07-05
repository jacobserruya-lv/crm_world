@isTest
public class FirmOrderTriggerHandler_TEST {
	@TestSetup
	static void init() {
		// create a store
		Store__c st = LV_TestFactory.createStore('LV TEST STORE MIY', 'Store', 'A00', 'FRANCE', 'EUR', 'Open');
		st.MANAGEMENT_ZONE_LEVEL__c = '15';
		insert st;

		// create a client
		Account client = LV_TestFactory.createAccount();
		insert client;
        
        Category__c cat1 = new 	Category__c(Name = 'Ready to Wear', Exotic_Workflow__c = true);
		insert cat1;
		// create a non exotic product catalog
		ProductCatalogue__c pc = LV_TestFactory.createProductCatalog('MY NEVERFULL', 'P0001', 3, 15, 5, 'Leather Goods');
		pc.Workshop__c ='1798';
        pc.ReportingCategory__c = cat1.id;
        pc.Category__c = cat1.id;
		insert pc;

		Category__c cat = new 	Category__c(Name = 'EXOTIC_CATEGORY', Exotic_Workflow__c = true);
		insert cat;
        
		// create an exotic product catalog
		ProductCatalogue__c pcExo = LV_TestFactory.createProductCatalog('MY NEVERFULL', 'P0002', 3, 15, 5, 'Leather Goods');
		pcExo.Exotic__c = true;
		pcExo.ReportingCategory__c = cat.id;
		pcExo.Workshop__c ='1798';
		insert pcExo;

		ProductCatalogue__c pcdup = LV_TestFactory.createProductCatalog('MY NEVERFULL', 'P0003', 0, 0, 0, 'Leather Goods');
		pcdup.LeadTimeManufacturing__c = 10;
		pcdup.Workshop__c ='1798';
		insert pcdup;

		// create a Lead Time
		MIY_LeadTime__c lt = LV_TestFactory.createLeadTime('FRANCE', 'Leather Goods', 20, 16);
		insert lt;

		// create a non exotic perso order
		Opportunity mypOrder = LV_TestFactory.createOrder('MY Neverfull bag', 'Creation in progress', null, st.id, client.id, null, null, 'PERSO');
		mypOrder.SPO_DepositSentStatusDate__c = System.today();
		insert mypOrder;

		Product_Allocation__c pa = new Product_Allocation__c(
				Product__c = pc.Id,
				Zone__c = 'Worldwide',
				Available_Quantity__c = 2,
				Reserved_Quantity__c = 0
		);
		insert pa;
		Product_Allocation__c storeAllocation = new Product_Allocation__c(
				Product__c = pcdup.Id,
				Available_Quantity__c = 2,
				Reserved_Quantity__c = 0,
				Available_In_Stores__c = 'A00',
				Availability_is_Blacklist__c = false
		);
		insert storeAllocation;

		//MIY-1745
		Opportunity spoOrder1 =
				LV_TestFactory.createOrder('SPO_1', 'Creation in progress', null, st.id, client.id, null, null, 'SPO');
				spoOrder1.SPO_DepositSentStatusDate__c = System.today();
				spoOrder1.SPO_EstimatedProductionTimeMonths__c = 1;
		insert spoOrder1;
		Opportunity ecoOrder =
				LV_TestFactory.createOrder('ECO', 'Creation in progress', null, st.id, client.id, null, null, 'ECO');
				ecoOrder.SPO_DepositSentStatusDate__c = System.today();
				ecoOrder.Is_Dup__c = true;
		insert ecoOrder;
	}

	@isTest
	static void initTest() { //MIY-1745
		Boolean firstRunTest = FirmOrderTriggerHandler.isFirstRun();
		System.assertEquals(firstRunTest, true);
		Boolean secondRunTest = FirmOrderTriggerHandler.isFirstRun();
		System.assertEquals(secondRunTest, false);
	}

	@isTest
	static void testManageLeadTimeNonExoPerso() {

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successJsonFluidData', 'json'));
		ProductCatalogue__c pc = [SELECT Id FROM ProductCatalogue__c WHERE SKU__c = 'P0001' LIMIT 1];
		ProductCatalogue__c pcdup = [SELECT Id FROM ProductCatalogue__c WHERE SKU__c = 'P0003' LIMIT 1];
		Opportunity mypOrder = [SELECT Id FROM Opportunity WHERE ApplicationSource__c = 'PERSO' LIMIT 1];
		Opportunity dupOrder = [SELECT Id FROM Opportunity WHERE ApplicationSource__c = 'ECO' LIMIT 1];

		// create a firm order
		SPO_FirmOrder__c fo = LV_TestFactory.createFirmOrder(mypOrder.id, 1, pc.id);
		SPO_FirmOrder__c dupfo = LV_TestFactory.createFirmOrder(dupOrder.id, 2, pcdup.id);
		dupfo.FluidRecipeId__c ='74473696';
		// run test
		Test.startTest();
		insert fo;
		insert dupfo;
		Test.stopTest();

		fo = [SELECT id, PlannedDeliveryDate__c, Planned_Delivery_date__c, Planned_Manufacturing_Date__c from SPO_FirmOrder__c where id =: fo.id];
		dupfo = [SELECT id, PlannedDeliveryDate__c, Planned_Delivery_date__c, Planned_Manufacturing_Date__c from SPO_FirmOrder__c where id =: dupfo.id];

		// for non exotic firm order
		Date plannedDateForClient = System.today().adddays(39);
		Date plannedManufDateForClient = System.today().adddays(18); //MIY-1745
		Date duplicatedManufDate = System.today().adddays(10);
		System.assertEquals(plannedDateForClient, fo.Planned_Delivery_date__c);
		System.assertEquals(duplicatedManufDate, dupfo.Planned_Manufacturing_Date__c);

		//Added for code coverage (MIY-1745)
		System.assertEquals(plannedManufDateForClient, fo.Planned_Manufacturing_Date__c);
	}
    
	@isTest
	static void testManageLeadTimeNonExoPers2() {

		Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successJsonFluidData', 'json'));
		ProductCatalogue__c pc = [SELECT Id FROM ProductCatalogue__c WHERE SKU__c = 'P0001' LIMIT 1];
		ProductCatalogue__c pcdup = [SELECT Id FROM ProductCatalogue__c WHERE SKU__c = 'P0003' LIMIT 1];
		Opportunity mypOrder = [SELECT Id FROM Opportunity WHERE ApplicationSource__c = 'ECO' LIMIT 1];

		// create a firm order
		SPO_FirmOrder__c fo = LV_TestFactory.createFirmOrder(mypOrder.id, 1, pc.id);

		// run test
		Test.startTest();
		insert fo;
		Test.stopTest();

		fo = [SELECT id, PlannedDeliveryDate__c, Planned_Delivery_date__c, Planned_Manufacturing_Date__c from SPO_FirmOrder__c where id =: fo.id];

		// for non exotic firm order
		Date plannedDateForClient = System.today().adddays(39);
		Date plannedManufDateForClient = System.today().adddays(18); //MIY-1745
		Date duplicatedManufDate = System.today().adddays(10);
		//System.assertEquals(plannedDateForClient, fo.Planned_Delivery_date__c);

		//Added for code coverage (MIY-1745)
		//System.assertEquals(plannedManufDateForClient, fo.Planned_Manufacturing_Date__c);
	}

	@isTest
	static void testManageLeadTimeExoPerso() {
		ProductCatalogue__c pcExo = [SELECT Id FROM ProductCatalogue__c WHERE SKU__c = 'P0002' LIMIT 1];
		Opportunity mypOrder = [SELECT Id FROM Opportunity WHERE ApplicationSource__c = 'PERSO' LIMIT 1];
		// create an exotic firm order
		SPO_FirmOrder__c foExo = LV_TestFactory.createFirmOrder(mypOrder.id, 9, pcExo.id);
		// run test
		Test.startTest();
		insert foExo;
		Test.stopTest();

		foExo = [SELECT id, PlannedDeliveryDate__c, Planned_Delivery_date__c from SPO_FirmOrder__c where id =: foExo.id];
		Date plannedDateForClientExo = System.today().adddays(43);
		System.assertEquals(plannedDateForClientExo, foExo.Planned_Delivery_date__c);
	}

	@isTest
	static void testManageLeadTimeSPO() { //MIY-1745
		Opportunity spoOrder1 = [SELECT Id FROM Opportunity WHERE Name = 'SPO_1' LIMIT 1];
        ProductCatalogue__c pcExo = [SELECT Id FROM ProductCatalogue__c WHERE SKU__c = 'P0002' LIMIT 1];
		SPO_FirmOrder__c foSpo1 = new SPO_FirmOrder__c(SPO_BriefName__c = spoOrder1.id, LineNumber__c = 2, ProductCatalogue__c= pcExo.id);

		Test.startTest();
		insert foSpo1;
		Test.stopTest();

		foSpo1 = [SELECT id, Planned_Manufacturing_Date__c from SPO_FirmOrder__c where id =: foSpo1.id];

		Date plannedManufDateForSpo = System.today().adddays(7);
		Date plannedDeliveryDateForSpo = System.today();

		//System.assertEquals(plannedManufDateForSpo, foSpo1.Planned_Manufacturing_Date__c);
	}

	@isTest
	static void test_updateSimpleProdStatus() {
		ProductCatalogue__c pc = [SELECT Id FROM ProductCatalogue__c WHERE SKU__c = 'P0001' LIMIT 1];
		Opportunity mypOrder = [SELECT Id FROM Opportunity WHERE ApplicationSource__c = 'PERSO' LIMIT 1];

		// create a firm order
		Test.startTest();
		SPO_FirmOrder__c fo = LV_TestFactory.createFirmOrder(mypOrder.id, 1, pc.id);
		insert fo;

		fo.MIY_ProductionStatus__c = '001';
		update fo;

	//	fo.SPO_TechETLStatus__c = 'Y';
	//	update fo;

		
		fo = [SELECT Id, MIY_ProductionStatus__c, MIY_ProductionStatusSimple__c FROM SPO_FirmOrder__c WHERE Id =: fo.Id];
		System.assertEquals('To be manufactured', fo.MIY_ProductionStatusSimple__c);
        Test.stopTest();
	}

	@isTest
	static void test_updateDeliveryDate() {
		ProductCatalogue__c pc = [SELECT Id, LeadTimeDistribution__c FROM ProductCatalogue__c WHERE SKU__c = 'P0001' LIMIT 1];
	//	ProductCatalogue__c pcExo = [SELECT Id FROM ProductCatalogue__c WHERE SKU__c = 'P0002' LIMIT 1];
		Opportunity mypOrder = [SELECT Id FROM Opportunity WHERE ApplicationSource__c = 'PERSO' LIMIT 1];
		MIY_LeadTime__c lt = [SELECT Id, Exotic_Distribution_Lead_Time_in_days__c, Non_Exotic_Distribution_LT_in_days__c FROM MIY_LeadTime__c LIMIT 1];
		
        Test.startTest();

            // create a firm order
            SPO_FirmOrder__c fo = LV_TestFactory.createFirmOrder(mypOrder.id, 1, pc.id);
            insert fo;
        //	SPO_FirmOrder__c foExo = LV_TestFactory.createFirmOrder(mypOrder.id, 9, pcExo.id);
        //	insert foExo;
    
            Date pddTest = Date.today().addDays(Integer.valueOf(pc.LeadTimeDistribution__c));
            Date exoPddTest = pddTest.addDays(Integer.valueOf(lt.Exotic_Distribution_Lead_Time_in_days__c));
            pddTest = pddTest.addDays(Integer.valueOf(lt.Non_Exotic_Distribution_LT_in_days__c));
    
            fo.SPO_FirmOrderStatus__c = 'Distribution in progress';
            update fo;
        //	foExo.SPO_FirmOrderStatus__c = 'Distribution in progress';
        //	update foExo;
    
            fo = [SELECT Id, Planned_Delivery_date__c FROM SPO_FirmOrder__c WHERE Id =: fo.Id LIMIT 1];
        //	foExo = [SELECT Id, Planned_Delivery_date__c FROM SPO_FirmOrder__c WHERE Id =: foExo.Id LIMIT 1];
            System.assertEquals(pddTest, fo.Planned_Delivery_date__c);
        //	System.assertEquals(exoPddTest, foExo.Planned_Delivery_date__c);
    
        	List <SPO_FirmOrder__c> foList = new List <SPO_FirmOrder__c> {fo/*,foExo*/};
            Set< String > ordersIds = new Set< String >{String.valueOf( mypOrder.id)};
    		Set< String > productsIds = new Set< String >{String.valueOf(pc.Id )/*,String.valueOf(pcExo.Id )*/};
            Map<Id,Date> foIdToStartDate= new Map<Id,Date>();
            foIdToStartDate.put(fo.id, pddTest);
        //	foIdToStartDate.put(foExo.id, exoPddTest);
            FirmOrderTriggerHandler.updateDeliveryDate(foList, ordersIds,productsIds, foIdToStartDate);
            
       Test.stopTest();

	}

	@isTest
	static void test_modifyProductAllocations() {
		System.debug('== FirmOrderTriggerHandler_TEST.test_modifyProductAllocations ==');

		ProductCatalogue__c pc = [SELECT Id FROM ProductCatalogue__c WHERE SKU__c = 'P0001' LIMIT 1];
		//ProductCatalogue__c pc2 = [SELECT Id FROM ProductCatalogue__c WHERE SKU__c = 'P0003' LIMIT 1];
		Opportunity mypOrder = [SELECT Id FROM Opportunity WHERE ApplicationSource__c = 'PERSO' LIMIT 1];
		Product_Allocation__c pa = [SELECT Id, Reserved_Quantity__c FROM Product_Allocation__c WHERE Product__c = :pc.Id LIMIT 1];
		//Product_Allocation__c storeAllocation = [SELECT Id, Reserved_Quantity__c FROM Product_Allocation__c WHERE Product__c = :pc2.Id LIMIT 1];
		
		Decimal paReservedA = pa.Reserved_Quantity__c;
        Test.startTest();

		System.debug('paReservedA'+paReservedA);
		// create a firm order
		SPO_FirmOrder__c fo = LV_TestFactory.createFirmOrder(mypOrder.id, 1, pc.id);
		//SPO_FirmOrder__c fo2 = LV_TestFactory.createFirmOrder(mypOrder.id, 2, pc2.id);

		// run test
		insert fo;
		//insert fo2;
		pa = [
				SELECT Id, Product__c, Zone__c, Available_Quantity__c, Reserved_Quantity__c
				FROM Product_Allocation__c
				WHERE Id = :pa.Id LIMIT 1
		];
		// storeAllocation = [
		// 		SELECT Id, Product__c, Zone__c, Available_Quantity__c, Reserved_Quantity__c
		// 		FROM Product_Allocation__c
		// 		WHERE Id = :storeAllocation.Id LIMIT 1
		// ];

		Decimal paReservedB = pa.Reserved_Quantity__c;
		System.debug('paReservedB'+paReservedB);

		fo.Cancellation_Reason__c = 'Client - Client decision';
		fo.Cancellation_Comment__c = 'testing';
		fo.SPO_FirmOrderStatus__c = 'Cancelled by store';
		update fo;

		// pa = [
		// 		SELECT Id, Product__c, Zone__c, Available_Quantity__c, Reserved_Quantity__c
		// 		FROM Product_Allocation__c
		// 		WHERE Id = :pa.Id LIMIT 1
		// ];
		Decimal paReservedC = pa.Reserved_Quantity__c;
		System.debug('paReservedC'+paReservedC);

	//	fo = [SELECT id, PlannedDeliveryDate__c, Planned_Delivery_date__c from SPO_FirmOrder__c where id =: fo.id LIMIT 1];

		// for non exotic firm order
		System.assertEquals(0, paReservedA);
		System.assertEquals(1, paReservedB);
	//	System.assertEquals(0, paReservedC);
	       Test.stopTest();

	}

	@isTest
	static void test_insertProductConfigDetails() {
		 //Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successJsonFluidData', 'json'));

		ProductCatalogue__c pc = [SELECT Id FROM ProductCatalogue__c WHERE SKU__c = 'P0001' LIMIT 1];
		Opportunity mypOrder = [SELECT Id FROM Opportunity WHERE ApplicationSource__c = 'ECO' LIMIT 1];
		

		ProductCatalogue__c pc2 = [SELECT Id FROM ProductCatalogue__c WHERE SKU__c = 'P0002' LIMIT 1];
		Opportunity mypOrder2 = [SELECT Id FROM Opportunity WHERE ApplicationSource__c = 'PERSO' LIMIT 1];


		// create a firm order
		SPO_FirmOrder__c fo = LV_TestFactory.createFirmOrder(mypOrder.id, 1, pc.id);
		SPO_FirmOrder__c fo2 = LV_TestFactory.createFirmOrder(mypOrder2.id, 2, pc2.id);
		fo.FluidRecipeId__c = '12345';
	//	fo2.FluidRecipeId__c = 'Sendtoprod';

		// run test
		Test.startTest();
	//		insert fo;
	//		insert fo2;
		Test.stopTest();

		List<ProductConfigurationDetail__c> configDetails = [SELECT Id FROM ProductConfigurationDetail__c WHERE Order_Line_Item__c = :fo.Id];
	//	fo2 = [SELECT id, FluidRecipeId__c FROM SPO_FirmOrder__c where id =: fo2.id];
	//	System.assertEquals(5, configDetails.size());
	//	System.assertEquals(fo2.FluidRecipeId__c, null);
	}
}