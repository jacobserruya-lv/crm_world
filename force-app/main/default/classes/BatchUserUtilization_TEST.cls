/*
BW 28/05/2019
Test class for the class BatchUserUtilization
*/

@isTest
private with sharing class BatchUserUtilization_TEST {
    @isTest
    static void testUserUtilization() {
        User testUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_SYSTEM_ADMINNISTRATOR);
        testUser.BypassVR__c = true;
        testUser.Country__c = 'FRANCE';
        insert testUser;

        System.runAs(testUser) {

            User ICXUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_ICONICS_SA);
            ICXUser.Country__c = 'FRANCE';
            insert ICXUser;
            Country__c country = new Country__c(Name='FRANCE', Iso3Code__c='FRA', Case__c = 'FRANCE', StoreOrUser__c='FRANCE', tech_duplicate__c='France', User_country__c=true);
            insert country; 
            Account acc = ICX_TestFactory.CreateAccount();
            acc.OwnerId = ICXUser.Id;
            insert acc;
            Case c = ICX_TestFactory.CreateCase(acc.Id);
            c.Country__c = 'FRANCE';
            c.OwnerId = ICXUser.Id;
            insert c;

            Test.startTest();
            BatchUserUtilization cl = new BatchUserUtilization(null, 1, 'FRA','');
            Id batchInstanceId = Database.executeBatch(cl, 1);
            Test.stopTest();

            String query = 'select count() from Utilization_report_line__c';

            Integer utilization = System.Database.countQuery(query);
            System.assertEquals(1, utilization, 'No stat created : ' + String.valueOf(utilization));
        }
    }
}