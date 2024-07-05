@isTest
private class Logs_Cleaner_BATCH_TEST {

    @isTest
    static void testBatch() {

        ID batchprocessid;  
        
        Datetime before2days = Datetime.now().addDays(-5);
        
        Logs__c log = new Logs__c( Apex_Class__c = 'IDENTITY_Login_CTRL', Level__c = 'INFO');  
        insert log;
        Test.setCreatedDate(log.Id, before2days);
        
        log = new Logs__c(  Apex_Class__c = 'IDENTITY_Registration_CTRL', Level__c = 'INFO');  
        insert log;
        Test.setCreatedDate(log.Id, before2days);
        
        
       Logs_Cleaner_BATCH myBatch = new Logs_Cleaner_BATCH();
        
        Test.startTest();
        batchprocessid = Database.executeBatch(myBatch,1000);
        Test.stopTest();
    }

}