@isTest 
global with sharing class VO_Scheduler_VO_BatchEmailAlert_TEST {
    
    
    @testSetup
    static void initDate(){
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
        VO_Config__c cs = new VO_Config__c(Name = 'NUM OF Q', Value__c = '50');
        insert new List<VO_Config__c> {cfg,cs};
        
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
        VO_Survey__c srv2 = new VO_Survey__c(Scoring__c='Delighted client', StoreID__c='P3', Store__c = st.Id ,DreamIDText__c = '14712', AnswerDate__c = Date.today());
        insert new List<VO_Survey__c> {srv,srv2};
    }
    static testMethod void myUnitScheduleTest() {
        Test.startTest();
        VO_Scheduler_VO_BatchEmailAlert bat = new VO_Scheduler_VO_BatchEmailAlert();
        String sch = '20 30 8 10 2 ?';
        System.schedule('TEST1', sch, bat);
        Test.stopTest();
    }
}