@isTest
public with sharing class BL_ICON_Scheduler_Batch_ToDo_TEST {
    
    

    @testsetup static void setupMethod(){
        Store__c store1 = new Store__c(RetailStoreId__c = 'A06' ,StoreType__c = 'Store' );
        insert store1;
        Account acc = new Account (LastName='Test', FirstName='Test',PersonEmail='test@Test.com');
        insert acc;
        Order__c order = new Order__c(Name ='Test',OrderNumber__c='2501002000228',Store__c=store1.id,Account__c=acc.id ,Source__c='KBRW',OrderDate__c=System.now());
        insert order;
        OrderShipping__c ordershipping= new OrderShipping__c(Name='Test' ,Order__c=order.id,ShippingNumber__c='a123456789',DeliveryType__c='shipforpickup',Status__c='Fulfilled',StatusDate__c=DateTime.now().addDays(-7));
        insert ordershipping ;

        OrderLine__c orderLine = new OrderLine__c(Name= 'Test',Order__c=order.id,Quantity__c=1,SKU__c='M14141',OrderShipping__c=ordershipping.id );
        insert orderLine;  


        Opportunity order2 = new Opportunity(   Name = 'Test SP Order',StageName = 'Brief in progress',CloseDate = Date.today(),Received_in_Store_Date__c = Date.today(),
                                                SPO_EstimatedProductionTimeMonths__c = 1,SPO_EstimatedDistributionTime__c = 12,SPO_UnitRetailPriceQuotation__c = 1000,
                                                SPO_ExportPrice__c = 111,SPO_Numberofproductivehours__c = 231,SPO_ProductCategory__c = 'Belts',SPO_Store__c = store1.Id,
                                                Amount = 1000,SPO_DepositAmount__c = 500, SPO_CACode__c='SIM', SPO_SkuQuantity__c=1,AccountId=acc.id , ApplicationSource__c = 'SPO' );
        insert order2;
        DateTime dT = DateTime.now().addMonths(-9);
        SPO_FirmOrder__c firmOrder = new SPO_FirmOrder__c(SPO_BriefName__c = order2.Id,LineNumber__c = 1,SPO_TechETLStatus__c = 'V',SPO_FirmOrderStatus__c = 'Distribution in progress', ProductionInProgressDate__c = date.newinstance(dT.year(), dT.month(), dT.day()));
        insert firmOrder; 
   }

   @isTest static void test_Todo_BatchAssistant() {
		
    Test.startTest();
    String cron = '0 0 23 * * ?';
    Database.executeBatch(new BL_ICON_Batch_NY_OrdersTodos(),200);
    BL_ICON_Scheduler_Batch_ToDo_Assistant schd = new BL_ICON_Scheduler_Batch_ToDo_Assistant();
    String jobId = System.schedule('test schedule spam deletion batch', cron, schd);

    // Get the information from the CronTrigger API object
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                             FROM CronTrigger WHERE id = :jobId];

    Test.stopTest();
    System.assertNotEquals(Null, ct.NextFireTime);
}



}