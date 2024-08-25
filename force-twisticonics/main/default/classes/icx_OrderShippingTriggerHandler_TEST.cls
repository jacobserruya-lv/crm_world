@isTest
public with sharing class icx_OrderShippingTriggerHandler_TEST {
    @TestSetup
    static void makeData(){
        CaseTeamRole caseTeam = [SELECT Id FROM CaseTeamRole WHERE Name='Back Office'];

        IconicsSettings__c setting = new IconicsSettings__c();
        setting.BackOfficeId__c = caseTeam.Id;        
        insert setting;

        CaseTeamTemplate myCaseTeam =  [SELECT Id FROM CaseTeamTemplate limit 1];
        system.debug(myCaseTeam);

        ProductReferential__c product = ICX_TestFactory.createProductReferential('M6868');
        insert product;

        store__c storeA10 = ICX_TestFactory.createStore('Louis Vuitton Store A10', 'A10');
        storeA10.StoreType__c = 'Warehouse';
        store__c storeA11 = ICX_TestFactory.createStore('Louis Vuitton Store A11', 'A11');
        insert new List<Store__c>{storeA10, storeA11};

        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
        Order__c orderRecord = ICX_TestFactory.createOrder(acc.Id) ;
        insert orderRecord;
        
    }

    @isTest
    static void insertOrderShipping() {
        Order__c orderRecord = [SELECT id, OrderNumber__c FROM order__c Limit 1];

        Test.startTest();
            OrderShipping__c orderShippingRecord = ICX_TestFactory.createOrderShipping(orderRecord.Id) ;
            orderShippingRecord.status__c = 'accepted';
            orderShippingRecord.Source_Location__c = 'A10';
            orderShippingRecord.Pickup_Location__c = 'A11';
            insert orderShippingRecord;
            
            // OrderLine__c orderLineRecord = createOrderLine(orderRecord) ;
            // insert orderLineRecord;

            
        Test.stopTest();


        orderShippingRecord = [SELECT id, statusIconics__c FROM orderShipping__c Limit 1];

        system.assertnotequals(null, orderShippingRecord.statusIconics__c);
    }

    @isTest
    static void updateOrderShipping() {
        Order__c orderRecord = [SELECT id, OrderNumber__c FROM order__c Limit 1];

        OrderShipping__c orderShippingRecord = ICX_TestFactory.createOrderShipping(orderRecord.Id) ;
        orderShippingRecord.status__c = 'received';
        insert orderShippingRecord;

        Test.startTest();
            
            orderShippingRecord.status__c = 'fulfilled';
            update orderShippingRecord;
            
            // OrderLine__c orderLineRecord = createOrderLine(orderRecord) ;
            // insert orderLineRecord;

            
        Test.stopTest();


        orderShippingRecord = [SELECT id, statusIconics__c FROM orderShipping__c Limit 1];

        system.assertnotequals(null, orderShippingRecord.statusIconics__c);
    }

    @isTest
    static void shippingGroupHistory() {
        
        JSON2KbrwOrder.Logs log = new JSON2KbrwOrder.Logs();
        JSON2KbrwOrder.Order_lines orderLineKbrw = new JSON2KbrwOrder.Order_lines();
        JSON2KbrwOrder orderKbrw = new JSON2KbrwOrder();

        log.status = 'accepted';
        log.location = new JSON2KbrwOrder.Requesting_location();
        log.location.rms_id = 'A10'; // 
        log.location.type = 'Store'; // 
        orderLineKbrw.reason = new OrderShipping__c();
        orderLineKbrw.reason.pickup_location__c = 'A10';
        orderLineKbrw.fulfillment_type = 'DELIVERY';

        orderLineKbrw.logs = new List<JSON2KbrwOrder.Logs>{log};
        orderKbrw.order_lines = new List<JSON2KbrwOrder.Order_lines>{orderLineKbrw};
        

        Test.startTest();
        
        ICX_OrderShippingStatusService.setIconicsShippingGroupStatusHistory(orderKbrw);    
        // OrderLine__c orderLineRecord = createOrderLine(orderRecord) ;
        // insert orderLineRecord;

            
        Test.stopTest();

        System.debug('JGU-log.iconicsStatus: '+orderKbrw.order_lines.get(0).logs.get(0));
        
        system.assertnotequals(null, orderKbrw.order_lines.get(0).logs.get(0).statusIconics);
    }

}