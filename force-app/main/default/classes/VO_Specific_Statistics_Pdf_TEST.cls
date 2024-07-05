/**
 * This is a test class for VO_Specific_Statistics_Pdf_CTRL class
 * @createdBy           Menash
 * @lastModifiedBy      Nadav Lichtenshtein, 11-2-2016
 */
@isTest	(seeAllData=false)
private class VO_Specific_Statistics_Pdf_TEST {
	
	/**
	* [Set database]
	* @scenario    		[insert objects to the system]
	* @result           [database to work with]
	* @createdBy        Menash
    * @lastModifiedBy 	Menash
	*/
	@testSetup
	static void initDate()
	{
       Test.loadData(VO_Config__c.sobjectType, 'VO_Config_TestCLS');
        VO_Config__c cs = new VO_Config__c(Name = 'PDF PPRODUCT LIMIT', Value__c = '400');
        insert cs;
        VO_Config__c cs2 = new VO_Config__c(Name = 'NUM OF Q', Value__c = '50');
        insert cs2;
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
	
	/**
	* [initIdLists test initIdLists function]
	* @scenario    		[call initIdLists, there is no surveys to return because for loop begin from 0 and not 1]
	* @result           []
	* @createdBy        Menash
	* @lastModifiedBy 	Menash
	*/
	@isTest 
	static void initIdLists() 
	{
		List<VO_Survey__c> surveyList = [SELECT id FROM VO_Survey__c ];
		PageReference ref = Page.VO_Specific_Statistics_Pdf;

		ref.getParameters().put('size','1');
		ref.getParameters().put('1',surveyList[0].id+'');

		Test.setCurrentPage(ref);

		VO_Specific_Statistics_Pdf_CTRL webPage = new VO_Specific_Statistics_Pdf_CTRL();

	}

	/**
	* [initLengthOfIdsException test initLengthOfIds function catch]
	* @scenario    		[call initLengthOfIds tries to get the parameter 'size' from the url and fails]
	* @result           [exception occours]
	* @createdBy        Nadav Lichtenshtein, 11-2-2016
	* @lastModifiedBy 	Nadav Lichtenshtein, 11-2-2016
	*/
	@isTest 
	static void initLengthOfIdsException() 
	{
		VO_Specific_Statistics_Pdf_CTRL webPage = new VO_Specific_Statistics_Pdf_CTRL();
	}

	/**
	* [testFlow test the flow]
	* @scenario    		[testFlow test the flow]
	* @result           []
	* @createdBy        Nadav Lichtenshtein, 11-2-2016
	* @lastModifiedBy 	Nadav Lichtenshtein, 11-2-2016
	*/
	@isTest 
	static void testFlow() 
	{
		List<VO_Survey__c> surveyList = [SELECT id FROM VO_Survey__c ];
		System.debug('SFDC surveyList: ' + surveyList);
		PageReference ref = Page.VO_Specific_Statistics_Pdf;

		ref.getParameters().put('size','1');
		ref.getParameters().put('0',surveyList[0].id);

		Test.setCurrentPage(ref);

		System.debug('SFDC URL: ' + ApexPages.currentPage().getUrl());

		VO_Specific_Statistics_Pdf_CTRL webPage = new VO_Specific_Statistics_Pdf_CTRL();

	}
	
}