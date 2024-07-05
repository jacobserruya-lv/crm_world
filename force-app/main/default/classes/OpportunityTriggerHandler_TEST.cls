@isTest
private class OpportunityTriggerHandler_TEST
{

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

		//Create Needed Custom Settings for Push notifications Flow
		IM_NotificationsMaps__c nmp1 = new IM_NotificationsMaps__c(Name = 'Client', Aliases__c = 'ClientId,Name', Fields__c='Id,Name', ObjectName__c = 'Account');
		IM_NotificationsMaps__c nmp2 = new IM_NotificationsMaps__c(Name = 'ClientList', Aliases__c = 'ClientListId,Name', Fields__c='Id,Name', ObjectName__c = 'CLI_CliList__c');
		IM_NotificationsMaps__c nmp3 = new IM_NotificationsMaps__c(Name = 'Feed');
		IM_NotificationsMaps__c nmp4 = new IM_NotificationsMaps__c(Name = 'FirmOrder', Aliases__c = 'ClientId,Name', Fields__c='SPO_BriefName__r.AccountId,SPO_BriefName__r.SPO_AccountName__c', ObjectName__c = 'SPO_FirmOrder__c');
		IM_NotificationsMaps__c nmp5 = new IM_NotificationsMaps__c(Name = 'Order', Aliases__c = 'ClientId,Name', Fields__c='	AccountId,SPO_AccountName__c', ObjectName__c = 'Opportunity');
		IM_NotificationsMaps__c nmp6 = new IM_NotificationsMaps__c(Name = 'Other');
		IM_NotificationsMaps__c nmp7 = new IM_NotificationsMaps__c(Name = 'Voice', Aliases__c = 'SurveyId,ClientId,Name', Fields__c='Id,ClientDreamID__c,ClientName__c', ObjectName__c = 'VO_Survey__c');
		List<IM_NotificationsMaps__c> npms = new List<IM_NotificationsMaps__c>{nmp1,nmp2,nmp3,nmp4,nmp5,nmp6,nmp7};
		insert npms;

		IM_Notifications__c imn =  new IM_Notifications__c(Name='en_US',Client_List__c='A new client List was assigned to you : {0}',
                Exceptional_Purchase__c='The client {0} has a new Exceptional Purchase Product : {1} $',Survey__c='A new Survey was created by: {0}',
                Clients_Reassigned__c='A new client List was assigned to you : {0}',	MIY__c='A new client List was assigned to you : {0}',	Order__c= 'A new client List was assigned to you : {0}',	SurveyManager__c='A new client List was assigned to you : {0}');
                insert imn;

        IM_Notifications__c imn2 =  new IM_Notifications__c(Name='zh_CN',Client_List__c='A new client List was assigned to you : {0}',
        Exceptional_Purchase__c='The client {0} has a new Exceptional Purchase Product : {1} $',Survey__c='A new Survey was created by: {0}',
        Clients_Reassigned__c='A new client List was assigned to you : {0}',Order__c= 'A new client List was assigned to you : {0}',	SurveyManager__c='A new client List was assigned to you : {0}');
        insert imn2;
	}

	@isTest
	static void itShould()
	{
		

	Test.startTest();
	 	User thisUser = [select Id,BypassVR__c from User where Id = :UserInfo.getUserId()];
        List<Opportunity> opp =[SELECT ID FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
        //Update Order with relevant stageName to trigger Push is working only if 	BypassVR__c

        if(	thisUser.BypassVR__c == true){
        	opp[0].stageName = 'Quotation submitted';
        	update opp;
        }
        
        Test.stopTest();

	}

	 @isTest
    static void testManageLeadTimeNonExoPerso()
    {
        // create a store
        Store__c st = LV_TestFactory.createStore('LV TEST STORE MIY', 'Store', 'A00', 'FRANCE', 'EUR', 'Open');
        insert st;
        
        // create a client
        Account client = LV_TestFactory.createAccount();
        insert client;
        
        // create a non exotic product catalog
        ProductCatalogue__c pc = LV_TestFactory.createProductCatalog('MY NEVERFULL', 'P0001', 3, 15, 5, 'Leather Goods');
        insert pc;
        

        // create a Lead Time
        MIY_LeadTime__c lt = LV_TestFactory.createLeadTime('FRANCE', 'Leather Goods', 20, 16);
        insert lt;

        // create a non exotic perso order
        Opportunity mypOrder = LV_TestFactory.createOrder('MY Neverfull bag', 'Creation in progress',  null, st.id, client.id, null, null, 'PERSO');
        mypOrder.SPO_DepositSentStatusDate__c = System.today();
        insert mypOrder;

        // create a firm order
        SPO_FirmOrder__c fo = LV_TestFactory.createFirmOrder(mypOrder.id, 1, pc.id);

        // run test
        Test.startTest();
        insert fo;

         Opportunity mypOrder2= LV_TestFactory.createOrder('MY Neverfull bag', 'Quotation submitted',  null, st.id, client.id, null, null, 'PERSO');
        mypOrder.SPO_DepositSentStatusDate__c = System.today();
        insert mypOrder2;

        fo.DistributionStatus__c = 'Sent from workshop';
        update fo;

        Test.stopTest();
        // for non exotic firm order    
        
    }

	@isTest
	static void testUpdateDistributionLeadTime()
		{
			// create a store
			Store__c st = LV_TestFactory.createStore('LV TEST STORE MIY', 'Store', 'A00', 'FRANCE', 'EUR', 'Open');
			insert st;

			// create a client
			Account client = LV_TestFactory.createAccount();
			insert client;

			// create a ProductReferential
			ProductReferential__c pr = LV_TestFactory.createProductReferential('MY NEVERFULL', 'P0001');
			pr.ProductCategory__c = 'Leather goods';
			insert pr;

			// create a non exotic product catalog
			/*ProductCatalogue__c pc = LV_TestFactory.createProductCatalog('MY NEVERFULL', 'P0001', 3, 15, 5, 'Leather Goods');
			pc.ProductReferential__c = pr.id;
			insert pc;*/


			// create a Lead Time
			MIY_LeadTime__c lt = LV_TestFactory.createLeadTime('FRANCE', 'Leather goods ', 20, 16);
			insert lt;

			// create a non exotic perso order
			Opportunity myOrder = LV_TestFactory.createOrder('MY Neverfull bag', 'Creation in progress',  null, st.id, client.id, null, null, 'PERSO');
			myOrder.SPO_BaseSKURefmodelSKU__c = pr.id;
			myOrder.Name='Test';
			myOrder.ApplicationSource__c = 'SPO';
			myOrder.SPO_Exo__c = 'yes';
			Test.startTest();
			insert myOrder;
			Test.stopTest();
            
            Opportunity newOpp = [SELECT SPO_EstimatedDistributionTime__c FROM Opportunity WHERE Id = :myOrder.id limit 1];
            System.assertEquals(3,newOpp.SPO_EstimatedDistributionTime__c);
		}

	@isTest
	static void testupdateManufacuringDelayTime()
		{
			// create a store
			Store__c st = LV_TestFactory.createStore('LV TEST STORE MIY', 'Store', 'A00', 'FRANCE', 'EUR', 'Open');
			insert st;

			// create a client
			Account client = LV_TestFactory.createAccount();
			insert client;

			// create a ProductReferential
			ProductReferential__c pr = LV_TestFactory.createProductReferential('MY NEVERFULL', 'P0001');
			pr.ProductCategory__c = 'Leather goods';
			insert pr;

			// create a workshop
			MIY_Workshop__c ws = LV_TestFactory.createWorkshop('Soft', 'Yes' ,'Creation (Hardsided & Soft)', 'Leather goods', 90, 'S004', 'SPO');
			insert ws;


			// create a non exotic perso order
			Opportunity myOrder = LV_TestFactory.createOrder('MY Neverfull bag', 'Creation in progress',  null, st.id, client.id, null, null, 'PERSO');
			myOrder.SPO_BaseSKURefmodelSKU__c = pr.id;
			myOrder.Name='Test';
			myOrder.ApplicationSource__c = 'SPO';
			myOrder.SPO_Exo__c = 'yes';
			myOrder.SPO_OrderType__c = 'Creation (Hardsided & Soft)';
			myOrder.SPO_CreationType__c = 'Soft';
			insert myOrder;

			Test.startTest();
			myOrder.workshop__c = 'S004';
		//	update myOrder;
			Test.stopTest();

		//	Opportunity newOpp = [SELECT SPO_EstimatedProductionTimeMonths__c FROM Opportunity WHERE Id = :myOrder.id limit 1];
		//	System.assertEquals(13,newOpp.SPO_EstimatedProductionTimeMonths__c);
		}
}