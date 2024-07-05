/**
 * This is a test class for class SO_Table_Wrapper_CTRL
 * @createdBy           Ester Mendelson, 29-12-2015
 * @lastModifiedBy      Ester Mendelson, 29-12-2015
 */
 @isTest
private class SO_Table_Wrapper_Test {

	@testSetup static void setData() {
		SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true,true);
	}
	
	@isTest static void testTableWrapper() {
		List<Opportunity> opp =[SELECT ID,SPO_ProductCategory__c,OwnerId,SPO_BaseSKURefmodelSKU__c,CreatedDate FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		SO_Table_Wrapper so = new SO_Table_Wrapper(opp[0],new Map<String, String>(),null,'test?');
	}	
}