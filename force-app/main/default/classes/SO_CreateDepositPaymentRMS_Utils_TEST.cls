/**
 * This is a test class for SO_CreateDepositPaymentRMS_Utils webservice class
 * @createdBy           Israel, 22-12-2015
 * @lastModifiedBy      Nadav Lichtenshtein, 22-12-2015
 */
@isTest
private class SO_CreateDepositPaymentRMS_Utils_TEST 
{

// 	/**
// 	* [Set database]
// 	* @scenario    		[insert objects to the system]
// 	* @result           [database to work with]
// 	* @createdBy        Nadav Lichtenshtein, 22-12-2015
//     * @lastModifiedBy 	Nadav Lichtenshtein, 22-12-2015
// 	*/
// 	@testSetup static void Setup()
// 	{
// 		SO_TestObjectCreator testObjectCreation = new SO_TestObjectCreator();
// 		testObjectCreation.initialization_one(true, false);
// 	}
	
// 	/**
// 	* [CreatePayment create payment]
// 	* @scenario    		[call CreatePaymentIntoRMS, use webservice to create payment]
// 	* @result           [payment successfuly made]
// 	* @createdBy        Israel, 22-12-2015
// 	* @lastModifiedBy 	Nadav Lichtenshtein, 22-12-2015
// 	*/

// //	@isTest static void CreatePayment()    // MIY-2154
// 	// {
// 	// 	//using SO_CreateDepositPaymentRMS_Utils_MOCK to create request
// 	// 	Test.setMock(WebServiceMock.class, new SO_CreateDepositPaymentRMS_Utils_MOCK('000'));
		
// 	// 	List<Opportunity> oppList = [Select Id, Name, StageName, CloseDate FROM Opportunity];
// 	// 	oppList[0].StageName = 'Creation in progress';
// 	// 	oppList[0].SPO_Date_Creation_in_progress__c = System.today();
// 	// 	oppList[0].CloseDate = (Date.today()).addDays(1);
// 	// 	update oppList[0];

// 	// 	Test.startTest();

// 	// 	try{
// 	// 		SO_Session.startSession(oppList[0]);
// 	// 		SO_CreateDepositPaymentRMS_Utils.CreateDepositOrPaymentIntoRMS(true);
// 	// 		SO_CreateDepositPaymentRMS_Utils.CreateDepositOrPaymentIntoRMS(false);
// 	// 	}
// 	// 	catch(Exception exp) {
// 	// 		system.assert(exp instanceof SO_UTIL.RMSException); 
// 	// 	}
		

// 	// 	Test.stopTest();
// 	// }

// 	/**
// 	* [CreateDepositCalloutSuccess create deposit]
// 	* @scenario    		[call CreateDepositCalloutSuccess, use webservice to create deposite]
// 	* @result           [deposite successfuly made]
// 	* @createdBy        Israel, 22-12-2015
// 	* @lastModifiedBy   Nadav Lichtenshtein, 22-12-2015
// 	*/
// 	@isTest static void CreateDepositCalloutSuccess() 
// 	{
// 		List<Opportunity> oppList = [Select Id, Name, StageName, CloseDate FROM Opportunity];
// 		oppList[0].StageName = 'Creation in progress';
// 		oppList[0].SPO_Date_Creation_in_progress__c = System.today();
// 		oppList[0].CloseDate = (Date.today()).addDays(1);
// 		update oppList[0];

// 		Test.startTest();

// 		//using SO_CreateDepositPaymentRMS_Utils_MOCK to create request
// 		Test.setMock(WebServiceMock.class, new SO_CreateDepositPaymentRMS_Utils_MOCK('000'));

// 		try{
// 			SO_Session.startSession(oppList[0]);
// 			SO_CreateDepositPaymentRMS_Utils.CreateDepositOrPaymentIntoRMS(true);
// 		}
// 		catch(Exception exp) {
// 			system.assert(exp instanceof SO_UTIL.RMSException); 
// 		}

// 		Test.stopTest();
// 	}

// 	/**
// 	* [CreateDepositCoverlaunchCreateDepositWSIf create deposit]
// 	* @scenario    		[call CreateDepositCalloutSuccess, use webservice to create deposite, get the correct values to cover the if statement]
// 	* @result           [opportunites been updated]
// 	* @createdBy        Nadav Lichtenshtein, 22-12-2015
// 	* @lastModifiedBy   Nadav Lichtenshtein, 22-12-2015
// 	*/
// 	@isTest static void CreateDepositCoverlaunchCreateDepositWSIf() 
// 	{
// 		List<Opportunity> oppList = [Select Id, Name, StageName, CloseDate, SPO_DisplayOrder__c, SPO_Free__c, SPO_DepositAmount__c, SPO_RMSClientId__c, SPO_caCode__c FROM Opportunity];
// 		oppList[0].SPO_DisplayOrder__c 	= false;
// 		oppList[0].SPO_Free__c 			= false;
// 		oppList[0].SPO_DepositAmount__c = 15;
// 		oppList[0].StageName 			= 'Creation in progress';
// 		oppList[0].SPO_Date_Creation_in_progress__c = System.today();
// 		oppList[0].CloseDate 			= (Date.today()).addDays(1);

// 		oppList[0].SPO_RMSClientId__c 	= 'testId';
// 		oppList[0].SPO_caCode__c 		= '2';
// 		update oppList[0];

// 		Test.startTest();

// 		//using SO_CreateDepositPaymentRMS_Utils_MOCK to create request
// 		Test.setMock(WebServiceMock.class, new SO_CreateDepositPaymentRMS_Utils_MOCK('000'));

// 		try{
// 			SO_Session.startSession(oppList[0]);
// 			SO_CreateDepositPaymentRMS_Utils.CreateDepositOrPaymentIntoRMS(true);
// 		}
// 		catch(Exception exp) {
// 			system.assert(exp instanceof SO_UTIL.RMSException); 
// 		}

// 		Test.stopTest();
// 	}

// 	/**
// 	* [CreateDepositCalloutFail create deposit and fail in callout]
// 	* @scenario    		[call the webservice and fail]
// 	* @result           [callout return error message]
// 	* @createdBy        Israel, 22-12-2015
// 	* @lastModifiedBy   Nadav Lichtenshtein, 22-12-2015
// 	*/
// 	@isTest static void CreateDepositCalloutFail() 
// 	{
// 		List<Opportunity> oppList = [Select Id, Name, StageName, CloseDate FROM Opportunity];
// 		oppList[0].StageName = 'Creation in progress';
// 		oppList[0].SPO_Date_Creation_in_progress__c = System.today();
// 		oppList[0].CloseDate = (Date.today()).addDays(1);
// 		update oppList[0];

// 		Test.startTest();

// 		//using SO_CreateDepositPaymentRMS_Utils_MOCK to create request
// 		Test.setMock(WebServiceMock.class, new SO_CreateDepositPaymentRMS_Utils_MOCK('010'));

// 		try{
// 			SO_Session.startSession(oppList[0]);
// 			SO_CreateDepositPaymentRMS_Utils.CreateDepositOrPaymentIntoRMS(true);
// 		}
// 		catch(Exception exp) {
// 			system.assert(exp instanceof SO_UTIL.RMSException); 
// 		}

// 		Test.stopTest();
// 	}
}