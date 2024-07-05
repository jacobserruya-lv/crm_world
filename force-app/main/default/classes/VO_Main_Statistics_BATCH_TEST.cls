@isTest
private class VO_Main_Statistics_BATCH_TEST {

	@isTest
	static void initDate()
	{
		Test.loadData(VO_Config__c.sobjectType, 'VO_Config_TestCLS');

		List<VO_Survey__c> surveyList = VO_data_Object_Creator_TEST.createSurvayList();
		List<Store__c> storeList = VO_data_Object_Creator_TEST.createStoreByNum(surveyList.size());

		List<VO_Survey__c> surveylist10 = new List<VO_Survey__c>();
		integer counter = 0;
		while(counter<2 && counter<surveyList.size()) {
		    surveylist10.add(surveyList[counter++]);
		}

		List<Store__c> storelist10 = new List<Store__c>();
		integer counter2 = 0;
		while(counter2<2 && counter2<storeList.size()) {
		    storelist10.add(storeList[counter2++]);
		}
		insert storelist10;
		
		for(Integer i = 0; i < storelist10.size(); i++)
		{
			surveylist10[i].Store__c = storelist10[i].id;
		}
		insert surveylist10;

		List<AggregateResult> results = new List<AggregateResult>();
		Store__c store = ICX_TestFactory.createStore('storeName', 'TESTCODE');
        insert store;

		VO_Survey__c survey1 = [SELECT Id, SurveyType__c, Store__r.id, Type__c, Status__c, AnswerDate__c FROM VO_Survey__c LIMIT 1];

		survey1.Type__c = VO_Utils.VOICE_SURVEY_TYPE_RECOVERY_ACT;
		survey1.AnswerDate__c = date.today().addDays(-100);
		update survey1;

		try{
			Test.StartTest();
			

			VO_Main_Statistics_BATCH msStaticBatch = new VO_Main_Statistics_BATCH();

			ID batchprocessid = Database.executeBatch(msStaticBatch);

			Test.StopTest();
        } catch (System.UnexpectedException theException){ // this exeption will not be catch because it is probably thown in a separate transaction
            System.assertEquals('No more than one executeBatch can be called from within a testmethod. Please make sure the iterable returned from ' +
                'your start method matches the batch size, resulting in one executeBatch invocation.', theException.getMessage());
 
        }
	}	
}