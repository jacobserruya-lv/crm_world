@isTest
private class ExclusiveExperienceTrigger_TEST {
    
    @isTest 
    static void test_trigger() {
        
        Test.StartTest();

        // CREATE PRE-REQUIRED DATA

        // Create Settings
        IDENTITY_TestFactory.createSettings();

        // Create Country-Languages
        IDENTITY_TestFactory.createCountryLanguageSettings();

        // Create Account
        String code = String.valueOf(Math.round(Math.random() * 100000));
        Account acc = new Account(
            LastName = 'lastName',
            FirstName = 'firstName',
            PersonEmail = code+'test@test.com',  
            PrimaryCountry__pc = 'BELGIUM',
            Salutation = '02',
            HomeAddressCountryCode__pc = 'BEL',
            PreferredLanguage__pc = 'FRA',
            DREAMID__c = '87654321'
        );
        insert acc;

        Account acc2 = new Account(
            LastName = 'lastName2',
            FirstName = 'firstName2',
            PersonEmail = code+'test2@test2.com',  
            PrimaryCountry__pc = 'BELGIUM',
            Salutation = '02',
            HomeAddressCountryCode__pc = 'BEL',
            AttachedStoreCountry__pc = 'FRA',
            DREAMID__c = '12345678'
        );
        insert acc2;

        Account acc3 = new Account(
            LastName = 'lastName3',
            FirstName = 'firstName3',
            PersonEmail = code+'test3@test3.com',
            PersonMobilePhone = '86150082828691',  
            PrimaryCountry__pc = 'CHINA',
            Salutation = '02',
            HomeAddressCountryCode__pc = 'CHN',
            AttachedStoreCountry__pc = 'CHN',
            DREAMID__c = '12312345'
        );
        insert acc3;

        // Create MergedClient record
        MergedClients__c mc = new MergedClients__c(
            Name = 'test-merge-client',
            Absorbed_DreamId__c = '12345678',
            MasterClient__c = '87654321'
        );
        insert mc;

        // Get XXPR Picklist values according to Org
        Schema.DescribeFieldResult XXPR_Typology = Exclusive_Experience__c.Typology__c.getDescribe();
        Schema.sObjectField fieldTypology = XXPR_Typology.getSObjectField();
        List<PicklistEntry> picklistValuesTypology = fieldTypology.getDescribe().getPicklistValues();        
        
        Schema.DescribeFieldResult XXPR_OfferCode = Exclusive_Experience__c.Offer_Code__c.getDescribe();
        Schema.sObjectField fieldOfferCode = XXPR_OfferCode.getSObjectField();
        List<PicklistEntry> picklistValuesOfferCode = fieldOfferCode.getDescribe().getPicklistValues();
        
        // Create XXPR
        Exclusive_Experience__c xxpr1 = new Exclusive_Experience__c(
            Account_Id__c = acc.Id,
            Dream_Id__c = acc.DREAMID__c,
            Typology__c = picklistValuesTypology[0].getValue(),
            Offer_Code__c = picklistValuesOfferCode[0].getValue()
        ); 

        Exclusive_Experience__c xxpr2 = new Exclusive_Experience__c(
            Account_Id__c = acc2.Id,
            Dream_Id__c = acc2.DREAMID__c,
            Typology__c = picklistValuesTypology[0].getValue(),
            Offer_Code__c = picklistValuesOfferCode[0].getValue()
        );       
             
        Exclusive_Experience__c xxpr3 = new Exclusive_Experience__c(
            Account_Id__c = acc3.Id,
            Dream_Id__c = acc3.DREAMID__c,
            Typology__c = picklistValuesTypology[0].getValue(),
            Offer_Code__c = picklistValuesOfferCode[0].getValue()
        );

        // TEST CASE 1: TRIGGER OK
        insert xxpr1;

        // TEST CASE 2: ABSORBED DREAM ID
        delete xxpr1;
        insert xxpr2;

        // TEST CASE 3: CHINESE CLIENT
        delete xxpr2;
        insert xxpr3;

        Test.StopTest();
    }

    /*
    *** DESCRIPTION Custom Exception Wrapper
    */
    public class ExclusiveExperienceTestException extends Exception {}
}