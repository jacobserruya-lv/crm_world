/**
 * This is a test class for SO_CustomLookup_Con 
 * @createdBy           Nadav Lichtenshtein, 28-12-2015
 * @lastModifiedBy      Nadav Lichtenshtein, 28-12-2015
 */
@isTest
private class SO_CustomLookup_Con_TEST 
{
	/**
	* [Set database]
	* @scenario    		[insert objects to the system]
	* @result           [database to work with]
	* @createdBy        Nadav Lichtenshtein, 28-12-2015
    * @lastModifiedBy 	Nadav Lichtenshtein, 28-12-2015
	*/
	@testSetup static void Setup()
	{
		SO_TestObjectCreator testObjectCreation = new SO_TestObjectCreator();
		testObjectCreation.initialization_one(true, true);
	}
	
	/**
	* [setCacheField]
	* @scenario    		[call setCacheField]
	* @result           [setCacheField covered]
	* @createdBy        Nadav Lichtenshtein, 28-12-2015
	* @lastModifiedBy 	Nadav Lichtenshtein, 28-12-2015
	*/
	@isTest static void SetCacheField() 
	{	
		Test.startTest();
		
		SO_CustomLookup_Con testObject = new SO_CustomLookup_Con();
		testObject.setCacheField('test');

		Test.stopTest();
	}

	/**
	* [setTargetFieldVar]
	* @scenario    		[call setTargetFieldVar]
	* @result           [setTargetFieldVar covered]
	* @createdBy        Nadav Lichtenshtein, 28-12-2015
	* @lastModifiedBy 	Nadav Lichtenshtein, 28-12-2015
	*/
	@isTest static void SetTargetFieldVar() 
	{
		ProductReferential__c productReferance = new ProductReferential__c();
		productReferance.Name 		= 'testPR'; 
		productReferance.SKUCode__c = '12345';
		insert productReferance;

		Test.startTest();
		
		SO_CustomLookup_Con testObject = new SO_CustomLookup_Con();
		testObject.sObjVal = 'ProductReferential__c';
		testObject.setTargetFieldVar('test');

		Test.stopTest();
	}

	/**
	* [GetTargetFieldVar]
	* @scenario    		[call GetTargetFieldVar]
	* @result           [GetTargetFieldVar covered]
	* @createdBy        Nadav Lichtenshtein, 28-12-2015
	* @lastModifiedBy 	Nadav Lichtenshtein, 28-12-2015
	*/
	@isTest static void GetTargetFieldVar() 
	{	
		Test.startTest();
		
		SO_CustomLookup_Con testObject = new SO_CustomLookup_Con();
		testObject.getTargetFieldVar();

		Test.stopTest();
	}

	/**
	* [NameOrSkuQueryString]
	* @scenario    		[call NameOrSkuQueryString, in case where string contain value and when string is blank]
	* @result           [NameOrSkuQueryString covered]
	* @createdBy        Nadav Lichtenshtein, 28-12-2015
	* @lastModifiedBy 	Nadav Lichtenshtein, 28-12-2015
	*/
	@isTest static void NameOrSkuQueryString() 
	{	
		Test.startTest();
		
		SO_CustomLookup_Con.nameOrSkuQueryString('');
		SO_CustomLookup_Con.nameOrSkuQueryString('test');
		SO_CustomLookup_Con.nameOrSkuQueryString('test:test');

		Test.stopTest();
	}

	/**
	* [GetData]
	* @scenario    		[call GetData, in case where string contain value and when string is blank]
	* @result           [GetData covered]
	* @createdBy        Nadav Lichtenshtein, 28-12-2015
	* @lastModifiedBy 	Nadav Lichtenshtein, 28-12-2015
	*/
	@isTest static void GetData() 
	{	
		Test.startTest();
		
		SO_CustomLookup_Con.getData('Account','Name','test','category','123');

		Test.stopTest();
	}

	/**
	* [AutoCompleteData]
	* @scenario    		[call AutoCompleteData, in case where string contain value and when string is blank]
	* @result           [AutoCompleteData covered]
	* @createdBy        Nadav Lichtenshtein, 28-12-2015
	* @lastModifiedBy 	Nadav Lichtenshtein, 28-12-2015
	*/
	@isTest static void AutoCompleteData() 
	{	
		Test.startTest();
		List<Account> accountList = [SELECT Id, Name FROM Account];
		
		SO_CustomLookup_Con.AutoCompleteData testObject = new SO_CustomLookup_Con.AutoCompleteData(accountList[0].Id,'test');
		
		Test.stopTest();
	}
}