@isTest
public class ICON_Todos_Test {
    @TestSetup
    static void makeData(){

        Account acc =  new Account(LastName = 'test',DreamId__c ='123456');
        insert acc;

        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = 'A07' ,StoreType__c='Store' ,ISO3_Code__c='FRA');
        insert store;
        
        User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.WWEmployeeNumber__c = '123';

        User u2 = IC_Test_Common.prepareTestUser('System Administrator');
        u2.WWEmployeeNumber__c = '1234';
        insert new List<sObject>{u2 ,u};


        Case request = new Case(Subject='TEST', Country__c='France', AccountId=acc.id, store__c=store.id, OwnerId=u.id, status='New');
        CareService__c repair = new CareService__c(IsToDo__c = false, Client__c = acc.id, store__c = store.id, StoreRetailCode__c = store.RetailStoreId__c,MessageToCA__c='Quotation to validate');

        insert new List<sObject>{request ,repair}; 
    }
    
    @isTest
    static void todoRequestCreate(){

        User u = [SELECT id  FROM User WHERE WWEmployeeNumber__c = '1234'];
        Store__c store = [SELECT id  FROM Store__c LIMIT 1];
        Account acc = [SELECT id  FROM Account LIMIT 1];
        Test.startTest();

        Case request1 = new Case(Country__c='France', AccountId=acc.id, store__c=store.id, OwnerId=u.id, status='New',Resolution__c = 'Request to Store');
        insert new List<sObject>{request1}; 

        Test.stopTest();
    }
    @isTest
    static void todoRequestUpdate(){

        User u = [SELECT id  FROM User WHERE WWEmployeeNumber__c = '1234'];
        Case request = [SELECT Id FROM Case LIMIT 1];

        Test.startTest();
        request.Resolution__c = 'Request to Store';
        request.CA_Name__c = u.Id;
        update request;
        Test.stopTest();
    }
    @isTest
    static void todoSurvey(){

        Test.loadData(VO_Config__c.sobjectType, 'VO_Config_TestCLS');

        User u = [SELECT id  FROM User WHERE WWEmployeeNumber__c = '1234'];
        Store__c store = [SELECT id  FROM Store__c LIMIT 1];
        Account acc = [SELECT id  FROM Account LIMIT 1];

        PPR_PurchProduct__c p = new PPR_PurchProduct__c(TicketNumber__c = '210728876',WWEmployeeNumber__c = '1234',Client__c = acc.id,Amount__c=995,Name='PF.SARAH RETIRO MNG CERI.',StoreRetailCode__c='A07',TransactionRMSId__c='2107288761');
        insert p;

        VO_Survey__c voice = new VO_Survey__c(StoreID__c='A07', DreamIDText__c= '123456', IDTransaction__c = '2107288761', SurveyType__c = 'VOICE Store Local Sales' ,ClientDreamID__c=acc.Id,AnswerDate__c=date.today(),Type__c='Neutral' ,Store__c = store.id,OwnerId = u.id ,CAName__c = 'YARE Callista (CALL)(1234)');
        insert voice;

        Test.startTest();
        voice.CAName__c = 'YARE Callista (CALL)(1234)';
        voice.Type__c = 'Promoter';
        update voice;
        
        List<Task> t = [SELECT id FROM Task WHERE whatId =: voice.id LIMIT 1];

        Test.stopTest();
    }

    @isTest
    static void todoCaresServiceInsert(){

        User u = [SELECT id  FROM User WHERE WWEmployeeNumber__c = '1234'];
        Store__c store = [SELECT id ,RetailStoreId__c  FROM Store__c LIMIT 1];
        Account acc = [SELECT id  FROM Account LIMIT 1];
        Test.startTest();
        CareService__c repair = new CareService__c( IsToDo__c = true, Client__c = acc.id, store__c = store.id, StoreRetailCode__c = store.RetailStoreId__c,MessageToCA__c='Quotation to validate',CA__c=u.id);
        insert repair;      
       
        Test.stopTest();
    }


    @isTest
    static void todoCaresServiceUpdate(){

        User u = [SELECT id  FROM User WHERE WWEmployeeNumber__c = '1234'];
        Store__c store = [SELECT id ,RetailStoreId__c  FROM Store__c LIMIT 1];
        Account acc = [SELECT id  FROM Account LIMIT 1];
        Test.startTest();
        CareService__c repair = [SELECT Id FROM CareService__c LIMIT 1];
      
        repair.IsToDo__c = true;
        repair.MessageToCA__c = 'extra delay';
        repair.CA__c=u.id;
        update repair;

        List<Task> t  = [SELECT id FROM Task WHERE whatId =: repair.id LIMIT 1];
        System.assertNotEquals(null, t);

        Test.stopTest();
    }


    @isTest
    static void todoXstoreOrder(){

        User u = [SELECT id  FROM User WHERE WWEmployeeNumber__c = '1234'];
        Store__c store = [SELECT id  FROM Store__c LIMIT 1];
        Account acc = [SELECT id  FROM Account LIMIT 1];

        Order__c ord = new Order__c(Name ='Test',OrderNumber__c='2501002000228',Store__c=store.id,Account__c=acc.id ,Source__c='KBRW',OrderDate__c=System.now());
        insert ord;
        System.debug('MAKE DATA ORDER DONE');


        Test.startTest();
        Order__c order2 = [SELECT id ,Account__r.PersonContactId  ,Store__c  ,OwnerId__c , Store__r.ISO3_Code__c  FROM Order__c LIMIT 1];
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
       
		SPO_FirmOrder__c firmOrder = new SPO_FirmOrder__c(SPO_BriefName__c = order2.Id,LineNumber__c = 1,SPO_TechETLStatus__c = 'V',SPO_FirmOrderStatus__c = 'Creation in progress');
        insert firmOrder; 

        firmOrder.SPO_FirmOrderStatus__c = 'Cancelled by Production';
        update firmOrder;

        SPO_FirmOrder__c firmOrder2 = [SELECT SPO_FirmOrderStatus__c ,Id , SPO_BriefName__r.Owner.Is_Store_User__c  ,SPO_BriefName__r.SPO_Store__r.ISO3_Code__c,SPO_BriefName__r.Owner.IsTechnicalUser__c ,SPO_RevisedDeliveryDate__c  ,Planned_Delivery_date__c ,SPO_BriefName__c, SPO_BriefName__r.ApplicationSource__c, SPO_BriefName__r.OwnerId,SPO_BriefName__r.SPO_Store__c, SPO_BriefName__r.Account.PersonContactId 
        FROM SPO_FirmOrder__c Limit 1 ];

        ICON_Todos_Helper.createToDoTaskFirmOrderNowYours(firmOrder2, ICON_Todos_Helper.getTechnicalUsers(),'product available in store','TD_NY_01');
        
       // Task t = [SELECT id FROM Task WHERE whatId =: firmOrder.SPO_BriefName__c LIMIT 1];
       // System.assertNotEquals(null, t);
        Test.stopTest();
    }
}