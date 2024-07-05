/**
    @Author : ouramdane.aouci
    Desc:     test class for Diduenjoy_FeedbackTriggerHandler
    V 1.0 :   12/06/2023
*/
@isTest
private class Diduenjoy_FeedbackTriggerHandler_Test {
    
    @testSetup
    private static void setup(){
        
        Test.loadData(VO_Config__c.sobjectType, 'VO_Config_TestCLS');
        User usr = IC_TestFactory.createUser('dreamuserLV@lvtest.com');
        usr.profileId = IC_UTILS.getSAProfile();
        usr.DefaultStore__c = 'LV Paris';
        usr.DREAMId__c = '123456';
        usr.isactive = true;
        INSERT usr;
        
        VO_Config__c cs = new VO_Config__c(Name = 'NUM OF Q', Value__c = '50');
        INSERT cs;
        
        List<Account> accList = new List<Account>();
        for(Integer i=1; i<=3; i++){
            Account acc = IC_TestFactory.createAccount();
            acc.DREAMID__c = '12345678'+i;
            accList.add(acc);
        }
        INSERT accList;
        
        List<Store__c> storesList = new List<Store__c>();
        Store__c st1 = new Store__c(Name='Store AS', RetailStoreId__c = 'A07');  storesList.add(st1);
        INSERT storesList;
        
        List<due__Diduenjoy_Feedback__c> feedbacksList = new List<due__Diduenjoy_Feedback__c>();
        //Retail Post Purchase
        for(Integer i=1; i<=3; i++){
            feedbacksList.add(new due__Diduenjoy_Feedback__c(Name='FeedBack_'+i, due__CreatedAt__c = DateTime.newInstance(2023,06,15), due__Profile__c = 'NPS',
                                                             due__Permalink__c = 'www.feedback.fdbk'+i, due__Comment__c='Comment test '+i,due__Status__c='live',
                                                             due__Solved__c = false, due__InternalId__c='9348-ebbef4a31f5'+i,
                                                             due__Segments__c = 'survey-name: Retail Post Purchase\r\nclient_dream_id:12345678'+i
                                                             + '\r\ntransaction_id:1239'+i+'\r\nadvisor_ww_id:LVM03075'+i+'\r\nrespondent_profile:Score '+i, 
                                                             due__User__c = usr.Id, due__Account__c = accList[i-1].Id, treated__c=true));										
        }
        INSERT feedbacksList;
        
        //Insert some Surveys
        List<VO_Survey__c> voList =new List<VO_Survey__c>();
        voList.add( new VO_Survey__c(DreamIDText__c = '123456781', IDTransaction__c='12391', FeedbackID__c='9348-ebbef4a31f51', Answer_DateTime__c=DateTime.newInstance(2023,06,15), Status__c='live', Solved__c=false));
        voList.add( new VO_Survey__c(DreamIDText__c = '123456782', IDTransaction__c='12392', FeedbackID__c='9348-ebbef4a31f52', Answer_DateTime__c=DateTime.newInstance(2023,06,15), Status__c='live', Solved__c=false));
        voList.add( new VO_Survey__c(DreamIDText__c = '123456783', IDTransaction__c='12393', FeedbackID__c='9348-ebbef4a31f53', Answer_DateTime__c=DateTime.newInstance(2023,06,15), Status__c='live', Solved__c=false));
        INSERT voList;
        
    }
    
    @isTest
    private static void testAfterUpdateFeedback(){
        System.debug('Launch test ...');
        System.assertEquals(3, [SELECT count() FROM due__Diduenjoy_Feedback__c WHERE Treated__c = true], 'DUE Feedback');
        System.assertEquals(3, [SELECT count() FROM VO_Survey__c], 'VO_Survey');
        
        Test.startTest();
        List<due__Diduenjoy_Feedback__c> feedbackList = [SELECT Id, due__Status__c, due__Solved__c, due__Last_Resolution_Date__c FROM due__Diduenjoy_Feedback__c];
        if(feedbackList.size() > 0){
            feedbackList[0].due__Status__c = 'deleted';
            feedbackList[1].due__Solved__c = true;
            feedbackList[1].due__Last_Resolution_Date__c = DateTime.newInstance(2023,06,15);
            feedbackList[2].due__Comment__c = 'test';
            
            UPDATE feedbackList;
        }   
        Test.stopTest();
        
        for(VO_Survey__c vo : 	[SELECT Id, DreamIDText__c, Status__c, Solved__c, LastResolutionDate__c FROM VO_Survey__c]){
            System.debug(vo);
        }
    }
}