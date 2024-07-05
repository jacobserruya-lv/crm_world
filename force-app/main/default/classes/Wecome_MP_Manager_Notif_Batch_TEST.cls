@IsTest
public with sharing class Wecome_MP_Manager_Notif_Batch_TEST {
    @IsTest static void testNotifBatch() {
		User u = IC_Test_Common.prepareTestUser('ICON_SA');
        u.DefaultStore__c = '1234';
        u.WWEmployeeNumber__c='AAAA';
        u.IsTechnicalUser__c= true;
        insert u;
        system.runAs(u){
        Account acc = IC_Test_Common.createAccount('12345');
        acc.isProspect__pc = false;
        acc.AttachedStore__pc = '1234';
        update acc;

        Test.startTest();

        Wecome_MP_Manager_Notification_Batch batch = new Wecome_MP_Manager_Notification_Batch('Id = \''+ UserInfo.getUserId()+'\'');
        Database.executeBatch(batch);

        Test.stopTest();
        }
    }
}