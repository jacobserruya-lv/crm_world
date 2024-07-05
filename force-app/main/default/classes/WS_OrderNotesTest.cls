@istest
public with sharing class WS_OrderNotesTest {
    static final string EXISTING_ORDER_NUMBER = '1234567898000000';
    static final string EXISTING_SHIPPING_NUMBER = '0123456789-1';

    @testSetup  
    static void makeData(){
        CaseTeamRole caseTeam = [SELECT Id FROM CaseTeamRole WHERE Name='Back Office'];

        IconicsSettings__c setting = new IconicsSettings__c();
        setting.BackOfficeId__c = caseTeam.Id;        
        insert setting;

        CaseTeamTemplate myCaseTeam =  [SELECT Id FROM CaseTeamTemplate limit 1];
        system.debug(myCaseTeam);

        ProductReferential__c product = createProductReferential('M6868');
        insert product;

        store__c store = createStore('I03');
        insert store;

        Account acc = createAccount('test', 'test', null, null);
        insert acc;
        
        Order__c orderRecord = createOrder(acc) ;
        insert orderRecord;
        
        OrderShipping__c orderShippingRecord = createOrderShipping(orderRecord) ;
        insert orderShippingRecord;
        
        OrderLine__c orderLineRecord = createOrderLine(orderRecord) ;
        insert orderLineRecord;
    }

    private static void requestSetup(String requestJson, String httpMethod) {
        RestRequest req = new RestRequest();
        RestResponse resp = new RestResponse();

        if(httpMethod.equals('POST')) {
            req.requestURI = '/services/apexrest/orderNotes/';
        }

        req.httpMethod = httpMethod;
        req.requestBody = Blob.valueOf(requestJson);
        RestContext.request = req;
        RestContext.response = resp;
    }

    private static String getOrderNote(String orderNumber, String shippingNumber, String orderType, String description, String reasonCode) {
        string addSeparator = '';

        String jsonNote = '{';
        if (orderNumber != null) {
            jsonNote += '"orderNumber": "'+orderNumber+'"';
            addSeparator = ',';
        }
        if (shippingNumber != null) {
            jsonNote += addSeparator+'"shippingNumber": "'+shippingNumber+'"';
            addSeparator = ',';
        }
        if (orderType != null) {
            jsonNote += addSeparator+'"orderType": "'+orderType+'"';
            addSeparator = ',';
        }
        if (description != null) {
            jsonNote += addSeparator+'"description": "'+description+'"';
            addSeparator = ',';
        }
        if (reasonCode != null) {
            jsonNote += addSeparator+'"reasonCode": "'+reasonCode+'"';
        }
        jsonNote += '}';

        return jsonNote;
    }

    private static JSON2OrderNotes getOrderNotes(List<String> jsonNotes) {
        system.debug('inside getOrderNotes: '+jsonNotes);
        string addSeparator = '';

        String jsonOrderNotes = '{"orderNotes" : [';
        for(String jsonNote: jsonNotes) {
            jsonOrderNotes += addSeparator+jsonNote;
            addSeparator = ',';
        }

        jsonOrderNotes += ']}';

        JSON2OrderNotes request = JSON2OrderNotes.parse(jsonOrderNotes);

        return request;
    }

    // Create order comment on existing Order
    @istest static void sendOrderCommentExisting() {

        List<String> jsonOrderNotes = new List<String>();
        String jsonComment = getOrderNote(EXISTING_ORDER_NUMBER, null, 'ATTACHED_NOTE', 'This is the first comment', null);
        jsonOrderNotes.add(jsonComment);        
        JSON2OrderNotes request = getOrderNotes(jsonOrderNotes);
        
        requestSetup(JSON.serializePretty(request), 'PUT');
        
        test.startTest();
        WS_OrderNotes.upsertOrderNotes();
        test.stopTest();

        system.debug(RestContext.response);
        system.assertEquals(RestContext.response.statusCode, 200, 'Mauvais statusCode' );
    }

    // Create order comment on not existing Order
    @istest static void sendOrderCommentNotExisting() {

        List<String> jsonOrderNotes = new List<String>();
        String jsonComment = getOrderNote('notExistingOrder', null, 'ATTACHED_NOTE', 'This is the first comment', null);
        jsonOrderNotes.add(jsonComment);        
        JSON2OrderNotes request = getOrderNotes(jsonOrderNotes);
        
        requestSetup(JSON.serializePretty(request), 'POST');
        
        test.startTest();
        WS_OrderNotes.upsertOrderNotes();
        test.stopTest();

        system.debug(RestContext.response);
        system.assertEquals(RestContext.response.statusCode, 200, 'Mauvais statusCode' );
    }

    // Create 2 order comments on existing Order
    @istest static void send2OrderCommentsExisting() {

        List<String> jsonOrderNotes = new List<String>();
        String jsonComment = getOrderNote(EXISTING_ORDER_NUMBER, null, 'ATTACHED_NOTE', 'This is the first comment', null);
        jsonOrderNotes.add(jsonComment);        
        jsonComment = getOrderNote(EXISTING_ORDER_NUMBER, null, 'ATTACHED_NOTE', 'This is the second comment', null);
        jsonOrderNotes.add(jsonComment); 
        JSON2OrderNotes request = getOrderNotes(jsonOrderNotes);
        
        requestSetup(JSON.serializePretty(request), 'POST');
        
        test.startTest();
        WS_OrderNotes.upsertOrderNotes();
        test.stopTest();

        system.debug(RestContext.response);
        system.assertEquals(RestContext.response.statusCode, 400, 'Mauvais statusCode' );
    }

    // Create order comment with 'shippingNumber' parameters
    @istest static void sendShippingGroupCommentExisting() {
        List<String> jsonOrderNotes = new List<String>();
        String jsonComment = getOrderNote(EXISTING_ORDER_NUMBER, EXISTING_SHIPPING_NUMBER, 'ATTACHED_NOTE', 'This is the first comment', null);
        jsonOrderNotes.add(jsonComment);        
        JSON2OrderNotes request = getOrderNotes(jsonOrderNotes);
        
        requestSetup(JSON.serializePretty(request), 'POST');
        
        test.startTest();
        WS_OrderNotes.upsertOrderNotes();
        test.stopTest();

        system.debug(RestContext.response);
        system.assertEquals(RestContext.response.statusCode, 400, 'Mauvais statusCode' );
    }

    // Create Price Adjustment at Order Level
    @istest static void sendOrderPriceAdjustmentExisting() {

        List<String> jsonOrderNotes = new List<String>();
        String jsonComment = getOrderNote(EXISTING_ORDER_NUMBER, null, 'PRICE_ADJUSTMENT', 'This is the price adjutment', 'None of above');
        jsonOrderNotes.add(jsonComment);        
        JSON2OrderNotes request = getOrderNotes(jsonOrderNotes);
        
        requestSetup(JSON.serializePretty(request), 'POST');
        
        test.startTest();
        WS_OrderNotes.upsertOrderNotes();
        test.stopTest();

        system.debug(RestContext.response);
        system.assertEquals(RestContext.response.statusCode, 400, 'Mauvais statusCode' );
    }

    // Create Price adjustment without 'shippingNumber' parameters
    @istest static void sendShippingGroupPriceAdjustment_WithoutShippingNumberExisting() {
        List<String> jsonOrderNotes = new List<String>();
        String jsonComment = getOrderNote(EXISTING_ORDER_NUMBER, null, 'PRICE_ADJUSTMENT', 'This is the price adjutment', 'None of above');
        jsonOrderNotes.add(jsonComment);        
        JSON2OrderNotes request = getOrderNotes(jsonOrderNotes);
        
        requestSetup(JSON.serializePretty(request), 'POST');
        
        test.startTest();
        WS_OrderNotes.upsertOrderNotes();
        test.stopTest();

        system.debug(RestContext.response);
        system.assertEquals(RestContext.response.statusCode, 400, 'Mauvais statusCode' );
    }

    // Create Price adjustment
    @istest static void sendShippingGroupPriceAdjustment() {
        List<String> jsonOrderNotes = new List<String>();
        String jsonComment = getOrderNote('notExistingOrder', 'notExistingShipping', 'PRICE_ADJUSTMENT', 'This is the price adjutment', 'None of above');
        jsonOrderNotes.add(jsonComment);        
        JSON2OrderNotes request = getOrderNotes(jsonOrderNotes);
        
        requestSetup(JSON.serializePretty(request), 'POST');
        
        test.startTest();
        WS_OrderNotes.upsertOrderNotes();
        test.stopTest();

        system.debug(RestContext.response);
        system.assertEquals(RestContext.response.statusCode, 200, 'Mauvais statusCode' );
    }

    // Create Price adjustment on not Existing Shipping Number
    @istest static void sendShippingGroupPriceAdjustmentExisting() {
        List<String> jsonOrderNotes = new List<String>();
        String jsonComment = getOrderNote(EXISTING_ORDER_NUMBER, EXISTING_SHIPPING_NUMBER, 'PRICE_ADJUSTMENT', 'This is the price adjutment', 'None of above');
        jsonOrderNotes.add(jsonComment);        
        JSON2OrderNotes request = getOrderNotes(jsonOrderNotes);
        
        requestSetup(JSON.serializePretty(request), 'POST');
        
        test.startTest();
        WS_OrderNotes.upsertOrderNotes();
        test.stopTest();

        system.debug(RestContext.response);
        system.assertEquals(RestContext.response.statusCode, 200, 'Mauvais statusCode' );
    }    


    // Create Perso Product Accepted on Existing Order Number
    @istest static void sendPersoProductAcc() {
        List<String> jsonOrderNotes = new List<String>();
        String jsonComment = getOrderNote(EXISTING_ORDER_NUMBER, null, 'PERSO_PRODUCT_ACC', null, null);
        jsonOrderNotes.add(jsonComment);        
        JSON2OrderNotes request = getOrderNotes(jsonOrderNotes);
        
        requestSetup(JSON.serializePretty(request), 'POST');
        
        test.startTest();
        WS_OrderNotes.upsertOrderNotes();
        test.stopTest();

        system.debug(RestContext.response);
        system.assertEquals(RestContext.response.statusCode, 200, 'Mauvais statusCode' );
    } 
    
    
    // Create Perso Product Refused on Existing Order Number
    @istest static void sendPersoProductRefWithoutReasonCode() {
        List<String> jsonOrderNotes = new List<String>();
        String jsonComment = getOrderNote(EXISTING_ORDER_NUMBER, null, 'PERSO_PRODUCT_REF', null, null);
        jsonOrderNotes.add(jsonComment);        
        JSON2OrderNotes request = getOrderNotes(jsonOrderNotes);
        
        requestSetup(JSON.serializePretty(request), 'POST');
        
        test.startTest();
        WS_OrderNotes.upsertOrderNotes();
        test.stopTest();

        system.debug(RestContext.response);
        system.assertEquals(RestContext.response.statusCode, 200, 'Mauvais statusCode' );
    } 

        // Create Perso Product Refused on Existing Order Number
        @istest static void sendPersoProductRefWithReasonCode() {
            List<String> jsonOrderNotes = new List<String>();
            String jsonComment = getOrderNote(EXISTING_ORDER_NUMBER, null, 'PERSO_PRODUCT_REF', 'This is the perso product refused', 'None of above');
            jsonOrderNotes.add(jsonComment);        
            JSON2OrderNotes request = getOrderNotes(jsonOrderNotes);
            
            requestSetup(JSON.serializePretty(request), 'POST');
            
            test.startTest();
            WS_OrderNotes.upsertOrderNotes();
            test.stopTest();
    
            system.debug(RestContext.response);
            system.assertEquals(RestContext.response.statusCode, 200, 'Mauvais statusCode' );
        }

    private static Order__c createOrder(Account acc) {
        Order__c orderRecord = new Order__c();
        orderRecord.OrderNumber__c = EXISTING_ORDER_NUMBER;
        orderRecord.Account__c = acc.id;
        return orderRecord;
    }
    private static OrderShipping__c createOrderShipping(Order__c orderId) {
        OrderShipping__c orderShippingRecord = new OrderShipping__c();
        orderShippingRecord.ShippingNumber__c = EXISTING_SHIPPING_NUMBER;
        orderShippingRecord.Order__c = orderId.id;
        return orderShippingRecord;
    }
    private static OrderLine__c createOrderLine(Order__c orderId) {
        OrderLine__c orderLineRecord = new OrderLine__c();
        orderLineRecord.Name = EXISTING_ORDER_NUMBER+'-1';
        orderLineRecord.Order__c = orderId.id;
        return orderLineRecord;
    }
    private static ProductReferential__c createProductReferential(String sku) {
        ProductReferential__c prod = new ProductReferential__c();
        prod.SKUCode__c = sku;
        prod.Name = 'DEMO PRODUCT';
        return prod;
    }
    private static store__c createStore(String retailStoreId) {
        store__c storeRecord = new store__c();
        storeRecord.RetailStoreId__c = retailStoreId;
        storeRecord.Name = 'Louis Vuitton';
        return storeRecord;
    }
    private static Account createAccount(String firstname, String lastname, String phone, String email) {
        Account acc = new Account();
        acc.Firstname = firstname;
        acc.LastName = lastname;
        acc.PersonMobilePhone = phone;
        acc.PersonEmail = email;
        return acc;
    }
}