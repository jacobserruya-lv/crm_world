/**
    @Author : 	deborah.marciano
    Desc 	:   test class for BatchPurgeEmailMessage class 
    V 1.0 	:   5/05/2024
*/


@isTest
private class BatchPurgeTask_Test {
    
    @testSetup
    static void setupTestData() {
       
       //Id toDoAssistantId = '0126S000001OCGeQAO';
       /*
       PurgeTask__mdt purgeSettings =new PurgeTask__mdt();
       purgeSettings.Limit__c = 20;
       purgeSettings.numberOfDayBefore__c = 180;
       purgeSettings.RecordTypeName__c = 'to do';
       */ 

		
       PurgeTask__mdt purgeSetting2 =new PurgeTask__mdt();
       purgeSetting2.Limit__c = 500000;
       purgeSetting2.numberOfDayBefore__c = 180;
       purgeSetting2.RecordTypeName__c = 'to do assistant';
        
     
    }

    
    @isTest
    private static void testLimit() {
        User testUser = IC_Test_Common.createTestUser();
        System.runAs(testUser) {
            Test.startTest();
            BatchPurgeTask batch = new BatchPurgeTask();
            Id batchId = Database.executeBatch(batch);
            Test.stopTest();
           
            PurgeTask__mdt purgeSettings = [SELECT Limit__c FROM PurgeTask__mdt WHERE RecordTypeName__c = 'to do assistant'];
			System.assertEquals(100000, purgeSettings.Limit__c, 'Nous avons definis la limite des records');
	    }
    }
    
    
}