/**
 * This is a test class for class SO_Notifications_CTRL
 * @createdBy           Ester Mendelson, 03-12-2015
 * @lastModifiedBy      Ester Mendelson, 28-12-2015
 */
 @isTest
private class SO_Notifications_TEST {
	
	///**
	//* [Set database]
	//* @scenario    		[insert objects to the system]
	//* @result           [database to work with]
	//* @createdBy      
 //   * @lastModifiedBy 	 Ester Mendelson, 28-12-2015
	//*/

	//@testSetup static void setUp() {
				
	//	String alias = 'atest_';
 //   	String email = 'atest_@test.com';
 //   	User u =  new User(
 //   		username = email,
 //   		email = email,
 //   		alias = alias,
 //   		profileId  = [Select Id from Profile where Name='SPO_Other'].Id,
 //   		emailEncodingKey = 'UTF-8',
 //   		firstName = 'John',
 //   		lastName = alias,
 //   		localeSIDKey = 'en_US',
 //   		languageLocaleKey = 'en_US',
 //   		timezoneSIDKey = 'America/Los_Angeles',
 //   		MANAGEMENT_ZONE_LEVEL__c = 'AMERICAS',
 //   		MGMT_ZONE_SUB_LEVEL1__c = 'CANADA/BERMUDA',
 //   		MGMT_ZONE_SUB_LEVEL2__c = 'CANADA',
 //   		MGMT_ZONE_SUB_LEVEL3__c = 'USA');
 //   	insert u;

 //   	System.runAs(u)
 //   	{
 //   		SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
	//		dataModel.initialization_one(true,true);
 //   	}
	//}
	//@isTest static void testNotification() {

	//	SO_Notifications_CTRL ctrl = new SO_Notifications_CTRL();

	//	List<Opportunity> opp =[SELECT ID,SPO_ProductCategory__c,OwnerId,SPO_BaseSKURefmodelSKU__c,StageName,LastModifiedDate,CreatedDate,Name,SPO_OrderType__c
	//							,SPO_StoreCode__c,SPO_CACode__c,Account.Name FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
	//	SPO_Message__c message = new SPO_Message__c(SPO_BriefConcerned__c = opp[0].id,	SPO_ReadByother__c = true , SPO_ReadByProduction__c = true ,SPO_ReadByStore__c = true);
	//	insert message;

	//	SPO_Message__c message1 = new SPO_Message__c(SPO_BriefConcerned__c = opp[0].id,	SPO_ReadByother__c = false , SPO_ReadByProduction__c = false ,SPO_ReadByStore__c = false);
	//	insert message1;

	//	opp[0].SPO_ProductCategory__c = 'Leather goods';
	//	opp[0].StageName = 'Creation in Progress';
	//	update opp[0];
	//	System.debug('testNotification - opp: ' + opp[0]);
	//	ctrl = new SO_Notifications_CTRL();
	//	SO_Notifications_CTRL.ViewLine vl= new SO_Notifications_CTRL.ViewLine(opp[0],'url');
	//}

	//@isTest static void testStoreNotification() {
	//	List<Opportunity> opp =[SELECT ID,SPO_ProductCategory__c,OwnerId,SPO_BaseSKURefmodelSKU__c,StageName,LastModifiedDate,CreatedDate,Name,SPO_OrderType__c
	//							,SPO_StoreCode__c,SPO_CACode__c,Account.Name FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];

	//	SPO_Message__c message = new SPO_Message__c(SPO_BriefConcerned__c = opp[0].id,	SPO_ReadByother__c = false , SPO_ReadByProduction__c = false ,SPO_ReadByStore__c = false);
	//	insert message;

 //   	User u = [SELECT Id FROM USER WHERE Username =:'atest_@test.com'];
 //   	System.runAs(u){
	//		opp[0].SPO_ProductCategory__c = 'Leather goods';
	//		opp[0].StageName = 'Creation in Progress';
	//		update opp[0];
	//		System.debug('testNotification - opp: ' + opp[0]);
	//		SO_Notifications_CTRL ctrl = new SO_Notifications_CTRL();
	//		SO_Notifications_CTRL.ViewLine vl= new SO_Notifications_CTRL.ViewLine(opp[0],'url');

 //   	}
    	
 //   }
}