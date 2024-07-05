@isTest()
public class SPO_OppStandardControllerExtension_Test {
    private static Id PERSO_ORDER_ID;
    private static Id SPO_ORDER_ID;

    @TestSetup
    static void init() {
        Store__c store = new Store__c(Name = 'Test Store', RetailStoreId__c = 'A06');
        insert store;

        Opportunity order = new Opportunity();
        order.Name = 'Test Order'; 
        order.StageName = 'Brief in progress';
        order.CloseDate = Date.today();
        order.SPO_DepositSentStatusDate__c = Date.today() ;
        order.Received_in_Store_Date__c = Date.today();
        order.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Perso Order').getRecordTypeId();
        order.SPO_Store__c = store.Id;
        insert order;
        PERSO_ORDER_ID = order.Id;
        
        Opportunity order78 = new Opportunity();
        order78.Name = 'Test Order 78'; 
        order78.StageName = 'Brief in progress';
        order78.ApplicationSource__c='ECO';
        order78.CloseDate = Date.today();
        order78.SPO_DepositSentStatusDate__c = Date.today() ;
        order78.Received_in_Store_Date__c = Date.today();
        order78.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Perso Order').getRecordTypeId();
        order78.SPO_Store__c = store.Id;
        insert order78;
        PERSO_ORDER_ID = order78.Id;

        Opportunity order2 = new Opportunity();
        order2.Name = 'Test SP Order';
        order2.StageName = 'Brief in progress';
        order2.CloseDate = Date.today();
        order2.Received_in_Store_Date__c = Date.today();
        order2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Special Order').getRecordTypeId();
        order2.SPO_EstimatedProductionTimeMonths__c = 1;
        order2.SPO_EstimatedDistributionTime__c = 12;
        order2.SPO_UnitRetailPriceQuotation__c = 1000;
        order2.SPO_ExportPrice__c = 111;
        order2.SPO_Numberofproductivehours__c = 231;
        order2.SPO_ProductCategory__c = 'Belts';
        order2.SPO_Store__c = store.Id;
        order2.Amount = 1000;
        order2.SPO_DepositAmount__c = 500;
        order2.SPO_CACode__c='SIM';
        order2.SPO_SkuQuantity__c=1;
        insert order2;
        SPO_ORDER_ID = order2.Id;

        ProductCatalogue__c pc1 = new ProductCatalogue__c(Name = 'testPc1', LeadTimeManufacturing__c = 0, SKU__c = '12345', Workshop__c ='1798');
        ProductCatalogue__c pc2 = new ProductCatalogue__c(Name = 'testPc2', Technical_Data_Defined__c = false, LeadTimeManufacturing__c = 1, SKU__c = '12346', Workshop__c ='1798');
        ProductCatalogue__c pc3 = new ProductCatalogue__c(Name = 'testPc3', Technical_Data_Defined__c = true, SKU__c = '12347', LeadTimeApproval__c = -1, Workshop__c ='1798');
        ProductCatalogue__c pc4 = new ProductCatalogue__c(Name = 'testPc4', Technical_Data_Defined__c = false, SKU__c = '12348', LeadTimeApproval__c = -1, Exotic_Leather__c = 'Alligator', Generic_SKU__c = '12348', Workshop__c ='1798');
        ProductCatalogue__c pc5 = new ProductCatalogue__c(Name = 'testPc5', Technical_Data_Defined__c = true, SKU__c = '12350', LeadTimeApproval__c = 1, Workshop__c ='1798');
        ProductCatalogue__c pc6 = new ProductCatalogue__c(Name = 'testPc6', Technical_Data_Defined__c = true, SKU__c = '12351', LeadTimeApproval__c = 1, Workshop__c ='1798');
        insert pc1;
        insert pc2;
        insert pc3;
        insert pc4;
        insert pc5; 
        insert pc6;

        List<SPO_FirmOrder__c> fosToInsert = new List<SPO_FirmOrder__c>();
        SPO_FirmOrder__c firmOrder = new SPO_FirmOrder__c(
            SPO_BriefName__c = order.Id,
            LineNumber__c = 1,
            SPO_TechETLStatus__c = 'V',
            SPO_FirmOrderStatus__c = 'Creation in progress'
        );
        fosToInsert.add(firmOrder);

        SPO_FirmOrder__c firmOrder258 = new SPO_FirmOrder__c(
            SPO_BriefName__c = order2.Id,
            LineNumber__c = 1,
            SPO_TechETLStatus__c = 'V',
            SPO_FirmOrderStatus__c = 'Sent to MyPR'
        );
        insert firmOrder258;

        SPO_FirmOrder__c firmOrder2 = new SPO_FirmOrder__c(
            SPO_BriefName__c = order.Id,
            LineNumber__c = 2,
            SPO_FirmOrderStatus__c = 'Creation in progress',
            Creation_Status__c = 'New Order',
            Undefined_Material__c = true,
            ProductCatalogue__c = pc2.Id
        );
        fosToInsert.add(firmOrder2);

        SPO_FirmOrder__c firmOrder3 = new SPO_FirmOrder__c(
            SPO_BriefName__c = order.Id,
            LineNumber__c = 3,
            SPO_FirmOrderStatus__c = 'Creation in progress',
            Creation_Status__c = 'Species to Choose',
            Undefined_Material__c = false,
            ProductCatalogue__c = pc2.Id
        );
        fosToInsert.add(firmOrder3);

        SPO_FirmOrder__c firmOrder4 = new SPO_FirmOrder__c(
            SPO_BriefName__c = order.Id,
            LineNumber__c = 4,
            SPO_FirmOrderStatus__c = 'Creation in progress',
            Creation_Status__c = 'Technical Data to Define',
            ProductCatalogue__c = pc2.Id
        );
        fosToInsert.add(firmOrder4);

        SPO_FirmOrder__c firmOrder5 = new SPO_FirmOrder__c(
            SPO_BriefName__c = order.Id,
            LineNumber__c = 5,
            SPO_FirmOrderStatus__c = 'Creation in progress',
            Creation_Status__c = 'New Order',
            Undefined_Material__c = false,
            ProductCatalogue__c = pc3.Id
        );
        fosToInsert.add(firmOrder5);

        SPO_FirmOrder__c firmOrder6 = new SPO_FirmOrder__c(
                SPO_BriefName__c = order.Id,
                LineNumber__c = 6,
                SPO_FirmOrderStatus__c = 'Creation in progress',
                Creation_Status__c = 'Technical Data to Check',
                ProductCatalogue__c = pc2.Id
        );
        fosToInsert.add(firmOrder6);

        SPO_FirmOrder__c firmOrder7 = new SPO_FirmOrder__c(
                SPO_BriefName__c = order.Id,
                LineNumber__c = 7,
                SPO_FirmOrderStatus__c = 'Creation in progress',
                Creation_Status__c = 'New Order',
                ProductCatalogue__c = pc2.Id
        );
        fosToInsert.add(firmOrder7);
        SPO_FirmOrder__c firmOrder8 = new SPO_FirmOrder__c(
                SPO_BriefName__c = order.Id,
                LineNumber__c = 8,
                SPO_FirmOrderStatus__c = 'Creation in progress', //'Received in store',
                Creation_Status__c = 'New Order',
                ProductCatalogue__c = pc4.Id
        );
        fosToInsert.add(firmOrder8);
        SPO_FirmOrder__c firmOrder9 = new SPO_FirmOrder__c(
                SPO_BriefName__c = order.Id,
                LineNumber__c = 9,
                SPO_FirmOrderStatus__c = 'Sent to MyPR',
                Creation_Status__c = 'New Order',
                ProductCatalogue__c = pc5.Id
        );
        fosToInsert.add(firmOrder9);

        SPO_FirmOrder__c firmOrder10 = new SPO_FirmOrder__c(
                SPO_BriefName__c = order.Id,
                LineNumber__c = 10,
                SPO_FirmOrderStatus__c = 'Production in progress',
                Creation_Status__c = 'New Order',
                ProductCatalogue__c = pc6.Id
        );
        fosToInsert.add(firmOrder10);
        
        SPO_FirmOrder__c firmOrder11 = new SPO_FirmOrder__c(
            SPO_BriefName__c = order78.Id,
            LineNumber__c = 10,
            SPO_FirmOrderStatus__c = 'Production in progress',
            Creation_Status__c = 'New Order',
            ProductCatalogue__c = pc6.Id
        );
        fosToInsert.add(firmOrder11);
         test.startTest() ;
        insert fosToInsert;
           test.stopTest() ;

        List<Picklist_Dependency__c> toInsert = new List<Picklist_Dependency__c>{
                new Picklist_Dependency__c(
                        Name = 'Accessory',
                        Opportunity_Category__c = 'Accessories',
                        Referential_Category__c = 'Special Order Accessory',
                        Opportunity_Record_Type__c = 'Accessories'
                ),
                new Picklist_Dependency__c(
                        Name = 'Leather good',
                        Opportunity_Category__c = 'Leather goods',
                        Referential_Category__c = 'Special Order Leather Good',
                        Opportunity_Record_Type__c = 'Leather Goods'
                ),
                new Picklist_Dependency__c(
                        Name = 'Watch',
                        Opportunity_Category__c = 'Watches',
                        Referential_Category__c = 'Special Order Watch',
                        Opportunity_Record_Type__c = 'Watches'
                )
                };
        insert toInsert;

        try {
            ProductReferential__c pr = new ProductReferential__c(Name = 'testPr', SKUCode__c = '12345');
            insert pr;
    
    
            SO_Settings__c setting = new SO_Settings__c(Name='WSCallNoCall', Value__c='nocall');
            insert setting;
        } catch(Exception e){
            System.debug('Exception: '+e.getMessage());
        }
    }


    @isTest
    static void test_duplicateOrder1() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successOrderPdf', 'OrderPdf'));
        Test.startTest();
        try{
        Opportunity o = [SELECT Id FROM Opportunity where ApplicationSource__c='ECO' LIMIT 1];
        String dupOrderPageRef = MIY_OrderPageController.duplicateOrder(o,'aaa');
        System.assertNotEquals(null, dupOrderPageRef);
        }
        catch(Exception ex){
            system.debug('Error : ' + ex);
        }
        Test.stopTest();
    }

    @isTest
    static void test_duplicateOrder2() {
        Test.setMock(HttpCalloutMock.class, new MockHttpResponse('successOrderPdf', 'OrderPdf'));
        Test.startTest();
        Opportunity o = [SELECT Id FROM Opportunity where ApplicationSource__c!='ECO' LIMIT 1];
        String dupOrderPageRef = MIY_OrderPageController.duplicateOrder(o,'');
        System.assertNotEquals(null, dupOrderPageRef);
        Test.stopTest();
    }
}