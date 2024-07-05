/**
 * This is a test class for SO_ClientAdvisorEnquiryRMS_Utils webservice class
 * @createdBy           Nadav Lichtenshtein	3/1/2016
 * @lastModifiedBy      Nadav Lichtenshtein	3/1/2016
 */
@isTest
private class SO_ClientAdvisorEnquiryRMS_Utils_TEST 
{
	/**
	* [Set database]
	* @scenario    		[insert objects to the system]
	* @result           [database to work with]
	* @createdBy        Nadav Lichtenshtein	3/1/2016
    * @lastModifiedBy 	Nadav Lichtenshtein	3/1/2016
	*/
	@testSetup static void Setup()
	{
		SO_TestObjectCreator testObjectCreation = new SO_TestObjectCreator();
		testObjectCreation.initialization_one(true, false);
	}

	/**
	* [TestCACode validate the CA Code success results]
	* @scenario    		[call CreateDepositOrPaymentIntoRMS, use webservice to validate the CA Code]
	* @result           [Webservice validate CA Code]
	* @createdBy        Nadav Lichtenshtein	3/1/2016
	* @lastModifiedBy 	Nadav Lichtenshtein	3/1/2016
	*/
	@isTest static void TestCACode() 
	{
		//using SO_ClientAdvisorEnquiryRMS_Utils_MOCK to create request
		Test.setMock(WebServiceMock.class, new SO_ClientAdvisorEnquiryRMS_Utils_MOCK('000'));

		List<Opportunity> oppList = [Select Id, Name, SPO_StoreCode__c, SPO_caCode__c FROM Opportunity];
		oppList[0].SPO_caCode__c = 'WEB';
		update oppList[0];

		Test.startTest();

		SO_Session.startSession(oppList[0]);
		
		try{
			SO_ClientAdvisorEnquiryRMS_Utils.VerifyClientAdvisorEnquiryRMS('WEB','A90');
		}
		catch(Exception exp) {
			system.assert(exp instanceof SO_UTIL.RMSException); 
		}

		Test.stopTest();
	}
	
	/**
	* [TestCACode2 validate the CA Code fail results]
	* @scenario    		[call CreateDepositOrPaymentIntoRMS, use webservice to validate the CA Code]
	* @result           [Webservice validate CA Code]
	* @createdBy        Nadav Lichtenshtein	3/1/2016
	* @lastModifiedBy 	Nadav Lichtenshtein	3/1/2016
	*/
	@isTest static void TestCACode2() 
	{
		//using SO_ClientAdvisorEnquiryRMS_Utils_MOCK to create request
		Test.setMock(WebServiceMock.class, new SO_ClientAdvisorEnquiryRMS_Utils_MOCK('0012'));

		List<Opportunity> oppList = [Select Id, Name, SPO_StoreCode__c, SPO_caCode__c FROM Opportunity];
		oppList[0].SPO_caCode__c = 'WEB';
		update oppList[0];

		Test.startTest();

		SO_Session.startSession(oppList[0]);
		
		try{
			SO_ClientAdvisorEnquiryRMS_Utils.VerifyClientAdvisorEnquiryRMS('WEB','A90');
		}
		catch(Exception exp) {
			system.assert(exp instanceof SO_UTIL.RMSException); 
		}

		Test.stopTest();
	}

	/**
	* [TestCACode2 validate the CA Code fail results]
	* @scenario    		[call CreateDepositOrPaymentIntoRMS, use webservice to validate the CA Code]
	* @result           [Webservice validate CA Code]
	* @createdBy        Nadav Lichtenshtein	3/1/2016
	* @lastModifiedBy 	Nadav Lichtenshtein	3/1/2016
	*/
	@isTest static void TestCACode3() 
	{
		//using SO_ClientAdvisorEnquiryRMS_Utils_MOCK to create request
		Test.setMock(WebServiceMock.class, new SO_ClientAdvisorEnquiryRMS_Utils_MOCK('Error'));

		List<Opportunity> oppList = [Select Id, Name, SPO_StoreCode__c, SPO_caCode__c FROM Opportunity];
		oppList[0].SPO_caCode__c = 'WEB';
		update oppList[0];

		Test.startTest();

		SO_Session.startSession(oppList[0]);
		
		try{
			SO_ClientAdvisorEnquiryRMS_Utils.VerifyClientAdvisorEnquiryRMS('WEB','A90');
		}
		catch(Exception exp) {
			system.assert(exp instanceof SO_UTIL.RMSException); 
		}

		Test.stopTest();
	}
}