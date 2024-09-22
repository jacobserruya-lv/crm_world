@isTest
public class BL_ICON_Batch_TaskAssistant_TEST {

    @TestSetup
    static void makeData(){
        Account acc =  new Account(LastName = 'test', DREAMID__c = '12345678');
        insert acc;
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = 'AAA');
        insert store;
        User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.WWEmployeeNumber__c = '987654321';
        insert u;
        TaskAssistant__c task = new TaskAssistant__c(ToDoType__c = 'first rtw purchase', WWEmployeeNumber__c = '987654321', StoreCode__c = 'AAA', dreamId__c = '12345678', IsArchieved__c = false, DueDate__c = Date.today().addDays(-6)) ;
        TaskAssistant__c task1 = new TaskAssistant__c(ToDoType__c = 'first rtw purchase', WWEmployeeNumber__c = '987654321', StoreCode__c = 'AAA', dreamId__c = '12345678', IsArchieved__c = true, DueDate__c = Date.today().addDays(-40)) ;

        insert new List<TaskAssistant__c>{task, task1};   
    }

    @isTest
    public static void testBatchPurgeTaskAssistant() {
        Test.startTest();
        BL_ICON_Batch_Purge_TaskAssistant batch = new BL_ICON_Batch_Purge_TaskAssistant();
        Database.executeBatch(batch);
        Test.stopTest();
    }

    @isTest
    public static void testSechdulerBatchPurgeTaskAssistant() {
        Test.startTest();
        BL_ICON_Scheduler_Batch_Purge_Assistant schd = new BL_ICON_Scheduler_Batch_Purge_Assistant();
        String cron = '0 0 23 * * ?';
        System.schedule('BL_ICON_Scheduler_Batch_Purge_Assistant', cron, schd);
        Test.stopTest();
    }
    @isTest
    public static void testSechdulerBatchArchivedTaskAssistant() {
        Test.startTest();
        BL_ICON_Scheduler_Batch_ArchiveAssistant schd = new BL_ICON_Scheduler_Batch_ArchiveAssistant();
        String cron = '0 0 23 * * ?';
        System.schedule('BL_ICON_Scheduler_Batch_ArchiveAssistant', cron, schd);
        Test.stopTest();
    }

    @isTest
    public static void testBatchArchiveTaskAssistant() {
        Test.startTest();
        BL_ICON_Batch_Archive_TaskAssistant batch = new BL_ICON_Batch_Archive_TaskAssistant();
        Database.executeBatch(batch);
        Test.stopTest();
    }
}