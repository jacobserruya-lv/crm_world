@isTest
private class Ex_new_brand_experience_modal_Ctrl_Test {

    @testSetup
    static void setup() {

        Id ExperienceRecordType = Schema.SObjectType.Brand_Experience__c.getRecordTypeInfosByDeveloperName().get('Experience').getRecordTypeId();
        Club_and_Seasons__c clubSneakers = new Club_and_Seasons__c(
            Name = 'Sneakers'
        );
        insert clubSneakers;
        
        Brand_Experience__c ex = new Brand_Experience__c(
            RecordTypeId = ExperienceRecordType,
            Name = 'test',
            Status__c = 'Ongoing',
            ClubName__c = clubSneakers.Id
        );
        insert ex;
		
        List<Store__c> testStores = new List<Store__c>();
        testStores.add(New Store__c(Name = 'test1', RetailStoreId__c = 'AA11', StoreType__c='Store', Status__c='Opening Soon'));
        testStores.add(New Store__c(Name = 'test2', RetailStoreId__c = 'AA22', StoreType__c='CSC', Status__c='Opening Soon'));
        testStores.add(New Store__c(Name = 'test3', RetailStoreId__c = 'BB33', StoreType__c='Store', Status__c='Open'));
        testStores.add(New Store__c(Name = 'test3', RetailStoreId__c = 'BB44', StoreType__c='CSC', Status__c='Open'));

        insert testStores;
    }
    @isTest
    static void testgetRecordType() {
        Test.startTest();
        List<RecordType> recordTypeList = Ex_new_brand_experience_modal_Controller.getRecordTypes();
        Test.stopTest();

        System.assertEquals(recordTypeList.size(), 2, 'There are 2 recordtypes availables for this component');
    }
    @isTest
    static void testCreateBrandEventAndStoreHierarchyRecords() {
        // Prepare test data
        Id ExperienceRecordType = Schema.SObjectType.Brand_Experience__c.getRecordTypeInfosByDeveloperName().get('Experience').getRecordTypeId();

        Map<String, Object> eventRecord = new Map<String, Object>{
            'recordTypeId' => ExperienceRecordType, 
            'name' => 'Test Body',
            'startDate' => '2024-06-24T20:48:00.000Z',
            'endDate' => '2024-11-27T21:48:00.000Z',
            'selectedStores' => new List<String>{'AA11', 'AA22'}
        };

        Test.startTest();
        Brand_Experience__c createdEvent = Ex_new_brand_experience_modal_Controller.createBrandEventAndStoreHierarchyRecords(eventRecord);
        Test.stopTest();

        // Perform assertions
        System.assert(createdEvent != null, 'Brand Event should have been created');
    }
    @isTest
    static void testUpdateSelectedStores() {
        
        List<Brand_Experience_Store_Hierarchy__c> initialHierarchyRecords = new List<Brand_Experience_Store_Hierarchy__c>();
        Brand_Experience__c brndEx =[SELECT Id FROM Brand_Experience__c LIMIT 1];
        List<Store__c> stores = [SELECT Id FROM Store__c];
    	initialHierarchyRecords.add(new Brand_Experience_Store_Hierarchy__c(
        Brand_Experience__c = brndEx.Id,
        Store__c = stores[0].Id
    	));
    	initialHierarchyRecords.add(new Brand_Experience_Store_Hierarchy__c(
        Brand_Experience__c = brndEx.Id,
        Store__c = stores[1].Id
    	));
    	insert initialHierarchyRecords;
        
        
        List<String> storeCodes = new List<String>{'BB33', 'BB44'};
        Test.startTest();
        Ex_new_brand_experience_modal_Controller.updateSelectedStores(storeCodes, brndEx.Id);
        Test.stopTest();
        
        List<Brand_Experience_Store_Hierarchy__c> updatedHierarchyRecords = [SELECT Id, Store__r.RetailStoreId__c FROM Brand_Experience_Store_Hierarchy__c WHERE Brand_Experience__c = :brndEx.Id];
        System.assertEquals(2, updatedHierarchyRecords.size(), 'New hierarchy records should have been inserted');

        Set<String> updatedStoreCodes = new Set<String>();
        for (Brand_Experience_Store_Hierarchy__c record : updatedHierarchyRecords) {
            updatedStoreCodes.add(record.Store__r.RetailStoreId__c);
        }
        System.assertEquals(new Set<String>{'BB33', 'BB44'}, updatedStoreCodes, 'Updated store codes should match expected values');
    }

}