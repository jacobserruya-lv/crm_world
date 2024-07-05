// BW 21/02/2020

@isTest
private class BatchDeletePendingOSA_Test {  
    @isTest
    static void testBatch() {   
        User testUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_SYSTEM_ADMINNISTRATOR);
        testUser.BypassVR__c = true;
        testUser.Country__c = 'FRANCE';
        insert testUser;

        System.runAs(testUser) {
            Id recordetypeid = Schema.SObjectType.event.getRecordTypeInfosByName().get('Online Appointment').getRecordTypeId();
            event OSA = new event (Subject='Test', StartDateTime=DateTime.Now(), EndDateTime=DateTime.Now(), Recordtypeid = recordetypeid, Status__c = 'Pending');
            insert OSA;

            BatchDeletePendingOSA cl = new BatchDeletePendingOSA();
            Id batchInstanceId = Database.executeBatch(cl, 3000);

            //Integer i = Database.countQuery('SELECT count() FROM event where Recordtype.name=\'Online Appointment\' and status__c=\'Pending\'');
            //System.assertEquals(0, i, 'Not all old pending appointments are deleted');
        }
    }
}