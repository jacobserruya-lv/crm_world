/**
    About
    -----
    Description= Test class for IC_UTILS 
    Created for= SOW= IC001 ICON project
    Create date= FEB 2013

    Details
    -------
    This class contains methods that cover 
        - Get Record Types for Task, .. 
        - Describe schema, fields and assigned object,  
        - Append List to Map
        - Get Salesforce with current instance
        - Get Custom Settings
    
    Update History
    --------------
    Feb 2013 / IC001/ Created by Maroun Imad

    Issues / TODOs
    --------------
*/
@isTest
private class IC_UTILS_TEST {

@TestSetup
    public static void setup() {
        String identityProfile = [SELECT Id FROM Profile WHERE Name = 'Identity User'][0].Id;
        insert new IC_Config__c(
            Name = 'Identity User',
            Value__c = identityProfile
        );

		ICONSettings__c iconSetting = new ICONSettings__c(
			Name = 'a04i0000000zpHL',
			ExcepPurchaseUSD__c = 4000,
			Check_IpAddress__c = false,
			Default_ShowAs__c = 'Busy',
			Domain__c = 'louisvuitton.my.salesforce.com',
			Email_Domain__c = '@icon.vuitton.com',
			Link_ClientDetails__c = 'IC_ClientDetails',
			Link_ClientSearch__c = 'IC_SearchClient',
			Link_EventDetails__c = 'IC_EventDetails',
			Link_MyCLientLists__c = 'IC_MyCLientLists',
			Link_MyEvents__c = 'IC_MyEvents',
			Link_MyToDo__c = 'IC_MyTasks',
			Link_MyTopClients__c = 'IC_MyTopClients',
			Link_TaskDetails__c = 'IC_TaskDetails',
			Login_Page__c = 'https=//icon-louisvuitton.secure.force.com/login',
			Session_Timeout__c = 28500,
			Completed_Picklist_Statuses__c = 'Completed;Done',
			Link_Calendar__c = 'IC_Calendar',
			Link_MyRecentClients__c = 'IC_MyRecentClients',
			Targeted_Clients_Lists_Nb_Rows__c = 1000,
			Targeted_Clients_Lists_PaginationSize__c = 100,
			Param_DeleteTransaction_batch__c = '2013-10-26T00=00=00.000+0000',
			CountryWhereDisplayName2__c = 'JAPAN',
			SiteDomain__c = 'icon-louisvuitton.secure.force.com',
			VFDomain__c = 'c.na15.visual.force.com',
			accountPurgeLimit__c = 25,
			Link_MyStoreTopClients__c = 'IC_MyStoreTopClients',
			taskPurgeMaxLimit__c = 6,
			taskPurgeMinLimit__c = 1,
			NewRelic__c = true,
			ShowWeChat__c = 'CHINA, HONG KONG',
			AnniversaryScheduledDays__c = '14, 15',
			BirthdateScheduledDays__c = '14, 15',
			ClientAnonymizationLimit__c = 100000,
			Exceptional_Purchase_Currency__c = 'EUR',
			ProspectClientPurge__c = 1,
			ExcepPurchaseFrequence__c = 1,
			AccLastContactTimeRange__c = 30,
			batchAnniversaryScope__c = 400,
			batchAnonymizationScope__c = 400,
			batchBirthdayReminderScope__c = 400,
			Link_MyBirthdayClients__c = 'IC_MyBirthdayClients',
			Link_MyVoiceClients__c = 'IC_MyVoiceClients',
			ClientAnonymizationSuffixe__c = 'prd',
			OnlineApptRT__c = '0120H000001QWpSQAW',
			ClientAnonymizationDaysLimit__c = 90,
			Technical_User__c = '0050H000009Joe6QAC',
			useOneData__c = false
		);
		insert iconSetting;
    }

	static testMethod void describeMethods()
	{
		// We cannot check the actual values of field names as the config may have changed this in the workbench, but they should all return a string of some length
		System.assert(IC_UTILS.getFieldLabel('Account', 'DREAMID__c').length()>0); 
		System.assert(IC_UTILS.getFieldLabel('Account', 'Name').length()>0);
		
		// This should product an empty string
		System.assert(IC_UTILS.getFieldLabel('Product2', 'does not exit')=='');
		System.assert(IC_UTILS.getFieldLabel('Product2', null)=='');
	}
	
	/**** Maps ****/
	static testMethod void testMapListAppend()
	{
		Map<Object,Object[]> objectMap = new Map<Object,Object[]>();
		
		// The first time add in Map the KEY and value in list 
		objectMap =  IC_UTILS.mapListAppend(objectMap, 'KEY1', 'Value 1-1');
		objectMap =  IC_UTILS.mapListAppend(objectMap, 'KEY2', 'Value 2-1');
		// If Key already exists in Map append to his list of values the parameter 
		objectMap =  IC_UTILS.mapListAppend(objectMap, 'KEY1', 'Value 1-2');
		objectMap =  IC_UTILS.mapListAppend(objectMap, 'KEY1', 'Value 1-3');
			
		Object[] theList = objectMap.get('KEY1'); 
		System.assert(objectMap.get('KEY2').size()>0); 
		System.assert(theList[0] == 'Value 1-1');
		System.assert(theList[1] == 'Value 1-2');
		System.assert(theList[2] == 'Value 1-3');
	}

    /**** Record Types ****/
    // Test the existing of record types for Exchnage Rate, Cpc Price Alert, ....
	static testMethod void testExistingRT() {
		System.assert(!IC_Utils.empty(IC_Utils.getTaskRT()));
		System.assert(!IC_Utils.empty(IC_Utils.getTaskDreamRT()));

	}
	
	/**** URL ****/
	static testMethod void testSfInstance() {
	   String sfInst = IC_Utils.sfInstance;
	   //System.assert(sfInst != null && sfInst.length() > 0);
	   String baseURL = IC_Utils.baseURL();
	   String sfURL =  'https=//' + sfInst + '.salesforce.com';
	   //System.assert(baseURL == sfURL);
	}
	
	/**** Lists ****/
	// Test convert List, Serialize, Deserialize, ..
	static testMethod void testList()
	{
		List<String> aList = new List<String>();
		String mutiSelectList =  '';
		
		for (Integer i=0; i < 3;  i++) {
			aList.add('value' + i);
			mutiSelectList= mutiSelectList + 'value'+i + ';';
		}
		mutiSelectList= mutiSelectList.removeEnd(';');
	
		Set<String> aSet = IC_UTILS.toSet(aList);
		System.assert(aSet.size() == 3);
		String[] deserialize = IC_UTILS.deserializeMultiSelect(mutiSelectList);
		System.assert(deserialize.size() == 3);
		String serializeListQotes = IC_UTILS.serializeWithQuotes(aList);
		System.assert(serializeListQotes.length() > 0);
		String serializeSetQotes = IC_UTILS.serializeWithQuotes(aSet);
		System.assert(serializeSetQotes.length() > 0);
		String serializeWithQotes = IC_UTILS.serializeWithQuotes(mutiSelectList);
		System.assert(serializeWithQotes.length() > 0);
		
	}
    
    /**** Generic ****/
	// Test math, generic,  ..
	static testMethod void testGeneric()
	{
		Decimal d = 1;
		Integer i;
		System.assert(IC_Utils.empty(i));
		System.assert(!IC_Utils.empty(d));
		System.debug('*** round=' + IC_Utils.round(1.7,2));
	}
	
	/**** Custom Settings ****/
	// Test the existing values in custom setting  ..
	static testMethod void testExistingCS()
	{	

	}
	
    static testMethod void testOrder() {
    	/* Lists */
    	Account[] items = new Account[]{};
    	items.add(new Account(Name='a'));
    	items.add(new Account(Name='b'));
    	items.add(new Account(Name='c'));
    	IC_UTILS.orderList(items, 'Name', 'asc');
    	System.assert(items[0].Name=='a');
    	IC_UTILS.orderList(items, 'Name', 'desc');
    	System.assert(items[0].Name=='c');
    	/******** tests Decembre 2013 *******/
    	Account a = IC_TestFactory.createAccount();
      	a.LastName='France';
      	insert a;
      	ICONSettings__c stt = new ICONSettings__c();
      	stt.CountryWhereDisplayName2__c = 'JAPAN';
      	stt.ShowWeChat__c = 'JAPAN';
      	stt.Completed_Picklist_Statuses__c = 'Complete, Done';
      	stt.Check_IpAddress__c = true;
      	insert stt;
      	
    	IC_UTILS.canDisplaySecondName();
    	IC_UTILS.canShowWeChat();
    	IC_UTILS.getLang();
    	IC_UTILS.getCorporateProfile();
    	IC_UTILS.getDreamProfile();
    	IC_UTILS.getLocale();
    	IC_UTILS.getSAProfile();
    	
    	IC_UTILS.getSAManagerProfile();
    	IC_UTILS.getSAAnimatorProfile();
    	
    	IC_UTILS.getDefaultCurrencyStep();
    	IC_UTILS.getDefaultUserCurrency();
    	IC_UTILS.getUserCountry();
    	User userr = IC_TestFactory.createUser('Test User');
    	
    	//PBD
    	User currentUser = [Select Id, Currency__c from User where Id=:UserInfo.getUserId() limit 1];
    	IC_UTILS.getDefaultUserCurrency();
    	IC_UTILS.getDefaultCurrencyStep();
    	currentUser.Currency__c = 'USD';
    	update currentUser;
    	IC_UTILS.getDefaultUserCurrency();
    	IC_UTILS.getDefaultCurrencyStep();
    	currentUser.Currency__c = 'EUR';
    	update currentUser;
    	IC_UTILS.getDefaultUserCurrency();
    	IC_UTILS.getDefaultCurrencyStep();
    	currentUser.Currency__c = 'JPY';
    	update currentUser;
    	IC_UTILS.getDefaultUserCurrency();
    	IC_UTILS.getDefaultCurrencyStep();
    	currentUser.Currency__c = 'CNY';
    	update currentUser;
    	IC_UTILS.getDefaultUserCurrency();
    	IC_UTILS.getDefaultCurrencyStep();
    	
    	IC_UTILS.isRecordOwner(null);
    	IC_UTILS.isRecordOwner(UserInfo.getUserId());
		Test.StartTest();
    	
    	Account aa = IC_TestFactory.createAccount();
    	insert aa;
		Test.StopTest();

    	IC_UTILS.hasRecordAccess(aa.Id);
    	
    	IC_UTILS.getUserStore();
    	IC_UTILS.getUserCountry();
    	IC_UTILS.getDreamId();
    	IC_UTILS.getSysAdminProfile();
    	IC_UTILS.getLVAdminProfile();
    	IC_UTILS.isSA();
    	IC_UTILS.isSAAnimator();
    	IC_UTILS.isSAManager();
    	IC_UTILS.isCorporate();
    	IC_UTILS.isInterfaceDream();
    	IC_UTILS.isLVAdmin();
    	IC_UTILS.isSystemAdmin();
    	IC_UTILS.getURLParameters('/apex/IC_EventDetails?cb=MyEvents&tsktype=new');
    	IC_UTILS.isCheckIpActive();
    	IC_UTILS.cs_Login_Page();
    	IC_UTILS.cs_Email_Domain();
    	IC_UTILS.cs_Domain();
    	IC_UTILS.cs_Default_ShowAs();
    	IC_UTILS.cs_Callback_Link('IC_Home');
    	IC_UTILS.cs_Sesssion_Timeout();
    	IC_UTILS.getLocale();
    	IC_UTILS.getLang();
    	IC_UTILS.canDisplaySecondName();
    	IC_UTILS.getTranslationPicklistValue('Contact', 'Salutation', '');
    	IC_UTILS.getTranslationPicklistValue('Contact', 'Salutation', '03');
    	
    	ICONSettings__c sttg = [Select Name, Id From ICONSettings__c i][0];
      	
      	Integer thisDay = Date.today().day();
      	
      	sttg.BirthdateScheduledDays__c = String.valueOf(thisDay);
      	sttg.AnniversaryScheduledDays__c = String.valueOf(thisDay);
      	update sttg;
      	IC_UTILS.getIndexedDays_BR();
      	IC_Utils.getIndexedDays_AR();
      	
      	sttg.BirthdateScheduledDays__c = String.valueOf(thisDay)+ ', 14';
      	sttg.AnniversaryScheduledDays__c = String.valueOf(thisDay)+', 14';
      	update sttg;
      	IC_UTILS.getIndexedDays_BR();
      	IC_Utils.getIndexedDays_AR();
      	sttg.BirthdateScheduledDays__c = '14, ' + String.valueOf(thisDay);
      	sttg.AnniversaryScheduledDays__c = '14, ' + String.valueOf(thisDay);
      	update sttg;
      	IC_UTILS.getIndexedDays_BR();
      	IC_Utils.getIndexedDays_AR();
      	
      	sttg.BirthdateScheduledDays__c = String.valueOf(thisDay)+', 14, 15';
      	sttg.AnniversaryScheduledDays__c = String.valueOf(thisDay)+', 14, 15';
      	update sttg;
      	IC_UTILS.getIndexedDays_BR();
      	IC_Utils.getIndexedDays_AR();
      	sttg.BirthdateScheduledDays__c = '14, '+ String.valueOf(thisDay) +', 15';
      	sttg.AnniversaryScheduledDays__c = '14, '+ String.valueOf(thisDay) +', 15';
      	update sttg;
      	IC_UTILS.getIndexedDays_BR();
      	IC_Utils.getIndexedDays_AR();
      	sttg.BirthdateScheduledDays__c = '14, 15, '+String.valueOf(thisDay);
      	sttg.AnniversaryScheduledDays__c = '14, 15, '+String.valueOf(thisDay);
      	update sttg;
      	IC_UTILS.getIndexedDays_BR();
      	IC_Utils.getIndexedDays_AR();
      	
      	sttg.BirthdateScheduledDays__c = '  ';
      	sttg.AnniversaryScheduledDays__c = '';
      	update sttg;
      	IC_UTILS.getIndexedDays_BR();
      	IC_Utils.getIndexedDays_AR();
      	
      	
      	List<ID> listIDs = new List<ID>{[Select Id from UserRole limit 1][0].Id};
      	IC_UTILS.getAllSubRoleIds(new Set<ID>(listIDs));
    	
    	
    	
    	
    }


	static testMethod void countryNameDisplay()
	{
		CountryConfig__c stt = new CountryConfig__c();
		stt.Name = 'FRANCE';
		stt.ClientNameDisplay__c = 'LNFN';
		insert stt;
		
		User usr = IC_TestFactory.createUser('dreamuserLV@lvtest.com');
		usr.profileId = IC_UTILS.getDreamProfile();
        usr.Country__c = 'FRANCE';
        insert usr;
        
        System.runAs(usr) {
        	IC_Utils.countryNameDisplay();
        }

        stt.ClientNameDisplay__c = null;
        stt.Name = 'BAD COUNTRY';
		update stt;
		
		System.runAs(usr) {
        	IC_Utils.countryNameDisplay();
        }
		
	}

	static testMethod void testUserProfil(){

		IC_UTILS.isLVCountryAdmin();
		IC_UTILS.isICONMonitoring();
		IC_UTILS.isICONSTARCorporate();
		IC_UTILS.isSTARCorporate();
		IC_UTILS.getIdentityProfile();
		IC_UTILS.getUserManagement();
		IC_UTILS.isIconicsProfile();
	}

	static testMethod void testpilotMode(){

		User usr = IC_Test_Common.prepareTestUser('System Administrator');
        insert usr;
        
        System.runAs(usr) {

			IC_UTILS.isInPilotStores();
			IC_UTILS.isInPilotBeta('icon');
			IC_UTILS.isInPilotVirtual();
			IC_UTILS.isUserInPilot('OSA_Virtual_Settings');
		}

		User usr2 = IC_Test_Common.prepareTestUser('System Administrator');
		usr2.MANAGEMENT_ZONE_LEVEL__c ='15';
		usr2.MGMT_ZONE_SUB_LEVEL1__c ='31';
		usr2.MGMT_ZONE_SUB_LEVEL2__c ='99';
		usr2.MGMT_ZONE_SUB_LEVEL3__c ='274';

        usr2.DefaultStore__c = 'A06';		
        usr2.Country__c = 'FRANCE';

        insert usr2;
        
        System.runAs(usr2) {

			IC_UTILS.isInPilotStores();
			IC_UTILS.isInPilotBeta('icon');
			IC_UTILS.isInPilotVirtual();
			IC_UTILS.isUserInPilot('OSA_Virtual_Settings');
		}

	}

	static testMethod void testNotificationMode(){

		User usr = IC_Test_Common.prepareTestUser('System Administrator');
		usr.MANAGEMENT_ZONE_LEVEL__c ='15';
		usr.MGMT_ZONE_SUB_LEVEL1__c ='31';
		usr.MGMT_ZONE_SUB_LEVEL2__c ='99';
		usr.MGMT_ZONE_SUB_LEVEL3__c ='274';
        usr.DefaultStore__c = 'A06';		
        usr.Country__c = 'FRANCE';

        insert usr;
        
        System.runAs(usr) {

			IC_UTILS.isNotificationAllowed('ONLINE APPOINTMENT', 'A06', 'FRANCE', '15');
			IC_UTILS.isNotificationsAllowed(IC_UTILS.getNotificationPermissionByApplication('ONLINE APPOINTMENT'), 'A06', 'FRANCE', '15');
		}

	}
}