@isTest
public with sharing class ICX_TWIST_OOB_TEST {
    public ICX_TWIST_OOB_TEST() {

    }
    @TestSetup
    static void makeData(){
        List<Country__c> countries = new List<Country__c>{
            new Country__c(Name='SAUDI ARABIA',    tech_duplicate__c = 'saudia arabia',    Iso2Code__c = 'SA', Iso3Code__c = 'SAU'),
            new Country__c(Name='FRANCE', tech_duplicate__c='France', Iso2Code__c = 'FR', Iso3Code__c='FRA')    
        };
        insert countries;

        List<Language2__c> languages = new List<Language2__c>{
            new Language2__c(Name='ARABIC', Iso2Code__c = 'AR', Iso3Code__c = 'ARA'),
            new Language2__c(Name='ENGLISH', Iso2Code__c = 'EN', Iso3Code__c = 'ENG'),
            new Language2__c(Name='FRENCH', Iso2Code__c = 'FR', Iso3Code__c = 'FRA')
        };
        insert languages;

        List<Country__c> c = [SELECT Id, Name FROM Country__c WHERE Name IN ('SAUDI ARABIA')];
        List<Language2__c> l = [SELECT Id, Name FROM Language2__c WHERE Name IN ('ARABIC', 'ENGLISH')];
        List<Country__c> c2 = [SELECT Id, Name FROM Country__c WHERE Name IN ('FRANCE')];
        List<Language2__c> l2 = [SELECT Id, Name FROM Language2__c WHERE Name IN ('FRENCH')];
        
        List<CountryLanguage__c> cl = new List<CountryLanguage__c>{
            new CountryLanguage__c(Name = 'Saudi arabic',      ATG_Locale__c = 'ara-ae', Salesforce_Locale__c = 'ar_SA', Country__c = c[0].Id, Language__c = l[0].Id, Default__c = false, Dispatch_Country__c = 'SA',OOB_Local__c='',Mulesoft_Local__c=''),
            new CountryLanguage__c(Name = 'Saudi english',     ATG_Locale__c = 'eng-ae', Salesforce_Locale__c = 'ar_SA', Country__c = c[0].Id, Language__c = l[1].Id, Default__c = true, Dispatch_Country__c = 'SA', OOB_Local__c='eng-sa',Mulesoft_Local__c='eco-eu'),
            new CountryLanguage__c(Name = 'France', ATG_Locale__c = 'fra-fr', Salesforce_Locale__c = 'fr_FR', Country__c = c2[0].Id, Language__c = l2[0].Id, Default__c = true, Dispatch_Country__c = '', OOB_Local__c='fra-fr',Mulesoft_Local__c='eco-eu',Cart_Translation__c ='selection' )
        };        
        insert cl;

        OOB_Setting__c orgDefault = new OOB_Setting__c();
        orgDefault.SetupOwnerId=UserInfo.getOrganizationId();
        orgDefault.VisibilityCountryIso2__c='SA;AE';
        insert orgDefault;

      
    }

    @isTest
    public static void isIndentityUser_Test() {
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        Test.startTest();
        User result= ICX_TWIST_OOB.IsIdentityUser(acc.id);
        System.assert(result == null);
        result= ICX_TWIST_OOB.activateIdentityUser(acc.id);
        System.assert(result == null);
        Test.stopTest();
        
    }



    

    @isTest
    public static void getRedirectionEndpoint_TEST()
    {
    

        Id profileId = [SELECT Id FROM Profile WHERE Name='ICONiCS_SA' LIMIT 1].Id;


        User currentUser = ICX_TestFactory.createUser(profileId);
        currentUser.Country__c='SAUDI ARABIA';
        insert currentUser;

        
        String local='';
        Test.startTest();
        System.runAs(currentUser) {
            
            local = ICX_TWIST_OOB.getRedirectionEndpoint('/homepage', null);
        }
        Test.stopTest();
        System.assertEquals('eng-ae/homepage?dispatchCountry=SA',local);
    }

    @isTest
    public static void getUserLocal_TEST()
    {
        Id profileId = [SELECT Id FROM Profile WHERE Name='ICONiCS_SA' LIMIT 1].Id;


        User currentUser = ICX_TestFactory.createUser(profileId);
        currentUser.Country__c='SAUDI ARABIA';
        insert currentUser;

        String local;
        Test.startTest();
        System.runAs(currentUser)
        {

            local = ICX_TWIST_OOB.getUserLocal(null);
        }
        Test.stopTest();
        System.assertEquals('eng-sa',local);

    }

    @isTest
    public static void getSFAgentAccessToken_TEST()
    {
    

        Id profileId = [SELECT Id FROM Profile WHERE Name='ICONiCS_SA' LIMIT 1].Id;


        User currentUser = ICX_TestFactory.createUser(profileId);
        insert currentUser;


        Test.startTest();
        System.runAs(currentUser)
        {
        String accessToken = ICX_TWIST_OOB.getSFAgentAccessToken();
        }
        Test.stopTest();
    }

    @isTest
    public static void getOOBEndpoint_TEST()
    {
        Id profileId = [SELECT Id FROM Profile WHERE Name='ICONiCS_SA' LIMIT 1].Id;


        User currentUser = ICX_TestFactory.createUser(profileId);
        currentUser.Country__c='SAUDI ARABIA';
        insert currentUser;

        Test.startTest();
        System.runAs(currentUser)
        {   
            MuleSoft_API_Callout__mdt endpoint = ICX_TWIST_OOB.getOOBEndpoint();
            Test.stopTest();
        }
    }

    @isTest
    public static void getMuleSoftAPICallout_TEST()
    {
        Id profileId = [SELECT Id FROM Profile WHERE Name='ICONiCS_SA' LIMIT 1].Id;


        User currentUser = ICX_TestFactory.createUser(profileId);
        currentUser.Country__c='SAUDI ARABIA';
        insert currentUser;

        Test.startTest();
        System.runAs(currentUser)
        {
        MuleSoft_API_Callout__mdt endpoint = ICX_TWIST_OOB.getOOBEndpoint();
        MuleSoft_API_Callout__mdt endpoint2 = ICX_TWIST_OOB.getOOBInitCartEndpoint();

        }
        Test.stopTest();
    }

    @isTest
    public static void getUserCountryIsoCode2_TEST()
    {
        Id profileId = [SELECT Id FROM Profile WHERE Name='ICONiCS_SA' LIMIT 1].Id;


        User currentUser = ICX_TestFactory.createUser(profileId);
        currentUser.Country__c='SAUDI ARABIA';
        insert currentUser;

        String UserCountry;
        Test.startTest();
        System.runAs(currentUser)
        {
            UserCountry =  ICX_TWIST_OOB.getUserCountryIsoCode2();
        }
        Test.stopTest();
        System.assertEquals('SA',UserCountry);


    }

    
    @isTest
    public static void OOBVisibleByCountry_TEST()
    {
        Id profileId = [SELECT Id FROM Profile WHERE Name='ICONiCS_SA' LIMIT 1].Id;


        User currentUser = ICX_TestFactory.createUser(profileId);
        currentUser.Country__c='SAUDI ARABIA';
        insert currentUser;

        Boolean visible = false;
        Test.startTest();
        System.runAs(currentUser) {

            visible = ICX_TWIST_OOB.OOBVisibleByCountry();
        }
        Test.stopTest();
        System.assertEquals(true,visible);

    }

    @isTest
    public static void getCartTranslation_TEST(){
        String translation = 'cart';
        Test.startTest();
        
        translation = ICX_TWIST_OOB.getCartTranslation('FR');
        
        Test.stopTest();
        
        System.assertEquals('selection',translation);
        
    }
   

}