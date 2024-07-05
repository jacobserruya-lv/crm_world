@isTest
public with sharing class MP_Mark_as_read_China_PushNotif_TEST {
    @IsTest static void testNotifBatch() {
		User u = IC_Test_Common.prepareTestUser('ICON_SA');
        u.MGMT_ZONE_SUB_LEVEL1__c = '1071';
        u.DefaultStore__c = '1234';
        insert u;
      
        system.runAs(u){
            Push_Notification_Item__c notifItem = new Push_Notification_Item__c(Is_Silent_Push__c=false, Type__c='Client');
            insert notifItem;
            Datetime d = Datetime.now().addDays(-8);
            Push_Notification_Recipient__c notif = new Push_Notification_Recipient__c (userId__c = u.Id, IsRead__c = False, Push_Notification_Item__c = notifItem.id, createdDate=d);
            insert notif;

            Test.startTest();

            MP_Mark_as_read_China_PushNotifications batch = new MP_Mark_as_read_China_PushNotifications();
            Database.executeBatch(batch);

            Test.stopTest();

            notif = [Select Id, IsRead__c from Push_Notification_Recipient__c where Id = :notif.Id];
            system.assertEquals(notif.IsRead__c, True);
        }
    }
}