@isTest
private class IM_SendPushNotifications_TEST
{
@testSetup static void setUp() {

		SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true,true);
		dataModel.customSettingForClientSearchInit(); 
		Store__c store = new Store__c(Currency__c='USD',RetailStoreId__c ='12334');
		insert store;

        IM_SendPushNotifications.setTestSettings();

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
		IM_NotificationsMaps__c nmp8 = new IM_NotificationsMaps__c(Name = 'Request', Aliases__c = 'CaseId,ClientId,Name', Fields__c='Id,AccountId,Account.Name', ObjectName__c = 'Case');
		IM_NotificationsMaps__c nmp9 = new IM_NotificationsMaps__c(Name = 'CareService', Aliases__c = 'CareServiceId,ClientId,Name', Fields__c='Id,Client__c,Client__r.Name', ObjectName__c = 'CareService__c');
		List<IM_NotificationsMaps__c> npms = new List<IM_NotificationsMaps__c>{nmp1,nmp2,nmp3,nmp4,nmp5,nmp6,nmp7,nmp8,nmp9};
		insert npms;

		IM_Notifications__c imn =  new IM_Notifications__c(Name='en_US',Client_List__c='A new client List was assigned to you : {0}',
                Exceptional_Purchase__c='The client {0} has a new Exceptional Purchase Product : {1} $',
                Survey__c='A new Survey was created by: {0}',
                Clients_Reassigned__c='A new client List was assigned to you : {0}',
                MIY__c ='A new client List was assigned to you : {0}',
                Order__c = 'A new client List was assigned to you : {0}',
                SurveyManager__c = 'A new client List was assigned to you : {0}',
                Request__c = 'A new client List was assigned to you : {0}',
                CareService__c = 'A new client List was assigned to you : {0}'
                );
                insert imn;

        IM_Notifications__c imn2 =  new IM_Notifications__c(Name='zh_CN',Client_List__c='A new client List was assigned to you : {0}',
        Exceptional_Purchase__c='The client {0} has a new Exceptional Purchase Product : {1} $',
        Survey__c='A new Survey was created by: {0}',
        Clients_Reassigned__c='A new client List was assigned to you : {0}',
        Order__c= 'A new client List was assigned to you : {0}',
        SurveyManager__c='A new client List was assigned to you : {0}',
        Request__c = 'A new client List was assigned to you : {0}',
        CareService__c = 'A new client List was assigned to you : {0}'
        );
        insert imn2;
    
    
      
	}

    @isTest
	static void itShouldRequest()
	{
            User thisUser = [select Id,BypassVR__c, DefaultStore__c from User where Id = :UserInfo.getUserId()];

        List<IconSetting__mdt> iconSettings = [Select Text__c FROM IconSetting__mdt   WHERE MasterLabel ='CaseStatusPush'];
        store__c str = new Store__c(RetailStoreId__c = '12345', Status__c='Open');
        insert str;
        
        User user = IC_TestFactory.createUser('TestLVBacthCLCreation@lvtest.com');
		user.profileId = IC_UTILS.getSAProfile();
        user.MGMT_ZONE_SUB_LEVEL1__c = '1071';
        user.DefaultStore__c = 'N03';
        user.WWEmployeeNumber__c='1234';
        user.DefaultStore__c = '12345';
        insert user;
        
         Account oAcc1 = new Account(
            LastName = 'TCLTest',
            FirstName='TCLTest',
            DREAMID__c = '1515',
            Salutation = 'Mr',
            LastTrans__pc = System.Today(),
            Segmentation__pc = 'VIC',
            PersonDoNotCall = true,
            PersonHasOptedOutOfEmail = true,
            DoNotSMS__pc = true,
            DoNotContactbyPost__pc = true,
            BirthdateMonth__pc = '1',
            Gender__pc = 'Male',
            HistoricalSpendEUR__pc = 250000
        );
        
        insert oAcc1;
        
        // Change the owner from 'DREAM' to the current user        
        oAcc1.OwnerId = thisUser.Id;
        update oAcc1;
        
        List<Id> accIdsList = new List<Id> {oAcc1.Id};

  		Test.startTest();	
           // System.runAs(user){
                
                Case ca = ICX_TestFactory.createCase(oAcc1.id);
                ca.Country__c = 'FRANCE';
                Id caRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Web&Email Case').getRecordTypeId();
                ca.recordTypeId = caRecordTypeId;
                ca.CA_Name__c = user.id;
                ca.Resolution__c = iconSettings[0].Text__c;
                ca.Store__c = str.Id;
                ca.Product_Sku_unknown__c = 'fdkl555';
                insert ca;
           // }
            IM_SendPushNotifications.ClientReassignSendPush(accIdsList);		
        Test.stopTest();

	}
    
	@isTest
    static void itShould(){
	
        
        list<Account> lAccount = new list<Account>();
        
        Account oAcc1 = new Account(
            LastName = 'TCLTest',
            FirstName='TCLTest',
            DREAMID__c = '1515',
            Salutation = 'Mr',
            LastTrans__pc = System.Today(),
            Segmentation__pc = 'VIC',
            PersonDoNotCall = true,
            PersonHasOptedOutOfEmail = true,
            DoNotSMS__pc = true,
            DoNotContactbyPost__pc = true,
            BirthdateMonth__pc = '1',
            Gender__pc = 'Male',
            HistoricalSpendEUR__pc = 250000
        );
        lAccount.add(oAcc1);
        
        Account oAcc2 = new Account(
            LastName = 'TCLTest2',
            FirstName='TCLTest2',
            DREAMID__c = '1616',
            Salutation = 'Mr',
            LastTrans__pc = System.Today(),
            Segmentation__pc = 'VIC',
            PersonDoNotCall = true,
            PersonHasOptedOutOfEmail = true,
            DoNotSMS__pc = true,
            DoNotContactbyPost__pc = true,
            BirthdateMonth__pc = '1',
            Gender__pc = 'Male',
            HistoricalSpendEUR__pc = 250000
        );
        lAccount.add(oAcc2);    
        
        insert lAccount;
		

        User thisUser = [select Id,BypassVR__c, DefaultStore__c from User where Id = :UserInfo.getUserId()];
        
        // Data Model       
      
        
        // Change the owner from 'DREAM' to the current user
        lAccount.clear();
        
        oAcc1.OwnerId = thisUser.Id;
        lAccount.add(oAcc1);
        
        oAcc2.OwnerId = thisUser.Id;
        lAccount.add(oAcc2);
        
        update lAccount;

        Event app = IC_TestFactory.createEvent(oAcc2);
        app.OwnerId = UserInfo.getUserId();
        List<Event> apps = new List<Event>();
        apps.add(app);
        IM_SendPushNotifications.AppointmentSendPush(apps);


        List<Account> accs = [Select id, PersonContactId from account where id IN : lAccount ];
        List<String> accIdsList = new List<String>();

        for(Account acc : accs){
            accIdsList.add(acc.Id);
        }
        Test.startTest();

        //Create Client List to trigger Push
        User usr = IC_TestFactory.createUser('TestLVBacthCLCreation@lvtest.com');
        //usr.BypassVR__c=true;
		usr.profileId = IC_UTILS.getSAProfile();
        insert usr;
        
        CLI_CliList__c cl1 = new CLI_CliList__c(Name = 'testcl1', OwnerId = usr.Id);
        insert cl1;
        CLM_CliListMember__c clm1 =new CLM_CliListMember__c(Client__c = accs[0].PersonContactId, ClientList__c=cl1.Id );
        insert clm1;


        List<Opportunity> opp =[SELECT ID FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
        //Update Order with relevant stageName to trigger Push is working only if 	BypassVR__c

        if(	thisUser.BypassVR__c == true){
        	opp[0].stageName = 'Quotation submitted';
        	update opp;
        }

        CareService__c careService = new CareService__c(ExternalId__c = '95TECH955',
                    client__c = oAcc1.Id,
					Is_Hot__c  = true,
					Red_Code__c  = true,
					SKU__c = 'M51980',
					TotalAmount__c = null,
					CA_Code__c =  'JM0726',
                    CA__c = usr.Id,
					StoreRetailCode__c =  'V06',
					Delivery_Date__c =  null,
					Delivery_Address__c =  'test adress USER TECH');
        
            insert careService;
        
        List<CareService__c> CSList = new List<CareService__c>();
        CSList.add(careService);
        IM_SendPushNotifications.CareServiceSendPush(CSList, false, null);

        store__c str = new Store__c(RetailStoreId__c = '12345', Status__c='Open');
        insert str;
    	usr.DefaultStore__c='12345';
    	update usr;

    
     
		
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
    static void testFirmOrderSendPush()
    {


		Store__c store = new Store__c(Name = 'Test Store', RetailStoreId__c = 'A06');
		insert store;

		Opportunity order = new Opportunity();
		order.Name = 'Test Order'; 
		order.StageName = 'Brief in progress';
		order.CloseDate = Date.today();
		order.SPO_DepositSentStatusDate__c = Date.today();
		order.Received_in_Store_Date__c = Date.today();
		order.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Perso Order').getRecordTypeId();
		order.SPO_Store__c = store.Id;
		insert order;

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

		ProductCatalogue__c pc1 = new ProductCatalogue__c(Name = 'testPc1', LeadTimeManufacturing__c = 0, SKU__c = '12345');
		ProductCatalogue__c pc2 = new ProductCatalogue__c(Name = 'testPc2', Technical_Data_Defined__c = false, LeadTimeManufacturing__c = 1, SKU__c = '12346');
		ProductCatalogue__c pc3 = new ProductCatalogue__c(Name = 'testPc3', Technical_Data_Defined__c = true, SKU__c = '12347');
		insert pc1;
		insert pc2;
		insert pc3;

		List<SPO_FirmOrder__c> fosToInsert = new List<SPO_FirmOrder__c>();

        SPO_FirmOrder__c firmOrder6 = new SPO_FirmOrder__c(
            SPO_BriefName__c = order.Id,
            LineNumber__c = 6,
            SPO_FirmOrderStatus__c = 'Creation in progress',
            Creation_Status__c = 'Technical Data to Check',
            ProductCatalogue__c = pc2.Id,
            Planned_Delivery_date__c = Date.today()
    );
    fosToInsert.add(firmOrder6);
    
		SPO_FirmOrder__c firmOrder = new SPO_FirmOrder__c(
			SPO_BriefName__c = order.Id,
			LineNumber__c = 1,
			SPO_TechETLStatus__c = 'V',
			SPO_FirmOrderStatus__c = 'Creation in progress'
		);
		fosToInsert.add(firmOrder);

		SPO_FirmOrder__c firmOrder2 = new SPO_FirmOrder__c(
			SPO_BriefName__c = order.Id,
			LineNumber__c = 2,
			SPO_FirmOrderStatus__c = 'Creation in progress',
			Creation_Status__c = 'Leather to Order',
			Undefined_Material__c = true,
			ProductCatalogue__c = pc2.Id
		);
		//fosToInsert.add(firmOrder2);

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
			Creation_Status__c = 'Leather to Order',
			Undefined_Material__c = false,
			ProductCatalogue__c = pc3.Id
		);
		//fosToInsert.add(firmOrder5);

test.startTest();

		insert fosToInsert;

     IM_SendPushNotifications.FirmOrderSendPush(fosToInsert);
     test.stopTest();
}

    
    
@isTest
static void itShould2Request()
{
    
        User thisUser = [select Id,BypassVR__c, DefaultStore__c from User where Id = :UserInfo.getUserId()];

     // Data Model       
    list<Account> lAccount = new list<Account>();
    
    Account oAcc1 = new Account(
        LastName = 'TCLTest',
        FirstName='TCLTest',
        DREAMID__c = '1515',
        Salutation = 'Mr',
        LastTrans__pc = System.Today(),
        Segmentation__pc = 'VIC',
        PersonDoNotCall = true,
        PersonHasOptedOutOfEmail = true,
        DoNotSMS__pc = true,
        DoNotContactbyPost__pc = true,
        BirthdateMonth__pc = '1',
        Gender__pc = 'Male',
        HistoricalSpendEUR__pc = 250000
    );
    lAccount.add(oAcc1);
    
    Account oAcc2 = new Account(
        LastName = 'TCLTest2',
        FirstName='TCLTest2',
        DREAMID__c = '1616',
        Salutation = 'Mr',
        LastTrans__pc = System.Today(),
        Segmentation__pc = 'VIC',
        PersonDoNotCall = true,
        PersonHasOptedOutOfEmail = true,
        DoNotSMS__pc = true,
        DoNotContactbyPost__pc = true,
        BirthdateMonth__pc = '1',
        Gender__pc = 'Male',
        HistoricalSpendEUR__pc = 250000
    );
    lAccount.add(oAcc2);    
    Test.startTest();
    insert lAccount;
    
       // Change the owner from 'DREAM' to the current user
        lAccount.clear();
        
        oAcc1.OwnerId = thisUser.Id;
        lAccount.add(oAcc1);
        
        oAcc2.OwnerId = thisUser.Id;
        lAccount.add(oAcc2);
        
        update lAccount;
    
     store__c str = new Store__c(RetailStoreId__c = '12345', Status__c='Open');
    insert str;
       //Create Client List to trigger Push
    User usr = IC_TestFactory.createUser('TestLVBacthCLCreation@lvtest.com');
    //usr.BypassVR__c=true;
    usr.profileId = IC_UTILS.getSAProfile();
     usr.DefaultStore__c='12345';
    insert usr;
    
   
    List<IconSetting__mdt> iconSettings = [Select Text__c
         FROM IconSetting__mdt 
         WHERE MasterLabel ='CaseStatusPush'];

    List<Case> listCaseInsert = new List<Case>();
    System.debug('RRRRRRRRRRR usr: ' + usr.DefaultStore__c);
    Case ca = ICX_TestFactory.createCase(oAcc1.id);
   
    
  
    ca.Country__c = 'FRANCE';
    Id caRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Web&Email Case').getRecordTypeId();
    ca.recordTypeId = caRecordTypeId;
    ca.CA_Name__c = usr.id;
    ca.Resolution__c = iconSettings[0].Text__c;
    System.debug('BBBBBBBBBBB ca: ' + ca);
    ca.Store__c = str.Id;
    ca.Product_Sku_unknown__c = 'fdkl555';
   // insert ca;
    listCaseInsert.add(ca);
    
    Case ca2 = ICX_TestFactory.createCase(oAcc2.id);
    ca2.High_Priority__c = true ;
    ca2.Store__c = str.id;
    listCaseInsert.add(ca2);
   // insert ca2;
   
    Case ca3 = ICX_TestFactory.createCase(oAcc2.id);
    ca3.CA_Name__c = null;
    //insert ca3;
    listCaseInsert.add(ca3);

    
    
    Store__c store = new Store__c(Currency__c='yen',RetailStoreId__c ='123334');
    insert store;
    Case ca4 = ICX_TestFactory.createCase(oAcc2.id);
    ca4.CA_Name__c=null;
    ca4.High_Priority__c =true;
    ca4.store__c=store.id;
    //insert ca4;
    listCaseInsert.add(ca4);
    
    insert     listCaseInsert;


    List<Case> caseList = new List<Case>();
    caseList.add(ca);
    caseList.add(ca3);
    caseList.add(ca2);
    caseList.add(ca4);

    List<Case> caseList2 = new List<Case>();
    
        IM_SendPushNotifications.CaseSendPush(caseList);
   
    IM_SendPushNotifications.CaseSendPush(caseList2);
}

@isTest
static void itShould2()
{
    
    User thisUser = [select Id,BypassVR__c, DefaultStore__c from User where Id = :UserInfo.getUserId()];


    // Data Model       
    list<Account> lAccount = new list<Account>();
    
    Account oAcc1 = new Account(
        LastName = 'TCLTest',
        FirstName='TCLTest',
        DREAMID__c = '1515',
        Salutation = 'Mr',
        LastTrans__pc = System.Today(),
        Segmentation__pc = 'VIC',
        PersonDoNotCall = true,
        PersonHasOptedOutOfEmail = true,
        DoNotSMS__pc = true,
        DoNotContactbyPost__pc = true,
        BirthdateMonth__pc = '1',
        Gender__pc = 'Male',
        HistoricalSpendEUR__pc = 250000
    );
    lAccount.add(oAcc1);
    
    Account oAcc2 = new Account(
        LastName = 'TCLTest2',
        FirstName='TCLTest2',
        DREAMID__c = '1616',
        Salutation = 'Mr',
        LastTrans__pc = System.Today(),
        Segmentation__pc = 'VIC',
        PersonDoNotCall = true,
        PersonHasOptedOutOfEmail = true,
        DoNotSMS__pc = true,
        DoNotContactbyPost__pc = true,
        BirthdateMonth__pc = '1',
        Gender__pc = 'Male',
        HistoricalSpendEUR__pc = 250000
    );
    lAccount.add(oAcc2);    
    Test.startTest();
    insert lAccount;
    
    // Change the owner from 'DREAM' to the current user
    lAccount.clear();
    
    oAcc1.OwnerId = thisUser.Id;
    lAccount.add(oAcc1);
    
    oAcc2.OwnerId = thisUser.Id;
    lAccount.add(oAcc2);
    
    update lAccount;

    Event app = IC_TestFactory.createEvent(oAcc2);
    app.OwnerId = UserInfo.getUserId();
    List<Event> apps = new List<Event>();
    apps.add(app);
    IM_SendPushNotifications.AppointmentSendPush(apps);


    List<Account> accs = [Select id, PersonContactId from account where id IN : lAccount ];
    List<String> accIdsList = new List<String>();

    for(Account acc : accs){
        accIdsList.add(acc.Id);
    }

   
    //Create Client List to trigger Push
    User usr = IC_TestFactory.createUser('TestLVBacthCLCreation@lvtest.com');
    //usr.BypassVR__c=true;
    usr.profileId = IC_UTILS.getSAProfile();
    insert usr;
    
    CLI_CliList__c cl1 = new CLI_CliList__c(Name = 'testcl1', OwnerId = usr.Id);
    insert cl1;
    CLM_CliListMember__c clm1 =new CLM_CliListMember__c(Client__c = accs[0].PersonContactId, ClientList__c=cl1.Id );
    insert clm1;


    List<Opportunity> opp =[SELECT ID FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
    //Update Order with relevant stageName to trigger Push is working only if 	BypassVR__c

    if(	thisUser.BypassVR__c == true){
        opp[0].stageName = 'Quotation submitted';
        update opp;
    }

    CareService__c careService = new CareService__c(ExternalId__c = '95TECH955',
                client__c = oAcc1.Id,
                Is_Hot__c  = true,
                Red_Code__c  = true,
                SKU__c = 'M51980',
                TotalAmount__c = null,
                CA_Code__c =  'JM0726',
                CA__c = usr.Id,
                StoreRetailCode__c =  'V06',
                Delivery_Date__c =  null,
                Delivery_Address__c =  'test adress USER TECH');
    
        //insert careService;
    
    List<CareService__c> CSList = new List<CareService__c>();
    CSList.add(careService);
    


    CareService__c careService1 = new CareService__c(ExternalId__c = '95TECH955',
    client__c = oAcc1.Id,
    Is_Hot__c  = true,
    Red_Code__c  = true,
    SKU__c = 'M51980',
    TotalAmount__c = null,
    CA_Code__c =  'JM0726',
    CA__c = usr.Id,
    StoreRetailCode__c =  'V06',
    Delivery_Date__c =  null,
    Delivery_Address__c =  'test adress USER TECH');
    insert careService1;
    Map<id, CareService__c> oldmapservice= new  Map<id, CareService__c>();
    oldmapservice.put(careService1.id,careService1);
try{
    IM_SendPushNotifications.CareServiceSendPush(CSList, false, oldmapservice);
    //IM_SendPushNotifications.ClientReassignSendPush(accIdsList);

    IM_SendPushNotifications.CareServiceSendPush(CSList, true, oldmapservice);
}
catch(Exception e){}
    
    
    Test.stopTest();
}
    
    

}