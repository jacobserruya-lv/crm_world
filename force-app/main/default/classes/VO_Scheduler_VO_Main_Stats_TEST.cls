@isTest 
global with sharing class VO_Scheduler_VO_Main_Stats_TEST {

@testSetup
	static void SchedulerVOMainStatsTest(){

		Test.loadData(VO_Config__c.sobjectType, 'VO_Config_TestCLS');

		List<VO_Survey__c> surveyList = VO_data_Object_Creator_TEST.createSurvayList();
		List<Store__c> storeList = VO_data_Object_Creator_TEST.createStoreByNum(surveyList.size());
		

		List<VO_Survey__c> surveylist33 = new List<VO_Survey__c>();
		integer counter = 0;
		while(counter<33 && counter<surveyList.size()) {
		    surveylist33.add(surveyList[counter++]);
		}

		List<Store__c> storelist33 = new List<Store__c>();
		integer counter2 = 0;
		while(counter2<33 && counter2<storeList.size()) {
		    storelist33.add(storeList[counter2++]);
		}
		insert storelist33;
		
		for(Integer i = 0; i < storelist33.size(); i++)
		{
			surveylist33[i].Store__c = storelist33[i].id;
		}
		insert surveylist33;
    }
	
        @isTest static void test_method_two() {
            Test.startTest();
            VO_Scheduler_VO_Main_Statistics_BATCH bat = new VO_Scheduler_VO_Main_Statistics_BATCH();
            String sch = '20 30 8 10 2 ?';
			System.schedule('TEST1', sch, bat);
			System.assertEquals(33, [select count() from  VO_Survey__c WHERE Store__c != Null]);
            Test.stopTest();
        }
    }