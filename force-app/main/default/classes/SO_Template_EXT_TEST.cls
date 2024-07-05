/**
 * This is a test class for SO_Template_EXT_TEST 
 * @createdBy           Nadav Lichtenshtein, 28-12-2015
 * @lastModifiedBy      Nadav Lichtenshtein, 28-12-2015
 */
@isTest
private class SO_Template_EXT_TEST 
{
	///**
	//* [Set database]
	//* @scenario    		[insert objects to the system]
	//* @result           [database to work with]
	//* @createdBy        Nadav Lichtenshtein, 28-12-2015
 //   * @lastModifiedBy 	Nadav Lichtenshtein, 28-12-2015
	//*/
	//@testSetup static void Setup()
	//{
	//	SO_TestObjectCreator testObjectCreation = new SO_TestObjectCreator();
	//	testObjectCreation.initialization_one(true, true);
	//	List<Opportunity> opp =[SELECT ID FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
	//	SPO_FirmOrder__c fo = new SPO_FirmOrder__c (LineNumber__c = 1, SPO_BriefName__c = opp[0].id,SPO_Substatus__c = 'Codification',SPO_FirmOrderStatus__c = 'Creation in progress');
	//	insert fo; 
	//}
	
	///**
	//* [CoverConstructor]
	//* @scenario    		[call CoverConstructor]
	//* @result           [CoverConstructor covered]
	//* @createdBy        Nadav Lichtenshtein, 28-12-2015
	//* @lastModifiedBy 	Nadav Lichtenshtein, 28-12-2015
	//*/
	//@isTest static void CoverConstructor() 
	//{
	//	//SO_OrderPageSwitch orderpage = new SO_OrderPageSwitch();
		
	//	List<Opportunity> opp =[SELECT ID, Name, SPO_DisplayOrder__c,AccountId,Account.Name, SPO_ConcatenateTitle__c
	//									,Account.LastName,toLabel(Account.Salutation),SPO_OpportunityCloning__c
	//									,SPO_Store__c,SPO_Store__r.RetailStoreId__c,SPO_Session_State__c,SPO_BaseSKURefmodelSKU__c
	//									,SPO_BaseSKURefmodelSKU__r.Name,SPO_BaseSKURefmodelSKU__r.SKUCode__c,StageName,OwnerId
 //								FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		
	//	SO_Session.startSession(opp[0]);
	//	SO_Session.currentBriefById(opp[0].id);
 
	//	SO_OrderPageSwitch orderPS = new SO_OrderPageSwitch();
	//	orderPS.buildTargetPageMap(opp);

	//	PageReference cPage = System.Page.SO_ClientSearch;
 //   	Test.setCurrentPageReference(cPage);

	//	SO_Template_CTRL template = new SO_Template_CTRL();
		
	//	Test.startTest();

	//	SO_Template_EXT testObject = new SO_Template_EXT(template);

	//	Test.stopTest();
	//}	

	///**
	//* [RetFilteredMessageList]
	//* @scenario    		[call RetFilteredMessageList, I gave the function opportunity with no reason]
	//* @result           [RetFilteredMessageList covered]
	//* @createdBy        Nadav Lichtenshtein, 28-12-2015
	//* @lastModifiedBy 	Nadav Lichtenshtein, 28-12-2015
	//*/
	//@isTest static void RetFilteredMessageList() 
	//{
	//	//SO_OrderPageSwitch orderpage = new SO_OrderPageSwitch();
		
	//	List<Opportunity> opp =[SELECT ID,SPO_DisplayOrder__c,AccountId,Account.Name, SPO_ConcatenateTitle__c
	//									,Account.LastName,toLabel(Account.Salutation),SPO_OpportunityCloning__c
	//									,SPO_Store__c,SPO_Store__r.RetailStoreId__c,SPO_Session_State__c,SPO_BaseSKURefmodelSKU__c
	//									,SPO_BaseSKURefmodelSKU__r.Name,SPO_BaseSKURefmodelSKU__r.SKUCode__c,StageName,OwnerId
 //								FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		
	//	SO_Session.startSession(opp[0]);
	//	SO_Session.currentBriefById(opp[0].id);
 
	//	SO_OrderPageSwitch orderPS = new SO_OrderPageSwitch();
	//	orderPS.buildTargetPageMap(opp);

	//	PageReference cPage = System.Page.SO_ClientSearch;
 //   	Test.setCurrentPageReference(cPage);

	//	SPO_Message__c message = new SPO_Message__c();
	//	message.SPO_Message__c = 'testMessage';

	//	List<SPO_Message__c> messageList = new List<SPO_Message__c>();
	//	messageList.add(message);

	//	Test.startTest();

	//	SO_Template_EXT.RetFilteredMessageList(opp[0],messageList);

	//	Test.stopTest();
	//}

	///**
	//* [MessageCounter]
	//* @scenario    		[call MessageCounter]
	//* @result           [MessageCounter covered]
	//* @createdBy        Nadav Lichtenshtein, 28-12-2015
	//* @lastModifiedBy 	Nadav Lichtenshtein, 28-12-2015
	//*/
	//@isTest static void messageCounter() 
	//{
	//	Test.startTest();

	//	SO_Template_EXT.MessageCounter();

	//	Test.stopTest();
	//}

	///**
	//* [messageCounterByOppId]
	//* @scenario    		[call messageCounterByOppId]
	//* @result           [messageCounterByOppId covered]
	//* @createdBy        Nadav Lichtenshtein, 28-12-2015
	//* @lastModifiedBy 	Nadav Lichtenshtein, 28-12-2015
	//*/
	//@isTest static void messageCounterByOppId() 
	//{
	//	List<Opportunity> opp =[SELECT ID,SPO_DisplayOrder__c,AccountId,Account.Name, SPO_ConcatenateTitle__c
	//									,Account.LastName,toLabel(Account.Salutation),SPO_OpportunityCloning__c
	//									,SPO_Store__c,SPO_Store__r.RetailStoreId__c,SPO_Session_State__c,SPO_BaseSKURefmodelSKU__c
	//									,SPO_BaseSKURefmodelSKU__r.Name,SPO_BaseSKURefmodelSKU__r.SKUCode__c,StageName,OwnerId
 //								FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		
	//	SO_Session.startSession(opp[0]);
	//	SO_Session.currentBriefById(opp[0].id);

	//	Test.startTest();

	//	SO_Template_EXT.messageCounterByOppId(opp[0].id);

	//	Test.stopTest();
	//}			

	///**
	//* [addMessage]
	//* @scenario    		[call addMessage]
	//* @result           [addMessage covered]
	//* @createdBy        Nadav Lichtenshtein, 28-12-2015
	//* @lastModifiedBy 	Nadav Lichtenshtein, 28-12-2015
	//*/
	//@isTest static void AddMessage() 
	//{
	//	List<Opportunity> opp =[SELECT ID,SPO_DisplayOrder__c,AccountId,Account.Name, SPO_ConcatenateTitle__c
	//									,Account.LastName,toLabel(Account.Salutation),SPO_OpportunityCloning__c
	//									,SPO_Store__c,SPO_Store__r.RetailStoreId__c,SPO_Session_State__c,SPO_BaseSKURefmodelSKU__c
	//									,SPO_BaseSKURefmodelSKU__r.Name,SPO_BaseSKURefmodelSKU__r.SKUCode__c,StageName,OwnerId
 //								FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		
	//	SO_Session.startSession(opp[0]);
	//	SO_Session.currentBriefById(opp[0].id);

	//	Test.startTest();

	//	SO_Template_EXT.AddMessage(opp[0].id, 'testText');

	//	Test.stopTest();
	//}	

	//*
	//* [initMassagesFirstTime]
	//* @scenario    		[call initMassagesFirstTime]
	//* @result           [initMassagesFirstTime covered]
	//* @createdBy        Nadav Lichtenshtein, 28-12-2015
	//* @lastModifiedBy 	Nadav Lichtenshtein, 28-12-2015
	
	//@isTest static void InitMassagesFirstTime() 
	//{
	//	List<Opportunity> opp =[SELECT ID,SPO_DisplayOrder__c,AccountId,Account.Name, SPO_ConcatenateTitle__c
	//									,Account.LastName,toLabel(Account.Salutation),SPO_OpportunityCloning__c
	//									,SPO_Store__c,SPO_Store__r.RetailStoreId__c,SPO_Session_State__c,SPO_BaseSKURefmodelSKU__c
	//									,SPO_BaseSKURefmodelSKU__r.Name,SPO_BaseSKURefmodelSKU__r.SKUCode__c,StageName,OwnerId
 //								FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		
	//	SO_Session.startSession(opp[0]);
	//	SO_Session.currentBriefById(opp[0].id);

	//	Test.startTest();

	//	SO_Template_EXT.InitMassagesFirstTime(opp[0].id);

	//	Test.stopTest();
	//}			

	///**
	//* [readMessage]
	//* @scenario    		[call readMessage]
	//* @result           [readMessage covered]
	//* @createdBy        Nadav Lichtenshtein, 28-12-2015
	//* @lastModifiedBy 	Nadav Lichtenshtein, 28-12-2015
	//*/
	//@isTest static void ReadMessages() 
	//{
	//	List<Opportunity> opp =[SELECT ID,SPO_DisplayOrder__c,AccountId,Account.Name, SPO_ConcatenateTitle__c
	//									,Account.LastName,toLabel(Account.Salutation),SPO_OpportunityCloning__c
	//									,SPO_Store__c,SPO_Store__r.RetailStoreId__c,SPO_Session_State__c,SPO_BaseSKURefmodelSKU__c
	//									,SPO_BaseSKURefmodelSKU__r.Name,SPO_BaseSKURefmodelSKU__r.SKUCode__c,StageName,OwnerId
 //								FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		
	//	List<SPO_Message__c> messagesList = new List<SPO_Message__c>
	//	{
	//		new SPO_Message__c(SPO_BriefConcerned__c = opp[0].id, SPO_Message__c = 'test1'), 
	//		new SPO_Message__c(SPO_BriefConcerned__c = opp[0].id, SPO_Message__c = 'test2'), 
	//		new SPO_Message__c(SPO_BriefConcerned__c = opp[0].id, SPO_Message__c = 'test3')
	//	};
	//	insert messagesList;

	//	SO_Session.startSession(opp[0]);
	//	SO_Session.currentBriefById(opp[0].id);

	//	Test.startTest();
	//	SO_Template_EXT.MessageWrapper wrapitup = new SO_Template_EXT.MessageWrapper(new SPO_Message__c(SPO_BriefConcerned__c = opp[0].id, SPO_Message__c = 'blank'));
	//	SO_Template_EXT.initMassagesFirstTime(opp[0].id);
	//	SO_Template_EXT.addMessage(opp[0].id, 'test4');
	//	SO_Template_EXT.ReadMessage(opp[0].id);
	//	SO_Template_EXT.readMessageRetIdList(opp[0].id);
	//	Test.stopTest();
	//}

	//@isTest static void ReadEmptyMessages() 
	//{
	//	List<Opportunity> opp =[SELECT ID,SPO_DisplayOrder__c,AccountId,Account.Name, SPO_ConcatenateTitle__c
	//									,Account.LastName,toLabel(Account.Salutation),SPO_OpportunityCloning__c
	//									,SPO_Store__c,SPO_Store__r.RetailStoreId__c,SPO_Session_State__c,SPO_BaseSKURefmodelSKU__c
	//									,SPO_BaseSKURefmodelSKU__r.Name,SPO_BaseSKURefmodelSKU__r.SKUCode__c,StageName,OwnerId
 //								FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
				
	//	SO_Session.startSession(opp[0]);
	//	SO_Session.currentBriefById(opp[0].id);

	//	Test.startTest();

	//	SO_Template_EXT.ReadMessage(opp[0].id);

	//	Test.stopTest();
	//}

	///**
	//* [readMessageRetIdList]
	//* @scenario    		[call readMessageRetIdList]
	//* @result           [readMessageRetIdList covered]
	//* @createdBy        Nadav Lichtenshtein, 28-12-2015
	//* @lastModifiedBy 	Nadav Lichtenshtein, 28-12-2015
	//*/
	//@isTest static void ReadMessageRetIdList() 
	//{
	//	List<Opportunity> opp =[SELECT ID,SPO_DisplayOrder__c,AccountId,Account.Name, SPO_ConcatenateTitle__c
	//									,Account.LastName,toLabel(Account.Salutation),SPO_OpportunityCloning__c
	//									,SPO_Store__c,SPO_Store__r.RetailStoreId__c,SPO_Session_State__c,SPO_BaseSKURefmodelSKU__c
	//									,SPO_BaseSKURefmodelSKU__r.Name,SPO_BaseSKURefmodelSKU__r.SKUCode__c,StageName,OwnerId
 //								FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		
	//	SO_Session.startSession(opp[0]);
	//	SO_Session.currentBriefById(opp[0].id);

	//	Test.startTest();

	//	SO_Template_EXT.ReadMessageRetIdList(opp[0].id);

	//	Test.stopTest();
	//}		

	/////**
	////* [MessageWrapper]
	////* @scenario    		[call MessageWrapper]
	////* @result           [readMessageRetIdList covered]
	////* @createdBy        Nadav Lichtenshtein, 28-12-2015
	////* @lastModifiedBy 	Nadav Lichtenshtein, 28-12-2015
	////*/
	////@isTest static void MessageWrapper() 
	////{
	////	SPO_Message__c message = new SPO_Message__c();
	////	message.SPO_Message__c = 'testMessage';
	////	message.SPO_WritterRole__c = 'test';
	////	insert message;

	////	Test.startTest();

	////	SO_Template_EXT.MessageWrapper = new SO_Template_EXT.MessageWrapper(message);

	////	Test.stopTest();
	////}	

	///**
	//* [cancelBrief]
	//* @scenario    		[call cancelBrief]
	//* @result           [cancelBrief covered]
	//* @createdBy        Nadav Lichtenshtein, 28-12-2015
	//* @lastModifiedBy 	Nadav Lichtenshtein, 28-12-2015
	//*/
	//@isTest static void cancelBrief() 
	//{
	//	List<Opportunity> opp =[SELECT ID, Name,SPO_DisplayOrder__c,AccountId,Account.Name, SPO_ConcatenateTitle__c
	//									,Account.LastName,toLabel(Account.Salutation),SPO_OpportunityCloning__c
	//									,SPO_Store__c,SPO_Store__r.RetailStoreId__c,SPO_Session_State__c,SPO_BaseSKURefmodelSKU__c
	//									,SPO_BaseSKURefmodelSKU__r.Name,SPO_BaseSKURefmodelSKU__r.SKUCode__c,StageName,OwnerId
 //								FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
		
	//	SO_Session.startSession(opp[0]);
	//	SO_Session.currentBriefById(opp[0].id);
 
	//	SO_OrderPageSwitch orderPS = new SO_OrderPageSwitch();
	//	orderPS.buildTargetPageMap(opp);

	//	PageReference cPage = System.Page.SO_ClientSearch;
 //   	Test.setCurrentPageReference(cPage);

	//	SO_Template_CTRL template = new SO_Template_CTRL();
		
	//	Test.startTest();

	//	SO_Template_EXT testObject = new SO_Template_EXT(template);
	//	testObject.cancelBrief();

	//	Test.stopTest();
	//}		
																											
}