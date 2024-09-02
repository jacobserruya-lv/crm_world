@isTest
public class EX_Variation_related_list_CTRL_TEST {
   @TestSetup
   static void setupTestData(){        
        Id experienceRT = Schema.SObjectType.Brand_Experience__c.getRecordTypeInfosByDeveloperName().get('Experience').getRecordTypeId();
        Brand_Experience__c experience = new Brand_Experience__c(
            recordTypeId = experienceRT,
            Name = 'test',
            Status__c = 'Ongoing'
        );
        insert experience;

       List<Store__c> testStores = new List<Store__c>();
        testStores.add(New Store__c(Name = 'test1', RetailStoreId__c = 'AA11', StoreType__c='Store', Status__c='Opening Soon', MANAGEMENT_ZONE_LEVEL_TECH__c='3', MANAGEMENT_ZONE_LEVEL__c='AMERICAS', MGMT_ZONE_SUB_LEVEL1_TECH__c='151', MGMT_ZONE_SUB_LEVEL1__c ='USA', MGMT_ZONE_SUB_LEVEL2_TECH__c='68', MGMT_ZONE_SUB_LEVEL2__c='WEST COAST', MGMT_ZONE_SUB_LEVEL3_TECH__c='1576', MGMT_ZONE_SUB_LEVEL3__c='OON WESTERN'));
        testStores.add(New Store__c(Name = 'check2', RetailStoreId__c = 'AA22', StoreType__c='CSC', Status__c='Opening Soon', MANAGEMENT_ZONE_LEVEL_TECH__c='15', MANAGEMENT_ZONE_LEVEL__c='EMEA', MGMT_ZONE_SUB_LEVEL1_TECH__c='32', MGMT_ZONE_SUB_LEVEL1__c ='EUROPE SOUTH', MGMT_ZONE_SUB_LEVEL2_TECH__c='24', MGMT_ZONE_SUB_LEVEL2__c='ITALY', MGMT_ZONE_SUB_LEVEL3_TECH__c='351', MGMT_ZONE_SUB_LEVEL3__c='ITALY'));
        testStores.add(New Store__c(Name = 'test3', RetailStoreId__c = 'BB33', StoreType__c='Store', Status__c='Open', MANAGEMENT_ZONE_LEVEL_TECH__c='15', MANAGEMENT_ZONE_LEVEL__c='EMEA', MGMT_ZONE_SUB_LEVEL1_TECH__c='31', MGMT_ZONE_SUB_LEVEL1__c ='EUROPE NORTH', MGMT_ZONE_SUB_LEVEL2_TECH__c='17', MGMT_ZONE_SUB_LEVEL2__c='EASTERN EUROPE', MGMT_ZONE_SUB_LEVEL3_TECH__c='284', MGMT_ZONE_SUB_LEVEL3__c='POLAND'));
        testStores.add(New Store__c(Name = 'test4', RetailStoreId__c = 'BB44', StoreType__c='CSC', Status__c='Open', MANAGEMENT_ZONE_LEVEL_TECH__c='14', MANAGEMENT_ZONE_LEVEL__c='ASIA SOUTH', MGMT_ZONE_SUB_LEVEL1_TECH__c='1351', MGMT_ZONE_SUB_LEVEL1__c ='SE ASIA', MGMT_ZONE_SUB_LEVEL2_TECH__c='289', MGMT_ZONE_SUB_LEVEL2__c='SINGAPORE', MGMT_ZONE_SUB_LEVEL3_TECH__c='1566', MGMT_ZONE_SUB_LEVEL3__c='POP UP SINGAPORE'));

        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = '123');
		insert store;
        Brand_Experience_Store_Hierarchy__c storeHierarchy = new Brand_Experience_Store_Hierarchy__c(Store__c = store.Id, Brand_Experience__c = experience.Id);
        insert storeHierarchy;

        Id physicalRT = Ex_new_experience_variation_Ctrl.getPhysicalEventRecordTypeID();

        Brand_Experience_Variation__c variation = new Brand_Experience_Variation__c(Brand_Experience__c = experience.Id, Name='TEST variation 1',recordTypeId = physicalRT, StartDateTime__c = system.today(),EndDateTime__c =  system.today().addDays(2),inStoreEventFormat__c = 'Brunch',Store__c = store.Id);      
        insert variation;

    }
    @isTest
    static void test_initComponentConfig_Admin() {

        Profile adminProfile = [SELECT Id FROM Profile WHERE Name =: ex_variation_related_list_CTRL.SYSTEM_ADMIN_PROFILE LIMIT 1];
        
        User testUser = new User(
            DefaultStore__c = '123',
            MGMT_ZONE_SUB_LEVEL3__c = 'abc',
            profile = adminProfile,
            profileId = adminProfile.Id,
            LastName = 'LV user',
            Alias = 'lvUser',
            Email = 'icon.user@louisvuitton.com.test123',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'en_US',
            Username = 'icon.user@louisvuitton.com.test123',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            IsActive = True
        );
        insert testUser;

        Brand_Experience__c experience = [SELECT Id FROM Brand_Experience__c WHERE  Name = 'test' limit 1];
        System.runAs(testUser) {
            Test.startTest();
            Map<String,Object> componentConfig = ex_variation_related_list_CTRL.initComponentConfig(experience.id);
            List<Brand_Experience_Variation__c> variations = (List<Brand_Experience_Variation__c>)componentConfig.get('variations');
            Boolean displayNewBtn = (Boolean)componentConfig.get('displayNewBtn');
            System.debug('variations'+variations);
            System.debug('displayNewBtn'+displayNewBtn);

            Test.stopTest();
            System.assertEquals(true, displayNewBtn);
            System.assertEquals(1,variations.size());
        }
    }
    @isTest
    static void test_initComponentConfig_corporate() {
        Profile Profile = [SELECT Id FROM Profile WHERE Name = 'ICON_Corporate' LIMIT 1];
        
        User testUser = new User(
            DefaultStore__c = '2222',//same as the brand store hirarchy created on setup
            MGMT_ZONE_SUB_LEVEL3__c = 'abc',
            profile = Profile,
            profileId = Profile.Id,
            LastName = 'LV user',
            Alias = 'lvUser',
            Email = 'icon.user@louisvuitton.com.test123',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'en_US',
            Username = 'icon.user@louisvuitton.com.test123',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            IsActive = True
        );
        insert testUser;

        Brand_Experience__c experience = [SELECT Id FROM Brand_Experience__c WHERE Name = 'test' limit 1];
        System.runAs(testUser) {
            Test.startTest();
            Map<String,Object> componentConfig = ex_variation_related_list_CTRL.initComponentConfig(experience.id);
            List<Brand_Experience_Variation__c> variations = (List<Brand_Experience_Variation__c>)componentConfig.get('variations');
            Boolean displayNewBtn = (Boolean)componentConfig.get('displayNewBtn');
            System.debug('variations'+variations);
            System.debug('displayNewBtn'+displayNewBtn);
            Test.stopTest();
            System.assertEquals(false,displayNewBtn);
            System.assertEquals(0,variations.size());

        }
    }
    @isTest
    static void test_initComponentConfig_corporate_matching() {
        Profile Profile = [SELECT Id FROM Profile WHERE Name = 'ICON_Corporate' LIMIT 1];
        
        User testUser = new User(
            DefaultStore__c = '123',//different from the brand store hirarchy created on setup
            MGMT_ZONE_SUB_LEVEL3__c = 'abc',
            profile = Profile,
            profileId = Profile.Id,
            LastName = 'LV user',
            Alias = 'lvUser',
            Email = 'icon.user@louisvuitton.com.test123',
            TimeZoneSidKey = 'Europe/Paris',
            LocaleSidKey = 'en_US',
            Username = 'icon.user@louisvuitton.com.test123',
            EmailEncodingKey = 'ISO-8859-1',
            LanguageLocaleKey = 'en_US',
            IsActive = True
        );
        insert testUser;

        Brand_Experience__c experience = [SELECT Id FROM Brand_Experience__c WHERE  Name = 'test' limit 1];
        System.runAs(testUser) {
            Test.startTest();
            Map<String,Object> componentConfig = ex_variation_related_list_CTRL.initComponentConfig(experience.id);
            List<Brand_Experience_Variation__c> variations = (List<Brand_Experience_Variation__c>)componentConfig.get('variations');
            Boolean displayNewBtn = (Boolean)componentConfig.get('displayNewBtn');
            System.debug('variations'+variations);
            System.debug('displayNewBtn'+displayNewBtn);
            Test.stopTest();
            System.assertEquals(false,displayNewBtn);
            System.assertEquals(1,variations.size());

        }
    }
    @isTest static void testGetFilteredStores() {
        List<Brand_Experience__c> testEx = [SELECT Id FROM Brand_Experience__c];
        test.startTest();
        List<ex_variation_related_list_CTRL.RecordsData> returnedRecords = ex_variation_related_list_CTRL.getFilteredStores('Brand_Experience_Store_Hierarchy__c', testEx[0].Id, 'te');
        test.stopTest();
		System.assertEquals(1, returnedRecords.size());
    }    
}