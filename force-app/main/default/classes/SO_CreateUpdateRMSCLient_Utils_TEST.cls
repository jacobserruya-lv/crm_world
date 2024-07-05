// /**
//  * This is a test class for SO_CreateUpdateRMSCLient_Utils webservice class
//  * @createdBy           Nadav Lichtenshtein, 23-12-2015
//  * @lastModifiedBy      Nadav Lichtenshtein, 14-1-2016
//  */
 @isTest
 public class SO_CreateUpdateRMSCLient_Utils_TEST 
 {	
	/**
	* [Set database]
	* @scenario    		[insert objects to the system]
	* @result           [database to work with]
	* @createdBy        Nadav Lichtenshtein, 22-12-2015
    * @lastModifiedBy 	Nadav Lichtenshtein, 22-12-2015
	*/
	@testSetup static void Setup()
	{
		SO_TestObjectCreator testObjectCreation = new SO_TestObjectCreator();
		testObjectCreation.initialization_one(true, false);
	}
	
	/**
	* [CreateUpdateSFDCAccount create account in RSM]
	* @scenario    		[call CreateUpdateSFDCAccountIntoRMS, use webservice to insert account in other program RMS]
	* @result           [account successfuly created, callout result is the RMSID]
	* @createdBy        Nadav Lichtenshtein, 23-12-2015
	* @lastModifiedBy 	Nadav Lichtenshtein, 23-12-2015
	*/
	@isTest static void CreateUpdateSFDCAccount() 
	{	
		List<Account> accountList = [Select Id, FirstName, Lastname, FirstName2__pc, Lastname2__pc, PreferredLanguage__pc, PassportNumber__pc,
										Company__pc, PrimaryAddressLine1__pc, PrimaryAddressLine2__pc, PrimaryAddressLine3__pc, PrimaryZipCode__pc,
										PrimaryCity__pc, PrimaryStateProvince__pc, HomePhoneCountryCode__pc, PersonMobilePhone, WorkPhoneCountryCode__pc,
										PersonOtherPhone, BirthdateDay__pc, BirthDateMonth__pc, BirthDateYear__pc, PersonDoNotCall, DoNotSMS__pc,
										DoNotContactbyPost__pc, PersonHasOptedOutOfEmail, PersonEmail
										//, SPO_TaxID__pc , SPO_VATNumber__pc AEF: removed for Ticket 0677
										FROM Account];
		accountList[0].FirstName2__pc 			= 'testFName2';
		accountList[0].Lastname2__pc 			= 'testLName2';
		accountList[0].PreferredLanguage__pc 	= 'AAR';
		accountList[0].PassportNumber__pc 		= '12345';
		accountList[0].Company__pc				= 'comp';
		accountList[0].PrimaryAddressLine1__pc 	= 'address1';
		accountList[0].PrimaryAddressLine2__pc 	= 'address2';
		accountList[0].PrimaryAddressLine3__pc  = 'address3';
		accountList[0].PrimaryZipCode__pc 		= '123';
		accountList[0].PrimaryCity__pc 			= 'Chu';
		accountList[0].PrimaryStateProvince__pc = 'Chong';
		accountList[0].HomePhoneCountryCode__pc = '08';
		accountList[0].PersonMobilePhone 		= '0343456665';
		accountList[0].WorkPhoneCountryCode__pc = '5646';
		accountList[0].PersonOtherPhone 		= '2345463223';
		accountList[0].BirthdateDay__pc   		= '1';
		accountList[0].BirthDateMonth__pc 		= '2';
		accountList[0].BirthDateYear__pc 		= '2006';
		accountList[0].PersonDoNotCall 			= True;
		accountList[0].DoNotSMS__pc 			= True;
		accountList[0].DoNotContactbyPost__pc 	= True;
		accountList[0].PersonHasOptedOutOfEmail = True;
		accountList[0].PersonEmail  			= 'test@mail.com';
		//AEF: removed for Ticket 0677
		//accountList[0].SPO_VATNumber__pc 		= '5678'; 
		//accountList[0].SPO_TaxID__pc 			= 'test';
		update accountList[0];

		List<Opportunity> oppList = [Select Id, Name, SPO_StoreCode__c, SPO_RMSClientId__c FROM Opportunity];
		oppList[0].SPO_RMSClientId__c = 'testId';
		update oppList[0];
		
		//using SO_CreateUpdateRMSCLient_Utils_MOCK to create request
		Test.setMock(WebServiceMock.class, new SO_CreateUpdateRMSCLient_Utils_MOCK('000'));

		Test.startTest();

		try{
			SO_Session.startSession(oppList[0]);
			SO_CreateUpdateRMSCLient_Utils.SO_CreateUpdateRmsClientResult calloutResult = SO_CreateUpdateRMSCLient_Utils.CreateUpdateSFDCAccountIntoRMS(accountList[0], 'testId');

			System.assert(calloutResult != Null);
		}
		catch(Exception exp) {
			system.debug(exp);
			// system.assert(exp instanceof SO_UTIL.RMSException); 
		}

		Test.stopTest();
	}

	/**
	* [CreateUpdateSFDCAccount2 create account in RSM, the callout fails]
	* @scenario    		[try to call the webservice, it fails and return an error]
	* @result           [error calling webservice]
	* @createdBy        Nadav Lichtenshtein, 23-12-2015
	* @lastModifiedBy 	Nadav Lichtenshtein, 23-12-2015
	*/
	@isTest static void CreateUpdateSFDCAccount2() 
	{	
		List<Account> accountList = [Select Id, FirstName, Lastname, FirstName2__pc, Lastname2__pc, PreferredLanguage__pc, PassportNumber__pc,
										Company__pc, PrimaryAddressLine1__pc, PrimaryAddressLine2__pc, PrimaryAddressLine3__pc, PrimaryZipCode__pc,
										PrimaryCity__pc, PrimaryStateProvince__pc, HomePhoneCountryCode__pc, PersonMobilePhone, WorkPhoneCountryCode__pc,
										PersonOtherPhone, BirthdateDay__pc, BirthDateMonth__pc, BirthDateYear__pc, PersonDoNotCall, DoNotSMS__pc,
										DoNotContactbyPost__pc, PersonHasOptedOutOfEmail, PersonEmail
										//, SPO_TaxID__pc , SPO_VATNumber__pc AEF: removed for Ticket 0677
										FROM Account];
		accountList[0].FirstName2__pc 			= 'testFName2';
		accountList[0].Lastname2__pc 			= 'testLName2';
		accountList[0].PreferredLanguage__pc 	= 'AAR';
		accountList[0].PassportNumber__pc 		= '12345';
		accountList[0].Company__pc				= 'comp';
		accountList[0].PrimaryAddressLine1__pc 	= 'address1';
		accountList[0].PrimaryAddressLine2__pc 	= 'address2';
		accountList[0].PrimaryAddressLine3__pc  = 'address3';
		accountList[0].PrimaryZipCode__pc 		= '123';
		accountList[0].PrimaryCity__pc 			= 'Chu';
		accountList[0].PrimaryStateProvince__pc = 'Chong';
		accountList[0].HomePhoneCountryCode__pc = '08';
		accountList[0].PersonMobilePhone 		= '0343456665';
		accountList[0].WorkPhoneCountryCode__pc = '5646';
		accountList[0].PersonOtherPhone 		= '2345463223';
		accountList[0].BirthdateDay__pc   		= '1';
		accountList[0].BirthDateMonth__pc 		= '2';
		accountList[0].BirthDateYear__pc 		= '2006';
		accountList[0].PersonDoNotCall 			= True;
		accountList[0].DoNotSMS__pc 			= True;
		accountList[0].DoNotContactbyPost__pc 	= True;
		accountList[0].PersonHasOptedOutOfEmail = True;
		accountList[0].PersonEmail  			= 'test@mail.com';
		//AEF: removed for Ticket 0677
		//accountList[0].SPO_VATNumber__pc 		= '5678'; 
		//accountList[0].SPO_TaxID__pc 			= 'test';
		update accountList[0];

		List<Opportunity> oppList = [Select Id, Name, SPO_StoreCode__c, SPO_RMSClientId__c FROM Opportunity];
		oppList[0].SPO_RMSClientId__c = 'testId';
		update oppList[0];
		
		//using SO_CreateUpdateRMSCLient_Utils_MOCK to create request
		Test.setMock(WebServiceMock.class, new SO_CreateUpdateRMSCLient_Utils_MOCK('001'));

		Test.startTest();

		try{
			SO_Session.startSession(oppList[0]);
			SO_CreateUpdateRMSCLient_Utils.SO_CreateUpdateRmsClientResult calloutResult = SO_CreateUpdateRMSCLient_Utils.CreateUpdateSFDCAccountIntoRMS(accountList[0], 'testId');
		
			System.assert(calloutResult != Null);
		}
		catch(Exception exp) {
			system.debug(exp);
			// system.assert(exp instanceof SO_UTIL.RMSException); 
		}
		
		Test.stopTest();
	}

	/**
	* [GetAccount get the Account by it's Id]
	* @scenario    		[Query for the account by it's Id]
	* @result           [account]
	* @createdBy        Nadav Lichtenshtein, 23-12-2015
	* @lastModifiedBy 	Nadav Lichtenshtein, 23-12-2015
	*/	
	@isTest static void GetAccount() 
	{	
		List<Opportunity> oppList = [Select Id, Name, SPO_StoreCode__c, SPO_RMSClientId__c FROM Opportunity];
		oppList[0].SPO_RMSClientId__c = 'testId';
		update oppList[0];

		List<Account> accountList = [Select Id, FirstName, FirstName2__pc, Lastname2__pc, PreferredLanguage__pc, PassportNumber__pc,
										Company__pc, PrimaryAddressLine1__pc, PrimaryAddressLine2__pc, PrimaryAddressLine3__pc, PrimaryZipCode__pc,
										PrimaryCity__pc, PrimaryStateProvince__pc, HomePhoneCountryCode__pc, PersonMobilePhone, WorkPhoneCountryCode__pc,
										PersonOtherPhone, BirthdateDay__pc, BirthDateMonth__pc, BirthDateYear__pc, PersonDoNotCall, DoNotSMS__pc,
										DoNotContactbyPost__pc, PersonHasOptedOutOfEmail, PersonEmail
										//, SPO_TaxID__pc , SPO_VATNumber__pc AEF: removed for Ticket 0677
										FROM Account];

		Test.startTest();

		try{
			SO_Session.startSession(oppList[0]);
			Account testAccount = SO_CreateUpdateRMSCLient_Utils.queryRelatedAccount(accountList[0].id);

			System.assert(testAccount != Null);
		}
		catch(Exception exp) {
			system.debug(exp);
			// system.assert(exp instanceof SO_UTIL.RMSException); 
		}

		Test.stopTest();
	}	

	/**
	* [MapRmsClientIntoSfdcClient get the account from RMS and return it as account]
	* @scenario    		[call CreateUpdateSFDCAccountIntoRMS, use webservice to insert account in other program RMS]
	* @result           [account returned from RMS]
	* @createdBy        Nadav Lichtenshtein, 14-1-2016
	* @lastModifiedBy 	Nadav Lichtenshtein, 14-1-2016
	// */
	// @isTest static void MapRmsClientIntoSfdcClient() 
	// {	
		
		
	// 	List<Account> accountList = [Select Id, FirstName, Lastname, FirstName2__pc, Lastname2__pc, PreferredLanguage__pc, PassportNumber__pc,
	// 									Company__pc, PrimaryAddressLine1__pc, PrimaryAddressLine2__pc, PrimaryAddressLine3__pc, PrimaryZipCode__pc,
	// 									PrimaryCity__pc, PrimaryStateProvince__pc, HomePhoneCountryCode__pc, PersonMobilePhone, WorkPhoneCountryCode__pc,
	// 									PersonOtherPhone, BirthdateDay__pc, BirthDateMonth__pc, BirthDateYear__pc, PersonDoNotCall, DoNotSMS__pc,
	// 									DoNotContactbyPost__pc, PersonHasOptedOutOfEmail, PersonEmail
	// 									//, SPO_TaxID__pc , SPO_VATNumber__pc AEF: removed for Ticket 0677
	// 									FROM Account];
	// 	accountList[0].FirstName2__pc 			= 'testFName2';
	// 	accountList[0].Lastname2__pc 			= 'testLName2';
	// 	accountList[0].PreferredLanguage__pc 	= 'AAR';
	// 	accountList[0].PassportNumber__pc 		= '12345';
	// 	accountList[0].Company__pc				= 'comp';
	// 	accountList[0].PrimaryAddressLine1__pc 	= 'address1';
	// 	accountList[0].PrimaryAddressLine2__pc 	= 'address2';
	// 	accountList[0].PrimaryAddressLine3__pc  = 'address3';
	// 	accountList[0].PrimaryZipCode__pc 		= '123';
	// 	accountList[0].PrimaryCity__pc 			= 'Chu';
	// 	accountList[0].PrimaryStateProvince__pc = 'Chong';
	// 	accountList[0].HomePhoneCountryCode__pc = '08';
	// 	accountList[0].PersonMobilePhone 		= '0343456665';
	// 	accountList[0].WorkPhoneCountryCode__pc = '5646';
	// 	accountList[0].PersonOtherPhone 		= '2345463223';
	// 	accountList[0].BirthdateDay__pc   		= '1';
	// 	accountList[0].BirthDateMonth__pc 		= '2';
	// 	accountList[0].BirthDateYear__pc 		= '2006';
	// 	accountList[0].PersonDoNotCall 			= True;
	// 	accountList[0].DoNotSMS__pc 			= True;
	// 	accountList[0].DoNotContactbyPost__pc 	= True;
	// 	accountList[0].PersonHasOptedOutOfEmail = True;
	// 	accountList[0].PersonEmail  			= 'test@mail.com';

	// 	//AEF: removed for Ticket 0677
	// 	//accountList[0].SPO_VATNumber__pc 		= '5678'; 
	// 	//accountList[0].SPO_TaxID__pc 			= 'test';
		
	// 	update accountList[0];

	// 	List<Opportunity> oppList = [Select Id, Name, SPO_StoreCode__c, SPO_RMSClientId__c FROM Opportunity];
	// 	oppList[0].SPO_RMSClientId__c = 'testId';
	// 	update oppList[0];
		
	// 	Test.startTest();

	// 	try{
	// 		SO_WS_RMS_DoClientEnquiry ws = new SO_WS_RMS_DoClientEnquiry();
	//         SO_WS_RMS_DoClientEnquiry.DataInput dataIn = new SO_WS_RMS_DoClientEnquiry.DataInput();
	//         SO_WS_RMS_DoClientEnquiry.Result result = new SO_WS_RMS_DoClientEnquiry.Result();

	// 		SO_Session.startSession(oppList[0]);
	// 		Account testAccount = SO_CreateUpdateRMSCLient_Utils.MapRmsClientIntoSfdcClient(result,accountList[0]);
	// 	}
	// 	catch(Exception exp) {
	// 		system.debug(exp);
	// 		// system.assert(exp instanceof SO_UTIL.RMSException); 
	// 	}

	// 	Test.stopTest();
	// }

	/**
	* [mapClonedClientToLocalClient clone the account]
	* @scenario    		[get two accounts, and copy one data into the other]
	* @result           account been copied]
	* @createdBy        Nadav Lichtenshtein, 14-1-2016
	* @lastModifiedBy 	Nadav Lichtenshtein, 14-1-2016
	*/
	@isTest static void mapClonedClientToLocalClient() 
	{	
		List<Account> accountList = [Select Id, FirstName, Lastname, FirstName2__pc, Lastname2__pc, PreferredLanguage__pc, PassportNumber__pc,
										Company__pc, PrimaryAddressLine1__pc, PrimaryAddressLine2__pc, PrimaryAddressLine3__pc, PrimaryZipCode__pc,
										PrimaryCity__pc, PrimaryStateProvince__pc, HomePhoneCountryCode__pc, PersonMobilePhone, WorkPhoneCountryCode__pc,
										PersonOtherPhone, BirthdateDay__pc, BirthDateMonth__pc, BirthDateYear__pc, PersonDoNotCall, DoNotSMS__pc,
										DoNotContactbyPost__pc, PersonHasOptedOutOfEmail, PersonEmail
										//, SPO_TaxID__pc, SPO_VATNumber__pc AEF: removed for Ticket 0677 
										FROM Account];
		accountList[0].FirstName2__pc 			= 'testFName2';
		accountList[0].Lastname2__pc 			= 'testLName2';
		accountList[0].PreferredLanguage__pc 	= 'AAR';
		accountList[0].PassportNumber__pc 		= '12345';
		accountList[0].Company__pc				= 'comp';
		accountList[0].PrimaryAddressLine1__pc 	= 'address1';
		accountList[0].PrimaryAddressLine2__pc 	= 'address2';
		accountList[0].PrimaryAddressLine3__pc  = 'address3';
		accountList[0].PrimaryZipCode__pc 		= '123';
		accountList[0].PrimaryCity__pc 			= 'Chu';
		accountList[0].PrimaryStateProvince__pc = 'Chong';
		accountList[0].HomePhoneCountryCode__pc = '08';
		accountList[0].PersonMobilePhone 		= '0343456665';
		accountList[0].WorkPhoneCountryCode__pc = '5646';
		accountList[0].PersonOtherPhone 		= '2345463223';
		accountList[0].BirthdateDay__pc   		= '1';
		accountList[0].BirthDateMonth__pc 		= '2';
		accountList[0].BirthDateYear__pc 		= '2006';
		accountList[0].PersonDoNotCall 			= True;
		accountList[0].DoNotSMS__pc 			= True;
		accountList[0].DoNotContactbyPost__pc 	= True;
		accountList[0].PersonHasOptedOutOfEmail = True;
		accountList[0].PersonEmail  			= 'test@mail.com';

		//AEF: removed for Ticket 0677 
		//accountList[0].SPO_VATNumber__pc 		= '5678'; 
		//accountList[0].SPO_TaxID__pc 			= 'test';

		update accountList[0];

		List<Opportunity> oppList = [Select Id, Name, SPO_StoreCode__c, SPO_RMSClientId__c FROM Opportunity];
		oppList[0].SPO_RMSClientId__c = 'testId';
		update oppList[0];
		
		Test.startTest();
		
		try{
			Account resultAccount = new Account();

			SO_Session.startSession(oppList[0]);
			SO_CreateUpdateRMSCLient_Utils.mapClonedClientToLocalClient(resultAccount,accountList[0]);

			System.assertEquals('testFName2', resultAccount.FirstName2__pc);
		}
		catch(Exception exp){
			system.debug(exp);
			// system.assert(exp instanceof SO_UTIL.RMSException); 
		}

		Test.stopTest();
	}
    
	@isTest static void mapClonedClientToLocalClient2() 
	{	
		List<Account> accountList = [Select Id, FirstName, Lastname, FirstName2__pc, Lastname2__pc, PreferredLanguage__pc, PassportNumber__pc,
										Company__pc, PrimaryAddressLine1__pc, PrimaryAddressLine2__pc, PrimaryAddressLine3__pc, PrimaryZipCode__pc,
										PrimaryCity__pc, PrimaryStateProvince__pc, HomePhoneCountryCode__pc, PersonMobilePhone, WorkPhoneCountryCode__pc,
										PersonOtherPhone, BirthdateDay__pc, BirthDateMonth__pc, BirthDateYear__pc, PersonDoNotCall, DoNotSMS__pc,
										DoNotContactbyPost__pc, PersonHasOptedOutOfEmail, PersonEmail
										//, SPO_TaxID__pc, SPO_VATNumber__pc AEF: removed for Ticket 0677 
										FROM Account];
		accountList[0].FirstName2__pc 			= 'testFName2';
		accountList[0].Lastname2__pc 			= 'testLName2';
		accountList[0].PreferredLanguage__pc 	= 'AAR';
		accountList[0].PassportNumber__pc 		= '12345';
		accountList[0].Company__pc				= 'comp';
		accountList[0].PrimaryAddressLine1__pc 	= 'address1';
		accountList[0].PrimaryAddressLine2__pc 	= 'address2';
		accountList[0].PrimaryAddressLine3__pc  = 'address3';
		accountList[0].PrimaryZipCode__pc 		= '123';
		accountList[0].PrimaryCity__pc 			= 'Chu';
		accountList[0].PrimaryStateProvince__pc = 'Chong';
		accountList[0].HomePhoneCountryCode__pc = '08';
		accountList[0].PersonMobilePhone 		= '0343456665';
		accountList[0].WorkPhoneCountryCode__pc = '5646';
		accountList[0].PersonOtherPhone 		= '2345463223';
		accountList[0].BirthdateDay__pc   		= '1';
		accountList[0].BirthDateMonth__pc 		= '2';
		accountList[0].BirthDateYear__pc 		= '2006';
		accountList[0].PersonDoNotCall 			= True;
		accountList[0].DoNotSMS__pc 			= True;
		accountList[0].DoNotContactbyPost__pc 	= True;
		accountList[0].PersonHasOptedOutOfEmail = True;
		accountList[0].PersonEmail  			= 'test@mail.com';
		update accountList[0];

		List<Opportunity> oppList = [Select Id, Name, SPO_StoreCode__c, SPO_RMSClientId__c FROM Opportunity];
		oppList[0].SPO_RMSClientId__c = 'testId';
		update oppList[0];
		
		Test.startTest();

		try{
			Account resultAccount = SO_CreateUpdateRMSCLient_Utils.syncClient('A06', '56f65ew4fwe', accountList[0], '56f65ew4fwe');

			SO_Session.startSession(oppList[0]);
			SO_CreateUpdateRMSCLient_Utils.createAccountIntoRMS_WS_v5(accountList[0].Id);
		}
		catch(Exception exp){
			system.debug(exp);
		}

		Test.stopTest();
	}
    
	@isTest static void mapClonedClientToLocalClient3() 
	{	
		List<Account> accountList = [Select Id, FirstName, Lastname, FirstName2__pc, Lastname2__pc, PreferredLanguage__pc, PassportNumber__pc,
										Company__pc, PrimaryAddressLine1__pc, PrimaryAddressLine2__pc, PrimaryAddressLine3__pc, PrimaryZipCode__pc,
										PrimaryCity__pc, PrimaryStateProvince__pc, HomePhoneCountryCode__pc, PersonMobilePhone, WorkPhoneCountryCode__pc,
										PersonOtherPhone, BirthdateDay__pc, BirthDateMonth__pc, BirthDateYear__pc, PersonDoNotCall, DoNotSMS__pc,
										DoNotContactbyPost__pc, PersonHasOptedOutOfEmail, PersonEmail
										FROM Account];
		accountList[0].FirstName2__pc 			= 'testFName2';
		accountList[0].Lastname2__pc 			= 'testLName2';
		accountList[0].PreferredLanguage__pc 	= 'AAR';
		accountList[0].PassportNumber__pc 		= '12345';
		accountList[0].Company__pc				= 'comp';
		accountList[0].PrimaryAddressLine1__pc 	= 'address1';
		accountList[0].PrimaryAddressLine2__pc 	= 'address2';
		accountList[0].PrimaryAddressLine3__pc  = 'address3';
		accountList[0].PrimaryZipCode__pc 		= '123';
		accountList[0].PrimaryCity__pc 			= 'Chu';
		accountList[0].PrimaryStateProvince__pc = 'Chong';
		accountList[0].HomePhoneCountryCode__pc = '08';
		accountList[0].PersonMobilePhone 		= '0343456665';
		accountList[0].WorkPhoneCountryCode__pc = '5646';
		accountList[0].PersonOtherPhone 		= '2345463223';
		accountList[0].BirthdateDay__pc   		= '1';
		accountList[0].BirthDateMonth__pc 		= '2';
		accountList[0].BirthDateYear__pc 		= '2006';
		accountList[0].PersonDoNotCall 			= True;
		accountList[0].DoNotSMS__pc 			= True;
		accountList[0].DoNotContactbyPost__pc 	= True;
		accountList[0].PersonHasOptedOutOfEmail = True;
		accountList[0].PersonEmail  			= 'test@mail.com';
		update accountList[0];

		List<Opportunity> oppList = [Select Id, Name, SPO_StoreCode__c, SPO_RMSClientId__c FROM Opportunity];
		oppList[0].SPO_RMSClientId__c = 'testId';
		update oppList[0];
		
		Test.startTest();

		try{
			Account resultAccount = SO_CreateUpdateRMSCLient_Utils.syncClient('A06', '56f65ew4fwe', accountList[0], '56f65ew4fwe');
		}
		catch(Exception exp){
			system.debug(exp);
		}

		Test.stopTest();
	}
    
 }