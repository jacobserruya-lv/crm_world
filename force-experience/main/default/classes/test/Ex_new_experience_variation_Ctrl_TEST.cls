/*	* @author Keman WU, updated by Nechama Wollach (getFilteredStores)
    * @date creation 02/05/2024
    * @description test class for Ex_new_experience_variation_Ctrl
*/

@isTest
public class Ex_new_experience_variation_Ctrl_TEST {
    
     @testSetup
    static void setup() {
        List<Store__c> testStores = new List<Store__c>();
        testStores.add(New Store__c(Name = 'test1', RetailStoreId__c = 'AA11', StoreType__c='Store', Status__c='Opening Soon', MANAGEMENT_ZONE_LEVEL_TECH__c='3', MANAGEMENT_ZONE_LEVEL__c='AMERICAS', MGMT_ZONE_SUB_LEVEL1_TECH__c='151', MGMT_ZONE_SUB_LEVEL1__c ='USA', MGMT_ZONE_SUB_LEVEL2_TECH__c='68', MGMT_ZONE_SUB_LEVEL2__c='WEST COAST', MGMT_ZONE_SUB_LEVEL3_TECH__c='1576', MGMT_ZONE_SUB_LEVEL3__c='OON WESTERN'));
        testStores.add(New Store__c(Name = 'check2', RetailStoreId__c = 'AA22', StoreType__c='CSC', Status__c='Opening Soon', MANAGEMENT_ZONE_LEVEL_TECH__c='15', MANAGEMENT_ZONE_LEVEL__c='EMEA', MGMT_ZONE_SUB_LEVEL1_TECH__c='32', MGMT_ZONE_SUB_LEVEL1__c ='EUROPE SOUTH', MGMT_ZONE_SUB_LEVEL2_TECH__c='24', MGMT_ZONE_SUB_LEVEL2__c='ITALY', MGMT_ZONE_SUB_LEVEL3_TECH__c='351', MGMT_ZONE_SUB_LEVEL3__c='ITALY'));
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
        
        List<Brand_Experience_Store_Hierarchy__c> storeHierarchyRecords = new List<Brand_Experience_Store_Hierarchy__c>();
        storeHierarchyRecords.add(New Brand_Experience_Store_Hierarchy__c(Store__c = testStores[0].Id, Brand_Experience__c=ex.Id));
        storeHierarchyRecords.add(New Brand_Experience_Store_Hierarchy__c(Store__c = testStores[1].Id, Brand_Experience__c=ex.Id));
    	insert storeHierarchyRecords;
    }
    
    
    
    @isTest static void testGetExperienceRecord() {
        Id experienceRTId = Schema.SObjectType.Brand_Experience__c.getRecordTypeInfosByDeveloperName().get('Club_Experience').getRecordTypeId();     	
       
        Store__c store= new Store__c(RetailStoreId__c = 'A06');
		insert store;      
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        Brand_Experience__c experience = new Brand_Experience__c(Name='TEST',recordTypeId = experienceRTId, Experience_StartDate__c =  system.today(),Experience_EndDate__c=  system.today().addDays(2));
        insert experience;
            
        
       
        test.startTest();
        Id experienceId = Ex_new_experience_variation_Ctrl.getExperienceRecord(experience.Id).Id;
        List<Brand_Experience_Variation__c> variationList = new List<Brand_Experience_Variation__c> ();
        Id variaton1RTId = Ex_new_experience_variation_Ctrl.getPhysicalEventRecordTypeID();
        Id variaton2RTId = Ex_new_experience_variation_Ctrl.getContentRecordTypeID();
        Id variaton3RTId = Ex_new_experience_variation_Ctrl.getExclusiveOfferRecordTypeID();
        Id variaton4RTId = Ex_new_experience_variation_Ctrl.getDigitalEventRecordTypeID();
        
        Brand_Experience_Variation__c variation1 = new Brand_Experience_Variation__c(Brand_Experience__c = experienceId, Name='TEST variation 1',recordTypeId = variaton1RTId, StartDateTime__c = system.today(),EndDateTime__c =  system.today().addDays(2),inStoreEventFormat__c = 'Brunch',Store__c = store.Id);      
        variationList.add(variation1);
        Brand_Experience_Variation__c variation2 = new Brand_Experience_Variation__c(Brand_Experience__c = experienceId,Name='TEST variation 2',recordTypeId = variaton2RTId, StartDateTime__c = system.today(),EndDateTime__c =  system.today().addDays(2),inStoreEventFormat__c = 'Brunch',Store__c = store.Id);     
        variationList.add(variation2); 
        Brand_Experience_Variation__c variation3 = new Brand_Experience_Variation__c(Brand_Experience__c = experienceId,Name='TEST variation 3',recordTypeId = variaton3RTId, StartDateTime__c = system.today(),EndDateTime__c =  system.today().addDays(2),inStoreEventFormat__c = 'Brunch',Store__c = store.Id);     
        variationList.add(variation3); 
        Brand_Experience_Variation__c variation4 = new Brand_Experience_Variation__c(Brand_Experience__c = experienceId,Name='TEST variation 4',recordTypeId = variaton4RTId, StartDateTime__c = system.today(),EndDateTime__c =  system.today().addDays(2),inStoreEventFormat__c = 'Brunch',Store__c = store.Id);     
        variationList.add(variation4);  
        insert  variationList;
        System.assertequals('TEST',Ex_new_experience_variation_Ctrl.getExperienceRecord(experience.Id).Name);
        
        test.stopTest();
    }
    @isTest static void testGetFilteredStores() {
        List<Brand_Experience__c> testEx = [SELECT Id FROM Brand_Experience__c];
        test.startTest();
        List<Ex_new_experience_variation_Ctrl.RecordsData> returnedRecords = Ex_new_experience_variation_Ctrl.getFilteredStores('Brand_Experience_Store_Hierarchy__c', testEx[0].Id, 'te');
        test.stopTest();
		System.assertEquals(1, returnedRecords.size());
    }    
}