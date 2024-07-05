/**
BW - 10/11/2015
 */
@isTest
private class VO_BatchEmailAlert_Test {
    static testMethod void myUnitTest() {
    	Test.loadData(VO_Config__c.sobjectType, 'VO_Config_TestCLS');
        User usr = IC_TestFactory.createUser('batchEmailAlert@lvtest.com');
	  	usr.profileId = IC_UTILS.getSysAdminProfile();
	  	usr.email = 'xxx@noemail.com';
	  	usr.DefaultStore__c = 'P3';
	  	//usr.UserRoleId = role.Id;
	  	usr.DREAMId__c = '123456';
	  	usr.isactive = true;
	  	insert usr;
		VO_Config__c cfg = new VO_Config__c(Name='EmailAlertUserGroup', Value__c='VoiceStoreManager');
		insert cfg;
	  	VO_Config__c cs = new VO_Config__c(Name = 'NUM OF Q', Value__c = '50');
	  	insert cs;
//		Group gr = new Group(Name='VoiceStoreManager', DeveloperName = 'VoiceStoreManager');
//		insert gr;
//		GroupMember gm = new GroupMember(GroupId = gr.Id, UserOrGroupId=usr.Id );
//		insert gm;
    	Account acc = IC_TestFactory.createAccount();
		acc.DREAMID__c = '14712';
		insert acc;
		Store__c st = new Store__c(Name='STLesChamps', RetailStoreId__c = 'P3');
		insert st;
		ICONSettings__c iconSet = new ICONSettings__c();
		iconSet.ExcepPurchaseUSD__c=70;
		iconSet.Exceptional_Purchase_Currency__c='USD';	
		insert iconSet;
		VO_Survey__c srv = new VO_Survey__c(Scoring__c='Recovery act', StoreID__c='P3', Store__c = st.Id ,DreamIDText__c = '14712', AnswerDate__c = Date.today());
		insert srv;
		VO_Survey__c srv2 = new VO_Survey__c(Scoring__c='Delighted client', StoreID__c='P3', Store__c = st.Id ,DreamIDText__c = '14712', AnswerDate__c = Date.today());
		insert srv2;
		Test.startTest();
		VO_BatchEmailAlert cl = new VO_BatchEmailAlert();
		Database.executeBatch(cl, 40);
    }
}