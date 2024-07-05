/**
 * This is a test class for class SO_ChoosePath_CTRL
 * @lastModifiedBy      Ester Mendelson, 14-01-2015
 */

@isTest private class SO_ChoosePath_TEST {
	
    /**
    * [Set database]
    * @scenario         [insert objects to the system]
    * @result           [database to work with]
    * @lastModifiedBy    Ester Mendelson, 28-12-2015
    */

	@testSetup
    private static void settigData() {
        List<SO_Settings__c> settigList = Test.loadData(SO_Settings__c.sObjectType, 'SO_LV_Settings_For_Test_CSV');

        SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
        dataModel.initialization_one(true,true);
    }
    
    @isTest
    private static void test_one() {
        //using SO_ClientAdvisorEnquiryRMS_Utils_MOCK to create request
        Test.setMock(WebServiceMock.class, new SO_ClientAdvisorEnquiryRMS_Utils_MOCK('000'));

        PageReference cPage = System.Page.SO_ChoosePath;
        Test.setCurrentPageReference(cPage);

        Test.startTest();
        SO_ChoosePath_CTRL contr = new SO_ChoosePath_CTRL();
        
        contr.newUser.MANAGEMENT_ZONE_LEVEL__c = SO_Constant_For_Test.JAPAN;
        contr.newUser.MGMT_ZONE_SUB_LEVEL1__c =  SO_Constant_For_Test.EAST;
        contr.newUser.MGMT_ZONE_SUB_LEVEL2__c =  SO_Constant_For_Test.Tokyo_Metro;
        contr.newUser.MGMT_ZONE_SUB_LEVEL3__c =  SO_Constant_For_Test.Tokyo_Metro_2;
        contr.newUser.DefaultStore__c         =  SO_Constant_For_Test.LV_TOKYO_ROPPONGI;
        
        contr.newOpportunity = buildTestOpportunity();
        PageReference pageRef = contr.redirectToClientSearchPage();
        
        System.assert(pageRef.getUrl().contains(System.Page.SO_ClientSearch.getUrl()));
        Test.stopTest();
    }
    
    @isTest
    private static void test_two() {
        //using SO_ClientAdvisorEnquiryRMS_Utils_MOCK to create request
        Test.setMock(WebServiceMock.class, new SO_ClientAdvisorEnquiryRMS_Utils_MOCK('000'));

        PageReference cPage = System.Page.SO_ChoosePath;
        Test.setCurrentPageReference(cPage);

        Test.startTest();
        SO_ChoosePath_CTRL contr = new SO_ChoosePath_CTRL();
        
        contr.newUser.MANAGEMENT_ZONE_LEVEL__c = SO_Constant_For_Test.JAPAN;
        contr.newUser.MGMT_ZONE_SUB_LEVEL1__c =  SO_Constant_For_Test.EAST;
        contr.newUser.MGMT_ZONE_SUB_LEVEL2__c =  SO_Constant_For_Test.Tokyo_Metro;
        contr.newUser.MGMT_ZONE_SUB_LEVEL3__c =  SO_Constant_For_Test.Tokyo_Metro_2;
        contr.newUser.DefaultStore__c         =  SO_Constant_For_Test.LV_TOKYO_ROPPONGI;
        
        contr.newOpportunity = buildTestOpportunity();
        PageReference pageRef = contr.redirectToProductSearchPage();
        
        //System.assert(pageRef.getUrl().contains(System.Page.SO_ProductSearch.getUrl()));
        String storeName = 'Test_' + SO_Constant_For_Test.LV_TOKYO_ROPPONGI;
        Store__c retailStore =[SELECT Id FROM Store__c WHERE Name =:storeName ];
        delete retailStore; 
        pageRef = contr.redirectToProductSearchPage();
        contr.newOpportunity = null;
        pageRef = contr.redirectToProductSearchPage();
        pageRef = contr.redirectToClientSearchPage();

        retailStore = new Store__c(Name = 'Test_' + SO_Constant_For_Test.LV_TOKYO_ROPPONGI
                                                       ,RetailStoreId__c = SO_Constant_For_Test.LV_TOKYO_ROPPONGI);
        
        Database.insert(retailStore); 
        Test.stopTest();
    }
    
    @isTest
    private static void test_dirtyData() {
        //using SO_ClientAdvisorEnquiryRMS_Utils_MOCK to create request
        Test.setMock(WebServiceMock.class, new SO_ClientAdvisorEnquiryRMS_Utils_MOCK('000'));

        PageReference cPage = System.Page.SO_ChoosePath;
        Test.setCurrentPageReference(cPage);

        Test.startTest();
        SO_ChoosePath_CTRL contr = new SO_ChoosePath_CTRL();
        
        contr.newUser.MANAGEMENT_ZONE_LEVEL__c = SO_Constant_For_Test.JAPAN;
        contr.newUser.MGMT_ZONE_SUB_LEVEL1__c =  SO_Constant_For_Test.EAST;
        contr.newUser.MGMT_ZONE_SUB_LEVEL2__c =  SO_Constant_For_Test.Tokyo_Metro;
        contr.newUser.MGMT_ZONE_SUB_LEVEL3__c =  SO_Constant_For_Test.Tokyo_Metro_2;
        contr.newUser.DefaultStore__c         =  'aaaa';
        
        contr.newOpportunity = buildTestOpportunity();
        PageReference pageRef = contr.redirectToClientSearchPage();
        System.assert(pageRef == null);
        pageRef = contr.redirectToProductSearchPage();
        System.assert(pageRef == null);

        Test.stopTest();
    }

    private static Opportunity buildTestOpportunity() {
        return 
            new Opportunity(
            	Name = 'Test Class Opp'
                ,SPO_CACode__c = 'WEB'
            );
	}
}