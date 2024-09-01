@isTest
public with sharing class ex_Event_ListView_Controller_Test {
    
    @TestSetup
    static void setupTestData() {
        Profile LVProfile = [SELECT Id FROM Profile WHERE Name = 'LV_Club' LIMIT 1];
        User mockUser = new User(
            DefaultStore__c = '123',
            MGMT_ZONE_SUB_LEVEL3__c = 'abc',
            profile = LVProfile,
            ProfileId = LVProfile.Id,
            LastName = 'LV user',
            Alias = 'lvUser',
            Email = 'icon.user@louisvuitton.com.123',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'en_US',
            Username = 'icon.user@louisvuitton.com.icon',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            IsActive = True
        );
        insert mockUser;
        
        User mockUser1 = new User(
            MGMT_ZONE_SUB_LEVEL3__c = 'abc',
            profile = LVProfile,
            ProfileId = LVProfile.Id,
            LastName = 'LV user',
            Alias = 'lvUser',
            Email = 'icon.user1@louisvuitton.com.123',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'en_US',
            Username = 'icon.user1@louisvuitton.com.icon',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            IsActive = True
        );
        insert mockUser1;

        Club_and_Seasons__c clubSneakers = new Club_and_Seasons__c(
            Name = 'Sneakers'
        );
        insert clubSneakers;
        
        Brand_Experience__c ex = new Brand_Experience__c(
            Name = 'test',
            Status__c = 'Ongoing',
            ClubName__c = clubSneakers.Id
        );
        insert ex;
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = '123');
		insert store;

        Brand_Experience_Store_Hierarchy__c storeHierarchy = new Brand_Experience_Store_Hierarchy__c(Store__c = store.Id, Brand_Experience__c = ex.Id);
    }
    @isTest
    static void testGetStoreHierarchiesEvents_DefaultStore() {
        
        User testUser = [SELECT Id, MGMT_ZONE_SUB_LEVEL2__c, MGMT_ZONE_SUB_LEVEL3__c, DefaultStore__c FROM User WHERE Username = 'icon.user@louisvuitton.com.icon'];
        System.runAs(testUser) {
            Test.startTest();
            List<Brand_Experience__c> experiences = ex_Event_ListView_Controller.getStoreHierarchiesEvents();
            Test.stopTest();
        }
    }
    @isTest
    static void testGetStoreHierarchiesEvents_SubLevel3() {
        
        User testUser = [SELECT Id, MGMT_ZONE_SUB_LEVEL3__c FROM User WHERE Username = 'icon.user1@louisvuitton.com.icon'];
        System.runAs(testUser) {
            Test.startTest();
            List<Brand_Experience__c> experiences = ex_Event_ListView_Controller.getStoreHierarchiesEvents();
            Test.stopTest();
        }
    }
    @isTest
    static void testGetStoreHierarchiesEvents_SubLevel2() {
        
        User testUser = [SELECT Id, MGMT_ZONE_SUB_LEVEL2__c, MGMT_ZONE_SUB_LEVEL3__c FROM User WHERE Username = 'icon.user1@louisvuitton.com.icon'];
        testUser.MGMT_ZONE_SUB_LEVEL3__c=null;
        testUser.MGMT_ZONE_SUB_LEVEL2__c='abc';
		update testUser;
        System.runAs(testUser) {
            Test.startTest();
            List<Brand_Experience__c> experiences = ex_Event_ListView_Controller.getStoreHierarchiesEvents();
            Test.stopTest();
        }
    }
    
     @isTest
    static void testGetStoreHierarchiesEvents_SubLevel1() {
        
        User testUser = [SELECT Id, MGMT_ZONE_SUB_LEVEL1__c, MGMT_ZONE_SUB_LEVEL2__c FROM User WHERE Username = 'icon.user1@louisvuitton.com.icon'];
        testUser.MGMT_ZONE_SUB_LEVEL3__c=null;
        testUser.MGMT_ZONE_SUB_LEVEL2__c=null;
        testUser.MGMT_ZONE_SUB_LEVEL1__c='abc';
		update testUser;
        System.runAs(testUser) {
            Test.startTest();
            List<Brand_Experience__c> experiences = ex_Event_ListView_Controller.getStoreHierarchiesEvents();
            Test.stopTest();
        }
    }
    
    @isTest
    static void testGetStoreHierarchiesEvents_SubLevel() {
        
        User testUser = [SELECT Id, MGMT_ZONE_SUB_LEVEL1__c, MANAGEMENT_ZONE_LEVEL__c FROM User WHERE Username = 'icon.user1@louisvuitton.com.icon'];
        testUser.MGMT_ZONE_SUB_LEVEL3__c=null;
        testUser.MGMT_ZONE_SUB_LEVEL2__c=null;
        testUser.MGMT_ZONE_SUB_LEVEL1__c=null;
        testUser.MANAGEMENT_ZONE_LEVEL__c='abc';
		update testUser;
        System.runAs(testUser) {
            Test.startTest();
            List<Brand_Experience__c> experiences = ex_Event_ListView_Controller.getStoreHierarchiesEvents();
            Test.stopTest();
        }
    }
    @isTest
    static void testGetStoreHierarchiesEvents_noLevel() {
        
        User testUser = [SELECT Id, MGMT_ZONE_SUB_LEVEL3__c, MGMT_ZONE_SUB_LEVEL2__c, MGMT_ZONE_SUB_LEVEL1__c, MANAGEMENT_ZONE_LEVEL__c FROM User WHERE Username = 'icon.user1@louisvuitton.com.icon'];
        testUser.MGMT_ZONE_SUB_LEVEL3__c=null;
        testUser.MGMT_ZONE_SUB_LEVEL2__c=null;
        testUser.MGMT_ZONE_SUB_LEVEL1__c=null;
        testUser.MANAGEMENT_ZONE_LEVEL__c=null;
		update testUser;
        System.runAs(testUser) {
            Test.startTest();
            List<Brand_Experience__c> experiences = ex_Event_ListView_Controller.getStoreHierarchiesEvents();
            Test.stopTest();
        }
    }
}