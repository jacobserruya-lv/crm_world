@isTest
public class TaskAssistantTriggerHandler_TEST {

    @isTest
    static void handleAfterInsertUpdate_TEST(){
        Account acc =  new Account(LastName = 'test', DREAMID__c = '12345678');
        insert acc;
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = 'AAA');
        insert store;
        User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.WWEmployeeNumber__c = '987654321';
        insert u;
        Test.startTest();
        	TaskAssistant__c task = new TaskAssistant__c(ToDoType__c = 'first rtw purchase', WWEmployeeNumber__c = '987654321', StoreCode__c = 'AAA', dreamId__c = '12345678');
            insert task;
        Test.stopTest();
    }
}