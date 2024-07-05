@isTest
private class SO_Session_TEST {

	@testSetup static void methodName() {
		SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
		dataModel.initialization_one(true,true);
	}

	@isTest static void test_method_one() {

		List<Opportunity> opp =[SELECT ID,Name
										,OwnerId
										,StageName
										,AccountId
										,Account.Name
										,Account.LastName
										,toLabel(Account.Salutation)

										,SPO_OpportunityCloning__c
										
										,SPO_Store__c
										,SPO_Store__r.RetailStoreId__c
										,SPO_DisplayOrder__c
										,SPO_Session_State__c
										,SPO_BaseSKURefmodelSKU__c
										,SPO_BaseSKURefmodelSKU__r.Name
										,SPO_BaseSKURefmodelSKU__r.SKUCode__c
								FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		SO_Session.startSession(opp[0]);
		SO_Session.currentBriefById(opp[0].id);
		system.assertEquals(SO_Session.currentBriefId,opp[0].id);

		system.assertEquals(SO_Session.retSessionStateForOpp(opp[0]).mode,null);
		system.assertEquals(SO_Session.retSessionStateForOpp(opp[0]).globalSearchData,null);
		system.assertEquals(SO_Session.retSessionStateForOpp(opp[0]).displayOrder,false);

	}

	@isTest static void testOppWithState() {
		

		List<Opportunity> opp =[SELECT ID,Name
										,OwnerId
										,StageName
										,AccountId
										,Account.Name
										,Account.LastName
										,toLabel(Account.Salutation)

										,SPO_OpportunityCloning__c
										
										,SPO_Store__c
										,SPO_Store__r.RetailStoreId__c
										
										,SPO_Session_State__c
										,SPO_BaseSKURefmodelSKU__c
										,SPO_BaseSKURefmodelSKU__r.Name
										,SPO_BaseSKURefmodelSKU__r.SKUCode__c
								FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		opp[0].SPO_Session_State__c = 'test stat';
		update opp[0];
		Id brifId = SO_Session.currentBriefId;
		SO_Session.currentBriefById(opp[0].id);
		SO_Session.startSession(opp[0]);
		SO_Session.currentBriefById(opp[0].id);

		SO_Session.retSessionState();
		system.assertEquals(SO_Session.retSessionState().mode,null);
		system.assertEquals(SO_Session.retSessionState().globalSearchData,null);
		system.assertEquals(SO_Session.retSessionState().displayOrder,false);


		system.assertEquals(SO_Session.retSessionStateForOpp(opp[0]).mode,null);
		system.assertEquals(SO_Session.retSessionStateForOpp(opp[0]).globalSearchData,null);
		system.assertEquals(SO_Session.retSessionStateForOpp(opp[0]).displayOrder,false);

		SO_Session.saveSession(opp[0],SO_Session.retSessionState(),false);
		SO_Session.saveSession(SO_Session.retSessionState(),true);
		SO_Session.retOpportunityBy(opp[0].id);


	}
	

	
}