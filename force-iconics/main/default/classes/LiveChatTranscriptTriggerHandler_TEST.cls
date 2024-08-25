@isTest
public class LiveChatTranscriptTriggerHandler_TEST {

@TestSetup
static void makeData(){
    
    Account acc = new Account();
    acc.LastName='Test123';
    acc.PrimaryCountry__pc='Korea';
    acc.PersonMobilePhone ='+82123456789';

    insert acc;
    system.debug(acc);
    
    LiveChatVisitor lcv = new LiveChatVisitor();
    insert lcv;
         
    

}
@isTest static void testMethod1() {
        
        Account acct = [SELECT Id ,PrimaryCountry__pc,PersonMobilePhone ,LastName ,Firstname2__pc ,LastModifiedDate  FROM Account WHERE Name='Test123' LIMIT 1];
        system.debug(acct);
    
        LiveChatVisitor lcv = [SELECT Id FROM LiveChatVisitor LIMIT 1];
    
        system.debug(acct);
        
        LiveChatTranscript lct = new LiveChatTranscript();
        lct.MobilePhone__c = '+82123456789';
        lct.LiveChatVisitorId = lcv.id;
        Test.StartTest();
            insert lct; 
        Test.StopTest();

        LiveChatTranscript liveChat = [select id,AccountId FROM LiveChatTranscript];    
        system.assertequals(acct.id,liveChat.AccountId);   



    }


}