@isTest
private class LogsCleaner_Batch_TEST {
 
    
    @testSetup
    static void setup() {
        List<Logs__c> logs = new List<Logs__c>();
        Global_Settings__mdt gs = Global_Settings__mdt.getInstance('Logs_Cleaner_Date_Support');
        for (Integer i=0;i<10;i++) {
            logs.add(new Logs__c(CreatedDate = system.now().addDays((Integer.valueOf(gs.Value__c) + 10) * -1) ));
        }
        insert logs;
        
    }
    @isTest static void test() {
        Test.startTest();
        LogsCleaner_Batch uca = new LogsCleaner_Batch();
        Id batchId = Database.executeBatch(uca);
        Test.stopTest();
    }
}