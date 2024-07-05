@isTest
public class Xstore_APITest { //MIY-2092
      
    public static User getAdminUser() {
        User adminUser = ICX_TestFactory.createUser(ICX_TestFactory.PROFILE_SYSTEM_ADMINNISTRATOR);
        adminUser.BypassVR__c = true;
        return adminUser;
    }
    
    private static User adminUser = getAdminUser();
    
    @IsTest
    // Running as Admin
    static void testXstoreCreateAmount() {
        User adminUser = adminUser;
        System.runAs(adminUser) {
            Opportunity objOpportunity = new Opportunity();
            objOpportunity.Name = 'Test Opp';
            objOpportunity.CloseDate = system.Today() + 3;
            objOpportunity.SPO_DepositAmount__c = 12345;
            objOpportunity.SPO_XstoreDeposit__c = null;
            objOpportunity.StageName = 'Closed Won';
            insert objOpportunity;
            Opportunity thisOppDeposit = [
                SELECT Id, SPO_DepositAmount__c, SPO_XstoreDeposit__c, OrderNumber__c
                FROM Opportunity
            ];
            
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.requestUri =
                'https://louisvuitton--pprod.my.salesforce.com/services/apexrest/Opportunity/' +
                thisOppDeposit.OrderNumber__c;
            RestContext.request = request;
            RestContext.response = res;
            
            request.httpMethod = 'PATCH';
            request.addHeader('Content-type', 'application/json');
            request.requestBody = Blob.valueOf('{"DepositAmount": 12345}');
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new Xstore_APIHTTPCalloutMock());
            Test.startTest();
            Xstore_API.updateOpportunityAmount();
            Test.stopTest();
        }
    }
    
    @IsTest
    static void testXstoreUpdateAmount() {
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test Opp';
        objOpportunity.CloseDate = system.Today() + 3;
        objOpportunity.SPO_DepositAmount__c = 12345;
        objOpportunity.SPO_XstoreDeposit__c = 800;
        objOpportunity.StageName = 'Closed Won';
        insert objOpportunity;
        Opportunity thisOppDeposit = [
            SELECT Id, SPO_DepositAmount__c, SPO_XstoreDeposit__c, OrderNumber__c
            FROM Opportunity
        ];
        
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri =
            'https://louisvuitton--pprod.my.salesforce.com/services/apexrest/Opportunity/' +
            thisOppDeposit.OrderNumber__c;
        RestContext.request = request;
        RestContext.response = res;
        
        request.httpMethod = 'PATCH';
        request.addHeader('Content-type', 'application/json');
        request.requestBody = Blob.valueOf('{"DepositAmount": 12345}');
        RestContext.request = request;
        Test.setMock(HttpCalloutMock.class, new Xstore_APIHTTPCalloutMock());
        Test.startTest();
        Xstore_API.updateOpportunityAmount();
        Test.stopTest();
    }
    
    @IsTest
    static void testXstoreQueryException() {
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri = 'https://louisvuitton--pprod.my.salesforce.com/services/apexrest/Opportunity/invalid';
        RestContext.request = request;
        RestContext.response = res;
        
        request.httpMethod = 'PATCH';
        request.addHeader('Content-type', 'application/json');
        request.requestBody = Blob.valueOf('{"DepositAmount": 12345}');
        RestContext.request = request;
        Test.setMock(HttpCalloutMock.class, new Xstore_APIHTTPCalloutMock());
        Test.startTest();
        Xstore_API.updateOpportunityAmount();
        Test.stopTest();
    }
    
    @IsTest
    static void testXstoreCreateAmountException() {
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test Opp';
        objOpportunity.CloseDate = system.Today() + 3;
        objOpportunity.SPO_DepositAmount__c = 12345;
        objOpportunity.SPO_XstoreDeposit__c = null;
        objOpportunity.StageName = 'Closed Won';
        insert objOpportunity;
        Opportunity thisOppDeposit = [
            SELECT Id, SPO_DepositAmount__c, SPO_XstoreDeposit__c, OrderNumber__c
            FROM Opportunity
        ];
        
        System.debug('ulhaaa' + thisOppDeposit);
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri =
            'https://louisvuitton--pprod.my.salesforce.com/services/apexrest/Opportunity/' +
            thisOppDeposit.OrderNumber__c;
        RestContext.request = request;
        RestContext.response = res;
        
        request.httpMethod = 'PATCH';
        request.addHeader('Content-type', 'application/json');
        request.requestBody = Blob.valueOf('{"DepositAmount": 999}');
        RestContext.request = request;
        Test.setMock(HttpCalloutMock.class, new Xstore_APIHTTPCalloutMock());
        Test.startTest();
        Xstore_API.updateOpportunityAmount();
        Test.stopTest();
    }
    
    @IsTest
    static void testXstoreNotZeroDepositCreationInProgress() {
        //MIY-2092 Starts here
        
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test Opp';
        objOpportunity.CloseDate = system.Today() + 3;
        objOpportunity.SPO_DepositAmount__c = 12345;
        objOpportunity.SPO_XstoreDeposit__c = 5000;
        objOpportunity.StageName = 'Creation in progress';
        objOpportunity.OrderNumber__c = 'P1234567';
        insert objOpportunity;
        Opportunity thisOppDeposit = [
            SELECT Id, SPO_DepositAmount__c, SPO_XstoreDeposit__c, OrderNumber__c
            FROM Opportunity
        ];
        
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri =
            'https://louisvuitton--pprod.my.salesforce.com/services/apexrest/Opportunity/' +
            thisOppDeposit.OrderNumber__c;
        RestContext.request = request;
        RestContext.response = res;
        
        request.httpMethod = 'PATCH';
        request.addHeader('Content-type', 'application/json');
        request.requestBody = Blob.valueOf('{"depositAmount": 0}');
        RestContext.request = request;
        Test.setMock(HttpCalloutMock.class, new Xstore_APIHTTPCalloutMock());
        Test.startTest();
        Xstore_API.updateOpportunityAmount();
        Test.stopTest();
    }
    
    @IsTest
    static void testXstoreNotZeroDepositCancelledByStore() {
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test Opp';
        objOpportunity.CloseDate = system.Today() + 3;
        objOpportunity.SPO_DepositAmount__c = 12345;
        objOpportunity.SPO_XstoreDeposit__c = 5000;
        objOpportunity.StageName = 'Cancelled by store';
        objOpportunity.SPO_StopBriefReason__c = 'Test Cancel';
        insert objOpportunity;
        Opportunity thisOppDeposit = [
            SELECT Id, SPO_DepositAmount__c, SPO_XstoreDeposit__c, OrderNumber__c
            FROM Opportunity
        ];
        
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri =
            'https://louisvuitton--pprod.my.salesforce.com/services/apexrest/Opportunity/' +
            thisOppDeposit.OrderNumber__c;
        RestContext.request = request;
        RestContext.response = res;
        
        request.httpMethod = 'PATCH';
        request.addHeader('Content-type', 'application/json');
        request.requestBody = Blob.valueOf('{"depositAmount": 0}');
        RestContext.request = request;
        Test.setMock(HttpCalloutMock.class, new Xstore_APIHTTPCalloutMock());
        Test.startTest();
        Xstore_API.updateOpportunityAmount();
        Test.stopTest();
    }
    
    @IsTest
    static void testXstoreNotZeroDepositFailCancel() {
        Opportunity objOpportunity = new Opportunity();
        objOpportunity.Name = 'Test Opp';
        objOpportunity.CloseDate = system.Today() + 3;
        objOpportunity.SPO_DepositAmount__c = 12345;
        objOpportunity.SPO_XstoreDeposit__c = 5000;
        objOpportunity.StageName = 'Distribution in progress';
        insert objOpportunity;
        Opportunity thisOppDeposit = [
            SELECT Id, SPO_DepositAmount__c, SPO_XstoreDeposit__c, OrderNumber__c
            FROM Opportunity
        ];
        
        RestRequest request = new RestRequest();
        RestResponse res = new RestResponse();
        request.requestUri =
            'https://louisvuitton--pprod.my.salesforce.com/services/apexrest/Opportunity/' +
            thisOppDeposit.OrderNumber__c;
        RestContext.request = request;
        RestContext.response = res;
        
        request.httpMethod = 'PATCH';
        request.addHeader('Content-type', 'application/json');
        request.requestBody = Blob.valueOf('{"DepositAmount": 0}');
        RestContext.request = request;
        Test.setMock(HttpCalloutMock.class, new Xstore_APIHTTPCalloutMock());
        Test.startTest();
        Xstore_API.updateOpportunityAmount();
        Test.stopTest();
    }
    
    @IsTest
    // Running as Admin
    static void testXstoreCreateFirmOrderCannotCancel() {
        User adminUser = adminUser;
        System.runAs(adminUser) {
            FirmOrderTriggerHandler_TEST helper = new FirmOrderTriggerHandler_TEST();
            Store__c st = LV_TestFactory.createStore(
                'LV TEST STORE MIY',
                'Store',
                'A00',
                'FRANCE',
                'EUR',
                'Open'
            );
            st.MANAGEMENT_ZONE_LEVEL__c = '15';
            insert st;
            
            // create a client
            Account client = LV_TestFactory.createAccount();
            insert client;
            
            // create a non exotic product catalog
            ProductCatalogue__c pc = LV_TestFactory.createProductCatalog(
                'MY NEVERFULL',
                'P0001',
                3,
                15,
                5,
                'Leather Goods'
            );
            pc.Workshop__c = '1798';
            insert pc;
            
            Opportunity spoOrder = LV_TestFactory.createOrder(
                'SPO_1',
                'Distribution in progress',
                null,
                st.id,
                client.id,
                null,
                null,
                'SPO'
            );
            spoOrder.SPO_DepositSentStatusDate__c = System.today();
            spoOrder.SPO_EstimatedProductionTimeMonths__c = 1;
            spoOrder.SPO_DepositAmount__c = 12345;
            spoOrder.SPO_XstoreDeposit__c = null;
            insert spoOrder;
            List<Opportunity> opps = [
                SELECT OrderNumber__c
                FROM Opportunity
                WHERE Id = :spoOrder.Id
            ];
            String orderNumber;
            if (opps.size() > 0) {
                orderNumber = opps[0].OrderNumber__c;
            }
            
            // create a firm order
            SPO_FirmOrder__c fo = LV_TestFactory.createFirmOrder(spoOrder.id, 1, pc.id);
            fo.SPO_FirmOrderStatus__c = 'Distribution in progress';
            fo.SPO_TechETLStatus__c = 'A';
            insert fo;
            
            fo = [
                SELECT Id, SPO_FirmOrderStatus__c, SPO_TechETLStatus__c
                FROM SPO_FirmOrder__c
                WHERE Id = :fo.Id
            ];
            
            RestRequest request = new RestRequest();
            RestResponse res = new RestResponse();
            request.requestUri =
                'https://louisvuitton--pprod.my.salesforce.com/services/apexrest/Opportunity/' +
                orderNumber;
            
            RestContext.request = request;
            RestContext.response = res;
            
            request.httpMethod = 'PATCH';
            request.addHeader('Content-type', 'application/json');
            request.requestBody = Blob.valueOf('{"depositAmount": 12345}');
            RestContext.request = request;
            Test.setMock(HttpCalloutMock.class, new Xstore_APIHTTPCalloutMock());
            Test.startTest();
            Xstore_API.updateOpportunityAmount();
            Test.stopTest();
        }
    }
}