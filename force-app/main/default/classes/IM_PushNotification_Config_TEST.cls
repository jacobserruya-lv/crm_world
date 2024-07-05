@isTest
private class IM_PushNotification_Config_TEST {

    @testSetup static void setUp(){
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
	static void itShould()
	{
		

        User thisUser = [select Id,BypassVR__c from User where Id = :UserInfo.getUserId()];
        
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


        List<Account> accs = [Select id, PersonContactId from account where id IN : lAccount ];
        List<String> accIdsList = new List<String>();

        for(Account acc : accs){
            accIdsList.add(acc.Id);
        }

        User usr = IC_TestFactory.createUser('TestLVBacthCLCreation@lvtest.com');
        //usr.BypassVR__c=true;
		usr.profileId = IC_UTILS.getSAProfile();
        insert usr;

        //Create Client List to trigger Push
        CLI_CliList__c cl1 = new CLI_CliList__c(Name = 'testcl1');
        insert cl1;
        CLM_CliListMember__c clm1 =new CLM_CliListMember__c(Client__c = accs[0].PersonContactId, ClientList__c=cl1.Id );
        insert clm1;


        List<Opportunity> opp =[SELECT ID FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
        //Update Order with relevant stageName to trigger Push is working only if 	BypassVR__c

        if(	thisUser.BypassVR__c == true){
        	opp[0].stageName = 'Quotation submitted';
        	update opp;
        }
    
        Test.startTest();
        

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

        
        // insert new CareService__c(
        //     ExternalId__c = '95TECH955',
		// 			Is_Hot__c  = true,
		// 			Red_Code__c  = true,
		// 			SKU__c = 'M51980',
		// 			TotalAmount__c = null,
		// 			CA_Code__c =  'JM0726',
        //             CA__c = UserInfo.getUserId(),
		// 			StoreRetailCode__c =  'A06',
		// 			Delivery_Date__c =  null,
		// 			Delivery_Address__c =  'test adress USER TECH'
        // );
 store__c str = new Store__c(RetailStoreId__c = '12345', Status__c='Open');
        insert str;
    usr.DefaultStore__c='12345';
    update usr;
    
        List<IconSetting__mdt> iconSettings = [Select Text__c
             FROM IconSetting__mdt 
             WHERE MasterLabel ='CaseStatusPush'];

System.debug('RRRRRRRRRRR usr: ' + usr.DefaultStore__c);
        Case ca = ICX_TestFactory.createCase(oAcc1.id);
        ca.Country__c = 'FRANCE';
        Id caRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Web&Email Case').getRecordTypeId();
        ca.recordTypeId = caRecordTypeId;
        ca.CA_Name__c = Usr.id;
        ca.Resolution__c = iconSettings[0].Text__c;
        System.debug('BBBBBBBBBBB ca: ' + ca);
        ca.Store__c = str.Id;
        ca.Product_Sku_unknown__c = 'fdkl555';
        insert ca;

    

        Test.stopTest();

		// When


		// Then

	}
}