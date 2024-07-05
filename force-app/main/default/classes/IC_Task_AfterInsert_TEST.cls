@isTest(seeAllData=false)
public class IC_Task_AfterInsert_TEST {
  
    public static Account acc; 
    public static Task tsk;
    public static Date lstContactedate;
    public static List<Account> accountList = new List<Account>();
    
    static void init(){
       
        acc = IC_TestFactory.createAccount();
        insert acc;
        tsk = IC_TestFactory.createTask(acc);
        tsk.RecordTypeId = IC_UTILS.getTaskRT();
        insert new ICONSettings__c(AccLastContactTimeRange__c=30);
    }
    
    static testMethod void testTrigger(){
        
        init();
        
        Test.startTest();
        insert tsk;
        accountList = [SELECT LastContactDate__pc FROM Account WHERE Id = :acc.Id];
        //System.assertEquals(accountList.get(0).LastContactDate__pc, tsk.ActivityDate);
        Test.stopTest();
    }
       
}