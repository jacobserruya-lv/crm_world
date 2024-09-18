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

        ProductReferential__c product = ICX_TestFactory.createProductReferential('M6868');
        insert product;

        store__c store = ICX_TestFactory.createStore('LV SOHO','I03');
        insert store;

        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
        Order__c orderRecord = ICX_TestFactory.createOrder(acc.id) ;
        orderRecord.store__c = store.id;
        insert orderRecord;
        
        OrderShipping__c orderShippingRecord = ICX_TestFactory.createOrderShipping(orderRecord) ;
        insert orderShippingRecord;
        
        OrderLine__c orderLineRecord = ICX_TestFactory.createOrderLine(orderRecord) ;
        insert orderLineRecord;

        Id profileId = [SELECT Id FROM Profile WHERE Name='ICONiCS_SA' LIMIT 1].Id;

        User currentUser = ICX_TestFactory.createUser(profileId);
        currentUser.WWEmployeeNumber__c='LV12345';
        currentUser.MANAGEMENT_ZONE_LEVEL__c = '3';
        insert currentUser;

		Country__c country = ICX_TestFactory.createCountry('US', 'USA', 'USA');
        insert country;

        Language2__c language = ICX_TestFactory.createLanguage('US', 'USA');
        insert language;

        CountryLanguage__c countryLanguage = ICX_TestFactory.createCountryLanguage(country.id, language.id);   
        countryLanguage.ATG_Locale__c = 'eng-ae'; 
        countryLanguage.Salesforce_Locale__c = 'en_US';
        countryLanguage.Dispatch_Country__c = 'USA';
        countryLanguage.OOB_Local__c='eng-ae';
        countryLanguage.Mulesoft_Local__c='eco-eu';
        insert countryLanguage;

        OOB_Setting__c orgDefault = new OOB_Setting__c();
        orgDefault.SetupOwnerId=UserInfo.getOrganizationId();
        orgDefault.VisibilityCountryIso2__c='US';
        insert orgDefault;
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
        Account_OrderDetailsControllerLC.backOfficeUser2();
        Account_OrderDetailsControllerLC.reasonPicklist();
        Account_OrderDetailsControllerLC.actionPicklist();


        //system.assertequals(str,ordership.order__c);
        Test.stopTest();
    }

    
    @isTest static void getOrderDetailsTwistV2RecordId() {
        Integer statusCode = 200;
        String status = 'OK';
        String body = infoOrder2();
        HttpResponseMock mock = new HttpResponseMock(new Map<String,String>(), statusCode, status, body);
        UnitTestsHelper.setSingleHttpMock(mock);
        Test.startTest();
        Order__c  ord = [SELECT id, OrderNumber__c FROM Order__c limit 1];
        Object response = Account_OrderDetailsControllerLC.getOrderDetailsTwistV2(ord.id, true);
        system.assertnotequals(null,response);
        Test.stopTest();
    }

    @isTest static void getOrderDetailsTwistV2FailedTEST() {
        Integer statusCode = 404;
        String status = 'ERROR';
        String body = infoOrder2();
        HttpResponseMock mock = new HttpResponseMock(new Map<String,String>(), statusCode, status, body);
        UnitTestsHelper.setSingleHttpMock(mock);
        Test.startTest();
        Order__c  ord = [SELECT id, OrderNumber__c FROM Order__c limit 1];
        Object response = Account_OrderDetailsControllerLC.getOrderDetailsTwistV2(ord.id, true);
        system.assertnotequals(null,response);
        Test.stopTest();
    }


    @isTest static void sendActionReturnTEST() {
        Test.startTest();
     
        Integer statusCode = 200;
        String status = 'OK';
        String body = infoOrder();
        HttpResponseMock mock = new HttpResponseMock(new Map<String,String>(), statusCode, status, body);
        UnitTestsHelper.setSingleHttpMock(mock);

        Order__c  ord = [SELECT id, OrderNumber__c, Store__r.RetailStoreId__c FROM Order__c limit 1];
        OrderShipping__c  ordShipp = [SELECT id, ShippingNumberV2__c FROM OrderShipping__c WHERE Order__c =:ord.Id  limit 1];
        User currentUser = [SELECT id, WWEmployeeNumber__c FROM User WHERE WWEmployeeNumber__c = 'LV12345' LIMIT 1];
        
        System.runAs(currentUser) {
        Account_OrderDetailsControllerLC.sendActionReturn(null,null,'SALE',currentUser.WWEmployeeNumber__c,ord.Store__r.RetailStoreId__c,ordShipp.ShippingNumberV2__c,'FRAUD',ord.OrderNumber__c,ordShipp.Id,'return');
        }
        
        Test.stopTest();
    }

    @isTest static void sendActionReturnStatus504TEST() {
        Test.startTest();
     
        Integer statusCode = 504;
        String status = 'OK';
        String body = infoOrder();
        HttpResponseMock mock = new HttpResponseMock(new Map<String,String>(), statusCode, status, body);
        UnitTestsHelper.setSingleHttpMock(mock);

        Order__c  ord = [SELECT id, OrderNumber__c, Store__r.RetailStoreId__c FROM Order__c limit 1];
        OrderShipping__c  ordShipp = [SELECT id, ShippingNumberV2__c FROM OrderShipping__c WHERE Order__c =:ord.Id  limit 1];
        User currentUser = [SELECT id, WWEmployeeNumber__c FROM User WHERE WWEmployeeNumber__c = 'LV12345' LIMIT 1];
        
        System.runAs(currentUser) {
        Account_OrderDetailsControllerLC.sendActionReturn(null,null,'SALE',currentUser.WWEmployeeNumber__c,ord.Store__r.RetailStoreId__c,ordShipp.ShippingNumberV2__c,'FRAUD',ord.OrderNumber__c,ordShipp.Id,'return');
        }

        Test.stopTest();
    }
   
    @isTest static void sendActionReturnErrorTEST() {
        Test.startTest();
     
        Integer statusCode = 500;
        String status = 'ERROR';
        String body = infoOrder();
        HttpResponseMock mock = new HttpResponseMock(new Map<String,String>(), statusCode, status, body);
        UnitTestsHelper.setSingleHttpMock(mock);

        Order__c  ord = [SELECT id, OrderNumber__c, Store__r.RetailStoreId__c FROM Order__c limit 1];
        OrderShipping__c  ordShipp = [SELECT id, ShippingNumberV2__c FROM OrderShipping__c WHERE Order__c =:ord.Id  limit 1];
        User currentUser = [SELECT id, WWEmployeeNumber__c FROM User WHERE WWEmployeeNumber__c = 'LV12345' LIMIT 1];
        
        System.runAs(currentUser) {
        Account_OrderDetailsControllerLC.sendActionReturn(null,null,'SALE',currentUser.WWEmployeeNumber__c,ord.Store__r.RetailStoreId__c,ordShipp.ShippingNumberV2__c,'FRAUD',ord.OrderNumber__c,ordShipp.Id,'return');
        }

        Test.stopTest();
    }

    @isTest static void sendActionRefundTEST() {
        Test.startTest();
     
        Integer statusCode = 200;
        String status = 'OK';
        String body = infoOrder();
        HttpResponseMock mock = new HttpResponseMock(new Map<String,String>(), statusCode, status, body);
        UnitTestsHelper.setSingleHttpMock(mock);

        Order__c  ord = [SELECT id, OrderNumber__c, Store__r.RetailStoreId__c FROM Order__c limit 1];
        OrderShipping__c  ordShipp = [SELECT id, ShippingNumberV2__c FROM OrderShipping__c WHERE Order__c =:ord.Id  limit 1];
        User currentUser = [SELECT id, WWEmployeeNumber__c FROM User WHERE WWEmployeeNumber__c = 'LV12345' LIMIT 1];
        
        System.runAs(currentUser) {
        Account_OrderDetailsControllerLC.sendActionRefund(null,'160','BANK_TRANSFER',currentUser.WWEmployeeNumber__c,ord.OrderNumber__c,'REFUND','Other',ordShipp.Id,ordShipp.ShippingNumberV2__c);
        }

        Test.stopTest();
    }

    @isTest static void sendActionRefundReceptionTEST() {
        Test.startTest();
     
        Integer statusCode = 200;
        String status = 'OK';
        String body = infoOrder();
        HttpResponseMock mock = new HttpResponseMock(new Map<String,String>(), statusCode, status, body);
        UnitTestsHelper.setSingleHttpMock(mock);

        Order__c  ord = [SELECT id, OrderNumber__c, Store__r.RetailStoreId__c FROM Order__c limit 1];
        OrderShipping__c  ordShipp = [SELECT id, ShippingNumberV2__c FROM OrderShipping__c WHERE Order__c =:ord.Id  limit 1];
        User currentUser = [SELECT id, WWEmployeeNumber__c FROM User WHERE WWEmployeeNumber__c = 'LV12345' LIMIT 1];
        
        System.runAs(currentUser) {
        Account_OrderDetailsControllerLC.sendActionFundsReception(null,'160','VISA','REFUND',currentUser.WWEmployeeNumber__c,'REFUND',ord.OrderNumber__c,ordShipp.ShippingNumberV2__c);
        }

        Test.stopTest();
    }


    @isTest static void sendActionRefundShippingFeesTEST() {
        Test.startTest();
     
        Integer statusCode = 200;
        String status = 'OK';
        String body = infoOrder();
        HttpResponseMock mock = new HttpResponseMock(new Map<String,String>(), statusCode, status, body);
        UnitTestsHelper.setSingleHttpMock(mock);

        Order__c  ord = [SELECT id, OrderNumber__c, Store__r.RetailStoreId__c FROM Order__c limit 1];
        OrderShipping__c  ordShipp = [SELECT id, ShippingNumberV2__c FROM OrderShipping__c WHERE Order__c =:ord.Id  limit 1];
        User currentUser = [SELECT id, WWEmployeeNumber__c FROM User WHERE WWEmployeeNumber__c = 'LV12345' LIMIT 1];
        Double amount = 160.00;
        System.runAs(currentUser) {
        Account_OrderDetailsControllerLC.sendActionRefundShippingFees(null,amount,'VISA',currentUser.WWEmployeeNumber__c,ord.OrderNumber__c,'refund_delivery_fees',null,ordShipp.ShippingNumberV2__c,ordShipp.id,'1');
        Account_OrderDetailsControllerLC.sendActionRefundShippingFees(null,amount,'BANK_TRANSFER',currentUser.WWEmployeeNumber__c,ord.OrderNumber__c,'refund_delivery_fees',null,ordShipp.ShippingNumberV2__c,ordShipp.id,'1');
        }

        Test.stopTest();
    }


    // @isTest static void sendActionExchangeTEST() {
    //     Test.startTest();

    //     Order__c  ord = [SELECT id, OrderNumber__c, Store__r.RetailStoreId__c FROM Order__c limit 1];
    //     OrderShipping__c  ordShipp = [SELECT id, ShippingNumberV2__c FROM OrderShipping__c WHERE Order__c =:ord.Id  limit 1];
    //     User currentUser = [SELECT id, WWEmployeeNumber__c FROM User WHERE WWEmployeeNumber__c = 'LV12345' LIMIT 1];
        
    //     System.runAs(currentUser) {
    //     Account_OrderDetailsControllerLC.sendActionExchange(ord.OrderNumber__c,ordShipp.Id,null,'Exchange');
    //     }

    //     Test.stopTest();
    // }

    @isTest static void sendActionExchangeWS_OrderActionTEST() {
        Test.startTest();
        Order__c  ord = [SELECT id, OrderNumber__c, Store__r.RetailStoreId__c FROM Order__c limit 1];
        OrderShipping__c  ordShipp = [SELECT id, ShippingNumberV2__c FROM OrderShipping__c WHERE Order__c =:ord.Id  limit 1];
        User currentUser = [SELECT id, WWEmployeeNumber__c FROM User WHERE WWEmployeeNumber__c = 'LV12345' LIMIT 1];
        
        Integer statusCode = 200;
        String status = 'OK';
        String body = exchangeResponseOK();
        HttpResponseMock mock = new HttpResponseMock(new Map<String,String>(), statusCode, status, body);
        UnitTestsHelper.setSingleHttpMock(mock);

        System.runAs(currentUser) {
            Account_OrderDetailsControllerLC.sendActionExchange(ord.OrderNumber__c,ordShipp.Id,'Other','Exchange');
        }

        Test.stopTest();
    }
    @isTest static void sendActionExchangeWS_OrderActionErrorTEST() {
        Test.startTest();
        Order__c  ord = [SELECT id, OrderNumber__c, Store__r.RetailStoreId__c FROM Order__c limit 1];
        OrderShipping__c  ordShipp = [SELECT id, ShippingNumberV2__c FROM OrderShipping__c WHERE Order__c =:ord.Id  limit 1];
        User currentUser = [SELECT id, WWEmployeeNumber__c FROM User WHERE WWEmployeeNumber__c = 'LV12345' LIMIT 1];
        
        Integer statusCode = 500;
        String status = 'Error';
        String body = exchangeResponseERROR();
        HttpResponseMock mock = new HttpResponseMock(new Map<String,String>(), statusCode, status, body);
        UnitTestsHelper.setSingleHttpMock(mock);

        System.runAs(currentUser) {
            Account_OrderDetailsControllerLC.sendActionExchange(ord.OrderNumber__c,ordShipp.Id,'Other','Exchange');
        }
        Test.stopTest();
    }


    @isTest static void getStoreTypeTEST() {
        Test.startTest();
        Store__c store = [SELECT id FROM Store__c LIMIT 1];
        Account_OrderDetailsControllerLC.getStoreType(store.id);

        Test.stopTest();
    }
    
    
    @isTest static void getProductMapTEST() {
        Test.startTest();
        List<String> skuList = new List<String>();
        skuList.add('M6868');
        Account_OrderDetailsControllerLC.getProductMap(skuList);
        Test.stopTest();
    }


    @isTest static void OrderPriorization() {
        Test.startTest();
     
        Integer statusCode = 200;
        String status = 'OK';
        String body = infoOrder();
        HttpResponseMock mock = new HttpResponseMock(new Map<String,String>(), statusCode, status, body);
        UnitTestsHelper.setSingleHttpMock(mock);

     
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

        OrderShipping__c ordership = [SELECT id, order__c,ShippingNumber__c, ShippingNumberV2__c FROM OrderShipping__c limit 1 ];
        Account_OrderDetailsControllerLC.sendAction(ordership.ShippingNumberV2__c,'SALESFORCE','prioritize','VIC' ,ordership.id, null);
    
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

    public static string exchangeResponseOK() {
        String str ='{"status":"OK}';
        return str;
    }
    public static string exchangeResponseERROR() {
        String str ='{"error":"error}';
        return str;
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

    public static string infoOrder2(){
        string str = '{'+
		'    "order_id": "1203003001798",'+
		'    "xstore_request_id": "10000969",'+
		'    "order_type": "SALE",'+
		'    "preferred_language": "en",'+
		'    "channel": "RETAIL",'+
		'    "creation_date": "2021-02-03T16:57:52.472Z",'+
		'    "currency": "EUR",'+
		'    "approval_confirmed": true,'+
		'    "risk_manual_review": true,'+
		'    "risk_auto_reviewed": true,'+
		'    "requesting_system": "XSTORE",'+
		'    "CA": {'+
		'        "employee_id": "999999000000090",'+
		'        "CACode": "JIHA",'+
		'        "WWEmployeeId": "LVM028862"'+
		'    },'+
		'    "requesting_location": {'+
		'        "xstore_id": "1406",'+
		'        "rms_id": "A06",'+
		'        "purchase_org": "F200",'+
		'        "name": "Louis Vuitton BRUXELLES",'+
		'        "type": "DC"'+
		'    },'+
		'    "transaction": {'+
		'        "total": 223,'+
		'        "subtotal": 223,'+
		'        "tax_amount": 13.23,'+
		'        "balance_due": 45.9,'+
		'        "deposit": 45.9,'+
		'        "deposit_rate": 1,'+
		'        "date": "2021-02-03T16:57:52.472Z"'+
		'    },'+
		'    "tenders": ['+
		'        {'+
		'            "amount": 65,'+
		'            "account": "to be used to pass additional info on tenders, such as last 4 digits for credit cards",'+
		'            "payment_method": "The payment method on 4 digits : Credit card, Apple pay, gift card ...",'+
		'            "description": "The description of the payment method on 3/4 digits : master card, visa, ..."'+
		'        }'+
		'    ],'+
		'    "sold_to": {'+
		'        "customer_no": "Z018918188",'+
		'        "email": "antoine.raith@louisvuitton.com",'+
		'        "phone1": "0033614740426",'+
		'        "phone2": "0032487575021",'+
		'        "name": {'+
		'            "company_name": "Louis Vuitton ANTWERPEN",'+
		'            "prefix": "Mr",'+
		'            "first": "Antoine",'+
		'            "middle": "",'+
		'            "last": "Raith",'+
		'            "suffix": ""'+
		'        },'+
		'        "address": {'+
		'            "address1": "10 rue Bailleul",'+
		'            "address2": "",'+
		'            "address3": "",'+
		'            "address4": "",'+
		'            "city": "Paris",'+
		'            "province": "",'+
		'            "postal_code": "75001",'+
		'            "country": "FR",'+
		'            "gps_lat": "48.789",'+
		'            "gps_lon": "2.789"'+
		'        },'+
		'        "nationality": "CAN",'+
		'        "type": "",'+
		'        "fiscal": {'+
		'            "fiscal_code": "",'+
		'            "tax_code": "",'+
		'            "tax_invoice_number": "",'+
		'            "legal_email": "antoine.raith@louisvuitton.com",'+
		'            "charity_code": "",'+
		'            "additional_information": "",'+
		'            "tax_system": "",'+
		'            "destination_code": "",'+
		'            "tax_invoice_date": "",'+
		'            "tax_type": ""'+
		'        }'+
		'    },'+
		'    "fees": ['+
		'        {'+
		'            "type": "shipping_fee",'+
		'            "total_amount": 10.1,'+
		'            "amount_tax_free": 10.1,'+
		'            "tax_amount": 10.1,'+
		'            "taxes": ['+
		'                {'+
		'                    "amount": 65,'+
		'                    "rate": 15.5,'+
		'                    "description": "VatTax"'+
		'                }'+
		'            ]'+
		'        }'+
		'    ],'+
		'    "shipping_groups": ['+
		'        {'+
		'            "request_id": "300001025",'+
		'            "fulfillment_type": "DELIVERY",'+
		'            "reservation_id": "ECOM20000399",'+
		'            "creation_date": "2021-02-03T16:57:52.472Z",'+
		'            "total_amount": 193.72,'+
		'            "total_amount_tax_free": 100,'+
		'            "tax_amount": 93.72,'+
		'            "taxes": ['+
		'                {'+
		'                    "amount": 65,'+
		'                    "rate": 15.5,'+
		'                    "description": "VatTax"'+
		'                }'+
		'            ],'+
		'            "status": "polled",'+
		'            "ship_to": {'+
		'                "email": "antoine.raith@louisvuitton.com",'+
		'                "special_instruction": "Leave at the door",'+
		'                "phone1": "0033614740426",'+
		'                "phone2": "0032487575021",'+
		'                "nationality": "CAN",'+
		'                "type": "",'+
		'                "name": {'+
		'                    "company_name": "Louis Vuitton ANTWERPEN",'+
		'                    "prefix": "Mr",'+
		'                    "first": "Antoine",'+
		'                    "middle": "",'+
		'                    "last": "Raith",'+
		'                    "suffix": ""'+
		'                },'+
		'                "address": {'+
		'                    "address1": "10 rue Bailleul",'+
		'                    "address2": "",'+
		'                    "address3": "",'+
		'                    "address4": "",'+
		'                    "city": "Paris",'+
		'                    "province": "",'+
		'                    "postal_code": "75001",'+
		'                    "country": "FR",'+
		'                    "gps_lat": "48.789",'+
		'                    "gps_lon": "2.789"'+
		'                }'+
		'            },'+
		'            "segments": ['+
		'                {'+
		'                    "ship_from_location": {'+
		'                        "xstore_id": "1406",'+
		'                        "rms_id": "A06",'+
		'                        "purchase_org": "F200",'+
		'                        "name": "Louis Vuitton BRUXELLES",'+
		'                        "type": "DC"'+
		'                    },'+
		'                    "ship_to_location": {'+
		'                        "xstore_id": "1406",'+
		'                        "rms_id": "A06",'+
		'                        "purchase_org": "F200",'+
		'                        "name": "Louis Vuitton BRUXELLES",'+
		'                        "type": "DC"'+
		'                    },'+
		'                    "next_ship_to_location": {'+
		'                        "xstore_id": "1406",'+
		'                        "rms_id": "A06",'+
		'                        "purchase_org": "F200",'+
		'                        "name": "Louis Vuitton BRUXELLES",'+
		'                        "type": "DC"'+
		'                    },'+
		'                    "state": "open"'+
		'                }'+
		'            ],'+
		'            "pickup_location": {'+
		'                "xstore_id": "1406",'+
		'                "rms_id": "A06",'+
		'                "purchase_org": "F200",'+
		'                "name": "Louis Vuitton BRUXELLES",'+
		'                "type": "DC"'+
		'            },'+
		'            "source_location": {'+
		'                "xstore_id": "1406",'+
		'                "rms_id": "A06",'+
		'                "purchase_org": "F200",'+
		'                "name": "Louis Vuitton BRUXELLES",'+
		'                "type": "DC"'+
		'            },'+
		'            "return_location": {'+
		'                "xstore_id": "1406",'+
		'                "rms_id": "A06",'+
		'                "purchase_org": "F200",'+
		'                "name": "Louis Vuitton BRUXELLES",'+
		'                "type": "DC"'+
		'            },'+
		'            "initial_leadtime": {'+
		'                "min": 10,'+
		'                "max": 15'+
		'            },'+
		'            "revised_leadtime": {'+
		'                "min": 10,'+
		'                "max": 15'+
		'            },'+
		'            "initial_eta": {'+
		'                "min": "2021-02-03",'+
		'                "max": "2021-02-08"'+
		'            },'+
		'            "revised_eta": {'+
		'                "min": "2021-02-03",'+
		'                "max": "2021-02-08"'+
		'            },'+
		'            "invoice": {'+
		'                "id": "300001025",'+
		'                "date": ""'+
		'            },'+
		'            "linked_shipping_groups": ['+
		'                {'+
		'                    "request_id": "",'+
		'                    "fulfilment_type": "DELIVERY"'+
		'                }'+
		'            ],'+
		'            "shipments": ['+
		'                {'+
		'                    "carrier_name": "UPS",'+
		'                    "carrier_service": "UPS-01_Standard_2805",'+
		'                    "tracking_number": "1ZE98V54DK00156398",'+
		'                    "delivery_date": "",'+
		'                    "delivery_status": "outfordelivery",'+
		'                    "delivery_status_date": "",'+
		'                    "tracking_link": "",'+
		'                    "estimated_delivery_date_min": "",'+
		'                    "estimated_delivery_date_max": ""'+
		'                }'+
		'            ],'+
		'            "delivery": {'+
		'                "delivery_method": "STANDARD",'+
		'                "delivery_method_code": "951",'+
		'                "delivery_method_timeslot": "",'+
		'                "delivery_customer_date": "2021-04-01",'+
		'                "special_instructions": "Deliver to the building caretaker",'+
		'                "carrier_service_name": "STANDARD_UPS_003900000_50",'+
		'                "collection_date": "2021-04-01"'+
		'            },'+
		'            "discount": {'+
		'                "id": "4",'+
		'                "description": "Change price",'+
		'                "amount": 0'+
		'            },'+
		'            "additional_services": ['+
		'                {'+
		'                    "code": "recipeId",'+
		'                    "message": "fluidId",'+
		'                    "personalization": {'+
		'                        "display_date": "010101",'+
		'                        "display_separator": "DOT",'+
		'                        "display_letters": "AAA",'+
		'                        "display_vertical": true,'+
		'                        "display_colorCode": "175AC3",'+
		'                        "display_finish": "GOLD | NONE",'+
		'                        "font_size": "82"'+
		'                    }'+
		'                }'+
		'            ],'+
		'            "reason_code": "return",'+
		'            "lines": ['+
		'                {'+
		'                    "item_id": "R20106",'+
		'                    "qty": 2,'+
		'                    "item_description": "COUV.AG.FON.GM2 LV MNG",'+
		'                    "kit_flag": "Y",'+
		'                    "item_stock_category": "AVA",'+
		'                    "pur_group": "ZOC",'+
		'                    "serial_number": "",'+
		'                    "vat_specificity": "",'+
		'                    "pedimento_number": "",'+
		'                    "vat_classification": "G",'+
		'                    "line_number": 3,'+
		'                    "unit_price": 540,'+
		'                    "unit_price_tax_free": 0,'+
		'                    "unit_tax_amount": 0,'+
		'                    "line_amount": 93.72,'+
		'                    "line_amount_tax_free": 93.72,'+
		'                    "tax_amount": 93.72,'+
		'                    "taxes": ['+
		'                        {'+
		'                            "amount": 65,'+
		'                            "rate": 15.5,'+
		'                            "description": "VatTax"'+
		'                        }'+
		'                    ],'+
		'                    "discount": {'+
		'                        "id": "4",'+
		'                        "description": "Change price",'+
		'                        "amount": 0'+
		'                    },'+
		'                    "additional_services": ['+
		'                        {'+
		'                            "code": "recipeId",'+
		'                            "message": "fluidId",'+
		'                            "personalization": {'+
		'                                "display_date": "010101",'+
		'                                "display_separator": "DOT",'+
		'                                "display_letters": "AAA",'+
		'                                "display_vertical": true,'+
		'                                "display_colorCode": "175AC3",'+
		'                                "display_finish": "GOLD | NONE",'+
		'                                "font_size": "82"'+
		'                            }'+
		'                        }'+
		'                    ]'+
		'                }'+
		'            ],'+
		'            "logs": ['+
		'                {'+
		'                    "by": "XStore",'+
		'                    "date": "",'+
		'                    "message": "Order created",'+
		'                    "status": "New",'+
		'                    "location": {'+
		'                        "xstore_id": "1406",'+
		'                        "rms_id": "A06",'+
		'                        "purchase_org": "F200",'+
		'                        "name": "Louis Vuitton BRUXELLES",'+
		'                        "type": "DC"'+
		'                    }'+
		'                }'+
		'            ],'+
		'            "available_actions": ['+
		'                "prioritize"'+
		'            ]'+
		'        }'+
		'    ]'+
		'}';
            return str;
    }
    
}