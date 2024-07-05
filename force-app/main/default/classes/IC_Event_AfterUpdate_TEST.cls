@isTest
public class IC_Event_AfterUpdate_TEST {

    public static Account acc; 
    public static Event evt;
    public static Date lstContactedate;
    public static List<Account> accountList = new List<Account>();
    
    static void init(){
       
        acc = IC_TestFactory.createAccount();
        insert acc;
        evt = IC_TestFactory.createEvent(acc);
        evt.ActivityDate = System.today().addDays(-10);
        insert new ICONSettings__c(AccLastContactTimeRange__c=30);
        insert evt;
   
    }
    
    static testMethod void testTrigger(){
        
        init();
        Test.startTest();
        update evt;
        accountList = [SELECT LastContactDate__pc FROM Account WHERE Id = :acc.Id];
  //      System.assertEquals(accountList.get(0).LastContactDate__pc, evt.ActivityDate);
        Test.stopTest();
    }
}