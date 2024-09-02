@isTest
public with sharing class ex_invitees_related_list_CTRL_TEST {
    @TestSetup
    static void setupTestData(){   
        Profile iconProfile = [SELECT Id FROM Profile WHERE Name = 'ICON_SA' LIMIT 1];
        
        User testUser = new User(
            MANAGEMENT_ZONE_LEVEL__c = 'abc',
            profile = iconProfile,
            profileId = iconProfile.Id,
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
        System.runAs(testUser) {

            Id experience_OOS_RT = Schema.SObjectType.Brand_Experience__c.getRecordTypeInfosByDeveloperName().get(EX_Store_Hierarchy_Utils.EXPERIENCE_OUT_STORE_RECORD_TYPE).getRecordTypeId();
            Brand_Experience__c experience = new Brand_Experience__c(
                recordTypeId = experience_OOS_RT,
                Name = 'test',
                Status__c = 'Ongoing'
            );
            insert experience;
    
            Store__c store = new Store__c(Name = 'test', RetailStoreId__c = '123', MANAGEMENT_ZONE_LEVEL__c = 'abc');
            insert store;
    
            Brand_Experience_Store_Hierarchy__c storeHierarchy = new Brand_Experience_Store_Hierarchy__c(Store__c = store.Id, Brand_Experience__c = experience.Id);
            insert storeHierarchy;

            Id variation_OOS_RT = Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get(EX_Store_Hierarchy_Utils.VARIATION_OUT_STORE_RECORD_TYPE).getRecordTypeId();

            Brand_Experience_Variation__c variation = new Brand_Experience_Variation__c (Brand_Experience__c = experience.Id, recordTypeId=variation_OOS_RT,  Name = 'test variation', Nb_Target_Clients__c = 15, StartDateTime__c = Datetime.now(), EndDateTime__c = Datetime.now().addDays(30));
            insert variation;

            Account acc = IC_TestFactory.createAccount();
            insert acc;

            Account acc2 = IC_TestFactory.createAccount();
            insert acc2;
            List<Brand_Experience_Variation_Member__c> members = new List<Brand_Experience_Variation_Member__c>{ new Brand_Experience_Variation_Member__c (Brand_Experience_Variation__c = variation.Id, GuestNumber__c=2, Nb_Appointment__c=3, client__c = acc.Id, Assigned_CA__c=testUser.Id),
                                                                                                                    new Brand_Experience_Variation_Member__c (Brand_Experience_Variation__c = variation.Id, GuestNumber__c=1, Nb_Appointment__c=1, client__c = acc2.Id, Assigned_CA__c=testUser.Id) };
            insert members;                                                                               
        }
    }
    @isTest
    static void variationTest() {

        User testUser = [SELECT Id FROM user WHERE Username = 'icon.user@louisvuitton.com.test123'];
        Brand_Experience_Variation__c variation = [SELECT Id FROM Brand_Experience_Variation__c limit 1];

        System.runAs(testUser) {
            
            Test.startTest();
            Map<String,Object> config =  ex_invitees_related_list_CTRL.initComponentConfig(variation.Id);
            Test.stopTest();
            
            List<Brand_Experience_Variation_Member__c> invitees = (List<Brand_Experience_Variation_Member__c>)config.get('invitees');
            System.assertEquals(2,invitees.size());
        }
    
    }
}