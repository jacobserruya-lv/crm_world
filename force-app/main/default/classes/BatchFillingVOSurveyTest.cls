/**
    @Author : ouramdane.aouci
    Desc :     test class for BatchFillingVOSurvey
    V 2.0 :   01/04/2023
	Update:   20/10/2023 (creation and mapping of new fields for a new feedback types - SV-208,SV-172)
*/
@isTest
private class BatchFillingVOSurveyTest {
    
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
        for(Integer i=1; i<=8; i++){
            Account acc = IC_TestFactory.createAccount();
            acc.DREAMID__c = '12345678'+i;
            accList.add(acc);
            
        }
        INSERT accList;
        
        List<Store__c> storesList = new List<Store__c>();
        Store__c st1 = new Store__c(Name='Store AS', RetailStoreId__c = 'A06');  storesList.add(st1);
        Store__c st2 = new Store__c(Name='Store Web', RetailStoreId__c = 'WFR'); storesList.add(st2);
        Store__c st3 = new Store__c(Name='Store Csc', RetailStoreId__c = 'A90'); storesList.add(st3);
        INSERT storesList;

        List<due__Diduenjoy_Feedback__c> feedbacksList = new List<due__Diduenjoy_Feedback__c>();
        
        //Retail Post Purchase
        for(Integer i=1; i<=2; i++){
            feedbacksList.add(new due__Diduenjoy_Feedback__c(Name='FeedBack_'+i, due__CreatedAt__c = DateTime.newInstance(2023,04,10), due__Profile__c = 'NPS',
                                                             due__Permalink__c = 'www.feedback.fdbk'+i, due__Comment__c='Comment test '+i,due__Status__c='live',
                                                             due__Solved__c = true, due__InternalId__c='76bd64e5-e08d-46c4-9348-ebbef4a31f5'+i,
                                                             due__Segments__c = 'survey-name: Retail Post Purchase\r\nsurvey_submitted:yes\r\nclient_dream_id:12345678'+i+'\r\nstore_code:WFR'
                                                             + '\r\ntransaction_id:1234567899999'+i+'\r\nadvisor_ww_id:LVM03075'+i+'\r\nrespondent_profile:Score '+i, 
                                                             due__User__c = usr.Id, due__Account__c = accList[i-1].Id));										
        }

        //Case: Empty due__Segments__c field
        feedbacksList.add(new due__Diduenjoy_Feedback__c(Name='FeedBack_3', due__CreatedAt__c = DateTime.newInstance(2023,04,11), due__Profile__c = 'NPS',
                                                         due__Permalink__c = 'www.feedback.fdbk', due__Comment__c='Comment test 3',due__Status__c='live',
                                                         due__InternalId__c='76bd64e5-e08d-46c4-9348-ebbef4a31f53',
                                                         due__Segments__c = '',  
                                                         due__User__c = usr.Id, due__Account__c = accList[0].Id));
        
        //Case: Missing segment__c field param client_dream_id/survey-name
        feedbacksList.add(new due__Diduenjoy_Feedback__c(Name='FeedBack_4', due__CreatedAt__c = DateTime.newInstance(2023,04,12), due__Profile__c = 'NPS',
                                                         due__Permalink__c = 'www.feedback.fdbk', due__Comment__c='Comment test',due__Status__c='live',
                                                         due__InternalId__c='76bd64e5-e08d-46c4-9348-ebbef4a31f54',
                                                         due__Segments__c = 'client_dream_id:123456781'
                                                         + '\r\ntransaction_id:12345678999993\r\nadvisor_ww_id:LVM030756\r\nrespondent_profile:Score 2',  
                                                         due__User__c = usr.Id, due__Account__c = accList[0].Id));
        
        //Case: Empty transaction_id segment
        feedbacksList.add(new due__Diduenjoy_Feedback__c(Name='FeedBack_5', due__CreatedAt__c = DateTime.newInstance(2023,04,14), due__Profile__c = 'NPS',
                                                         due__Permalink__c = 'www.feedback.fdbk', due__Comment__c='test',due__Status__c='live',
                                                         due__InternalId__c='76bd64e5-e08d-46c4-9348-ebbef4a31f55',
                                                         due__Segments__c = 'survey-name: Retail Post Purchase\r\nsurvey_submitted:yes\r\nclient_dream_id:123456781'
                                                         + '\r\nadvisor_ww_id:LVM030756\r\nrespondent_profile:Score 1',  
                                                         due__User__c = usr.Id, due__Account__c = accList[0].Id));
        
        //Case: survey-name != Retail Post Purchase 
        feedbacksList.add(new due__Diduenjoy_Feedback__c(Name='FeedBack_6', due__CreatedAt__c = DateTime.newInstance(2023,04,24), due__Profile__c = 'NPS',
                                                         due__Permalink__c = 'www.feedback.fdbk', due__Comment__c='Comment type',due__Status__c='live',
                                                         due__InternalId__c='76bd64e5-e08d-46c4-9348-ebbef4a31f56',
                                                         due__Segments__c = 'survey-name: Online Post Payment\r\nsurvey_submitted:yes\r\nclient_dream_id:123456781'
                                                         + '\r\ntransaction_id:12345678999995\r\nadvisor_ww_id:LVM030756\r\nrespondent_profile:Score 1-3',  
                                                         due__User__c = usr.Id, due__Account__c = accList[0].Id));
        
        //Case: Empty due__InternalId__c field 
        feedbacksList.add(new due__Diduenjoy_Feedback__c(Name='FeedBack_7', due__CreatedAt__c = DateTime.newInstance(2023,05,12), due__Profile__c = 'NPS',
                                                         due__Permalink__c = 'www.feedback.fdbk', due__Comment__c='Comment test empty dueInternalId',due__Status__c='live',
                                                         due__InternalId__c='',
                                                         due__Segments__c = 'survey-name: Retail Post Purchase\r\nsurvey_submitted:yes\r\nclient_dream_id:123456781'
                                                         + '\r\ntransaction_id:12345678999996\r\nadvisor_ww_id:LVM030756\r\nrespondent_profile:Score 2',  
                                                         due__User__c = usr.Id, due__Account__c = accList[0].Id));
        
        //CSC Post Contact
        feedbacksList.add(new due__Diduenjoy_Feedback__c(Name='FeedBack_'+8, due__CreatedAt__c = DateTime.newInstance(2023,07,27), due__Profile__c = 'NPS',
                                                         due__Permalink__c = 'www.feedback.fdbk', due__Comment__c='CSC Comment test',due__Status__c='live',
                                                         due__Solved__c = true, due__InternalId__c='76bd64e5-e08d-46c4-9348-ebbef4a31f58',
                                                         due__Segments__c = 'survey-name: CSC Post Contact\r\nsurvey_submitted:yes\r\nclient_dream_id:123456783'
                                                         + '\r\ntask_id:00T6S00007K3pBbUAJ\r\nadvisor_ww_id:LVM030758\r\nrespondent_profile:Score 1-3', 
                                                         due__User__c = usr.Id, due__Account__c = accList[2].Id));
        
        //Case -CSC: Empty task_id segment
        feedbacksList.add(new due__Diduenjoy_Feedback__c(Name='FeedBack_'+9, due__CreatedAt__c = DateTime.newInstance(2023,07,27), due__Profile__c = 'NPS',
                                                         due__Permalink__c = 'www.feedback.fdbk', due__Comment__c='CSC empty task_id',due__Status__c='live',
                                                         due__Solved__c = true, due__InternalId__c='76bd64e5-e08d-46c4-9348-ebbef4a31f59',
                                                         due__Segments__c = 'survey-name: CSC Post Contact\r\nsurvey_submitted:yes\r\nclient_dream_id:123456783'
                                                         + '\r\nadvisor_ww_id:LVM030758\r\nrespondent_profile:Score 2', 
                                                         due__User__c = usr.Id, due__Account__c = accList[2].Id));
        //Case: feedback not submitted
        feedbacksList.add(new due__Diduenjoy_Feedback__c(Name='FeedBack_'+10, due__CreatedAt__c = DateTime.newInstance(2023,09,09), due__Profile__c = 'NPS',
                                                         due__Permalink__c = 'www.feedback.fdbk', due__Comment__c='Feedback not submitted',due__Status__c='live',
                                                         due__Solved__c = true, due__InternalId__c='76bd64e5-e08d-46c4-9348-ebbef4a31f60',
                                                         due__Segments__c = 'survey-name: CSC Post Contact\r\nsurvey_submitted:no\r\nclient_dream_id:123456783'
                                                         + '\r\ntask_id:00T6S00007K3pBbUAJ\r\nadvisor_ww_id:LVM030758\r\nrespondent_profile:Score 1-3', 
                                                         due__User__c = usr.Id, due__Account__c = accList[2].Id));
		
        //Online Post Delivery
        feedbacksList.add(new due__Diduenjoy_Feedback__c(Name='FeedBack_'+11, due__CreatedAt__c = DateTime.newInstance(2023,10,01), due__Profile__c = 'NPS',
                                                         due__Permalink__c = 'www.feedback.fdbk', due__Comment__c='New Online Post Delivery',due__Status__c='live',
                                                         due__Solved__c = true, due__InternalId__c='76bd64e5-e08d-46c4-9348-ebbef4a31f61',
                                                         due__Segments__c = 'survey-name: Online Post Delivery\r\nsurvey_submitted:yes\r\nclient_dream_id:123456783'
                                                         + '\r\nrequest_id:AS61Z71\r\nrespondent_profile:Score 1-3\r\norder_id:AS75A8', 
                                                         due__User__c = usr.Id, due__Account__c = accList[2].Id));
        
        //Case: Online Post Delivery (Empty request_id segment)
        feedbacksList.add(new due__Diduenjoy_Feedback__c(Name='FeedBack_'+12, due__CreatedAt__c = DateTime.newInstance(2023,10,02), due__Profile__c = 'NPS',
                                                         due__Permalink__c = 'www.feedback.fdbk', due__Comment__c='New Online Post Delivery',due__Status__c='live',
                                                         due__Solved__c = true, due__InternalId__c='76bd64e5-e08d-46c4-9348-ebbef4a31f62',
                                                         due__Segments__c = 'survey-name: Online Post Delivery\r\nsurvey_submitted:yes\r\nclient_dream_id:123456783'
                                                         + '\r\nrespondent_profile:Score 4', 
                                                         due__User__c = usr.Id, due__Account__c = accList[2].Id));
        
        //Retail Care Service
        feedbacksList.add(new due__Diduenjoy_Feedback__c(Name='FeedBack_'+13, due__CreatedAt__c = DateTime.newInstance(2023,10,03), due__Profile__c = 'NPS',
                                                         due__Permalink__c = 'www.feedback.fdbk', due__Comment__c='New Retail Care Service',due__Status__c='live',
                                                         due__Solved__c = true, due__InternalId__c='76bd64e5-e08d-46c4-9348-ebbef4a31f63',
                                                         due__Segments__c = 'survey-name: Retail Care Service\r\nsurvey_submitted:yes\r\nclient_dream_id:123456783'
                                                         + '\r\nrepair_id:o177357651\r\nrespondent_profile:Score 1-3', 
                                                         due__User__c = usr.Id, due__Account__c = accList[2].Id));
        
        //Case: Retail Care Service (Empty repair_id segment)
        feedbacksList.add(new due__Diduenjoy_Feedback__c(Name='FeedBack_'+14, due__CreatedAt__c = DateTime.newInstance(2023,10,04), due__Profile__c = 'NPS',
                                                         due__Permalink__c = 'www.feedback.fdbk', due__Comment__c='New Retail Care Service',due__Status__c='live',
                                                         due__Solved__c = true, due__InternalId__c='76bd64e5-e08d-46c4-9348-ebbef4a31f64',
                                                         due__Segments__c = 'survey-name: Retail Care Service\r\nsurvey_submitted:yes\r\nclient_dream_id:123456783'
                                                         + '\r\nrepair_id:\r\nrespondent_profile:Score 4', 
                                                         due__User__c = usr.Id, due__Account__c = accList[2].Id));
        
        INSERT feedbacksList;
    }
    
    @isTest
    private static void batchTest(){
        Test.startTest();
        BatchFillingVOSurveyScheduler myScheduler = new BatchFillingVOSurveyScheduler();
        String sch = '0 0 23 L * ?';
        system.schedule('Test check', sch, myScheduler);
        myScheduler.execute(null);
        //BatchFillingVOSurvey bfvos = new BatchFillingVOSurvey();
        //Id batchId = Database.executeBatch(bfvos);
        Test.stopTest();
        
        //Check the results
        //Ckeck if all Feedbacks are treated
        System.assertEquals(14, [SELECT count() FROM due__Diduenjoy_Feedback__c WHERE Treated__c = true], 'DUE Feedback');
        //Only some feedbacks will be synchronized with VO_Survey (contain all the expected data)
        System.assertEquals(5, [SELECT count() FROM VO_Survey__c], 'VO_Survey');
        
        for(VO_Survey__c vo : [SELECT Id, Answer_DateTime__c, SurveyType__c, OwnerId, CreatedById, DreamIDText__c, StoreID__c,
                               Status__c, Solved__c, LastResolutionDate__c, AdvisorWWId__c, RespondentProfile__c, SurveyComment__c,
                               IDTransaction__c, Task__c, RequestID__c, OrderID__c, RepairID__c, FeedbackID__c, Tech_Unique_Key__c 
                               FROM VO_Survey__c]){
                                   System.debug(vo);
                               }
    }
    
}