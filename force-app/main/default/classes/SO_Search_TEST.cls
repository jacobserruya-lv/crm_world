/**
 * This is a class that TEST SO_Search_CTRL
 * @createdBy           
 * @lastModifiedBy      Nadav Lichtenshtein, 28-12-2015
 */
@isTest
private class SO_Search_TEST {

	/**
	* [Set database]
	* @scenario    		[insert objects to the system]
	* @result           [database to work with]
	* @createdBy      
    * @lastModifiedBy 	Nadav Lichtenshtein, 22-12-2015
	*/
	@testSetup static void setup()
	{
		User usr2 = IC_TestFactory.createUser('Test2LVBacthCLCreation@lvtest.com');
     	usr2.profileId = IC_UTILS.getSAProfile();
     	insert usr2;
     	SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true,true);
		User u = [SELECT ID,SPO_Session_State__c FROM User WHERE id =:UserInfo.getUserId()];
		u.SPO_Session_State__c ='{"searchProductData":null,"searchClientData":null,"mode":null,"globalSearchData":{"statusDateTo":" PM","statusDateFrom":" PM","opportunityZoneApproval":null,"opportunitySpecialOrderSKUCode":"","opportunityProductCategory":null,"opportunityOrderType":null,"opportunityName":"te*","opportunityMarketingApproval":null,"opportunityExo":null,"opportunityCentralApproval":null,"opportunityCACode":"","opportunityBriefCode":"","filterStatus":[],"createdDateTo":" PM","createdDateFrom":" PM","accountName":"","accountGivenName":""},"displayOrder":false}';
		update u;
	}
	
	@isTest static void testOrderSearch() 
	{
		List<User> userList = [SELECT id,SPO_Session_State__c FROM user WHERE username LIKE '%Test2LVBacthCLCreation@lvtest.com' LIMIT 1];
		Account acc = IC_TestFactory.createAccount();
		insert acc;

		PageReference ref =  new PageReference('/apex/SO_Search');
        Test.setCurrentPage(ref);

        
		SO_Search_CTRL ctrl = new SO_Search_CTRL();
		ctrl.filterUser = userList[0];
		ctrl.theSession.searchClientData = new SO_UTIL.SearchClientData();
		List<Opportunity> opp =[SELECT ID ,Name,SPO_ProductCategory__c,SPO_OrderType__c,SPO_BriefCode__c,SPO_CACode__c,SPO_Exo__c,
		SPO_ZoneApproval__c,SPO_SpecialOrderSKUCode__c,SPO_MarketingApproval__c ,SPO_CentralApproval__c,CreatedDate   FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		ctrl.filterOpportunity = opp[0];
		ctrl.filterOpportunity.Account = acc;
		Object temp  = ctrl.briefStatus ;
		List<String> tempList = SO_Search_CTRL.apiDisplayFieldNames; 
		tempList = SO_Search_CTRL.headerList;
		ctrl.filterOpportunity.SPO_ProductCategory__c = SO_PicklistDependency.OPP_WATCH;
		ctrl.filterStatus= new List<String> ();
		ctrl.filterStatus.add('test');

		ctrl.statusDateFrom = 'AM';
		ctrl.createdDateFrom = '01/01/2014';
		ctrl.createdDateTo = '01/01/2015';
		ctrl.statusDateTo ='01/01/2014';
		ctrl.searchOrder();

		ctrl.clearFilterFields();
		
	}

	@isTest static void testDateToNoOkFromOk() 
	{
		PageReference ref =  new PageReference('/apex/SO_Search');
        Test.setCurrentPage(ref);

		SO_Search_CTRL ctrl = new SO_Search_CTRL();
		List<Opportunity> opp =[SELECT ID ,Name,SPO_ProductCategory__c,SPO_OrderType__c,SPO_BriefCode__c,SPO_CACode__c,SPO_Exo__c,
		SPO_ZoneApproval__c,SPO_SpecialOrderSKUCode__c,SPO_MarketingApproval__c ,SPO_CentralApproval__c,CreatedDate   FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		ctrl.filterOpportunity = opp[0];
		//ctrl.filterOpportunity.Account = acc;
		Object temp  = ctrl.briefStatus ;
		List<String> tempList = SO_Search_CTRL.apiDisplayFieldNames; 
		tempList = SO_Search_CTRL.headerList;
		ctrl.filterOpportunity.SPO_ProductCategory__c = SO_PicklistDependency.OPP_WATCH;
		ctrl.filterStatus= new List<String> ();
		ctrl.filterStatus.add('test');

		ctrl.statusDateTo = 'AM';
		ctrl.createdDateFrom = '01/01/2014';
		ctrl.createdDateTo = 'AM';
		ctrl.statusDateFrom ='01/01/2015';
		ctrl.searchOrder();
	}

	@isTest static void testODateFromAndToOk() 
	{
		List<User> userList = [SELECT id FROM user WHERE username ='Test2LVBacthCLCreation@lvtest.com' LIMIT 1];
		Account acc = IC_TestFactory.createAccount();
		insert acc;

		PageReference ref =  new PageReference('/apex/SO_Search');
        Test.setCurrentPage(ref);

			SO_Search_CTRL ctrl = new SO_Search_CTRL();
			List<Opportunity> opp =[SELECT ID ,Name,SPO_ProductCategory__c,SPO_OrderType__c,SPO_BriefCode__c,SPO_CACode__c,SPO_Exo__c,
			SPO_ZoneApproval__c,SPO_SpecialOrderSKUCode__c,SPO_MarketingApproval__c ,SPO_CentralApproval__c,CreatedDate   FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
			opp[0].SPO_OrderType__c = 'dd';
			opp[0].SPO_Exo__c ='dd';
			opp[0].SPO_SpecialOrderSKUCode__c = 'sku123';
			opp[0].SPO_ZoneApproval__c = 'test';
			update opp[0];

			ctrl.filterOpportunity = opp[0];
			ctrl.filterOpportunity.Account = acc;
			Object temp  = ctrl.briefStatus ;
			List<String> tempList = SO_Search_CTRL.apiDisplayFieldNames; 
			tempList = SO_Search_CTRL.headerList;
			ctrl.filterOpportunity.SPO_ProductCategory__c = SO_PicklistDependency.OPP_WATCH;
			ctrl.filterStatus= new List<String> ();
			ctrl.filterStatus.add('test');

			ctrl.statusDateTo = '01/01/2014';
			ctrl.createdDateFrom = 'AM';
			ctrl.createdDateTo = '01/01/2014';
			ctrl.statusDateFrom ='01/01/2015';
			ctrl.searchOrder();	

			opp[0].SPO_OrderType__c = null;
			opp[0].SPO_Exo__c =null;
			opp[0].SPO_SpecialOrderSKUCode__c = null;
			opp[0].SPO_ZoneApproval__c = null;
			update opp[0];



	}

	@isTest static void testODateFromAndToOk2() 
	{
		List<User> userList = [SELECT id FROM user WHERE username ='Test2LVBacthCLCreation@lvtest.com' LIMIT 1];
		Account acc = IC_TestFactory.createAccount();
		insert acc;

		PageReference ref =  new PageReference('/apex/SO_Search');
        Test.setCurrentPage(ref);

			SO_Search_CTRL ctrl = new SO_Search_CTRL();
			List<Opportunity> opp =[SELECT ID ,Name,SPO_ProductCategory__c,SPO_OrderType__c,SPO_BriefCode__c,SPO_CACode__c,SPO_Exo__c,
			SPO_ZoneApproval__c,SPO_SpecialOrderSKUCode__c,SPO_MarketingApproval__c ,SPO_CentralApproval__c,CreatedDate   FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
			ctrl.filterOpportunity = opp[0];
			ctrl.filterOpportunity.Account = acc;
			Object temp  = ctrl.briefStatus ;
			List<String> tempList = SO_Search_CTRL.apiDisplayFieldNames; 
			tempList = SO_Search_CTRL.headerList;
			ctrl.filterOpportunity.SPO_ProductCategory__c = SO_PicklistDependency.OPP_WATCH;
			ctrl.filterStatus= new List<String> ();
			ctrl.filterStatus.add('test');
			ctrl.searchOrder();	
	}


}