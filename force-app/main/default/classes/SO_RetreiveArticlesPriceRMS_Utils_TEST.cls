/**
 * This is a test class for SO_RetreiveArticlesPriceRMS_Utils webservice class
 * @createdBy           Nadav Lichtenshtein	11/1/2016
 * @lastModifiedBy      Nadav Lichtenshtein	11/1/2016
 */
@isTest
private class SO_RetreiveArticlesPriceRMS_Utils_TEST 
{
	/**
	* [Set database]
	* @scenario    		[insert objects to the system]
	* @result           [database to work with]
	* @createdBy        Nadav Lichtenshtein	11/1/2016
    * @lastModifiedBy 	Nadav Lichtenshtein	11/1/2016
	*/
	@testSetup static void Setup()
	{
		SO_TestObjectCreator testObjectCreation = new SO_TestObjectCreator();
		testObjectCreation.initialization_one(true, true);
	}
	
	/**
	* [Success flow]
	* @scenario    		[Call SO_WS_RMS_DoStoreGetId to get number of decimals in the price of the product, 
	*                	 call SO_WS_RMS_DoProductSearch to get product price
	*                	  calculate final price]
	* @result           [product final price]
	* @createdBy        Nadav Lichtenshtein	11/1/2016
	* @lastModifiedBy 	Nadav Lichtenshtein	11/1/2016
	*/
	@isTest static void calculatePrice() 
	{
		//using StoreGetIdFromRMS_MOCK to create request
		Test.setMock(WebServiceMock.class, new SO_RetreiveArticlesPriceRMS_Utils_MOCK('000', '2'));

		List<Opportunity> oppList = [Select Id, Name, SPO_StoreCode__c, SPO_BaseSku__c FROM Opportunity];

		Test.startTest();
		
		try{
			SO_RetreiveArticlesPriceRMS_Utils.RetrieveArticlePriceFromRMS(oppList[0].SPO_StoreCode__c, oppList[0].SPO_BaseSku__c);
		}
		catch(Exception exp) {
			system.assert(exp instanceof SO_UTIL.RMSException); 
		}

		Test.stopTest();
	}
	
	/**
	* [StoreGetIdFromRMS webservice fail]
	* @scenario    		[Call SO_WS_RMS_DoStoreGetId with fail data]
	* @result           [error message]
	* @createdBy        Nadav Lichtenshtein	11/1/2016
	* @lastModifiedBy 	Nadav Lichtenshtein	11/1/2016
	*/
	@isTest static void StoreGetIdFromRMS() 
	{
		//using StoreGetIdFromRMS_MOCK to create request
		Test.setMock(WebServiceMock.class, new SO_RetreiveArticlesPriceRMS_Utils_MOCK('001', '2'));

		List<Opportunity> oppList = [Select Id, Name, SPO_StoreCode__c, SPO_BaseSku__c FROM Opportunity];

		System.debug('oppList : ' + oppList);

		Test.startTest();
		
		try{
			SO_RetreiveArticlesPriceRMS_Utils.StoreGetIdFromRMS(oppList[0].SPO_StoreCode__c);
		}
		catch(Exception exp) {
			system.assert(exp instanceof SO_UTIL.RMSException); 
		}

		Test.setMock(WebServiceMock.class, new SO_RetreiveArticlesPriceRMS_Utils_MOCK('000', ''));

		try{
			SO_RetreiveArticlesPriceRMS_Utils.StoreGetIdFromRMS(oppList[0].SPO_StoreCode__c);
		}
		catch(Exception exp) {
			System.assertEquals(exp.getMessage(), 'RMS Empty result');
		}

		Test.stopTest();
	}

	/**
	* [ProductSearchIntoRMS webservice fail]
	* @scenario    		[Call SO_WS_RMS_DoProductSearch with fail data]
	* @result           [error message]
	* @createdBy        Nadav Lichtenshtein	11/1/2016
	* @lastModifiedBy 	Nadav Lichtenshtein	11/1/2016
	*/
	
	@isTest static void ProductSearchIntoRMS() 
	{
		//using ProductSearchIntoRMS_MOCK to create request
		Test.setMock(WebServiceMock.class, new SO_RetreiveArticlesPriceRMS_Utils_MOCK('001', '2'));

		List<Opportunity> oppList = [Select Id, Name, SPO_StoreCode__c, SPO_BaseSku__c FROM Opportunity];

		Test.startTest();
		
		try{
			SO_RetreiveArticlesPriceRMS_Utils.ProductSearchIntoRMS(oppList[0].SPO_StoreCode__c, oppList[0].SPO_BaseSku__c);
		}
		catch(Exception exp) {
			system.assert(exp instanceof SO_UTIL.RMSException); 
		}

		Test.setMock(WebServiceMock.class, new SO_RetreiveArticlesPriceRMS_Utils_MOCK('000', ''));

		try{
			SO_RetreiveArticlesPriceRMS_Utils.ProductSearchIntoRMS(oppList[0].SPO_StoreCode__c, oppList[0].SPO_BaseSku__c);
		}
		catch(Exception exp) {
			System.assertEquals(exp.getMessage(), 'RMS Empty result');
		}

		Test.stopTest();
	}
}