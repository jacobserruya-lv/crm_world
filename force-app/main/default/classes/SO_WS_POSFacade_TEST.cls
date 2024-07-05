@isTest
public with sharing class SO_WS_POSFacade_TEST {
    @testSetup
    static void testSetup(){
        Store__c store = LV_TestFactory.createStore('Test store', 'Store', 'A00', 'FRANCE', 'EUR', 'Open');
        store.SalesServices__c = true;
        insert store;

        Opportunity opp = new Opportunity(
            Name = 'opp1',
            StageName = 'Creation in progress',
            CloseDate = Date.today(),
            SPO_CACode__c = '123456'
            );
        insert opp;
        
    }


    @isTest
    static void test_class_SO_WS_RMS_DoClientEnquiry(){
        Test.startTest();
         Test.setMock(WebServiceMock.class, new SO_WS_POSFacade_MOCK('000', 'test_class_SO_WS_RMS_DoClientEnquiry', null));
         
         SO_WS_RMS_DoClientEnquiryMulesoft.DataInput dataIn = new SO_WS_RMS_DoClientEnquiryMulesoft.DataInput ();
        dataIn.storeCode = 'A06';
        dataIn.RMSId = 'virginie';
        dataIn.wwRmsClientCode = 'legrand';
        SO_WS_RMS_DoClientEnquiryMulesoft ws = new SO_WS_RMS_DoClientEnquiryMulesoft();

        SO_WS_RMS_DoClientEnquiryMulesoft.Result result = ws.doClientEnquiry(dataIn);

        System.assertNotEquals(null, result); 
        Test.setMock(WebServiceMock.class, new SO_WS_POSFacade_MOCK('001', 'test_class_SO_WS_RMS_DoClientEnquiry', null));
         
        SO_WS_RMS_DoClientEnquiryMulesoft.DataInput dataIn2 = new SO_WS_RMS_DoClientEnquiryMulesoft.DataInput ();
       dataIn.storeCode = 'A06';
       dataIn.RMSId = 'virginie';
       dataIn.wwRmsClientCode = 'legrand';
       SO_WS_RMS_DoClientEnquiryMulesoft ws2 = new SO_WS_RMS_DoClientEnquiryMulesoft();

       SO_WS_RMS_DoClientEnquiryMulesoft.Result result2 = ws.doClientEnquiry(dataIn);
       System.assertNotEquals(null, result); 
       
        try{
             Account clientSearchResult1 = SO_WS_POSFacade.clientSearch('A00', '123456789', '01295Q');
        }
        catch(Exception error){
            System.debug(error);
        }

        Test.setMock(WebServiceMock.class, new SO_WS_POSFacade_MOCK('000', 'test_class_SO_WS_RMS_DoClientEnquiry', '1'));
        Account clientSearchResult2 = SO_WS_POSFacade.clientSearch('A00', '123456789', '987654321');
        
        Test.setMock(WebServiceMock.class, new SO_WS_POSFacade_MOCK('000', 'test_class_SO_WS_RMS_DoClientEnquiry', '2'));
        Account clientSearchResult3 = SO_WS_POSFacade.clientSearch('A00', '123456789', '987654321');

        Test.setMock(WebServiceMock.class, new SO_WS_POSFacade_MOCK('000', 'test_class_SO_WS_RMS_DoClientEnquiry', '3'));
        Account clientSearchResult4 = SO_WS_POSFacade.clientSearch('A00', '123456789', '987654321');

        Test.setMock(WebServiceMock.class, new SO_WS_POSFacade_MOCK('000', 'test_class_SO_WS_RMS_DoClientEnquiry', '4'));
        Account clientSearchResult5 = SO_WS_POSFacade.clientSearch('A00', '123456789', '987654321');

        String callToTestResult = SO_WS_RMS_DoClientEnquiryMulesoft.callToTest();
        
        Test.stopTest();
    }

    @isTest
    static void test_SO_WS_RMS_DoClientSearchMulesoft(){
        SO_Util.SearchClientData dataSO_Util = new SO_Util.SearchClientData();
        Test.startTest();
        try{
            SO_WS_RMS_DoClientSearchMulesoft.Result baba = SO_WS_POSFacade.clientSearchMulesoft(dataSO_Util);
       }
       catch(Exception error){
            System.debug(error);
       }
        Test.stopTest();
    }


   // @isTest
    // static void test_verifyClientAdvisorEnquiry(){
    //     Test.startTest();
    //     Test.setMock(WebServiceMock.class, new SO_ClientAdvisorEnquiryRMS_Utils_MOCK('000'));

    //     try{
    //         SO_WS_POSFacade.SO_ClientAdvisorEnquiryResults clientAdvisorEnquiryResults = SO_WS_POSFacade.verifyClientAdvisorEnquiry('', 'A00');
    //     }
    //     catch(Exception error){
    //         System.assertEquals('The store code and the CA Code are mandatory', error.getMessage());
    //     }

    //     SO_WS_POSFacade.SO_ClientAdvisorEnquiryResults clientAdvisorEnquiryResults = SO_WS_POSFacade.verifyClientAdvisorEnquiry('123456', 'A00'); 
        
    //     Test.stopTest();
    // }


    // @isTest
    // static void test_verifyCaCodeWS(){
    //     Test.startTest();
    //     Test.setMock(WebServiceMock.class, new SO_ClientAdvisorEnquiryRMS_Utils_MOCK('000'));
    //     Boolean verifyCaCodeWS1 = SO_WS_POSFacade.verifyCaCodeWS('A00', '123456');
    //     Test.stopTest();
    // }

    // @isTest
    // static void test_createDepositOrPayment14(){

    //     Store__c storeOpp = new Store__c();
    //     storeOpp.SalesServices__c = true;
    //     insert storeOpp;

    //     Opportunity opp = new Opportunity();
    //     opp.SPO_Store__c = storeOpp.Id;
    //     Test.startTest();
    //     try{
    //     SO_WS_POSFacade.SO_CreateUpdateRmsDepositPaymentResult createUpdateResult5 = SO_WS_POSFacade.createDepositOrPayment(true, opp);
    //     }
    //     catch(Exception e){
    //         system.debug(e);
    //     }
    //     Test.stopTest();
    // }


    // @isTest
    // static void test_createDepositOrPayment2(){
    //     Opportunity opp = new Opportunity(
    //         Name = 'opp2',
    //         StageName = 'Creation in progress',
    //         CloseDate = Date.today(),
    //         SPO_EstimatedDistributionTime__c = 1,
    //         SPO_EstimatedProductionTimeMonths__c = 1,
    //         OrderNumber__c = '1234',
    //         SPO_RMSClientId__c = '4321',
    //         SPO_CACode__c = 'A00',
    //         SPO_DepositAmount__c = 10.00,
    //         SPO_SpecialOrderSKUCode__c = '54321',
    //         SPO_UnitRetailPriceQuotation__c = 10,
    //         SPO_SkuQuantity__c = 10
    //     );
    //     insert opp;
        
    //     Test.startTest();
    //     Test.setMock(WebServiceMock.class, new SO_CreateDepositPaymentRMS_Utils_MOCK('000'));
    //     SO_WS_POSFacade.SO_CreateUpdateRmsDepositPaymentResult createUpdateResult1 = SO_WS_POSFacade.createDepositOrPayment(true, opp, false);
    //     SO_WS_POSFacade.SO_CreateUpdateRmsDepositPaymentResult createUpdateResult2 = SO_WS_POSFacade.createDepositOrPayment(false, opp, false);

    //     Opportunity selectedOpp = [SELECT SPO_EstimatedDistributionTime__c,
    //                             SPO_EstimatedProductionTimeMonths__c,
    //                             SPO_Estimated_date_NOMTO__c,
    //                             SPO_StoreCode__c,
    //                             CreatedDate,
    //                             OrderNumber__c,
    //                             SPO_RMSClientId__c,
    //                             SPO_wwRMSClientId__c,
    //                             SPO_CACode__c,
    //                             SPO_DepositAmount__c,
    //                             SPO_SpecialOrderSKUCode__c,
    //                             SPO_UnitRetailPriceQuotation__c,
    //                             SPO_SkuQuantity__c
    //                             FROM Opportunity
    //                             WHERE Name = 'opp2'];
    //     System.debug('selectedOpp = ' + selectedOpp);
    //     Test.stopTest();
    // }

    // @isTest
    // static void test_createDepositOrPayment10(){

    //     List<Store__c > storList = [SELECT ID, Store__c.SalesServices__c FROM Store__c WHERE SalesServices__c = true LIMIT 1];

    //     Opportunity opp = new Opportunity();
    //     opp.SPO_Store__r = storList[0];
    //     opp.Name = 'Test test';
    //     opp.StageName = 'In progress';
    //     opp.CloseDate = system.today();
    //     opp.SPO_EstimatedDistributionTime__c = 5;
    //     opp.SPO_EstimatedProductionTimeMonths__c = 5;
    //     insert opp;

    //     Test.startTest();
    //     try{
    //     SO_WS_POSFacade.SO_CreateUpdateRmsDepositPaymentResult createUpdateResult1 = SO_WS_POSFacade.createDepositOrPayment(true, opp, true);
    //     }
    //     catch(Exception e){
    //         system.debug(e);
    //     }
    //     Test.stopTest();
    // }

    // @isTest  // MIY-2154
    // static void test_SO_UtilSearchClientData2(){
    //     SO_Util.SearchClientData dataSO_Util = new SO_Util.SearchClientData();
    //     Test.startTest();
    //     try{
    //         SO_WS_RMS_DoClientSearch.Result baba = SO_WS_POSFacade.clientSearch(null);
    //    }
    //    catch(Exception error){
    //         System.debug(error);
    //    }
    //     Test.stopTest();
    // }
   
    @isTest
    static void test_SO_WS_RMS_DoClientSearchMulesoft2(){
        Account baba = new Account(Name='hello');
        SO_WS_RMS_DoClientSearchMulesoft.ResultLine result = new SO_WS_RMS_DoClientSearchMulesoft.ResultLine();
        
        SO_Util.SearchClientData dataSO_Util = new SO_Util.SearchClientData();
        Test.startTest();
        try{
            SO_WS_RMS_DoClientSearchMulesoft.Result bobo = SO_WS_POSFacade.clientSearchMulesoft(null);
       }
       catch(Exception error){
            System.debug(error);
       }
        
        try{
            SO_WS_RMS_DoClientSearchMulesoft.callToTest();
       }
       catch(Exception error){
            System.debug(error);
       }

        
        try{
            Account zoobi = SO_WS_RMS_DoClientSearchMulesoft.MapRmsClientIntoSfdcClient(result, baba);
       }
       catch(Exception error){
            System.debug(error);
       }
        Test.stopTest();
    }
   
   
    // @isTest  // MIY-2154
    // static void test_SO_UtilSearchClientData(){
    //     SO_Util.SearchClientData dataSO_Util = new SO_Util.SearchClientData();
    //     Test.startTest();
    //     try{
    //         SO_WS_RMS_DoClientSearch.Result baba = SO_WS_POSFacade.clientSearch(dataSO_Util);
    //    }
    //    catch(Exception error){
    //         System.debug(error);
    //    }
    //     Test.stopTest();
    // }
}