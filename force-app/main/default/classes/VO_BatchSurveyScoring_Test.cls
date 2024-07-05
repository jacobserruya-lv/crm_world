/*
To test VO_BatchSurveyScoring
Created by BW
Creation date : 30/10/2015
*/

@isTest
private class VO_BatchSurveyScoring_Test {

    static testMethod void myUnitTest() {
    	Test.loadData(VO_Config__c.sobjectType, 'VO_Config_TestCLS');
        User usr = IC_TestFactory.createUser('dreamuserLV165E38@lvtest.com');
	  	usr.profileId = IC_UTILS.getSysAdminProfile();
	  	usr.DefaultStore__c = 'LV GUADALAJARA PALACIO DE HIERRO';
	  	//usr.UserRoleId = role.Id;
	  	usr.DREAMId__c = '123456';
	  	usr.isactive = true;
	  	insert usr;
	  	VO_Config__c cs = new VO_Config__c(Name = 'NUM OF Q', Value__c = '50');
	  	insert cs;
    	Account acc = IC_TestFactory.createAccount();
		acc.DREAMID__c = '14712';
		insert acc;
		Store__c st = new Store__c(Name='STLesChamps', RetailStoreId__c = 'P3');
		insert st;
		ICONSettings__c iconSet = new ICONSettings__c();
		iconSet.ExcepPurchaseUSD__c=70;
		iconSet.Exceptional_Purchase_Currency__c='USD';	
		insert iconSet;
		PPR_PurchProduct__c pp = new PPR_PurchProduct__c(Client__c=acc.Id, TransactionRMSId__c='123',
			PurchasedDate__c = System.Today(),
			ProductLine__c = 'Shoes',
			SKU__c = '1515',
			TicketNumber__c = '789',
			Amount__c = 1000,
			ConvertedAmountUSD__c = 1000,
			SA__c=usr.id);
		insert pp; 
		VO_Survey__c srv = new VO_Survey__c(SurveyType__c=VO_Utils.VOICE_WEB_SALES, StoreID__c='P3', DreamIDText__c = '14712', IDTransaction__c='123', Scoring__c = '', AnswerDate__c = Date.newInstance(2015,10,01));
		VO_Survey__c srv2 = new VO_Survey__c(SurveyType__c=VO_Utils.VOICE_CSC_SALES, StoreID__c='P3', DreamIDText__c = '14712', IDTransaction__c='123', Scoring__c = '', AnswerDate__c = Date.newInstance(2015,10,01));
		VO_Survey__c srv3 = new VO_Survey__c(SurveyType__c=VO_Utils.VOICE_SALES, StoreID__c='P3', DreamIDText__c = '14712', IDTransaction__c='123', Scoring__c = '', AnswerDate__c = Date.newInstance(2015,10,01));
		VO_Survey__c srv4 = new VO_Survey__c(SurveyType__c=VO_Utils.VOICE_AFTER_SALES, StoreID__c='P3', DreamIDText__c = '14712', IDTransaction__c='123', Scoring__c = '', AnswerDate__c = Date.newInstance(2015,10,01));
		VO_SurveyScoring__c sc1 = new VO_SurveyScoring__c(SurveyType__c = VO_Utils.VOICE_WEB_SALES, StartDate__c = Date.newInstance(2015,10,01), EndDate__c = Date.newInstance(2015,10,01));
		VO_SurveyScoring__c sc2 = new VO_SurveyScoring__c(SurveyType__c = VO_Utils.VOICE_CSC_SALES, StartDate__c = Date.newInstance(2015,10,01), EndDate__c = Date.newInstance(2015,10,01));
		VO_SurveyScoring__c sc3 = new VO_SurveyScoring__c(SurveyType__c = VO_Utils.VOICE_SALES, StartDate__c = Date.newInstance(2015,10,01), EndDate__c = Date.newInstance(2015,10,01));
		VO_SurveyScoring__c sc4 = new VO_SurveyScoring__c(SurveyType__c = VO_Utils.VOICE_AFTER_SALES, StartDate__c = Date.newInstance(2015,10,01), EndDate__c = Date.newInstance(2015,10,01));

		insert new List<VO_Survey__c>{srv ,srv2,srv3,srv4};
		srv.Scoring__c = 'x';
		srv2.Scoring__c = 'x';
		srv3.Scoring__c = 'x';
		srv4.Scoring__c = 'x';
		update new List<VO_Survey__c>{srv ,srv2,srv3,srv4};

		insert new List<VO_SurveyScoring__c>{sc1 ,sc2,sc3,sc4};
		
		VO_BatchSurveyScoring.startBatch(sc1.Id, 200);
		VO_BatchSurveyScoring.startBatch(sc2.Id, 200);
		VO_BatchSurveyScoring.startBatch(sc3.Id, 200);
		VO_BatchSurveyScoring.startBatch(sc4.Id, 200);
    }
}