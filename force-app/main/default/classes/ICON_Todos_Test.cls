@isTest
public class ICON_Todos_Test {
    @TestSetup
    static void makeData(){
        Test.loadData(VO_Config__c.sobjectType, 'VO_Config_TestCLS');

        Account acc =  new Account(LastName = 'test');
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = 'A07' ,StoreType__c='Store');
        
        User u = IC_Test_Common.prepareTestUser('System Administrator');
        
        User u2 = IC_Test_Common.prepareTestUser('System Administrator');
        u2.WWEmployeeNumber__c = '1234';
        insert new List<sObject>{u2 , u, store, acc};


        CareService__c c = new CareService__c( IsToDo__c = true, Client__c = acc.id, store__c = store.id, StoreRetailCode__c = store.RetailStoreId__c,MessageToCA__c='Quotation to validate',CA__c=u.id);

        Case ca = new Case(Country__c = 'France' , AccountId = acc.id, store__c = store.id,OwnerId=u.id,status='New',CA_Name__c=u.id);
    
        VO_Survey__c vo = new VO_Survey__c(SurveyType__c = 'VOICE Store Local Sales' ,ClientDreamID__c=acc.Id,AnswerDate__c=date.today(),Type__c='Neutral' ,Store__c = store.id,OwnerId = u.id ,CAName__c = 'YARE Callista (CALL)(1234)');
        
        Order__c order = new Order__c(Name ='Test',OrderNumber__c='2501002000228',Store__c=store.id,Account__c=acc.id ,Source__c='KBRW',OrderDate__c=System.now());

        insert new List<sObject>{c , ca, vo, order};

		
    }
    
    @isTest
    static void todoRequest(){
        Test.startTest();
        Case ca = [SELECT id  FROM Case LIMIT 1];
        User u2 = [SELECT id  FROM User where WWEmployeeNumber__c = '1234'];
        if(ca != null && u2 != null ){
            ca.Resolution__c = 'Request to Store';
            ca.CA_Name__c = u2.Id;
            update ca;
        }
        Task t = [SELECT id FROM Task WHERE whatId =: ca.id LIMIT 1];
        System.assertNotEquals(null, t);

        Test.stopTest();
    }
    @isTest
    static void todoSurvey(){
        Test.startTest();
        VO_Survey__c vo = [SELECT id ,CAName__c  FROM VO_Survey__c LIMIT 1];
        if(vo != null){
            vo.CAName__c = 'YARE Callista (CALL)(1234)';
            vo.Type__c = 'Promoter';
            update vo;
        }
        Task t = [SELECT id FROM Task WHERE whatId =: vo.id LIMIT 1];
        System.assertNotEquals(null, t);

        Test.stopTest();
      
    }

    @isTest
    static void todoCaresService(){
        Test.startTest();
        CareService__c c = [SELECT id  FROM CareService__c LIMIT 1];
        //User u2 = [SELECT id  FROM User where WWEmployeeNumber__c = '1234'];

        if(c != null){
            c.IsToDo__c = true;
            c.MessageToCA__c = 'extra delay';
            update c;
        }
        Task t = [SELECT id FROM Task WHERE whatId =: c.id LIMIT 1];
        System.assertNotEquals(null, t);

        Test.stopTest();
      
    }


    @isTest
    static void todoXstoreOrder(){
        Test.startTest();
        Order__c order2 = [SELECT id  FROM Order__c LIMIT 1];
        User u2 = [SELECT id  FROM User where WWEmployeeNumber__c = '1234'];

        if(order2 != null && u2 != null){
          order2.OwnerId__c = u2.Id;
          update order2;
        }
        Task t = [SELECT id FROM Task WHERE whatId =: order2.id LIMIT 1];
        System.assertNotEquals(null, t);

        Test.stopTest();
      
    }


    @isTest
    static void testFirmOrder(){
        Store__c store = [select id from store__c where RetailStoreId__c = 'A07'];
        Account acc =  new Account(LastName = 'test');
        insert new List<sObject>{ acc};
        Test.startTest();

        Opportunity order2 = new Opportunity( Name = 'Test SP Order',StageName = 'Brief in progress',CloseDate = Date.today(),Received_in_Store_Date__c = Date.today(),
                                              SPO_EstimatedProductionTimeMonths__c = 1,SPO_EstimatedDistributionTime__c = 12,SPO_UnitRetailPriceQuotation__c = 1000,
                                              SPO_ExportPrice__c = 111,SPO_Numberofproductivehours__c = 231,SPO_ProductCategory__c = 'Belts',SPO_Store__c = store.Id,
		                                     Amount = 1000,SPO_DepositAmount__c = 500, SPO_CACode__c='SIM', SPO_SkuQuantity__c=1,AccountId=acc.id , ApplicationSource__c = 'PERSO' );
		insert order2;
       
		SPO_FirmOrder__c firmOrder1 = new SPO_FirmOrder__c(SPO_BriefName__c = order2.Id,LineNumber__c = 1,SPO_TechETLStatus__c = 'V',SPO_FirmOrderStatus__c = 'Creation in progress');
        insert firmOrder1; 
        SPO_FirmOrder__c firmOrder = [SELECT id ,SPO_BriefName__c  FROM SPO_FirmOrder__c LIMIT 1];
        if(firmOrder != null){
            firmOrder.SPO_FirmOrderStatus__c = 'Cancelled by Production';
            update firmOrder;
        }
       // Task t = [SELECT id FROM Task WHERE whatId =: firmOrder.SPO_BriefName__c LIMIT 1];
       // System.assertNotEquals(null, t);
        Test.stopTest();
      
    }
}