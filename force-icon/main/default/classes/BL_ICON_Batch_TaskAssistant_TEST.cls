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
        TaskAssistant__c task3 = new TaskAssistant__c(ToDoType__c = 'first rtw purchase', WWEmployeeNumber__c = '987654321', StoreCode__c = 'AAA', IsArchieved__c = true, DueDate__c = Date.today().addDays(5)) ;
        insert new List<TaskAssistant__c>{task, task1, task3};   
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
        System.schedule('testSechdulerBatchPurgeTaskAssistant', cron, schd);
        Test.stopTest();
    }
    @isTest
    public static void testSechdulerBatchArchivedTaskAssistant() {
        Test.startTest();
        BL_ICON_Scheduler_Batch_ArchiveAssistant schd = new BL_ICON_Scheduler_Batch_ArchiveAssistant();
        String cron = '0 0 23 * * ?';
        System.schedule('testSechdulerBatchArchivedTaskAssistant', cron, schd);
        Test.stopTest();
    }

    @isTest
    public static void testBatchArchiveTaskAssistant() {
        Test.startTest();
        BL_ICON_Batch_Archive_TaskAssistant batch = new BL_ICON_Batch_Archive_TaskAssistant();
        Database.executeBatch(batch);
    Test.stopTest();
    }

    @isTest
    public static void testBatchCorrectionTaskAssistant() {
        Test.startTest();

        TaskAssistant__c task = [SELECT ID FROM TaskAssistant__c WHERE dreamId__c = NULL] ;
        task.dreamId__c = '12345678';
        update task;

        BL_ICON_Batch_Correction_TaskAssistant batch = new BL_ICON_Batch_Correction_TaskAssistant();
        Database.executeBatch(batch);
        Test.stopTest();
    }
    @isTest
    public static void testSechdulerBatchCorrecttionTaskAssistant() {
        Test.startTest();
        BL_ICON_Batch_Correction_TaskAssistant schd = new BL_ICON_Batch_Correction_TaskAssistant();
        String cron = '0 0 23 * * ?';
        System.schedule('testSechdulerBatchCorrecttionTaskAssistant', cron, schd);
        Test.stopTest();
    }

}