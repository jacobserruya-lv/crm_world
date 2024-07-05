@IsTest
public with sharing class Wecome_MP_Assistant_Notif_Batch_TEST {
    @IsTest static void testNotifBatch() {
        Id TaskTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('To_Do_Assistant').getRecordTypeId();
		User u = IC_Test_Common.prepareTestUser('ICON_SA');
        u.DefaultStore__c = '1234';
        u.WWEmployeeNumber__c='AAAA';
        insert u;
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
        insert store;
        system.runAs(u){
        List<Task> task = new List<Task>{ new Task( status = 'NEW', isBadged__c = false,  recordTypeId = TaskTypeId, To_do_type__c = 'Client'),
                                            new Task( status = 'NEW', isBadged__c = false, recordTypeId = TaskTypeId, To_do_type__c = 'Client Service')};
        insert task;
        Push_Notification_Item__c notifItem = new Push_Notification_Item__c(Is_Silent_Push__c=false, Type__c='Client');
        insert notifItem;
        Push_Notification_Recipient__c notif = new Push_Notification_Recipient__c (userId__c = u.Id, IsRead__c = False, Push_Notification_Item__c = notifItem.id );
        insert notif;

        Test.startTest();

        Wecome_MP_Assistant_Notification_Batch batch = new Wecome_MP_Assistant_Notification_Batch('Id = \''+ UserInfo.getUserId()+'\'');
        Database.executeBatch(batch);

        Test.stopTest();
        }
    }
    
}