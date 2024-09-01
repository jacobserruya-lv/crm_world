@isTest
private class Experience_Store_Hierarchy_Ctrl_Test {

    @testSetup
    static void setup() {
        List<Store__c> testStores = new List<Store__c>();
        testStores.add(New Store__c(Name = 'test1', RetailStoreId__c = 'AA11', StoreType__c='Store', Status__c='Opening Soon', MANAGEMENT_ZONE_LEVEL_TECH__c='3', MANAGEMENT_ZONE_LEVEL__c='AMERICAS', MGMT_ZONE_SUB_LEVEL1_TECH__c='151', MGMT_ZONE_SUB_LEVEL1__c ='USA', MGMT_ZONE_SUB_LEVEL2_TECH__c='68', MGMT_ZONE_SUB_LEVEL2__c='WEST COAST', MGMT_ZONE_SUB_LEVEL3_TECH__c='1576', MGMT_ZONE_SUB_LEVEL3__c='OON WESTERN'));
        testStores.add(New Store__c(Name = 'test2', RetailStoreId__c = 'AA22', StoreType__c='CSC', Status__c='Opening Soon', MANAGEMENT_ZONE_LEVEL_TECH__c='15', MANAGEMENT_ZONE_LEVEL__c='EMEA', MGMT_ZONE_SUB_LEVEL1_TECH__c='32', MGMT_ZONE_SUB_LEVEL1__c ='EUROPE SOUTH', MGMT_ZONE_SUB_LEVEL2_TECH__c='24', MGMT_ZONE_SUB_LEVEL2__c='ITALY', MGMT_ZONE_SUB_LEVEL3_TECH__c='351', MGMT_ZONE_SUB_LEVEL3__c='ITALY'));
        testStores.add(New Store__c(Name = 'test3', RetailStoreId__c = 'BB33', StoreType__c='Store', Status__c='Open', MANAGEMENT_ZONE_LEVEL_TECH__c='15', MANAGEMENT_ZONE_LEVEL__c='EMEA', MGMT_ZONE_SUB_LEVEL1_TECH__c='31', MGMT_ZONE_SUB_LEVEL1__c ='EUROPE NORTH', MGMT_ZONE_SUB_LEVEL2_TECH__c='17', MGMT_ZONE_SUB_LEVEL2__c='EASTERN EUROPE', MGMT_ZONE_SUB_LEVEL3_TECH__c='284', MGMT_ZONE_SUB_LEVEL3__c='POLAND'));
        testStores.add(New Store__c(Name = 'test4', RetailStoreId__c = 'BB44', StoreType__c='CSC', Status__c='Open', MANAGEMENT_ZONE_LEVEL_TECH__c='14', MANAGEMENT_ZONE_LEVEL__c='ASIA SOUTH', MGMT_ZONE_SUB_LEVEL1_TECH__c='1351', MGMT_ZONE_SUB_LEVEL1__c ='SE ASIA', MGMT_ZONE_SUB_LEVEL2_TECH__c='289', MGMT_ZONE_SUB_LEVEL2__c='SINGAPORE', MGMT_ZONE_SUB_LEVEL3_TECH__c='1566', MGMT_ZONE_SUB_LEVEL3__c='POP UP SINGAPORE'));

        insert testStores;
        
        Club_and_Seasons__c clubSneakers = new Club_and_Seasons__c(
            Name = 'Sneakers'
        );
        insert clubSneakers;
        
        Id ExperienceRecordType = Schema.SObjectType.Brand_Experience__c.getRecordTypeInfosByDeveloperName().get('Experience').getRecordTypeId();
        Brand_Experience__c ex = new Brand_Experience__c(
            RecordTypeId=ExperienceRecordType,
            Name = 'test',
            Status__c = 'Ongoing',
            ClubName__c = clubSneakers.Id
        );
        insert ex;
        
        Brand_Experience_Store_Hierarchy__c storeHierarchyRecord = new Brand_Experience_Store_Hierarchy__c(Store__c = testStores[0].Id, Brand_Experience__c=ex.Id);
    	insert storeHierarchyRecord;
    }
    @isTest
    static void testGetManagementZoneLevel() {
        Test.startTest();
        List<AggregateResult> result = Experience_Store_Hierarchy_Ctrl.getManagementZoneLevel();
        Test.stopTest();

        System.assertEquals(3, result.size(), 'Expected 3 aggregate results');
    }

    @isTest
    static void testGetManagementZoneSubLevel1() {
        List<String> selectedLevelTech = new List<String>{ '3', '14', '15'};
        Test.startTest();
        List<AggregateResult> result = Experience_Store_Hierarchy_Ctrl.getManagementZoneSubLevel1(selectedLevelTech);
        Test.stopTest();

        System.assertEquals(4, result.size(), 'Expected 4 aggregate result');
    }

    @isTest
    static void testGetManagementZoneSubLevel2() {
        List<String> selectedSubLevel1Tech = new List<String>{ '31', '32', '151', '1351' };
        Test.startTest();
        List<AggregateResult> result = Experience_Store_Hierarchy_Ctrl.getManagementZoneSubLevel2(selectedSubLevel1Tech);
        Test.stopTest();

        System.assertEquals(4, result.size(), 'Expected 4 aggregate result');
    }

    @isTest
    static void testGetManagementZoneSubLevel3() {
        
        List<String> selectedSubLevel2Tech = new List<String>{ '17','24','68' };
        Test.startTest();
        List<AggregateResult> result = Experience_Store_Hierarchy_Ctrl.getManagementZoneSubLevel3(selectedSubLevel2Tech);
        Test.stopTest();

        System.assertEquals(3, result.size(), 'Expected 3 aggregate result');
    }

    @isTest
    static void testGetStoreLevel() {

        List<String> selectedSubLevel3Tech = new List<String>{ '12345' };
        Test.startTest();
        List<AggregateResult> result = Experience_Store_Hierarchy_Ctrl.getStoreLevel(selectedSubLevel3Tech);
        Test.stopTest();

        System.assertEquals(0, result.size(), 'Expected 0 aggregate result');
    }

    @isTest
    static void testGetSelectedStores() {
        Brand_Experience__c brandExp = [SELECT Id FROM Brand_Experience__c LIMIT 1];
        Test.startTest();
        List<Experience_Store_Hierarchy_Ctrl.SelctedStoreHierarchy> result = Experience_Store_Hierarchy_Ctrl.getSelectedStores(brandExp.Id);
        Test.stopTest();

        System.assertEquals(1, result.size(), 'Expected 1 selected store hierarchies');
    }
}