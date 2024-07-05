@isTest	(seeAllData=false)
private class VO_Specific_Statistics_Excel_TEST {
	
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

            if (i== 5)  i= surveyList.size();
    	
                
        }        
        //insert surveyList;
        insert surveyListInsert;

	}
	@isTest static void test_method_one() {
		

		PageReference ref = Page.VO_Specific_Statistics_Excel;
		ref.getParameters().put('lvl1','');
		ref.getParameters().put('lvl2','');
		ref.getParameters().put('lvl3','');
		ref.getParameters().put('lvl4','');
		ref.getParameters().put('storeName','');
		ref.getParameters().put('ca','');
		ref.getParameters().put('surveyType','');
		ref.getParameters().put('fromDate',Datetime.now().addYears(-1).format('MM-dd-yyyy'));
		ref.getParameters().put('surveyType','');
		ref.getParameters().put('toDate',Datetime.now().format('MM-dd-yyyy'));
		Test.setCurrentPage(ref);
	
		VO_Specific_Statistics_Excel_CTRL webPage = new VO_Specific_Statistics_Excel_CTRL();
	}

	
}