@isTest
public class ProductReferentialTriggerHandler_TEST {
    @TestSetup
    static void init() {
        Category__c cat1 = new Category__c(Name = 'Leather Goods');
        Category__c cat2 = new Category__c(Name = 'Suitcases');
        Category__c cat3 = new Category__c(Name = 'Trunks');
        List<Category__c> cats = new List<Category__c> {cat1, cat2, cat3};
    insert cats; // meow =^._.^= ∫

        ProductCatalogue__c pc1 = LV_TestFactory.createProductCatalog('MY NEVERFULL', 'P0001', 3, 15, 5, 'Leather Goods');
    pc1.Category__c = cat1.Id;
        ProductCatalogue__c pc2 = LV_TestFactory.createProductCatalog('MY NEVERFULL', 'P0002', 3, 15, 5, 'Suitcases');
    pc2.Category__c = cat2.Id;
        ProductCatalogue__c pc3 = LV_TestFactory.createProductCatalog('MY NEVERFULL', 'P0003', 3, 15, 5, 'Trunks');
    pc3.Category__c = cat3.Id;
        List<ProductCatalogue__c> pcs = new List<ProductCatalogue__c> {pc1, pc2, pc3};
        insert pcs;

        Opportunity order = new Opportunity();
        order.Name = 'Test Order'; 
        order.StageName = 'Brief in progress';
        order.CloseDate = Date.today();
        order.SPO_DepositSentStatusDate__c = Date.today();
        order.Received_in_Store_Date__c = Date.today();
        order.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Perso Order').getRecordTypeId();
        insert order;
        
        Opportunity order2 = new Opportunity();
        order2.Name = 'Test Order'; 
        order2.StageName = 'Creation in progress';
        order2.CloseDate = Date.today();
        order2.SPO_DepositSentStatusDate__c = Date.today();
        order2.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Perso Order').getRecordTypeId();
        insert order2;
    }

    @isTest
    static void test_handleBeforeInsert() {
    // Create a temp object so the default value can be accessed below
    ProductReferential__c prTemp = (ProductReferential__c)ProductReferential__c.sObjectType.newSObject(null, true);

        ProductReferential__c pr1 = new ProductReferential__c(Name = 'Test PR 1', SKUCode__c = 'P0001');
        ProductReferential__c pr2 = new ProductReferential__c(Name = 'Test PR 2', SKUCode__c = 'P0002');
        ProductReferential__c pr3 = new ProductReferential__c(Name = 'Test PR 3', SKUCode__c = 'P0003');
        List<ProductReferential__c> prs = new List<ProductReferential__c> {pr1, pr2, pr3};
        insert prs;

    // Use query similar to SO_ProductController.findAll to test accurately
    List<ProductReferential__c> testPRs = [
      SELECT Id, SKUCode__c, Creation_Sort_Order__c 
      FROM ProductReferential__c
      ORDER BY Creation_Sort_Order__c NULLS LAST
    ];

    // Confirm that all objects were inserted
    System.assertEquals(prs.size(), testPRs.size());
    // Confirm that the first one in the list is the correct SKU
    System.assertEquals('P0003', testPRs.get(0).SKUCode__c);
    // Confirm that the first one in the list has the correct ordering
    System.assertEquals(10, testPRs.get(0).Creation_Sort_Order__c);
    // Confirm that the second and third ones are also correct
    System.assertEquals('P0002', testPRs.get(1).SKUCode__c);
    System.assertEquals(20, testPRs.get(1).Creation_Sort_Order__c);
    System.assertEquals('P0001', testPRs.get(2).SKUCode__c);
    // Use the default value for sort order for assert
    System.assertEquals(prTemp.Creation_Sort_Order__c, testPRs.get(2).Creation_Sort_Order__c);
    }

    @isTest
    static void test_handleAfterInsert() {
        Opportunity testOrder = [SELECT Id, SPO_SpecialOrderSKUCodeRef__c, OrderNumber__c FROM Opportunity where StageName = 'Creation in progress' LIMIT 1];

        ProductReferential__c prodref = new ProductReferential__c();
        prodref.Name = 'TEST PReferential';
        prodref.SKUCode__c = 'S54706';
        prodref.OrderNumber__c = testOrder.OrderNumber__c;
        insert prodref;
        
        

    testOrder = [
            SELECT Id, SPO_SpecialOrderSKUCodeRef__c, OrderNumber__c
            FROM Opportunity
            WHERE Id = :testOrder.Id
        ];

    System.assertEquals(testOrder.OrderNumber__c, prodref.OrderNumber__c);
        System.assertEquals(testOrder.SPO_SpecialOrderSKUCodeRef__c, prodref.Id);
    }

  
    @isTest
    static void test_handleBeforeUpdate() {
    // Create a temp object so the default value can be accessed below
    ProductReferential__c prTemp = (ProductReferential__c)ProductReferential__c.sObjectType.newSObject(null, true);

        ProductReferential__c pr1 = new ProductReferential__c(Name = 'Test PR 1', SKUCode__c = 'P0001');
        insert pr1;

    // Ensure that the sort order is correct before update
    ProductReferential__c testPR1 = [
      SELECT Id, SKUCode__c, Creation_Sort_Order__c 
      FROM ProductReferential__c
      WHERE SKUCode__c = 'P0001'
      LIMIT 1
    ];
    System.assertEquals(prTemp.Creation_Sort_Order__c, testPR1.Creation_Sort_Order__c);

    testPR1.Creation_Sort_Order__c = null;
    update testPR1;

    // Ensure that the sort order is correct after update
    ProductReferential__c testPR2 = [
      SELECT Id, SKUCode__c, Creation_Sort_Order__c 
      FROM ProductReferential__c
      WHERE SKUCode__c = 'P0001'
      LIMIT 1
    ];
    System.assertEquals(prTemp.Creation_Sort_Order__c, testPR2.Creation_Sort_Order__c);
    }
  
}