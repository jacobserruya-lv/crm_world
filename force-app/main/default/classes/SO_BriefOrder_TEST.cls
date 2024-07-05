/**
 * This is a test class for class SO_BriefOrder_CTRL
 * @createdBy           Ester Mendelson, 29-12-2015
 * @lastModifiedBy      Ester Mendelson, 14-01-2015
 */

 @isTest
private class SO_BriefOrder_TEST {

    ///**
    //* [Set database]
    //* @scenario         [insert objects to the system]
    //* @result           [database to work with]
    //* @createdBy      
    //* @lastModifiedBy    Ester Mendelson, 28-12-2015
    //*/
    
    //@testSetup static void setUp() {
    //    SO_TestObjectCreator dataModel = new SO_TestObjectCreator();
    //    dataModel.initialization_one(true,true);
    //}

    //@isTest static void buildMixHistoryForEachFirmOrderBucketsTest()
    //{
    //    PageReference ref =  new PageReference('/apex/SO_BriefOrder');
    //    Test.setCurrentPage(ref);

    //    List<ProductReferential__c> proList = [SELECT ID,SKUCode__c FROM ProductReferential__c WHERE name ='PR-001' LIMIT 1];
    //    List<Opportunity> opp =[SELECT StageName,SPO_MarketingApproval__c,SPO_CentralApproval__c,SPO_ZoneApproval__c,ID,SPO_ProductCategory__c,OwnerId,SPO_BaseSKURefmodelSKU__c, SPO_CACode__c, Name FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
    //    opp[0].SPO_ProductCategory__c = 'Accessories';
    //    opp[0].SPO_CentralApproval__c ='Yes';
    //    opp[0].SPO_MarketingApproval__c = 'Yes';
    //    opp[0].SPO_ZoneApproval__c = 'Yes';
    //    opp[0].StageName = 'Brief in progress';
    //    opp[0].SPO_BaseSKURefmodelSKU__c = proList[0].id;
    //    opp[0].SPO_Free__c = true;
    //    opp[0].SPO_SkuQuantity__c = 2;
    //    update opp[0];

    //    SPO_FirmOrder__c frimOrder = new SPO_FirmOrder__c(LineNumber__c = 1,SPO_BriefName__c = opp[0].id, SPO_FirmOrderStatus__c ='A', SPO_Substatus__c = 'B');
    //    insert frimOrder;

    //    ApexPages.currentPage().getParameters().put('id', opp[0].id);
    //    ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);

    //    SO_BriefOrder_CTRL ctrl = new SO_BriefOrder_CTRL(sc);

    //    Map<Id, List<SO_BriefOrder_CTRL.orderDetailsHistory_Wrapper>> firmOrderHistoryByFirmOrderIdMap = new Map<Id, List<SO_BriefOrder_CTRL.orderDetailsHistory_Wrapper>>();
    //    Map<Id, SPO_FirmOrder__c> firmOrdersMap = new Map<Id, SPO_FirmOrder__c>(new List<SPO_FirmOrder__c>{frimOrder});
    //    for(Id firmOrderId : firmOrdersMap.keySet())
    //    {
    //        if(!firmOrderHistoryByFirmOrderIdMap.containsKey(firmOrderId))
    //        {
    //            firmOrderHistoryByFirmOrderIdMap.put(firmOrderId, new List<SO_BriefOrder_CTRL.orderDetailsHistory_Wrapper>());
    //        }
    //    }

    //    List<SPO_FirmOrder__History> firmOrderStatusHistoryList = new List<SPO_FirmOrder__History>
    //    {
    //        new SPO_FirmOrder__History(Field = 'SPO_FirmOrderStatus__c', ParentId = frimOrder.Id)
    //    };

    //    List<SPO_FirmOrder__History> firmOrderSubStatusHistoryList = new List<SPO_FirmOrder__History>
    //    {
    //        new SPO_FirmOrder__History(Field = 'SPO_Substatus__c', ParentId = frimOrder.Id)
    //    };

    //    List<OpportunityHistory> opportunityHistoryList = new List<OpportunityHistory>
    //    {
    //        new OpportunityHistory()
    //    };

    //    Test.startTest();
    //    ctrl.buildMixHistoryForEachFirmOrderBuckets(firmOrderHistoryByFirmOrderIdMap, firmOrderStatusHistoryList, firmOrderSubStatusHistoryList, opportunityHistoryList);
    //    Test.stopTest();
    //}

    //@isTest static void getUserRoleAndReadonlyMode() {

    //    PageReference ref =  new PageReference('/apex/SO_BriefOrder');
    //    Test.setCurrentPage(ref);

    //    List<Opportunity> opp = [SELECT StageName,SPO_MarketingApproval__c,SPO_CentralApproval__c,SPO_ZoneApproval__c,ID,SPO_ProductCategory__c,OwnerId,SPO_BaseSKURefmodelSKU__c, SPO_CACode__c, Name FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
    //    opp[0].SPO_ProductCategory__c = 'Accessories';
    //    opp[0].SPO_CentralApproval__c ='Yes';
    //    opp[0].SPO_MarketingApproval__c = 'Yes';
    //    opp[0].SPO_ZoneApproval__c = 'Yes';
    //    opp[0].StageName = 'Brief in progress';
    //    update opp[0];

    //    SPO_FirmOrder__c frimOrder = new SPO_FirmOrder__c(LineNumber__c = 1,SPO_BriefName__c = opp[0].id);
    //    insert frimOrder;

    //    ApexPages.currentPage().getParameters().put('id', opp[0].id);

    //    ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);
    //    SO_BriefOrder_CTRL ctrl = new SO_BriefOrder_CTRL(sc);
    //    ctrl.getUserRoleAndReadonlyMode();
    //    //system.assertEquals(ctrl.isReadonlyMode,false);
    //}

    //@isTest static void depositSentOppStatus() {

    //    PageReference ref =  new PageReference('/apex/SO_BriefOrder');
    //    Test.setCurrentPage(ref);

    //    List<Opportunity> opp =[SELECT StageName,SPO_MarketingApproval__c,SPO_CentralApproval__c,SPO_ZoneApproval__c,ID,SPO_ProductCategory__c,OwnerId,SPO_BaseSKURefmodelSKU__c, SPO_CACode__c, Name FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
    //    opp[0].SPO_ProductCategory__c = 'Accessories';
    //    opp[0].SPO_CentralApproval__c ='Yes';
    //    opp[0].SPO_MarketingApproval__c = 'Yes';
    //    opp[0].SPO_ZoneApproval__c = 'Yes';
    //    opp[0].StageName = 'Creation in Progress';
    //    update opp[0];

    //    SPO_FirmOrder__c frimOrder = new SPO_FirmOrder__c(LineNumber__c = 1,SPO_BriefName__c = opp[0].id);
    //    insert frimOrder;

    //    ApexPages.currentPage().getParameters().put('id', opp[0].id);
    //    ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);

    //    SO_BriefOrder_CTRL ctrl = new SO_BriefOrder_CTRL(sc);
    //    ctrl.getUserRoleAndReadonlyMode();
    //   // system.assertEquals(ctrl.isReadonlyMode,false);
    //}

    //@isTest static void allPageFunction() {
    //    //using SO_ClientAdvisorEnquiryRMS_Utils_MOCK to create request
    //    Test.setMock(WebServiceMock.class, new SO_ClientAdvisorEnquiryRMS_Utils_MOCK('000'));

    //    PageReference ref =  new PageReference('/apex/SO_BriefOrder');
    //    Test.setCurrentPage(ref);

    //    List<ProductReferential__c> proList = [SELECT ID,SKUCode__c FROM ProductReferential__c WHERE name ='PR-001' LIMIT 1];
    //    List<Opportunity> opp =[SELECT StageName,SPO_MarketingApproval__c,SPO_CentralApproval__c,SPO_ZoneApproval__c,ID,SPO_ProductCategory__c,OwnerId,SPO_BaseSKURefmodelSKU__c, SPO_CACode__c, Name FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
    //    opp[0].SPO_ProductCategory__c = 'Accessories';
    //    opp[0].SPO_CentralApproval__c ='Yes';
    //    opp[0].SPO_MarketingApproval__c = 'Yes';
    //    opp[0].SPO_ZoneApproval__c = 'Yes';
    //    opp[0].StageName = 'Brief in progress';
    //    opp[0].SPO_BaseSKURefmodelSKU__c = proList[0].id;
    //    opp[0].SPO_Free__c = true;
    //    opp[0].SPO_SkuQuantity__c = 2;
    //    update opp[0];
    //    //opp[0].StageName = 'Quotation in progress';
    //    update opp[0];

    //    SPO_FirmOrder__c frimOrder = new SPO_FirmOrder__c(LineNumber__c = 1,SPO_BriefName__c = opp[0].id);
    //    insert frimOrder;

    //    ApexPages.currentPage().getParameters().put('id', opp[0].id);
    //    ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);

    //    SO_BriefOrder_CTRL ctrl = new SO_BriefOrder_CTRL(sc);

    //    Test.startTest();
    //    ctrl.validateEnterance();
    //    ctrl.wishedDate = '06/06/2016';
    //    ctrl.requestQuotation();
    //    ctrl.refreshOpportunityHistoryList();
    //    ctrl.createQuotation();
    //    ctrl.updateQuotation();
    //    ctrl.editQuotation();
    //    ctrl.addDeposit();
    //    ctrl.sendToReferential();
    //    ctrl.createOrderInERP();
    //    ctrl.currentFirmOrderId =frimOrder.id;
    //    ctrl.foStartProduction();
    //    ctrl.launchQA();
    //    ctrl.receivedInStore();
    //    //ctrl.sendToRMS();
    //    ctrl.saveFirmOrderRecords();
    //    ctrl.orderDetailEditMode();
    //    ctrl.saveDateEdit();
    //    ctrl.zoneApprovalClick();
    //    ctrl.buildMixHistoryForEachFirmOrder();
    //    ctrl.cloning();
    //    ctrl.updateBrief();
    //    Test.stopTest();

    //    ctrl.buildMixHistoryForEachFirmOrder();
    //    SO_BriefOrder_CTRL.orderDetailsHistory_Wrapper ohdw = new SO_BriefOrder_CTRL.orderDetailsHistory_Wrapper();
    //    //opp =[SELECT ID,SPO_ProductCategory__c,OwnerId,StageName FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
        
    //}

    //@isTest static void buildMixHistoryForEachFirmOrderTest() {
    //    //using SO_ClientAdvisorEnquiryRMS_Utils_MOCK to create request
    //    Test.setMock(WebServiceMock.class, new SO_ClientAdvisorEnquiryRMS_Utils_MOCK('000'));

    //    PageReference ref =  new PageReference('/apex/SO_BriefOrder');
    //    Test.setCurrentPage(ref);

    //    List<ProductReferential__c> proList = [SELECT ID,SKUCode__c FROM ProductReferential__c WHERE name ='PR-001' LIMIT 1];
    //    List<Opportunity> opp =[SELECT StageName,SPO_MarketingApproval__c,SPO_CentralApproval__c,SPO_ZoneApproval__c,ID,SPO_ProductCategory__c,OwnerId,SPO_BaseSKURefmodelSKU__c, SPO_CACode__c, Name FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
    //    opp[0].SPO_ProductCategory__c = 'Accessories';
    //    opp[0].SPO_CentralApproval__c ='Yes';
    //    opp[0].SPO_MarketingApproval__c = 'Yes';
    //    opp[0].SPO_ZoneApproval__c = 'Yes';
    //    opp[0].StageName = 'Brief in progress';
    //    opp[0].SPO_BaseSKURefmodelSKU__c = proList[0].id;
    //    opp[0].SPO_Free__c = true;
    //    opp[0].SPO_SkuQuantity__c = 2;
    //    update opp[0];
    //    opp[0].StageName = 'Quotation in progress';
    //    update opp[0];

    //    SPO_FirmOrder__c frimOrder = new SPO_FirmOrder__c(LineNumber__c = 1,SPO_BriefName__c = opp[0].id);
    //    insert frimOrder;

    //    ApexPages.currentPage().getParameters().put('id', opp[0].id);
    //    ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);

    //    SO_BriefOrder_CTRL ctrl = new SO_BriefOrder_CTRL(sc);

    //    Test.startTest();
    //    ctrl.createQuotation();
    //    ctrl.addDeposit();
    //    ctrl.sendToReferential();
    //    ctrl.createOrderInERP();
    //    ctrl.currentFirmOrderId =frimOrder.id;
    //    ctrl.foStartProduction();
    //    ctrl.launchQA();
    //    ctrl.receivedInStore();
    //    //ctrl.sendToRMS();
    //    ctrl.saveFirmOrderRecords();
        
    //    Test.stopTest();

    //    ctrl.buildMixHistoryForEachFirmOrder();
    //    SO_BriefOrder_CTRL.orderDetailsHistory_Wrapper ohdw = new SO_BriefOrder_CTRL.orderDetailsHistory_Wrapper();
    //    //opp =[SELECT ID,SPO_ProductCategory__c,OwnerId,StageName FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
        
    //}

    //@isTest static void cloning() {
    //    //using SO_ClientAdvisorEnquiryRMS_Utils_MOCK to create request
    //    Test.setMock(WebServiceMock.class, new SO_ClientAdvisorEnquiryRMS_Utils_MOCK('000'));

    //    PageReference ref =  new PageReference('/apex/SO_BriefOrder');
    //    Test.setCurrentPage(ref);

    //    List<ProductReferential__c> proList = [SELECT ID,SKUCode__c FROM ProductReferential__c WHERE name ='PR-001' LIMIT 1];
    //    List<Opportunity> opp =[SELECT StageName,SPO_MarketingApproval__c,SPO_CentralApproval__c,SPO_ZoneApproval__c,ID,SPO_ProductCategory__c,OwnerId,SPO_BaseSKURefmodelSKU__c, SPO_CACode__c, Name FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
    //    opp[0].SPO_ProductCategory__c = 'Accessories';
    //    opp[0].SPO_CentralApproval__c = 'Yes';
    //    opp[0].SPO_MarketingApproval__c = 'Yes';
    //    opp[0].SPO_ZoneApproval__c = 'Yes';
    //    opp[0].StageName = 'Brief in progress';
    //    //opp[0].StageName = 'Quotation in progress';
    //    opp[0].SPO_BaseSKURefmodelSKU__c = proList[0].id;
    //    opp[0].SPO_Free__c = true;
    //    opp[0].SPO_SkuQuantity__c = 2;
    //    update opp[0];

    //    SPO_FirmOrder__c frimOrder = new SPO_FirmOrder__c(LineNumber__c = 1,SPO_BriefName__c = opp[0].id);
    //    insert frimOrder;

    //    ApexPages.currentPage().getParameters().put('id', opp[0].id);
    //    ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);

    //    SO_BriefOrder_CTRL ctrl = new SO_BriefOrder_CTRL(sc);

    //    Test.startTest();
    //    ctrl.cloning();
    //    Test.stopTest();
    //}

    //@isTest static void buildMixHistoryForEachFirmOrder() {
    //    //using SO_ClientAdvisorEnquiryRMS_Utils_MOCK to create request
    //    Test.setMock(WebServiceMock.class, new SO_ClientAdvisorEnquiryRMS_Utils_MOCK('000'));

    //    PageReference ref =  new PageReference('/apex/SO_BriefOrder');
    //    Test.setCurrentPage(ref);

    //    List<ProductReferential__c> proList = [SELECT ID,SKUCode__c FROM ProductReferential__c WHERE name ='PR-001' LIMIT 1];
    //    List<Opportunity> opp =[SELECT StageName,SPO_MarketingApproval__c,SPO_CentralApproval__c,SPO_ZoneApproval__c,ID,SPO_ProductCategory__c,OwnerId,SPO_BaseSKURefmodelSKU__c, SPO_CACode__c, Name FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
    //    opp[0].SPO_ProductCategory__c = 'Accessories';
    //    opp[0].SPO_CentralApproval__c ='Yes';
    //    opp[0].SPO_MarketingApproval__c = 'Yes';
    //    opp[0].SPO_ZoneApproval__c = 'Yes';
    //    opp[0].StageName = 'Brief in progress';
    //    //opp[0].StageName = 'Quotation in progress';
    //    opp[0].SPO_BaseSKURefmodelSKU__c = proList[0].id;
    //    opp[0].SPO_Free__c = true;
    //    opp[0].SPO_SkuQuantity__c = 2;
    //    update opp[0];

    //    SPO_FirmOrder__c frimOrder = new SPO_FirmOrder__c(LineNumber__c = 1,SPO_BriefName__c = opp[0].id);
    //    insert frimOrder;

    //    ApexPages.currentPage().getParameters().put('id', opp[0].id);
    //    ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);

    //    SO_BriefOrder_CTRL ctrl = new SO_BriefOrder_CTRL(sc);

    //    Test.startTest();
    //    ctrl.refreshOpportunityHistoryList();
    //    ctrl.buildMixHistoryForEachFirmOrder();
    //    Test.stopTest();
    //}

    //@isTest static void sendToRMS() {
    //    //using SO_ClientAdvisorEnquiryRMS_Utils_MOCK to create request
    //    Test.setMock(WebServiceMock.class, new SO_CreateDepositPaymentRMS_Utils_MOCK('000'));

    //    PageReference ref =  new PageReference('/apex/SO_BriefOrder');
    //    Test.setCurrentPage(ref);

    //    List<ProductReferential__c> proList = [SELECT ID,SKUCode__c FROM ProductReferential__c WHERE name ='PR-001' LIMIT 1];
    //    List<Opportunity> opp =[SELECT StageName,SPO_MarketingApproval__c,SPO_CentralApproval__c,SPO_ZoneApproval__c,ID,SPO_RMSClientId__c,SPO_ProductCategory__c, SPO_SpecialOrderSKUCode__c, OwnerId,SPO_BaseSKURefmodelSKU__c, SPO_CACode__c, Name FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
    //    opp[0].SPO_ProductCategory__c = 'Accessories';
    //    opp[0].SPO_CentralApproval__c ='Yes';
    //    opp[0].SPO_MarketingApproval__c = 'Yes';
    //    opp[0].SPO_ZoneApproval__c = 'Yes';
    //    opp[0].StageName = 'Brief in progress';
    //    opp[0].StageName = 'Quotation in progress';
    //    opp[0].SPO_BaseSKURefmodelSKU__c = proList[0].id;
    //    opp[0].SPO_Free__c = true;
    //    opp[0].SPO_SkuQuantity__c = 2;
    //    opp[0].SPO_RMSClientId__c = 'israelTest';
    //    opp[0].SPO_DepositNumber__c = '6';
    //    opp[0].SPO_SpecialOrderSKUCode__c = '6';
    //    opp[0].SPO_UnitRetailPriceQuotation__c = 6;
    //    opp[0].SPO_DepositAmount__c = 6;
    //    update opp[0];

    //    SPO_FirmOrder__c frimOrder = new SPO_FirmOrder__c(LineNumber__c = 1,SPO_BriefName__c = opp[0].id);
    //    insert frimOrder;

    //    ApexPages.currentPage().getParameters().put('id', opp[0].id);
    //    ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);

    //    SO_BriefOrder_CTRL ctrl = new SO_BriefOrder_CTRL(sc);
    //    //ctrl.createQuotation();
    //    //ctrl.addDeposit();
    //    //ctrl.sendToReferential();
    //    //ctrl.createOrderInERP();
    //    //system.debug('ctrl.currentFirmOrderId 1 = '+ctrl.currentFirmOrderId);
    //    //ctrl.currentFirmOrderId = frimOrder.id;
    //    //system.debug('ctrl.currentFirmOrderId 2 = '+ctrl.currentFirmOrderId);
    //    //ctrl.sendToRMS();
    //    Test.startTest();
    //    ctrl.foStartProduction();
    //    ctrl.launchQA();
    //    ctrl.receivedInStore();
    //    ctrl.sendToRMS();
    //    Test.stopTest();
    //}

    ////
    // @isTest static void retreiveArticleRMSPrice() {
    //    //SO_RetreiveArticlesPriceRMS_Utils_MOCK
    //    Test.setMock(WebServiceMock.class, new SO_RetreiveArticlesPriceRMS_Utils_MOCK('000'));

    //    PageReference ref =  new PageReference('/apex/SO_BriefOrder');
    //    Test.setCurrentPage(ref);

    //    List<ProductReferential__c> proList = [SELECT ID,SKUCode__c FROM ProductReferential__c WHERE name ='PR-001' LIMIT 1];
    //    List<Opportunity> opp =[SELECT Id,SPO_StoreCode__c,SPO_RMSClientId__c,SPO_ProductCategory__c, 
    //                            SPO_SpecialOrderSKUCode__c, OwnerId,SPO_BaseSKURefmodelSKU__c, 
    //                            SPO_CACode__c, Name, StageName,SPO_MarketingApproval__c,SPO_CentralApproval__c,SPO_ZoneApproval__c 
    //                            FROM Opportunity 
    //                            WHERE name='Test Class Opp' LIMIT 1];

    //    opp[0].SPO_ProductCategory__c = SO_PicklistDependency.OPP_LEATHER_GOOD;
    //    opp[0].SPO_OrderType__c = SO_PicklistDependency.ORDER_TYPE_MTO_ON_CATALOG;
    //    opp[0].SPO_CentralApproval__c ='Yes';
    //    opp[0].SPO_MarketingApproval__c = 'Yes';
    //    opp[0].SPO_ZoneApproval__c = 'Yes';
    //    opp[0].StageName = 'Brief in progress';
    //    opp[0].StageName = 'Quotation in progress';
    //    opp[0].SPO_BaseSKURefmodelSKU__c = proList[0].id;
    //    opp[0].SPO_Free__c = true;
    //    opp[0].SPO_SkuQuantity__c = 2;
    //    opp[0].SPO_RMSClientId__c = 'israelTest';
    //    opp[0].SPO_DepositNumber__c = '6';
    //    opp[0].SPO_SpecialOrderSKUCode__c = '6';
    //    opp[0].SPO_UnitRetailPrice__c = 6;
    //    opp[0].SPO_DepositAmount__c = 6;

    //    ApexPages.currentPage().getParameters().put('id', opp[0].id);
    //    ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);
    //    SO_BriefOrder_CTRL ctrl = new SO_BriefOrder_CTRL(sc);
    //    Boolean bol = ctrl.isValidForPriceCall;
        
    //    Test.startTest();
    //    SO_BriefOrder_CTRL.remoteRetreiveArticleRMSPrice(opp[0].SPO_UnitRetailPrice__c, opp[0].SPO_StoreCode__c, opp[0].SPO_SpecialOrderSKUCode__c);
    //    SO_BriefOrder_CTRL.remoteRetreiveArticleRMSPrice(null, null, null);
    //    update opp[0];
    //    SO_BriefOrder_CTRL.remoteRetreiveArticleRMSPrice(opp[0].SPO_UnitRetailPrice__c, opp[0].SPO_StoreCode__c, opp[0].SPO_SpecialOrderSKUCode__c);
    //    Test.stopTest();
    // }

    ////@isTest static void testRejectQuotation() {

    ////    PageReference ref =  new PageReference('/apex/SO_BriefOrder');
    ////    Test.setCurrentPage(ref);

    ////    List<Opportunity> opp =[SELECT ID,SPO_ProductCategory__c,OwnerId FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
    ////    ApexPages.currentPage().getParameters().put('id', opp[0].id);
    ////    ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);
    ////    SO_BriefOrder_CTRL ctrl = new SO_BriefOrder_CTRL(sc);

    ////    ctrl.getUserRoleAndReadonlyMode();
    ////    system.assertEquals(ctrl.isReadonlyMode,null);

    ////    ctrl.rejectQuotation();
    ////    opp =[SELECT ID,SPO_ProductCategory__c,OwnerId,StageName FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];

    ////    system.assert(opp[0].StageName.containsIgnoreCase('cancel'));

    ////    ctrl.validateEnterance();
    ////}

    //@isTest static void acceptQuotation() {

    //    Test.setMock(WebServiceMock.class, new SO_ClientAdvisorEnquiryRMS_Utils_MOCK('000'));
    //    PageReference ref =  new PageReference('/apex/SO_BriefOrder');
    //    Test.setCurrentPage(ref);

    //    List<Opportunity> opp =[SELECT StageName,SPO_MarketingApproval__c,SPO_CentralApproval__c,SPO_ZoneApproval__c,ID,SPO_ProductCategory__c,OwnerId,SPO_CACode__c, Name FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
    //    ApexPages.currentPage().getParameters().put('id', opp[0].id);
    //    ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);
    //    SO_BriefOrder_CTRL ctrl = new SO_BriefOrder_CTRL(sc);

    //    ctrl.getUserRoleAndReadonlyMode();
    //    system.assertEquals(ctrl.isReadonlyMode,false);

    //    ctrl.acceptQuotation();
    //    opp =[SELECT ID,SPO_ProductCategory__c,OwnerId,StageName FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];

    //    system.assertEquals(opp[0].StageName,'Quotation accepted');
    //}

    //@isTest static void saveFirmOrderRecords() {
    //    Test.setMock(WebServiceMock.class, new SO_ClientAdvisorEnquiryRMS_Utils_MOCK('000'));

    //    PageReference ref =  new PageReference('/apex/SO_BriefOrder');
    //    Test.setCurrentPage(ref);

    //    List<ProductReferential__c> proList = [SELECT ID,SKUCode__c FROM ProductReferential__c WHERE name ='PR-001' LIMIT 1];
    //    List<Opportunity> opp =[SELECT StageName,SPO_MarketingApproval__c,SPO_CentralApproval__c,SPO_ZoneApproval__c,ID,SPO_ProductCategory__c,OwnerId,SPO_BaseSKURefmodelSKU__c, SPO_CACode__c, Name FROM Opportunity WHERE name='Test Class Opp' LIMIT 1];
    //    opp[0].SPO_ProductCategory__c = 'Accessories';
    //    opp[0].SPO_CentralApproval__c = 'Yes';
    //    opp[0].SPO_MarketingApproval__c = 'Yes';
    //    opp[0].SPO_ZoneApproval__c = 'Yes';
    //    opp[0].StageName = 'Quotation in progress';
    //    opp[0].SPO_BaseSKURefmodelSKU__c = proList[0].id;
    //    opp[0].SPO_Free__c = true;
    //    opp[0].SPO_SkuQuantity__c = 2;
    //    update opp[0];

    //    SPO_FirmOrder__c frimOrder = new SPO_FirmOrder__c(LineNumber__c = 1,SPO_BriefName__c = opp[0].id);
    //    insert frimOrder;

    //    ApexPages.currentPage().getParameters().put('id', opp[0].id);
    //    ApexPages.StandardController sc = new ApexPages.StandardController(opp[0]);

    //    SO_BriefOrder_CTRL ctrl = new SO_BriefOrder_CTRL(sc);

    //    Test.startTest();
    //    ctrl.createOrderInERP();
    //    ctrl.currentFirmOrderId =frimOrder.id;
    //    ctrl.saveFirmOrderRecords();
    //    Test.stopTest();
    //}
}