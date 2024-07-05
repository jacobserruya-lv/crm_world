@isTest
public class DUE_AnswerTriggerHandler_TEST {
    @isTest
    static void testMethodSetup(){
        Account acc = new Account(LastName = 'test');
		insert acc;
        User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = '1234';
        u.DefaultStore__c = 'A06';
        u.WWEmployeeNumber__c = 'WW198765467';
		insert u;
        
        due__Diduenjoy_Feedback__c feed = new due__Diduenjoy_Feedback__c();
        feed.due__InternalId__c = '12345';
        feed.due__CreatedAt__c = Date.today();
        feed.due__Permalink__c  = 'www.test.com';
        feed.due__Profile__c = 'testProfile';
        insert feed;
        
        VO_Survey__c survey = new VO_Survey__c();
        
        
        system.runAs(u) {
            Test.startTest();
            due__Diduenjoy_Answer__c ans = new due__Diduenjoy_Answer__c();
        ans.due__Step__c = 1;
        ans.due__Position__c = 0;
        ans.due__Diduenjoy_Feedback__c = feed.id;
            ans.due__Question__c = 'question';
            ans.due__Question_Type__c = 'rating';
            ans.due__Score__c = 4;
            insert ans;
            
            ans.due__Score__c = 3;
            update ans;
            Test.stopTest();
        }
        
    }

}