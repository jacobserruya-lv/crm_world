@isTest
public with sharing class BL_Experience_Batch_Variation_Notif_TEST {
   
    
    @TestSetup
	static void createTestData() {

		Account acc = IC_TestFactory.createAccount();
		insert acc;

		Store__c store = new Store__c(Name = 'test', RetailStoreId__c = 'A06' ,storecountry__c ='FRANCE' ,ISO3_Code__c='FRA');
		insert store;

		User u = IC_Test_Common.prepareTestUser('System Administrator');
		u.DefaultStore__c = 'A06';
		u.WWEmployeeNumber__c = 'WW198765467';
		insert u;

        User ca = IC_Test_Common.prepareTestUser('ICON_SA');
		ca.DefaultStore__c = 'A06';
		ca.WWEmployeeNumber__c = 'WW198765';
		insert ca;

        Brand_Experience__c ex = new Brand_Experience__c();
        ex.Name = 'test';
        ex.Status__c = 'Ongoing';
        ex.Experience_StartDate__c =  DateTime.Now().AddDays(45);
        ex.Experience_EndDate__c = DateTime.Now().AddDays(72) ;
        ex.RecordTypeId = BL_Experience_Variation_Utils.getRecordTypeExperience('Experience');
    
        insert ex;

        Brand_Experience_Variation__c exVar = new Brand_Experience_Variation__c();
        exVar.Brand_Experience__c = ex.Id;
        exVar.Store__c = store.Id;
        exVar.Name = 'test';
        exVar.Status__c = 'Draft';
        exVar.StartDateTime__c = DateTime.Now().AddDays(46);
        exVar.EndDateTime__c = DateTime.Now().AddDays(47);
        exVar.RecordTypeId = Schema.SObjectType.Brand_Experience_Variation__c.getRecordTypeInfosByDeveloperName().get('Physical_Event').getRecordTypeId();
        exVar.TargetingMethod__c = 'Manual';
        exVar.Type__c = 'Event';
        exVar.SubType__c = 'Physical';
        insert exVar;
        
        exVar.Status__c = 'Ready';
        update exVar;

        Brand_Experience_Variation_Member__c exMember = new Brand_Experience_Variation_Member__c();
        exMember.Brand_Experience_Variation__c = exVar.Id;
        exMember.Client__c = acc.Id;
        exMember.NominationStatus__c = 'Pending';
        exMember.Assigned_CA__c = ca.Id;
        
        insert exMember;

        Country__c country = new Country__c(Name = 'France',iso3code__c = 'FRA',tech_duplicate__c='France' ,iso2code__c ='FR', HasOtherValue__c=false);
        Language2__c language = new Language2__c(Name='FRANCE', Iso2Code__c = 'FR', Iso3Code__c = 'FRA');

        insert new List<SObject> {country ,language};
        CountryLanguage__c countryLang = new CountryLanguage__c(Name = 'France',   Default__c=true,   ATG_Locale__c = 'fra-fr', Salesforce_Locale__c = 'fr_FR' , Country__c = country.Id ,Language__c=language.id);

        insert new List<SObject> {countryLang };
	}

    @isTest 
    static void runBatch(){

        BL_Experience_Scheduler_Variation_Notif myScheduler = new BL_Experience_Scheduler_Variation_Notif();
        User u = [SELECT id,DefaultStore__c FROM user Where WWEmployeeNumber__c = 'WW198765'];

        system.runAs(u){
    
            Test.startTest();
                String sch = '0 0 23 L * ?';
                System.schedule('Test check', sch, myScheduler);
            Test.stopTest();
        }
    } 
}