@isTest
public class EX_Store_Hierarchy_Utils_TEST {
    @TestSetup
    static void setupTestData(){        
         Id experienceRT = Schema.SObjectType.Brand_Experience__c.getRecordTypeInfosByDeveloperName().get('Experience').getRecordTypeId();
         Brand_Experience__c experience = new Brand_Experience__c(
             recordTypeId = experienceRT,
             Name = 'test',
             Status__c = 'Ongoing'
         );
         insert experience;
 
         Store__c store = new Store__c(Name = 'test', RetailStoreId__c = '123', MANAGEMENT_ZONE_LEVEL__c = 'abc');
         insert store;
 
         Brand_Experience_Store_Hierarchy__c storeHierarchy = new Brand_Experience_Store_Hierarchy__c(Store__c = store.Id, Brand_Experience__c = experience.Id);
         insert storeHierarchy;

    }
    @isTest
    static void test() {

        Profile adminProfile = [SELECT Id FROM Profile WHERE Name =: ex_variation_related_list_CTRL.SYSTEM_ADMIN_PROFILE LIMIT 1];
        
        User testUser = new User(
            MANAGEMENT_ZONE_LEVEL__c = 'abc',
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
            List<string> PermissionSet_list = EX_Store_Hierarchy_Utils.getUserPermissionSet();
            User runningUser = EX_Store_Hierarchy_Utils.getUserHierarchies();
            Set<Id> stores = EX_Store_Hierarchy_Utils.getStoreIds(experience.Id, runningUser);

            Test.stopTest();
            System.assertEquals(1,stores.size());
        }
    }
}