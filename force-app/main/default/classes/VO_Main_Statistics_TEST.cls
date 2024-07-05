@isTest	(seeAllData=false)
private class VO_Main_Statistics_TEST {
	
	static final Integer LOOP_STORE = 100;
	
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

            if (i== 3)  i= surveyList.size();
    	
                
        }        
        //insert surveyList;
        insert surveyListInsert;
	}

	@isTest
	static void myUnitTest()
	{
		PageReference ref = Page.VO_Main_Statistics;
		Test.setCurrentPage(ref);
		VO_Utils.MS_USE_BATCH = false;
		VO_Main_Statistics_CTRL webPage = new VO_Main_Statistics_CTRL();
		VO_Utils.MS_USE_BATCH = true;
		VO_Main_Statistics_CTRL webPagewithBatch = new VO_Main_Statistics_CTRL();
		Date lessTest = webPagewithBatch.todayLessNmonths;
		VO_Main_Statistics_CTRL.updateAllStoresMSfieldsToZero();
	}

}