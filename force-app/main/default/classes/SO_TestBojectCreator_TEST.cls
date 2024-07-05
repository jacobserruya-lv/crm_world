@isTest
public with sharing class SO_TestBojectCreator_TEST {
    @testSetup
    static void testSetup(){
        SO_TestBojectCreator tb = new SO_TestBojectCreator();

        Account acc = LV_TestFactory.createAccount();
        insert acc;

        Opportunity opp1 = new Opportunity(Name = 'opp1', StageName = 'Creation in progress', CloseDate = Date.today());
        Opportunity opp2 = new Opportunity(Name = 'opp2', StageName = 'Creation in progress', CloseDate = Date.today());
        List<Opportunity> opportunities = new List<Opportunity>{opp1, opp2};
        insert opportunities;

        Store__c store = new Store__c();
        insert store;

        ProductReferential__c prodRef = new ProductReferential__c(SKUCode__c = 'SKUTEST');
        insert prodRef;

        tb.client = acc;
        tb.opp1 = opportunities[0];
        tb.opp2 = opportunities[1];
        tb.retailStore = store;
        tb.prodRef = prodRef;
    }

    @isTest
    static void test_initialization_one(){
        SO_TestBojectCreator tb = new SO_TestBojectCreator();
        tb.initialization_one(true, true);
    }

    @isTest
    static void test_customSettingForClientSearchInit(){
        SO_TestBojectCreator tb = new SO_TestBojectCreator();
        tb.customSettingForClientSearchInit();
    }

    /*
    @isTest
    static void test_createAccount(){
        SO_TestBojectCreator tb = new SO_TestBojectCreator();
        tb.createAccount();
    }
    */
}