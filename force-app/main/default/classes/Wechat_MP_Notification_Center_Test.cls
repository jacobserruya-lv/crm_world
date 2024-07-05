@IsTest
public class Wechat_MP_Notification_Center_Test {
@IsTest static void testMPNotification_Center() {
		User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.DefaultStore__c = '1234';
        insert u;
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c);
        insert store;
		Notification__c n =  new Notification__c(Message_Id__c = 'OSAW2',External_Id__c = '32350c71-3464-405f-7ed4-8d57b33dc71d',application__c = 'WECHAT ONLINE APPOINTMENT');
        insert n;
        Map<String, Object> params = new Map<String, Object>{'date_osa'=>'test','local_name'=>'test','tech_address__c'=>'test','appointmentType'=>'Event'};
        Wechat_MP_Notification_Center.sendNotification(n,params);
    }
    
}