/**
 * This is a test class for VO_SurvayTypeStat class
 * @createdBy           Nadav Lichtenshtein, 11-2-2016
 * @lastModifiedBy      Nadav Lichtenshtein, 11-2-2016
 */
@isTest
private class VO_SurvayTypeStat_TEST 
{
	@testSetup
	static void initDate()
	{
		Test.loadData(VO_Config__c.sobjectType, 'VO_Config_TestCLS');

		List<VO_Survey__c> surveyList = VO_data_Object_Creator_TEST.createSurvayList();
		List<Store__c> storeList = VO_data_Object_Creator_TEST.createStoreByNum(3);
        insert storeList;
        List<VO_Survey__c> surveyListInsert = new List<VO_Survey__c> ();
        for(Integer i = 0; i < surveyList.size(); i++)
        {
            surveyList[i].Store__c = storeList[math.mod(i,3)].id;
            surveyListInsert.add(surveyList[i]);
            if (i== 5)  i = surveyList.size();
    	
        }        
        //insert surveyList;
        insert surveyListInsert;
	}

	@isTest static void testConstructors() 
	{
		VO_SurvayTypeStat testObject1 = new VO_SurvayTypeStat();
		VO_SurvayTypeStat testObject2 = new VO_SurvayTypeStat('title');
	}
	
	@isTest static void initSurvayTypeStatMap() 
	{ 
		List<String> permisstionList = new List<String>{VO_Utils.VOICE_SALES,VO_Utils.VOICE_AFTER_SALES, VO_Utils.VOICE_WEB_SALES, VO_Utils.VOICE_CSC_SALES};

		VO_SurvayTypeStat.initSurvayTypeStatMap();
		VO_SurvayTypeStat.initSurvayTypeStatMap(permisstionList);
	}
	
	@isTest static void updatesurvayTypeStatMap() 
	{
		List<VO_Survey__c> surveyList = [SELECT id FROM VO_Survey__c];
		surveyList[0].Q01Number__c = 50;
		update surveyList[0];

		AggregateResult[] groupedResults = [SELECT count(Id), count(SurveyType__c)SurveyType__c, count(Status__c)Status__c, count(Type__c)Type__c 
											FROM VO_Survey__c];
		
		Map<String, VO_SurvayTypeStat> surveyTypeMap = VO_SurvayTypeStat.initSurvayTypeStatMap();
		surveyTypeMap.put('1024',surveyTypeMap.get(VO_Utils.VOICE_AFTER_SALES));

		VO_SurvayTypeStat.updatesurvayTypeStatMap(surveyTypeMap, groupedResults);
	}

	@isTest static void updatesurvayTypeStatMapForLastNdays() 
	{
		List<String> permisstionList = new List<String>{VO_Utils.VOICE_SALES,VO_Utils.VOICE_AFTER_SALES, VO_Utils.VOICE_WEB_SALES, VO_Utils.VOICE_CSC_SALES};

		AggregateResult[] groupedResults = [SELECT COUNT(Id), SurveyType__c, Status__c, Type__c
											 FROM VO_Survey__c
											 WHERE SurveyType__c IN:permisstionList
											 GROUP BY SurveyType__c, Status__c, Type__c];

		Map<String, VO_SurvayTypeStat> surveyTypeMap = VO_SurvayTypeStat.initSurvayTypeStatMap();
		surveyTypeMap.put('1024',surveyTypeMap.get(VO_Utils.VOICE_AFTER_SALES));

		VO_SurvayTypeStat.updatesurvayTypeStatMapForLastNdays(surveyTypeMap, groupedResults);
	}
}