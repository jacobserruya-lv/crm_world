@isTest
public class ProductCatalogTriggerHandler_TEST {
@TestSetup
    static void init() {
        
        Account client = LV_TestFactory.createAccount();
        insert client;
        
        
        Category__c category = new Category__c();
        category.name = 'Hardsided';
        category.Category_Hardsided__c = true;
        insert category;
        
        
        ProductCatalogue__c pc =
                LV_TestFactory.createProductCatalog('MY NEVERFULL', 'P0001', 3, 15, 5, 'Leather Goods');
        pc.Category__c = category.Id;
        pc.Workflow__c = true;
        pc.Technical_Data_Defined__c = false;
        
        pc.Workshop__c = '1798';
        pc.StockRequest__c = false;
        
        pc.ReportingCategory__c=category.Id;
        insert pc;
        system.debug('pc' + pc);
        Opportunity order =
                LV_TestFactory.createOrder('MY Neverfull bag', 'Creation in progress', null, null, client.Id, null,
                        null, 'PERSO');
        
        order.SPO_DepositSentStatusDate__c = System.today();
        order.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Perso Order').getRecordTypeId();
        insert order;
       
        
    }
    
    
    @isTest
    static void test_handleAfterUpdate() {
        
        ProductCatalogue__c pc = [SELECT Id,Technical_Data_Defined__c FROM ProductCatalogue__c WHERE SKU__c = 'P0001' LIMIT 1];
        Opportunity mypOrder = [SELECT Id FROM Opportunity WHERE ApplicationSource__c = 'PERSO' LIMIT 1];
		SPO_FirmOrder__c fo = LV_TestFactory.createFirmOrder(mypOrder.Id,1,pc.Id);
        fo.SPO_TechETLStatus__c = 'V';
        fo.Creation_Status__c = 'Order to Check/Validate';
        fo.SPO_FirmOrderStatus__c = 'Creation in progress';
        insert fo;
        SPO_FirmOrder__c fo2 = [SELECT Id, SPO_TechETLStatus__c,Creation_Status__c,SPO_FirmOrderStatus__c, ProductCatalogue__c,TECH_Product_Hard_Workflow__c,SPO_BriefName__c FROM SPO_FirmOrder__c WHERE Id =: fo.Id];

        


        fo2.Creation_Status__c = 'Technical Data to Define';
        fo2.SPO_TechETLStatus__c = 'V';
        fo2.SPO_FirmOrderStatus__c = 'Creation in progress';
        update fo2;


       

        
        Test.startTest();
        pc.Technical_Data_Defined__c = true;
        update pc;
        Test.stopTest();
        ProductCatalogue__c pc1 = [SELECT Id,Technical_Data_Defined__c FROM ProductCatalogue__c WHERE id =: pc.Id LIMIT 1];
                
        System.assertEquals('V', fo2.SPO_TechETLStatus__c);
        System.assertEquals('Creation in progress', fo2.SPO_FirmOrderStatus__c);

    }
}