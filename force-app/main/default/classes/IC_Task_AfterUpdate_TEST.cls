@isTest
public class IC_Task_AfterUpdate_TEST {
  
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
        insert tsk;
        
    }
    
    static testMethod void testTrigger(){
        
        init();
        Test.startTest();
        update tsk;
        accountList = [SELECT LastContactDate__pc FROM Account WHERE Id = :acc.Id];
        //System.assertEquals(accountList.get(0).LastContactDate__pc, tsk.ActivityDate);
        Test.stopTest();
    }
    static testMethod void CreateNotification() {
        // Init data
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSC_Call').getRecordTypeId();
        init();
        Task t = ICX_TestFactory.creatCallTaskOnAccount(acc.Id);
        // Test
       
        t.recordTypeId = recordTypeId;
        t.CallType = 'Inbound';
        t.ICX_Country__c='USA';
        insert t;

        Test.startTest();
        t.Resolution__c='Immediate Response';
        update t;
        Test.stopTest();       
        
        // Check
        //     
             
        List<Notification_Settings__mdt> notificationSettings = [select id,DeveloperName ,Is_Active__c from Notification_Settings__mdt where DeveloperName ='VOICE_AFTER_CALL_SURVEY'  and Is_Active__c=true];
        integer numOfNotif= 0;
        List<Notification__c> notif = [select id from notification__c];
        if(!notificationSettings.isEmpty()){
           numOfNotif= 1;
        }
        System.assertEquals(numOfNotif, notif.size());


    }
}