@isTest
public class Ex_nomination_kpi_controller_TEST {
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
            Id experienceRT = Schema.SObjectType.Brand_Experience__c.getRecordTypeInfosByDeveloperName().get('Experience').getRecordTypeId();
            Id inStoreRT = Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Physical_Event').getRecordTypeId();

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

            Brand_Experience_Variation__c variation = new Brand_Experience_Variation__c (recordTypeId=inStoreRT, Brand_Experience__c = experience.Id, Name = 'test variation', Store__c=store.Id, Nb_Target_Clients__c = 15, StartDateTime__c = Datetime.now(), EndDateTime__c = Datetime.now().addDays(30));
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
            Map<String,Integer> KPIs =  Ex_nomination_kpi_controller.getKPIValues(variation.Id, 'Brand_Experience_Variation__c', new List<String> {'NOMINATED_CLIENT','CONFIRMED_CLIENT', 'APPOINTMENTS_FIELD', 'GUESTS_FIELD'});
            Test.stopTest();
            System.assertEquals(0,KPIs.get('NOMINATED_CLIENT'));
            System.assertEquals(0,KPIs.get('CONFIRMED_CLIENT'));
            System.assertEquals(3,KPIs.get('GUESTS_FIELD'));
            System.assertEquals(4,KPIs.get('APPOINTMENTS_FIELD'));



        }
    }
    @isTest
    static void experienceTest() {

        User testUser = [SELECT Id FROM user WHERE Username = 'icon.user@louisvuitton.com.test123'];

        Brand_Experience__c experience = [SELECT Id FROM Brand_Experience__c limit 1];

        System.runAs(testUser) {
            
            Test.startTest();
            Map<String,Integer> KPIs =  Ex_nomination_kpi_controller.getKPIValues(experience.Id, 'Brand_Experience__c', new List<String> {'GLOBAL_TARGET_CLIENT','GLOBAL_NOMINATED_CLIENT', 'GLOBAL_CONFIRMED_CLIENT', 'GLOBAL_APPOINTMENTS', 'GLOBAL_GUESTS'});
            Test.stopTest();
            System.assertEquals(15,KPIs.get('GLOBAL_TARGET_CLIENT'));
            System.assertEquals(0,KPIs.get('GLOBAL_NOMINATED_CLIENT'));
            System.assertEquals(0,KPIs.get('GLOBAL_CONFIRMED_CLIENT'));
            System.assertEquals(3,KPIs.get('GLOBAL_GUESTS'));
            System.assertEquals(4,KPIs.get('GLOBAL_APPOINTMENTS'));

        }
    }
}