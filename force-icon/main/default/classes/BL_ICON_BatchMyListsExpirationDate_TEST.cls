@isTest
public with sharing class BL_ICON_BatchMyListsExpirationDate_TEST {
    
    static testMethod void  BL_ICON_BatchMyListsExpirationDate_TEST() {
        User testUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_SYSTEM_ADMINNISTRATOR);
        testUser.BypassWF__c = true;
        testUser.BypassVR__c = true;
        testUser.Country__c = 'FRANCE';
        insert testUser;

        system.runAs(testUser) {

            CLI_CliList__c clientList = new CLI_CliList__c( ExpirationDate__c = Date.today().addDays(7), Name = '#May Client Birthdays#', OwnerId = testUser.id, IsMasterClientList__c = false, Type__c = 'Regular', TECH_PushNotified__c = false);
            insert clientList;
        
            Test.startTest();
            String cron = '0 0 23 * * ?';
            Database.executeBatch(new BL_ICON_BatchMyListsExpirationDate(),200);
            BL_Scheduler_BatchMyListsExpirationDate schd = new BL_Scheduler_BatchMyListsExpirationDate();
            String jobId = System.schedule('test schedule spam deletion batch', cron, schd);
        
            // Get the information from the CronTrigger API object
            CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                                        FROM CronTrigger WHERE id = :jobId];
        
            Test.stopTest();
            System.assertNotEquals(null, ct.NextFireTime);
        }
    }
}