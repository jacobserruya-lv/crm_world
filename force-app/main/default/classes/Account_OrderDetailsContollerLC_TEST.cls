@Istest
global class Account_OrderDetailsContollerLC_TEST  {

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
     @isTest static void testMethod1() {
        Test.setMock(HttpCalloutMock.class, new Account_OrderDetailsContollerLC_TEST.OrderHttpCalloutMock()); 
        Test.startTest();
        Order__c  ord = [SELECT id, OrderNumber__c FROM Order__c limit 1];
        Object response = Account_OrderDetailsControllerLC.getOrderDetails(ord.OrderNumber__c, false);
        Test.stopTest();
        system.assertnotequals(null,response);
    }
     @isTest static void testMethod2() {
        Test.setMock(HttpCalloutMock.class, new Account_OrderDetailsContollerLC_TEST.OrderHttpCalloutMock()); 
        Test.startTest();
        Order__c  ord = [SELECT id, OrderNumber__c FROM Order__c limit 1];
        Object response = Account_OrderDetailsControllerLC.getOrderDetails(ord.id, true);
        system.assertnotequals(null,response);
        Test.stopTest();
    }
    @isTest static void testMethod3() {
        Test.startTest();
        OrderShipping__c ordership = [SELECT id, order__c FROM OrderShipping__c limit 1 ];
        String str = Account_OrderDetailsControllerLC.getOrderId(ordership.id);
        system.assertequals(str,ordership.order__c);
        Test.stopTest();
    }
    @isTest static void testMethod4() {
        Test.startTest();

        CaseTeamRole caseTeam = [SELECT Id FROM CaseTeamRole WHERE Name='Back Office'];
        CaseTeamTemplate myCaseTeam =  [SELECT Id FROM CaseTeamTemplate limit 1];


        CaseTeamTemplateMember caseTeamMember = new CaseTeamTemplateMember (MemberId = UserInfo.getuserid() ,TeamRoleId = caseTeam.id ,TeamTemplateId = myCaseTeam.id);
        insert caseTeamMember;


        Account_OrderDetailsControllerLC.backOfficeUser();
        Account_OrderDetailsControllerLC.reasonPicklist();
        Account_OrderDetailsControllerLC.actionPicklist();


        //system.assertequals(str,ordership.order__c);
        Test.stopTest();
    }


    @isTest static void OrderPriorization() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Account_OrderDetailsContollerLC_TEST.OrderHttpCalloutMock()); 

        sendAction();

        Account_OrderDetailsControllerLC.reasonPicklist();
        Account_OrderDetailsControllerLC.actionPicklist();

        //system.assertequals(str,ordership.order__c);
        Test.stopTest();
    }

    @isTest static void OrderPriorization2() {
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new Account_OrderDetailsContollerLC_TEST.ActionFailHttpCalloutMock()); 
        try
        {
            sendAction();
        } catch (Exception e) {  }
       // system.assertequals(str,ordership.order__c);
        Test.stopTest();
    }
    private static void sendAction(){

        OrderShipping__c ordership = [SELECT id, order__c,ShippingNumber__c FROM OrderShipping__c limit 1 ];
        Map<String,Object> bodyTosend = new Map<String,Object> {
            'id' => ordership.ShippingNumber__c.split('-')[0],
            'requesting_system' => 'SALESFORCE',
            'item_id' => 'M6868',
            'line_number' => ordership.ShippingNumber__c.split('-')[1],
            'action_message' =>  'prioritize',
            'action' => 'VIC'
        };
        Account_OrderDetailsControllerLC.sendAction(bodyTosend,ordership.id);
        
    }
    private static Order__c createOrder(Account acc) {
        Order__c orderRecord = new Order__c();
        orderRecord.OrderNumber__c = '1234567898000000';
        orderRecord.Account__c = acc.id;
        return orderRecord;
    }
    private static OrderShipping__c createOrderShipping(Order__c orderId) {
        OrderShipping__c orderShippingRecord = new OrderShipping__c();
        orderShippingRecord.ShippingNumber__c = '0123456789-1';
        orderShippingRecord.Order__c = orderId.id;
        return orderShippingRecord;
    }
    private static OrderLine__c createOrderLine(Order__c orderId) {
        OrderLine__c orderLineRecord = new OrderLine__c();
        orderLineRecord.Name = '1234567898000000-1';
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
    
    global class OrderHttpCalloutMock implements HttpCalloutMock {

        global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(infoOrder());
            response.setStatusCode(200);
            return response; 
        }
    }

    global class ActionFailHttpCalloutMock implements HttpCalloutMock {

        global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(infoOrder());
            response.setStatusCode(400);
            return response; 
        }
    }
     public static string infoOrder(){
        string str = '{'+
                    '"order_id":"1234567898000000",'+
                    '"xstore_request_id":"10000969",'+
                    '"gift":"N",'+
                    '"employee_id":"999999000000090",'+
                    '"requesting_location":{'+
                        '"name":"Louis Vuitton",'+
                        '"rms_id":"I03",'+
                        '"xstore_id":"I03"'+
                    '},'+
                    '"transaction":{'+ 
                        '"total":"223",'+
                        '"subtotal":"223",'+
                        '"tax_amount":"13.23",'+
                        '"balance_due":"45.9",'+
                        '"date":"2020-01-15T07:53:48.734Z"'+
                    '},'+
                    '"sold_to":{'+
                        '"customer_no":"Z018918188",'+
                        '"email":"antoine.raith@louisvuitton.com",'+
                        '"phone1":"0033614740426",'+
                        '"phone2":"0032487575021",'+
                        '"name":{'+
                            '"prefix":"Mr",'+
                            '"first":"Antoine",'+
                            '"middle":"",'+
                            '"last":"Raith",'+
                            '"suffix":""'+
                        '},'+
                        '"address":{'+
                            '"address1":"10 rue Bailleul",'+
                            '"address2":"",'+
                            '"address3":"",'+
                            '"address4":"",'+
                            '"city":"Paris",'+
                            '"province":"",'+
                            '"postal_code":"75001",'+
                            '"country":"France"'+
                        '}'+
                '},'+
                    '"order_lines":['+
                        '{'+
                            '"id":"1123456789",'+
                            '"creation_date":"2020-01-15T07:53:48.735Z",'+
                            '"request_id":"0123456789",'+
                            '"fulfillment_type":"DEV",'+
                            '"source_location":{'+
                                '"name":"EUROPA",'+
                                '"rms_id":"EUR",'+
                                '"xstore_id":"EUR"'+
                            '},'+
                            '"qty":"2",'+
                            '"item_id":"M6868",'+
                            '"item_description":"COUV.AG.FON.GM2 LV MNG",'+
                            '"line_number":"1",'+
                            '"unit_price":"540",'+
                            '"tax_amount":"93.72",'+
                            '"status":"polled",'+
                            '"ship_to":{'+
                                '"name":{'+
                                    '"company_name":"Louis Vuitton ANTWERPEN",'+
                                    '"prefix":"Mr",'+
                                    '"first":"Antoine",'+
                                    '"middle":"",'+
                                    '"last":"Raith",'+
                                    '"suffix":""'+
                                '},'+
                                '"address":{'+
                                    '"address1":"10 rue Bailleul",'+
                                    '"address2":"",'+
                                    '"address3":"",'+
                                    '"address4":"",'+
                                    '"city":"Paris",'+
                                    '"province":"",'+
                                    '"postal_code":"75001",'+
                                    '"country":"France"'+
                                '}'+
                            '},'+
                            '"segments":['+
                                '{'+
                                    '"ship_from_location":"I02",'+
                                    '"ship_to_location":"DER",'+
                                    '"next_ship_to_location":"R33",'+
                                    '"state":"open"'+
                                '}'+
                            '],'+
                            '"shipment":['+
                                
                            '],'+
                            '"logs":['+
                                
                            '],'+
                            '"available_actions":['+
                                '"string2"'+
                            ']'+
                        '}'+
                    ']'+
            '}';
            return str;
    }
    
}