public with sharing class icx_searchDigitalStoreController {
    @AuraEnabled(cacheable=false)
    public static List<Store__c>  searchDigitalStore(String searchKey){
        try {

            String searchKeyAPI = '%'+searchKey +'%';
            List<Store__c> listStore =  [SELECT ID,Name, RetailStoreId__c FROM Store__c WHERE (NAME LIKE: searchKeyAPI OR RetailStoreId__c LIKE: searchKeyAPI) AND Status__c = 'Open' AND StoreType__c = 'CSC' LIMIT 5];
            return listStore;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}