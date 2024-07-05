/**
 * This is a test class for SO_ClientSearch_CTRL webservice class
 * @createdBy           
 * @lastModifiedBy      Ester Mendelson, 14-01-2015
 */
@isTest
private class SO_ClientSearch_TEST 
{
	///**
	//* [Set database]
	//* @scenario    		[insert objects to the system]
	//* @result           [database to work with]
	//* @createdBy        
 //   * @lastModifiedBy 	
	//*/
	//@testSetup static void methodName() 
	//{
	//	SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
	//	dataModel.initialization_one(true,true);
	//	dataModel.customSettingForClientSearchInit(); 
	//}

	//@isTest static void test_method_one() 
	//{
	//	List<Opportunity> oppList = [Select Id, Name,AccountId, SPO_ConcatenateTitle__c ,StageName, SPO_StoreCode__c, SPO_RMSClientId__c, SPO_Session_State__c, SPO_DisplayOrder__c FROM Opportunity];
	//	SO_Session.startSession(oppList[0]);

	//	PageReference ref =  new PageReference('/apex/so_clientsearch');
 //       Test.setCurrentPage(ref);

	//	SO_ClientSearch_CTRL ctrl = new SO_ClientSearch_CTRL();
	//	system.assertEquals(ctrl.productPage,null);
	//	system.assertEquals(ctrl.clieniIndex,null);
	//	ctrl.retColumns(null);
	//	Integer testInt = ctrl.retTotalCount('1234');
		
	//}
	
	//@isTest static void testWithSession() 
	//{
	//	Account acc = IC_TestFactory.createAccount();
	//	insert acc;

	//	List<Opportunity> opp =[SELECT ID,Name
	//									,OwnerId
	//									,StageName
	//									,AccountId
	//									,Account.Name
	//									,Account.LastName
	//									,toLabel(Account.Salutation)
	//									,SPO_ConcatenateTitle__c
	//									,SPO_OpportunityCloning__c
	//									,SPO_StoreCode__c
	//									,SPO_Store__c
	//									,SPO_Store__r.RetailStoreId__c
	//									,SPO_RMSClientId__c
	//									,SPO_Session_State__c
	//									,SPO_BaseSKURefmodelSKU__c
	//									,SPO_BaseSKURefmodelSKU__r.Name
	//									,SPO_BaseSKURefmodelSKU__r.SKUCode__c

	//									,SPO_DisplayOrder__c
	//							FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
	//	SO_Session.startSession(opp[0]);
	//	SO_Session.currentBriefById(opp[0].id);

	//	SO_UTIL.SearchClientData clientData = new SO_UTIL.SearchClientData();
	//	clientData.lastName = 'Test';
	//	clientData.givenName = 'Test';
	//	clientData.email = 'test@test.com';
	//	clientData.passportNumber ='12345678';
	//	PageReference ref =  new PageReference('/apex/so_clientsearch');
 //       ref.getParameters().put('bid',opp[0].id);
 //       Test.setCurrentPage(ref);

	//	SO_ClientSearch_CTRL ctrl = new SO_ClientSearch_CTRL();
	//	ctrl.theSessionState.displayOrder = true;
	//	ctrl.contactForCountry.SPO_Country__c = 'FRANCE';
	//	ctrl.theSessionState.searchClientData.country ='FRANCE';
	//	ctrl.selectAccountId = acc.id;
	//	ctrl.showAccount();
	//	ctrl.nextAndSetDisplayOrder();
		
	//	ctrl.retTemplate('1234','Id',new Account());
	//	ctrl.theSessionState.displayOrder =false;
	//	ctrl.search();
	//	ctrl.theSessionState.searchClientData.lastName = 'Data Model Tester 001';
	//	ctrl.search();
	//	ctrl.theSessionState.searchClientData.country ='FRANCE';
	//	ctrl.theSessionState.searchClientData.lastName = 'Data Model Tester*';
	//	ctrl.theSessionState.searchClientData.email = 'test*';
	//	ctrl.theSessionState.searchClientData.phoneNumber = 'test*';
	//	ctrl.theSessionState.searchClientData.passportNumber = 'test*';
	//	ctrl.theSessionState.searchClientData.givenName ='test*';
	//	ctrl.theSessionState.searchClientData.zipCode = 'test*';
	//	ctrl.search();
	//	ctrl.theSessionState.searchClientData.givenName ='test';
	//	ctrl.theSessionState.searchClientData.email = 'test';
	//	ctrl.theSessionState.searchClientData.phoneNumber = 'test';
	//	ctrl.theSessionState.searchClientData.passportNumber = 'test';
	//	ctrl.theSessionState.searchClientData.country ='FRANCE';
	//	ctrl.theSessionState.searchClientData.zipCode = 'test';
	//	ctrl.search();
	//	ctrl.retColumns(null);
	//	ctrl.getCurrentPosition(null,1,1,1,1,1,1);
	//	ctrl.selectAccountId = (String)acc.id;
	//	ctrl.showAccount();
	//	ctrl.checkDisplayOrder();
	//	ctrl.searchFromRMS();		
	//}

	//@isTest static void testWithSessionNoSKU() 
	//{
	//	Account acc = IC_TestFactory.createAccount();
	//	insert acc;

	//	List<Opportunity> opp =[SELECT ID,Name
	//									,OwnerId
	//									,StageName
	//									,AccountId
	//									,Account.Name
	//									,Account.LastName
	//									,toLabel(Account.Salutation)
	//									,SPO_ConcatenateTitle__c
	//									,SPO_OpportunityCloning__c
	//									,SPO_StoreCode__c
	//									,SPO_Store__c
	//									,SPO_Store__r.RetailStoreId__c
	//									,SPO_RMSClientId__c
	//									,SPO_Session_State__c
	//									,SPO_BaseSKURefmodelSKU__c
	//									,SPO_BaseSKURefmodelSKU__r.Name
	//									,SPO_BaseSKURefmodelSKU__r.SKUCode__c

	//									,SPO_DisplayOrder__c
	//							FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		

	//	SO_Session.startSession(opp[0]);
	//	SO_Session.currentBriefById(opp[0].id);

	//	SO_UTIL.SearchClientData clientData = new SO_UTIL.SearchClientData();
	//	clientData.lastName = 'Test';
	//	clientData.givenName = 'Test';
	//	clientData.email = 'test@test.com';
	//	clientData.passportNumber ='12345678';
	//	PageReference ref =  new PageReference('/apex/so_clientsearch');
 //       ref.getParameters().put('bid',opp[0].id);
 //       Test.setCurrentPage(ref);

	//	SO_ClientSearch_CTRL ctrl = new SO_ClientSearch_CTRL();
	//	ctrl.theSessionState.displayOrder =true;

	//	ctrl.selectAccountId = acc.id;
	//	ctrl.showAccount();
	//	ctrl.nextAndSetDisplayOrder();
	//}

	//@isTest static void testNextAndSetDisplayOrder() 
	//{
	//	Account acc = IC_TestFactory.createAccount();
	//	insert acc;

	//	List<Opportunity> opp =[SELECT ID,Name
	//									,OwnerId
	//									,StageName
	//									,AccountId
	//									,Account.Name
	//									,Account.LastName
	//									,toLabel(Account.Salutation)
	//									,SPO_ConcatenateTitle__c
	//									,SPO_OpportunityCloning__c
	//									,SPO_StoreCode__c
	//									,SPO_Store__c
	//									,SPO_Store__r.RetailStoreId__c
	//									,SPO_RMSClientId__c
	//									,SPO_Session_State__c
	//									,SPO_BaseSKURefmodelSKU__c
	//									,SPO_BaseSKURefmodelSKU__r.Name
	//									,SPO_BaseSKURefmodelSKU__r.SKUCode__c

	//									,SPO_DisplayOrder__c
	//							FROM Opportunity WHERE name='Test Class Opp2' LIMIT 1];
		
	//	opp[0].SPO_BaseSKURefmodelSKU__c = null;
	//	update opp[0];

		
	//	PageReference ref =  new PageReference('/apex/so_clientsearch');
 //       ref.getParameters().put('bid',opp[0].id);
 //       Test.setCurrentPage(ref);
 //       SO_ClientSearch_CTRL ctrl = new SO_ClientSearch_CTRL();

	//	ctrl.nextAndSetDisplayOrder();

	//	SO_Session.startSession(opp[0]);
	//	SO_Session.currentBriefById(opp[0].id);
	//	ctrl.theSessionState.displayOrder =true;
		
	//	ctrl.nextAndSetDisplayOrder();
	//}

	//@isTest static void testWsTemplate() 
	//{	
	//	List<Opportunity> oppList = [Select Id, Name, SPO_ConcatenateTitle__c, StageName,AccountId, SPO_StoreCode__c, SPO_RMSClientId__c, SPO_Session_State__c, SPO_DisplayOrder__c FROM Opportunity];
	//	SO_Session.startSession(oppList[0]);

	//	SO_UTIL.SearchClientData clientData = new SO_UTIL.SearchClientData();
	//	clientData.lastName = 'Test';
	//	clientData.givenName = 'Test';
	//	clientData.email = 'test@test.com';
	//	clientData.passportNumber ='12345678';
	//	PageReference ref =  new PageReference('/apex/so_clientsearch');
 //       Test.setCurrentPage(ref);

	//	SO_ClientSearch_CTRL ctrl = new SO_ClientSearch_CTRL();


	//	ctrl.wsTemplate('1234','Name',new Map<String, Object>{'Account' => new Account(Name ='pc')});
	//	ctrl.wsTemplate('1234','Email',new Map<String, Object>{'Account'=>new Account(Name ='pc')});
	//	ctrl.wsTemplate('1234','Phone',new Map<String, Object>{'Account'=>new Account(Name ='pc')});
	//	ctrl.wsTemplate('1234','Action',new Map<String, Object>{'Account'=>new Account(Name ='pc')});
	//	ctrl.wsTemplate('1234','Location__c',new Map<String, Object>{'PrimaryCity__pc'=>'pc'});
	//	ctrl.wsTemplate('1234','Location__c',new Map<String, Object>{'PrimaryCity'=>'pc'});
	//	ctrl.wsTemplate('1234','Location__c',new Map<String, Object>{'PrimaryCountry'=>'PrimaryCountry'});
	//	ctrl.wsTemplate('1234','Location__c',new Map<String, Object>{'SPO_Country_code__pc'=>'SPO_Country_code__pc'});
	//	ctrl.wsTemplate('1234','',new Map<String, Object>{'SPO_Country_code__pc'=>'SPO_Country_code__pc'});

	//	ctrl.dbTemplate('1234','Location__c',new Map<String, Object>{'PrimaryCity__pc'=>'pc'});
	//	ctrl.dbTemplate('1234','Location__c',new Map<String, Object>{'PrimaryCity'=>'pc'});
	//	ctrl.dbTemplate('1234','Location__c',new Map<String, Object>{'PrimaryCountry'=>'PrimaryCountry'});
	//	ctrl.dbTemplate('1234','Location__c',new Map<String, Object>{'SPO_Country_code__pc'=>'SPO_Country_code__pc'});
	//	ctrl.dbTemplate('1234','PersonMobilePhone',new Map<String, Object>{'PersonMobilePhone'=>'PersonMobilePhone'});
	//	ctrl.dbTemplate('1234','PersonMobilePhone',new Map<String, Object>{'Phone'=>'Phone'});
	//	ctrl.dbTemplate('1234','PersonMobilePhone',new Map<String, Object>{'PersonHomePhone'=>'PersonHomePhone'});
	//	ctrl.dbTemplate('1234','PersonMobilePhone',new Map<String, Object>{'PersonAssistantPhone'=>'PersonAssistantPhone'});
	//	ctrl.dbTemplate('1234','',new Map<String, Object>{'SPO_Country_code__pc'=>'SPO_Country_code__pc'});
	//}

	//@isTest static void testDBTemplate() 
	//{
	//	List<Opportunity> oppList = [Select Id, Name, SPO_ConcatenateTitle__c ,AccountId, StageName, SPO_Session_State__c, SPO_RMSClientId__c, SPO_DisplayOrder__c FROM Opportunity];
	//	SO_Session.startSession(oppList[0]);

	//	SO_UTIL.SearchClientData clientData = new SO_UTIL.SearchClientData();
	//	clientData.lastName = 'Test';
	//	clientData.givenName = 'Test';
	//	clientData.email = 'test@test.com';
	//	clientData.passportNumber ='12345678';
	//	PageReference ref =  new PageReference('/apex/so_clientsearch');
 //       Test.setCurrentPage(ref);

	//	SO_ClientSearch_CTRL ctrl = new SO_ClientSearch_CTRL();

	//	ctrl.dbTemplate('1234','Location__c',new Map<String, Object>{'Account'=>new Account(PrimaryCity__pc ='pc')});
	//	ctrl.dbTemplate('1234','Email',new Map<String, Object>{'Account'=>new Account(PrimaryCity__pc ='pc')});
	//	ctrl.dbTemplate('1234','Name',new Map<String, Object>{'Account'=>new Account(PrimaryCity__pc ='pc')});
	//	ctrl.dbTemplate('1234','DREAMID__c',new Map<String, Object>{'Account'=>new Account(PrimaryCity__pc ='pc')});
	//	ctrl.dbTemplate('1234','PersonMobilePhone',new Map<String, Object>{'Account'=>new Account(PrimaryCity__pc ='pc')});
	//	ctrl.dbTemplate('1234','Actions',new Map<String, Object>{'Account'=>new Account(PrimaryCity__pc ='pc')});
	//	ctrl.clear();
	//}
	
	///**
	//* [Search client in RMS using webservice]
	//* @scenario    		[call SO_WS_RMS_DoClientSearch webservice to search for client]
	//* @result           [client found]
	//* @createdBy        Nadav Lichtenshtein, 24-12-2015
	//* @lastModifiedBy 	Nadav Lichtenshtein, 24-12-2015
	//*/
	//@isTest static void ClientSearch() 
	//{
	//	List<Account> accountList = [SELECT Id, LastName, FirstName, Salutation, Segmentation__pc, PrimaryAddressLine1__pc,
	//									PrimaryAddressLine2__pc, PrimaryAddressLine3__pc, PrimaryCity__pc, PersonEmail,
	//									PrimaryZipCode__pc, SPO_Country_code__pc, PassportNumber__pc 
	//									FROM Account];
 //       accountList[0].Salutation = 'Ms';
 //       accountList[0].Segmentation__pc='VIC';
 //       accountList[0].PrimaryAddressLine1__pc='Adresse ligne 1';
 //       accountList[0].PrimaryAddressLine2__pc='Adresse ligne 2';
 //       accountList[0].PrimaryAddressLine3__pc ='Adresse ligne 3';
 //       accountList[0].PrimaryCity__pc='Paris';
 //       accountList[0].PersonEmail='sylvie@lv.com';
 //       accountList[0].PrimaryZipCode__pc='75000';
 //       accountList[0].SPO_Country_code__pc='FRA';
 //       accountList[0].PassportNumber__pc='ABC12345';
 //       update accountList[0];

	//	List<Opportunity> oppList = [Select Id, Name, SPO_ConcatenateTitle__c,AccountId, StageName, SPO_StoreCode__c, SPO_RMSClientId__c, SPO_Session_State__c, SPO_DisplayOrder__c FROM Opportunity];
	//	Opportunity currOpp = oppList[0];

	//	SO_UTIL.SearchClientData clientData = new SO_UTIL.SearchClientData();
	//	clientData.lastName = 'Test';
	//	clientData.givenName = 'Test';
	//	clientData.email = 'test@test.com';
	//	clientData.passportNumber ='12345678';
	//	clientData.zipCode = '12345';
	//	clientData.dreamId = '1234';
	//	clientData.storeCode = '123';
	//	PageReference ref =  new PageReference('/apex/so_clientsearch');
 //       Test.setCurrentPage(ref);

	//	Test.setMock(WebServiceMock.class, new SO_ClientSearch_MOCK('000'));

	//	Test.startTest();

	//	SO_Session.startSession(currOpp);

	//	SO_ClientSearch_CTRL ctrl = new SO_ClientSearch_CTRL();
	//	ctrl.theSessionState.displayOrder = true;
	//	ctrl.theSessionState.searchClientData = clientData;
	//	ctrl.selectAccountId = accountList[0].id;
		
	//	ctrl.retTemplate('1234','Id',new Account());
	//	ctrl.theSessionState.displayOrder =false;
	
	//	ctrl.searchFromRMS();

	//	Test.stopTest();
	//}

	///**
	//* [Clone client in RMS using webservice]
	//* @scenario    		[Call cloneClient, it will create a client with a webservice]
	//* @result           [client found]
	//* @createdBy        Nadav Lichtenshtein, 24-12-2015
	//* @lastModifiedBy 	Nadav Lichtenshtein, 24-12-2015
	//*/
	//@isTest static void cloneClient() 
	//{
 //       //using SO_ClientSearch_MOCK to create request
	//	Test.setMock(WebServiceMock.class, new SO_ClientSearch_Enqiery_MOCK('000'));
		
	//	List<Account> accountList = [SELECT Id, LastName, FirstName, Salutation, Segmentation__pc, PrimaryAddressLine1__pc,
	//									PrimaryAddressLine2__pc, PrimaryAddressLine3__pc, PrimaryCity__pc, PersonEmail,
	//									PrimaryZipCode__pc, SPO_Country_code__pc, PassportNumber__pc 
	//									FROM Account];
 //       accountList[0].Salutation = 'Ms';
 //       accountList[0].Segmentation__pc='VIC';
 //       accountList[0].PrimaryAddressLine1__pc='Adresse ligne 1';
 //       accountList[0].PrimaryAddressLine2__pc='Adresse ligne 2';
 //       accountList[0].PrimaryAddressLine3__pc ='Adresse ligne 3';
 //       accountList[0].PrimaryCity__pc='Paris';
 //       accountList[0].PersonEmail='test@test.com';
 //       accountList[0].PrimaryZipCode__pc='12345';
 //       //accountList[0].PrimaryCountry__pc='France';
 //       accountList[0].SPO_Country_code__pc='FRA';
 //       accountList[0].PassportNumber__pc='12345678';
 //       update accountList[0];

	//	List<Opportunity> opp =[SELECT ID,Name
	//									,OwnerId
	//									,StageName
	//									,AccountId
	//									,Account.Name
	//									,Account.LastName
	//									,toLabel(Account.Salutation)
	//									,SPO_ConcatenateTitle__c
	//									,SPO_OpportunityCloning__c
	//									,SPO_StoreCode__c
	//									,SPO_Store__c
	//									,SPO_Store__r.RetailStoreId__c
	//									,SPO_RMSClientId__c
	//									,SPO_Session_State__c
	//									,SPO_BaseSKURefmodelSKU__c
	//									,SPO_BaseSKURefmodelSKU__r.Name
	//									,SPO_BaseSKURefmodelSKU__r.SKUCode__c

	//									,SPO_DisplayOrder__c
	//							FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
	//	opp[0].SPO_RMSClientId__c = 'testId';
	//	update opp[0];

	//	SO_Session.startSession(opp[0]);
	//	SO_Session.currentBriefById(opp[0].id);

	//	SO_UTIL.SearchClientData clientData = new SO_UTIL.SearchClientData();
	//	clientData.lastName = 'Data Model Tester 001';
	//	clientData.givenName = 'Test';
	//	clientData.email = 'test@test.com';
	//	clientData.passportNumber ='12345678';
	//	clientData.zipCode = '12345';
	//	clientData.dreamId = '1234';
	//	clientData.storeCode = '123';
	//	PageReference ref =  new PageReference('/apex/so_clientsearch');
 //       ref.getParameters().put('bid',opp[0].id);
 //       Test.setCurrentPage(ref);

 //       List<Map<String, Object>> generalResultObjMapList = new List<Map<String, Object>>();
 //       Map<String, Object> obj1 = new Map<String, Object>();
 //       generalResultObjMapList.add(obj1);

	//	SO_ClientSearch_CTRL ctrl = new SO_ClientSearch_CTRL();
	//	ctrl.theSessionState.displayOrder = true;
	//	ctrl.selectAccountId = accountList[0].id;
	//	ctrl.nextAndSetDisplayOrder();
	//	ctrl.generalResultObjMapList = generalResultObjMapList;
		
	//	ctrl.retTemplate('1234','Id',new Account());
	//	ctrl.theSessionState.displayOrder =false;

	//	ctrl.theSessionState.searchClientData.dreamId = '123';

	//	ctrl.theSessionState.searchClientData = clientData;
		
	//	Test.startTest();

	//	ctrl.clieniIndex = 0;
	//	ctrl.cloneClient();

	//	Test.stopTest();
	//}

	///**
	//* [initPage function]
	//* @scenario    		[Initialize the page]
	//* @result           [page initialize]
	//* @createdBy        Nadav Lichtenshtein, 24-12-2015
	//* @lastModifiedBy 	Nadav Lichtenshtein, 24-12-2015
	//*/
	//@isTest static void InitPage() 
	//{
	//	List<Opportunity> oppList = [Select Id, Name, SPO_ConcatenateTitle__c , StageName, SPO_Session_State__c, SPO_RMSClientId__c, SPO_StoreCode__c, SPO_DisplayOrder__c, AccountId FROM Opportunity];
	//	oppList[0].StageName 	= 'Creation in Progress';
	//	update oppList[0];

	//	SO_Session.startSession(oppList[0]);

	//	SO_UTIL.SearchClientData clientData = new SO_UTIL.SearchClientData();
	//	clientData.lastName = 'Test';
	//	clientData.givenName = 'Test';
	//	clientData.email = 'test@test.com';
	//	clientData.passportNumber ='12345678';
	//	PageReference ref =  new PageReference('/apex/so_clientsearch');
 //       Test.setCurrentPage(ref);

	//	Test.startTest();

	//	SO_ClientSearch_CTRL ctrl = new SO_ClientSearch_CTRL();
	//	ctrl.initPage();

	//	Test.stopTest();
	//}

	///**
	//* [retQueryResult]
	//* @scenario    		[call search to call searchFromSF that will put values in generalResultObjMapList, then call retQueryResult]
	//* @result           [client found]
	//* @createdBy        Nadav Lichtenshtein, 24-12-2015
	//* @lastModifiedBy 	Nadav Lichtenshtein, 24-12-2015
	//*/
	//@isTest static void RetQueryResult() 
	//{
	//	Account acc = IC_TestFactory.createAccount();
	//	acc.NationalityCountryCode__pc = 'FRA';
	//	acc.SPO_Country_code__pc = 'FRA';
	//	insert acc;

	//	List<Opportunity> opp =[SELECT ID,Name
	//									,OwnerId
	//									,StageName
	//									,AccountId
	//									,Account.Name
	//									,Account.LastName
	//									,toLabel(Account.Salutation)
	//									,SPO_ConcatenateTitle__c
	//									,SPO_OpportunityCloning__c
	//									,SPO_StoreCode__c
	//									,SPO_Store__c
	//									,SPO_Store__r.RetailStoreId__c
	//									,SPO_RMSClientId__c
	//									,SPO_Session_State__c
	//									,SPO_BaseSKURefmodelSKU__c
	//									,SPO_BaseSKURefmodelSKU__r.Name
	//									,SPO_BaseSKURefmodelSKU__r.SKUCode__c

	//									,SPO_DisplayOrder__c
	//							FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
	//	SO_Session.startSession(opp[0]);
	//	SO_Session.currentBriefById(opp[0].id);

	//	SO_UTIL.SearchClientData clientData = new SO_UTIL.SearchClientData();
	//	clientData.lastName = 'Test';
	//	clientData.givenName = 'Test';
	//	clientData.email = 'test@test.com';
	//	clientData.passportNumber ='12345678';
	//	PageReference ref =  new PageReference('/apex/so_clientsearch');
 //       ref.getParameters().put('bid',opp[0].id);
 //       Test.setCurrentPage(ref);

 //       //using SO_ClientSearch_MOCK to create request
	//	Test.setMock(WebServiceMock.class, new SO_ClientSearch_Enqiery_MOCK('000'));

	//	Test.startTest();

	//	SO_ClientSearch_CTRL ctrl = new SO_ClientSearch_CTRL();
	//	ctrl.contactForCountry.SPO_Country__c = 'FRANCE';
	//	ctrl.theSessionState.searchClientData.country ='FRANCE';
	//	ctrl.theSessionState.displayOrder = true;
	//	ctrl.selectAccountId = acc.id;
	//	ctrl.showAccount();
	//	ctrl.nextAndSetDisplayOrder();
		
	//	ctrl.retTemplate('1234','Id',new Account());
	//	ctrl.theSessionState.displayOrder =false;
	//	ctrl.search();

	//	ctrl.theSessionState.searchClientData.lastName = 'Data Model Tester 001';
	//	ctrl.search();

	//	ctrl.retQueryResult('123', 1, 0, 's', 'so');

	//	Test.stopTest();
	//}

	///**
	//* [ShowAccount]
	//* @scenario    		[call webservice]
	//* @result           []
	//* @createdBy        Nadav Lichtenshtein, 24-12-2015
	//* @lastModifiedBy 	Nadav Lichtenshtein, 24-12-2015
	//*/
	//@isTest static void ShowAccount() 
	//{
	//	Account acc = IC_TestFactory.createAccount();
	//	insert acc;

	//	List<Opportunity> opp =[SELECT ID,Name
	//									,OwnerId
	//									,StageName
	//									,AccountId
	//									,Account.Name
	//									,Account.LastName
	//									,toLabel(Account.Salutation)
	//									,SPO_StoreCode__c
	//									,SPO_OpportunityCloning__c
	//									, SPO_ConcatenateTitle__c
	//									,SPO_Store__c
	//									,SPO_Store__r.RetailStoreId__c
	//									,SPO_RMSClientId__c
	//									,SPO_Session_State__c
	//									,SPO_BaseSKURefmodelSKU__c
	//									,SPO_BaseSKURefmodelSKU__r.Name
	//									,SPO_BaseSKURefmodelSKU__r.SKUCode__c

	//									,SPO_DisplayOrder__c
	//							FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
	//	SO_Session.startSession(opp[0]);
	//	SO_Session.currentBriefById(opp[0].id);

	//	SO_UTIL.SearchClientData clientData = new SO_UTIL.SearchClientData();
	//	clientData.lastName = 'Test';
	//	clientData.givenName = 'Test';
	//	clientData.email = 'test@test.com';
	//	clientData.passportNumber ='12345678';
	//	PageReference ref =  new PageReference('/apex/so_clientsearch');
 //       ref.getParameters().put('bid',opp[0].id);
 //       Test.setCurrentPage(ref);

 //      //using SO_CreateUpdateRMSCLient_Utils_MOCK to create request
	//	Test.setMock(WebServiceMock.class, new SO_CreateUpdateRMSCLient_Utils_MOCK('000'));

	//	Test.startTest();

	//	SO_ClientSearch_CTRL ctrl = new SO_ClientSearch_CTRL();
	//	ctrl.theSessionState.displayOrder = true;
	//	ctrl.selectAccountId = acc.id;
	//	ctrl.showAccount();

	//	Test.stopTest();
	//}
}