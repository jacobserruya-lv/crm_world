@isTest
public with sharing class BL_Batch_For_StoreHirerchy_DataFix_Test {
    
    @testSetup
    static void setup() {

        Id ExperienceRecordType = Schema.SObjectType.Brand_Experience__c.getRecordTypeInfosByDeveloperName().get('Experience').getRecordTypeId();

        Club_and_Seasons__c clubSneakers = new Club_and_Seasons__c(
            Name = 'Sneakers'
        );
        insert clubSneakers;
        
        Brand_Experience__c ex = new Brand_Experience__c(
            RecordTypeId=ExperienceRecordType,
            Name = 'test',
            Status__c = 'Ongoing',
            ClubName__c = clubSneakers.Id
        );
        insert ex;

        Store__c store1 = new Store__c(Name = 'test1', RetailStoreId__c = 'A06', StoreType__c='Store', Status__c='Open');
		insert store1;

        Store__c store2 = new Store__c(Name = 'test1', RetailStoreId__c = 'A05', StoreType__c='CSC', Status__c='Open');
		insert store2;
    }
    
    @isTest
    static void testBatch(){
        Test.startTest();
        BL_Batch_For_StoreHirerchy_DataFix ba= new BL_Batch_For_StoreHirerchy_DataFix();
        Database.executeBatch(ba);
        Test.stopTest();
    }
}