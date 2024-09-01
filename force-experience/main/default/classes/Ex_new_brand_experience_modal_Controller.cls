public with sharing class Ex_new_brand_experience_modal_Controller {

    @AuraEnabled(cacheable=true)
    public static List<RecordType> getRecordTypes() {
        return [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Brand_Experience__c' AND IsActive = true AND DeveloperName IN ('Experience', 'Out_of_Store_Event')];
    }

    @AuraEnabled
    static public Brand_Experience__c createBrandEventAndStoreHierarchyRecords(Map<String,Object> eventRecord){
        Brand_Experience__c newEvent = createBrandEventRecord(eventRecord);
        createStoreHierarchyRecords(eventRecord, newEvent);
        return newEvent;   
    }
    private static Brand_Experience__c createBrandEventRecord(Map<String, Object> eventRecord){
        Brand_Experience__c newEvent = new Brand_Experience__c();
        newEvent.recordTypeId = String.valueOf(eventRecord.get('recordTypeId'));
        newEvent.Name = String.valueOf(eventRecord.get('name'));
        newEvent.Experience_StartDate__c = convertDateTime(eventRecord.get('startDate'));
        newEvent.Experience_EndDate__c	 = convertDateTime(eventRecord.get('endDate'));
        newEvent.Description__c =  eventRecord.containsKey('description')?  String.valueOf(eventRecord.get('description')): '';
        newEvent.Type__c =  eventRecord.containsKey('type')?  String.valueOf(eventRecord.get('type')): null;
        newEvent.Sub_Type__c =  eventRecord.containsKey('subType')?  String.valueOf(eventRecord.get('subType')): null;
        newEvent.Status__c = 'Ready';

        insert newEvent;
        return newEvent;
    }
    private static DateTime convertDateTime(Object dateTimeString){
        return (DateTime)Json.deserialize('"'+dateTimeString+'"', DateTime.class);
    }
    private static void createStoreHierarchyRecords(Map<String, Object> eventRecord, Brand_Experience__c newEvent){
        List<String> storeCodesList = new List<String>();
        for (Object store : (List<Object>)eventRecord.get('selectedStores')) {
            storeCodesList.add(String.valueOf(store));
        }
        createRecords(storeCodesList, newEvent.Id);
    }
    @AuraEnabled
    public static void updateSelectedStores(List<String> storeCodesList, Id recordId) {
        List<Brand_Experience_Store_Hierarchy__c> existStoreHierarchyList = [SELECT Id FROM Brand_Experience_Store_Hierarchy__c WHERE Brand_Experience__c=:recordId];
        if (existStoreHierarchyList!=null && !existStoreHierarchyList.isEmpty()) {
          delete existStoreHierarchyList;
        }
        createRecords(storeCodesList, recordId);

    }
    public static void createRecords(List<String> storeCodesList, Id newEventId) {
        
        Map<String, Id> storeCodeToId = new Map<String, Id>();
        List<Brand_Experience_Store_Hierarchy__c> storeHierarchyList = new List<Brand_Experience_Store_Hierarchy__c>();
        for (Store__c store : [SELECT Id, RetailStoreId__c FROM Store__c WHERE RetailStoreId__c IN: storeCodesList]) {
            storeCodeToId.put(store.RetailStoreId__c, store.Id);
        }
        for (String storeCode : storeCodeToId.keySet()) {
            Brand_Experience_Store_Hierarchy__c storeHierarchy =new Brand_Experience_Store_Hierarchy__c();
            storeHierarchy.Brand_Experience__c = newEventId;
            storeHierarchy.Store__c = storeCodeToId.get(storeCode);
            storeHierarchyList.add(storeHierarchy);
        }
        System.debug('**storeHierarchyList: '+storeHierarchyList);
        if (!storeHierarchyList.isEmpty()) {
            insert storeHierarchyList;
        }
    }
}