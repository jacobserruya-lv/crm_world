@isTest
private class VO_Case_Details_TEST 
{
	
	@testSetup
	static void initData()
	{
		Test.loadData(VO_Config__c.sobjectType, 'VO_Config_TestCLS');

		List<VO_Survey__c> surveyList 	= VO_data_Object_Creator_TEST.createSurvayList();
		//List<Store__c> storeList 		= VO_data_Object_Creator_TEST.createStoreByNum(surveyList.size());
        List<Store__c> storeList = VO_data_Object_Creator_TEST.createStoreByNum(3);
		Account currentAccount 			= VO_data_Object_Creator_TEST.createAccount('VO-TEST-ACCOUNT');

		insert storeList;
		insert currentAccount;

        List<VO_Survey__c> surveyListInsert = new List<VO_Survey__c> ();
        for(Integer i = 0; i < surveyList.size(); i++)
        {
            surveyList[i].Store__c = storeList[math.mod(i,3)].id;
            surveyList[i].ClientDreamID__c 	= currentAccount.Id; 
            surveyListInsert.add(surveyList[i]);
            if (i== 5)  i = surveyList.size();
    	
        }        
        insert surveyListInsert;

		/*for(Integer i = 0; i < surveyList.size(); ++i)
		{
			surveyList[i].Store__c 			= storeList[i].id;
			surveyList[i].ClientDreamID__c 	= currentAccount.Id; 
		}
		insert surveyList;*/
	}

	@isTest
	static void viewCaseDetailsPage()
	{
		VO_Survey__c currentSurvey	= [SELECT Id, ClientDreamID__c FROM VO_Survey__c LIMIT 1];
		Account currentAccount	= [SELECT Id FROM Account];
		System.assert(currentSurvey.ClientDreamID__c == currentAccount.Id);

		PageReference pageRef = Page.VO_Case_Details;
		pageRef.getParameters().put('surveyID', currentSurvey.Id);
		pageRef.getParameters().put('accountId', currentSurvey.ClientDreamID__c);
		Test.setCurrentPage(pageRef);

		ApexPages.StandardController sc = new ApexPages.StandardController(currentAccount);
        VO_Case_Details_CTRL ctrl = new VO_Case_Details_CTRL(sc);

        List<VO_Feedback_Wrappers.AnswerList_Wrapper> ansListWrapperList = ctrl.ansListWrapperList;

		pageRef.getParameters().put('Comment','false');
		pageRef.getParameters().put('Chanel','');
		pageRef.getParameters().put('Root','');
		pageRef.getParameters().put('CA','');
		
        ctrl.clickSaveModal();
        ctrl.clickCloseCaseModal();
	}
	
}