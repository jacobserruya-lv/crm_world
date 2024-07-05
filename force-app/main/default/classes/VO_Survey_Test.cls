/*
To test VO_Survey
Created by BW
Creation date : 01/10/2015
*/

@isTest
private class VO_Survey_Test {

    static testMethod void myUnitTest() {
    	Test.loadData(VO_Config__c.sobjectType, 'VO_Config_TestCLS');
        User usr = IC_TestFactory.createUser('dreamuserLV@lvtest.com');
	  	usr.profileId = IC_UTILS.getSAProfile();
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
		MergedClients__c mc = new MergedClients__c(MasterClient__c = '14712', Absorbed_DreamId__c = '14710');
		insert mc;
		ICONSettings__c iconSet = new ICONSettings__c();
		iconSet.ExcepPurchaseUSD__c=70;
		iconSet.Exceptional_Purchase_Currency__c='USD';	
		insert iconSet;
		PPR_PurchProduct__c pp = new PPR_PurchProduct__c(Client__c=acc.Id, TransactionRMSId__c='123',
			PurchasedDate__c = System.Today(),
			StoreRetailCode__c = 'P3',
			ProductLine__c = 'Shoes',
			SKU__c = '1515',
			TicketNumber__c = '789',
			Amount__c = 1000,
			ConvertedAmountUSD__c = 1000,
			SA__c=usr.id);
		insert pp; 
		system.debug('tes6');
		List<VO_Survey__c> listvo =new List<VO_Survey__c>();
		VO_Survey__c srv5 = new VO_Survey__c(ClientDreamID__c=acc.Id,AnswerDate__c=date.today()-1,Type__c='New');
		listvo.add(srv5);
		VO_Survey__c srv6 = new VO_Survey__c(ClientDreamID__c=acc.Id,AnswerDate__c=date.today(),Type__c='New');
		listvo.add(srv6);
		VO_Survey__c srv = new VO_Survey__c(SurveyType__c=VO_Utils.VOICE_WEB_SALES, StoreID__c='P3', DreamIDText__c = '14712', IDTransaction__c='123');
		listvo.add(srv);

		VO_Survey__c srv2 = new VO_Survey__c(SurveyType__c=VO_Utils.VOICE_CSC_SALES, StoreID__c='P3', DreamIDText__c = '14710', IDTransaction__c='123');
		listvo.add(srv2);

		VO_Survey__c srv3 = new VO_Survey__c(SurveyType__c=VO_Utils.VOICE_SALES, StoreID__c='P3', DreamIDText__c = '14710', IDTransaction__c='123');
		listvo.add(srv3);

		VO_Survey__c srv4 = new VO_Survey__c(SurveyType__c=VO_Utils.VOICE_AFTER_SALES, StoreID__c='P3', DreamIDText__c = '14712', IDTransaction__c='123');
		listvo.add(srv4);

		insert listvo;
    }
}