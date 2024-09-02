/*	* @author: Nechama Wollach
    * @date creation: 13/06/2024
    * @description: Batch for data fix, creation Brand_Experience_Store_Hierarchy__c for each Brand_Experience__c<->Store_c combination. (https://vuitton.atlassian.net/browse/SE-674)
    Script to run:
    DataFixBatch batchJob = new DataFixBatch();
    Database.executeBatch(batchJob, 50);
*/
public class BL_Batch_For_StoreHirerchy_DataFix implements Database.Batchable<sObject> {
    
    private static final String QUERY_EVENTS = 'SELECT Id FROM Brand_Experience__c WHERE RecordType.DeveloperName=\'Experience\'';
    private static final String QUERY_STORES = 'SELECT Id FROM Store__c WHERE StoreType__c IN (\'Store\', \'POP-UP OON\', \'CSC\', \'WEB\') AND Status__c IN (\'Open\', \'Opening Soon\')';

    
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator(QUERY_STORES);
    }
    
    public void execute(Database.BatchableContext context, List<Store__c> scope) {
        List<Brand_Experience_Store_Hierarchy__c> storeHierarchyRecords = new List<Brand_Experience_Store_Hierarchy__c>();
        List<Brand_Experience__c> events = Database.query(QUERY_EVENTS);

        for(Store__c store : scope) {

            for(Brand_Experience__c event : events) {

            // Create Store_Hierarchy__c records for each Store__c and Brand_Experience__c combination
            
                Brand_Experience_Store_Hierarchy__c storeHierarchy = new Brand_Experience_Store_Hierarchy__c();
                storeHierarchy.Store__c = store.Id;
                storeHierarchy.Brand_Experience__c = event.Id;                
                storeHierarchyRecords.add(storeHierarchy);
            }
        }  
        insert storeHierarchyRecords;
    }
    
    public void finish(Database.BatchableContext context) {
    }
}