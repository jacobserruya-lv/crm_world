/**
 * This is a test class for class PicklistDependency_CTRL
 * @createdBy           Ester Mendelson, 29-12-2015
 * @lastModifiedBy      Ester Mendelson, 29-12-2015
 */

@isTest
private class SO_PicklistDependency_Test {

	/**
	* [Set database]
	* @scenario    		[insert objects to the system]
	* @result           [database to work with]
	* @createdBy      
	* @lastModifiedBy 	 Ester Mendelson, 28-12-2015
	*/
	@testSetup static void setup() {
		SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true,true);
	}

	/**
	* [Test SO_PicklistDependency_CTRL  ]
	* @scenario    		[test all picklistDependency]
	* @createdBy        Ester Mendelson, 28-12-2015
	* @lastModifiedBy 	Ester Mendelson, 28-12-2015
	*/
	@isTest static void picklistDependency() {

		List<Opportunity> opp =[SELECT ID,SPO_ProductCategory__c,OwnerId FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);
		SO_PicklistDependency pld = new SO_PicklistDependency(sc);
		pld.getPickListDependencyHandler();
		String getPickListDependencyHandlerString = pld.oppAccessory;
		getPickListDependencyHandlerString = pld.prorAccessory;
		getPickListDependencyHandlerString =pld.oppRecTypeNameAccessory; 
		getPickListDependencyHandlerString = pld.oppLeatherGood;
		getPickListDependencyHandlerString = pld.prorLeatherGood; 
		getPickListDependencyHandlerString = pld.oppRecTypeNameLeatherGood;
		getPickListDependencyHandlerString = pld.oppWatch;
		getPickListDependencyHandlerString = pld.prorWatch;
		getPickListDependencyHandlerString = pld.oppRecTypeNameWatch;
	}
}