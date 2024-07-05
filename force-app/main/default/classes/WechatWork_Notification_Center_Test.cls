@isTest
public class WechatWork_Notification_Center_Test {
    @IsTest static void testNotification_Center() {
		User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.DefaultStore__c = '1234';
        insert u;
        Account acc = IC_TestFactory.createAccount();
        insert acc;
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
        insert store;
        List<Event> lstEvent = new List<Event>();
        Event ev1= IC_TestFactory.createEvent(acc);
        ev1.Status__c = 'Assigned';
        ev1.OwnerId = u.id;
        insert ev1;
        Event ev2= IC_TestFactory.createEvent(acc);
        ev2.RecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();
        ev2.Status__c = 'Not Assigned';
        ev2.Store_Location__c = store.Id;
        insert ev2;
        Event ev3= IC_TestFactory.createEvent(acc);
        ev3.Status__c = 'Cancelled';
        ev3.OwnerId = u.id;
        insert ev3;
        lstEvent.add(ev1);
        lstEvent.add(ev2);
        lstEvent.add(ev3);
        Map<Id, Account> clients = new Map<Id,Account>();
        clients.put(acc.Id, acc);
        WechatWork_Notification_Center.WCW_OSA_notification(lstEvent, clients);
    }
    
}