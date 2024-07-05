@isTest
public class NotificationParameterTrigger_TEST {
    
    @isTest
    static void testChangeEventTrigger() {
        
        // Enable all Change Data Capture entities for notifications.
        Test.enableChangeDataCapture();
        
        // setup
        Notification__c notif = new Notification__c(
            Channel__c = 'EMAIL MARKETING CLOUD',
            Application__c = 'CARE SERVICE',
            Message_Id__c = 's1',
            Status__c = 'CREATED',
            External_Id__c = '12345678910',
            Country__c = 'GBR',
            Language__c = 'GBR'
        );
        insert notif;

        Notification_Parameter__c notifParam = new Notification_Parameter__c(
            Notification__c = notif.Id,
            Field__c = 'mylv_url',
            Type__c = 'TEXT',
            LongValue__c = 'https://account.louisvuitton.com/eng-gb/mylv/registration?campaign=e_careServiceCreation_content'
        );
        insert notifParam;

        // Call deliver to fire the trigger for the insert operation
        Test.getEventBus().deliver();
    }
}