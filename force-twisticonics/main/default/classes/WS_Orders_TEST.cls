@isTest
global class WS_Orders_TEST {

    @isTest 
    public static void testOrderCreation_OK() {
        Test.setMock(HttpCalloutMock.class, new WS_Orders_TEST.OrderHttpCalloutMock());

        String firstname = 'sarah';
        String lastname = 'test';
        String orderNumber=  '2201002000228';
        String email = 'sarah.test@test.com';
        String phone = '+33611223785';

        Account acc = createAccount(firstname, lastname, phone, email);
        insert acc;

        Store__c store1 = new Store__c(RetailStoreId__c = 'A06');
        // Add by Johan GUINOT : JIRA-13682 / 13683
        Store__c storeSource = new Store__c(RetailStoreId__c = 'A07');
        Store__c storePickup = new Store__c(RetailStoreId__c = 'A08');
        insert new List<Store__c> {store1, storeSource, storePickup};
        
        ProductReferential__c prod1 = createProductReferential('M41414');
        ProductReferential__c prod2 = createProductReferential('M41415');
        insert new List<ProductReferential__c> {prod1, prod2};
        
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/orders'; //Request URL
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;

        String JsonMsg ='{'+
						//'"order":{'+
  							'"orderNumber": ' + orderNumber + ',' +
   							'"orderDate": "2019-09-18T00:00:00.000Z",'+
                         	'"storeCode": "A06",'+
  							'"source": "KBRW",'+
  							'"client": {'+
    							'"firstName": "' + firstname + '",'+
    							'"lastName": "' + lastname + '",'+
    							'"customer_no": "A006703373",' +
    							'"phone": "' + '0033611223785' + '",' +
    							'"email": "' + email + '"' +
  							  '},'+
  							'"lines": ['+
							  '{'+
      							'"shippingNumber": "c123456789",'+
      							'"sku": "M41414",'+
      							'"quantity": 1'+
    					      '},'+
            				  '{'+
      							'"shippingNumber": "c123456789",'+
      							'"sku": "M41415",'+
      							'"quantity": 22'+
    					      '}' +
 							 '],'+
                            '"shippings": ['+
                                '{'+
                                    '"shippingNumber": "c123456788",'+
                                    '"type": "standard",'+
                                    '"status": "Received",'+
                                    '"statusDate": "2019-09-20T10:00:00.000Z"'+
 //                                   '"sourceLocation": "A07",'+
 //                                   '"pickupLocation": "A08"'+
                                '},'+
                                '{'+
                                    '"shippingNumber": "c123456789",'+
                                    '"type": "express",'+
                                    '"status": "New",'+
                                    '"statusDate": "2019-08-18T08:50:00.000Z"'+
                                '}'+
            				']'+
						 //'}'+
						'}';
        req.requestBody = Blob.valueof(JsonMsg);

        // Test
        Test.startTest();
        WS_Orders.createOrders();
        Test.stopTest();

        // Check
        System.assertEquals(200, RestContext.response.statusCode);

        String jsonResult = RestContext.response.responseBody.toString();
        System.debug('jsonResult=' + jsonResult);
        WS_Orders.ResponseHandler resultObject = (WS_Orders.ResponseHandler) JSON.deserialize(jsonResult, WS_Orders.ResponseHandler.class);
        System.assertEquals(true, resultObject.success);
        System.assertEquals(true, resultObject.created);
        System.assert(String.isBlank(resultObject.message));

        //List<Account> accList = [SELECT Id ,LastModifiedDate FROM Account WHERe Firstname = :firstname AND Lastname = :lastname AND PersonEmail = :email AND PersonMobilePhone = :phone];
       // System.assertEquals(1, accList.size());

        List<Order__c> orderList = [SELECT Id, Account__c, Store__c, OrderDate__c, Source__c FROM Order__c WHERe OrderNumber__c = :orderNumber];
        System.assertEquals(1, orderList.size());
        //System.assertEquals(acc.Id, orderList.get(0).Account__c); // Existing Account, no creation
        System.assertEquals(store1.Id, orderList.get(0).Store__c);
        System.assertEquals('KBRW', orderList.get(0).Source__c);
        Datetime orderDateResult = orderList.get(0).OrderDate__c;
        System.assert(orderDateResult != null);
        System.assertEquals(2019, orderDateResult.year());
        System.assertEquals(9, orderDateResult.month());
        System.assertEquals(18, orderDateResult.day());

        Id orderId = orderList.get(0).Id;

        List<OrderShipping__c> shippingList = [SELECT Id, ShippingNumber__c, Status__c, StatusDate__c, DeliveryType__c FROM OrderShipping__c WHERE Order__c = :orderId];
        System.assertEquals(2, shippingList.size());
        for (OrderShipping__c shipping : shippingList) {
            System.assert(String.isNotBlank(shipping.ShippingNumber__c));
            if ('c123456788'.equals(shipping.ShippingNumber__c)) {
                System.assertEquals('standard', shipping.DeliveryType__c);
                System.assertEquals('Received', shipping.Status__c);
                
                //2019-09-20T10:00:00.000Z
                System.assert(shipping.StatusDate__c != null);
                System.assertEquals(Date.newInstance(2019, 9, 20), shipping.StatusDate__c.date());

                System.assertEquals(2019, shipping.StatusDate__c.year());
                System.assertEquals(9, shipping.StatusDate__c.month());
                System.assertEquals(20, shipping.StatusDate__c.day());
                //System.assertEquals(10, shipping.StatusDate__c.hour());

            } else if ('c123456789'.equals(shipping.ShippingNumber__c)) {
                System.assertEquals('express', shipping.DeliveryType__c);
                System.assertEquals('New', shipping.Status__c);
                
                //2019-08-18T08:50:00.000Z
                System.assert(shipping.StatusDate__c != null);
               	System.assertEquals(Date.newInstance(2019, 8, 18), shipping.StatusDate__c.date());
                //System.assertEquals(2019, shipping.StatusDate__c.year());
                //System.assertEquals(8, shipping.StatusDate__c.month());
                //System.assertEquals(18, shipping.StatusDate__c.day());
                //System.assertEquals(8, shipping.StatusDate__c.hour());
                //System.assertEquals(50, shipping.StatusDate__c.minute());
            }
        }

        List<OrderLine__c> orderLineList = [SELECT Id, SKU__c, Quantity__c, ProductReferential__c FROM OrderLine__c WHERE Order__c = :orderId AND OrderShipping__r.ShippingNumber__c = 'c123456789'];
        System.assertEquals(2, orderLineList.size());
        for (OrderLine__c line : orderLineList) {
            System.assert(String.isNotBlank(line.SKU__c));
            if ('M41414'.equals(line.SKU__c)) {
                System.assertEquals(1, line.Quantity__c);
                System.assertEquals(prod1.Id, line.ProductReferential__c);
            } else if ('M41415'.equals(line.SKU__c)) {
                System.assertEquals(22, line.Quantity__c);                
                System.assertEquals(prod2.Id, line.ProductReferential__c);
            }
        }
    }

    // @isTest 
    // public static void testOrderCreationAndOrderNotes_OK() {
    //     Test.setMock(HttpCalloutMock.class, new WS_Orders_TEST.OrderHttpCalloutMock());

    //     String firstname = 'sarah';
    //     String lastname = 'test';
    //     String orderNumber=  '2201002000228';
    //     String email = 'sarah.test@test.com';
    //     String phone = '+33611223785';

    //     // createOrderNote(String orderNumber, String shippingNumber, String orderType, String description, String reasonCode)
    //     Order_note__c orderNote = createOrderNote(orderNumber, null, 'ATTACHED_NOTE', 'first comment', null);
    //     insert orderNote;

    //     Account acc = createAccount(firstname, lastname, phone, email);
    //     insert acc;

    //     Store__c store1 = new Store__c(RetailStoreId__c = 'A06');
    //     insert store1;
        
    //     ProductReferential__c prod1 = createProductReferential('M41414');
    //     ProductReferential__c prod2 = createProductReferential('M41415');
    //     insert new List<ProductReferential__c> {prod1, prod2};
        
    //     RestRequest req = new RestRequest();
    //     RestResponse res = new RestResponse();
    //     req.requestURI = '/services/apexrest/orders'; //Request URL
    //     req.httpMethod = 'POST';
        
    //     RestContext.request = req;
    //     RestContext.response= res;

    //     String JsonMsg ='{'+
	// 					//'"order":{'+
  	// 						'"orderNumber": ' + orderNumber + ',' +
   	// 						'"orderDate": "2019-09-18T00:00:00.000Z",'+
    //                      	'"storeCode": "A06",'+
  	// 						'"source": "KBRW",'+
  	// 						'"client": {'+
    // 							'"firstName": "' + firstname + '",'+
    // 							'"lastName": "' + lastname + '",'+
    // 							//'"phone": "' + phone + '",' +
    // 							'"phone": "' + '0033611223785' + '",' +
    // 							'"email": "' + email + '"' +
  	// 						  '},'+
  	// 						'"lines": ['+
	// 						  '{'+
    //   							'"shippingNumber": "c123456789",'+
    //   							'"sku": "M41414",'+
    //   							'"quantity": 1'+
    // 					      '},'+
    //         				  '{'+
    //   							'"shippingNumber": "c123456789",'+
    //   							'"sku": "M41415",'+
    //   							'"quantity": 22'+
    // 					      '}' +
 	// 						 '],'+
    //                         '"shippings": ['+
    //                             '{'+
    //                                 '"shippingNumber": "c123456788",'+
    //                                 '"type": "standard",'+
    //                                 '"status": "Received",'+
    //                                 '"statusDate": "2019-09-20T10:00:00.000Z"'+
    //                             '},'+
    //                             '{'+
    //                                 '"shippingNumber": "c123456789",'+
    //                                 '"type": "express",'+
    //                                 '"status": "New",'+
    //                                 '"statusDate": "2019-08-18T08:50:00.000Z"'+
    //                             '}'+
    //         				']'+
	// 					 //'}'+
	// 					'}';
    //     req.requestBody = Blob.valueof(JsonMsg);

    //     // Test
    //     Test.startTest();
    //     WS_Orders.createOrders();
    //     Test.stopTest();

    //     // Check
    //     System.assertEquals(200, RestContext.response.statusCode);

    //     Order__c order = [SELECT id, orderNumber__c FROM order__c WHERE orderNumber__c = :orderNumber LIMIT 1];
    //     LIST<Order_Note__c> orderNotes = [SELECT Id, order__c, Order_Shipping__c, Tech_OrderNumber__c, Tech_shippingNumber__c FROM order_note__c WHERE Tech_OrderNumber__c = :orderNumber and order__c = :order.id];
    //     system.debug('JGU-orderNotes: '+orderNotes);
    //     system.debug('JGU-order: '+order);
    //     System.assertEquals(1, orderNotes.size(), 'Order Note not linked to the Order');
    // }
    // 
    // 
    @isTest
    public static void createOrders_withCommissionedCA() {
        Test.setMock(HttpCalloutMock.class, new WS_Orders_TEST.OrderHttpCalloutMock());
                
        String firstname = 'sarah';
        String lastname = 'test';
        String orderNumber=  '2201002000228';
        String email = 'sarah.test@test.com';
        String phone = '+33611223785';
        

        Account acc = createAccount(firstname, lastname, phone, email);
        insert acc;

        Id profileId = [SELECT Id FROM Profile WHERE Name = 'ICONiCS_SA'].Id;

        List<User> userList = new List<User>();
        User user1 = ICX_TestFactory.createUser(profileId);
        user1.WWEmployeeNumber__c = 'LV1234';
        userList.add(user1);

        User user2 = ICX_TestFactory.createUser(profileId);
        user2.WWEmployeeNumber__c = 'LV4321';
        userList.add(user2);

        insert userList;




        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/orders'; //Request URL
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;


        String JsonMsg ='{'+
              '"orderNumber": ' + orderNumber + ',' +
               '"orderDate": "2019-09-18T00:00:00.000Z",'+
             '"storeCode": "A06",'+
              '"source": "KBRW",'+
              '"client": {'+
                '"firstName": "' + firstname + '",'+
                '"lastName": "' + lastname + '",'+
                '"customer_no": "A006703373",' +
                '"phone": "' + '0033611223785' + '",' +
                '"email": "' + email + '"' +
                '},'+
              '"lines": ['+
              '{'+
                  '"shippingNumber": "c123456789",'+
                  '"sku": "M41414",'+
                  '"quantity": 1'+

              '},'+
              '{'+
                  '"shippingNumber": "c123456789",'+
                  '"sku": "M41415",'+
                  '"quantity": 22,'+
                '"initial_eta_min": "2023 - 05 - 20",'+
                '"initial_eta_max": "2023 - 05 - 22"'+

              '}' +
              '],'+
            '"shippings": ['+
                '{'+
                    '"shippingNumber": "c123456788",'+
                    '"type": "standard",'+
                    '"status": "Received",'+
                    '"statusDate": "2019-09-20T10:00:00.000Z",'+
                    '"sourceLocation": "A07",'+
                    '"pickupLocation": "A08"'+
                '}'+
                '],'+
                '"address": {'+
                '"address1": "10 rue Bailleul",'+
                '"address2": "",'+
                '"address3": "",'+
                '"address4": "",'+
                '"city": "Paris",'+
                '"province": "",'+
                '"postal_code": "75001",'+
                '"country": "FR",'+
                '"gps_lat": "48.789",'+
                '"gps_lon": "2.789"'+
                '},'+
                '"Comissioned_CA":"LV1234;LV4321"'+        
                     '}';
     
        req.requestBody = Blob.valueof(JsonMsg);

        // Test
        Test.startTest();
        WS_Orders.createOrders();
        Test.stopTest();

        // Check
        System.assertEquals(200, RestContext.response.statusCode);

  

        List<CommissionedCA__c> CommissionedCAList = [SELECT Id FROM CommissionedCA__c];
        System.assertEquals(2, CommissionedCAList.size());
    }

    @isTest
    public static void createOrders_ClientWithoutLastname() {
        Test.setMock(HttpCalloutMock.class, new WS_Orders_TEST.OrderHttpCalloutMock());
                
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/orders'; //Request URL
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;

        String orderNumber=  '2201002000228';

        // No emai or phone
        String JsonMsg ='{'+
						//'"order":{'+
  							'"orderNumber": ' + orderNumber + ',' +
   							'"orderDate": "2019-09-18T00:00:00.000Z",'+
                         	'"storeCode": "A06",'+
  							'"source": "KBRW",'+
  							'"client": {'+
    							'"firstName": "sarah"'+
  							  '},'+
  							'"lines": ['+
            				  '{'+
      							'"shippingNumber": "c123456789",'+
      							'"sku": "M41415",'+
      							'"quantity": 22'+
    					      '}' +
 							 '],'+
                            '"shippings": ['+
                                '{'+
                                    '"shippingNumber": "c123456789",'+
                                    '"type": "standard",'+
                                    '"status": "Received",'+
                                    '"statusDate": "2019-09-20T10:00:00.000Z"'+
                                '}'+
            				']'+
						// '}'+
						'}';
        req.requestBody = Blob.valueof(JsonMsg);

        // Test
        Test.startTest();
        WS_Orders.createOrders();
        Test.stopTest();

        // Check
        System.assertEquals(400, RestContext.response.statusCode);

        String jsonResult = RestContext.response.responseBody.toString();
        WS_Orders.ResponseHandler resultObject = (WS_Orders.ResponseHandler) JSON.deserialize(jsonResult, WS_Orders.ResponseHandler.class);
        System.assertEquals(false, resultObject.success);
        System.assertEquals(false, resultObject.created);
        System.assertEquals(Label.WS_Orders_Client_Empty, resultObject.message);

        // Existing Account, no creation
        List<Account> accList = [SELECT Id FROM Account LIMIT 200];
        System.assertEquals(0, accList.size());

        List<Order__c> orderList = [SELECT Id, Account__c, Store__c, OrderDate__c, Source__c FROM Order__c WHERe OrderNumber__c = :orderNumber];
        System.assertEquals(0, orderList.size());
    }
    
    @isTest
    public static void createOrders_ClientWithEmailNoPhone() {
        Test.setMock(HttpCalloutMock.class, new WS_Orders_TEST.OrderHttpCalloutMock());
                
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/orders'; //Request URL
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;

        String firstname = 'sarah';
        String lastname = 'test';
        String orderNumber=  '2201002000228';
        String email = 'sarah.test@test.com';
        String phone = '+33611223785';

        Account acc = createAccount(firstname, lastname, phone, email);
        insert acc;

        Store__c store1 = new Store__c(RetailStoreId__c = 'A06');
        insert store1;

        // With email, no phone
        String JsonMsg ='{'+
						//'"order":{'+
  							'"orderNumber": ' + orderNumber + ',' +
   							'"orderDate": "2019-09-18T00:00:00.000Z",'+
                         	'"storeCode": "A06",'+
  							'"source": "KBRW",'+
  							'"client": {'+
    							'"firstName": "' + firstname + '",'+
    							'"lastName": "' + lastname + '",'+
    							'"email": "' + email + '"' +
  							  '},'+
  							'"lines": ['+
            				  '{'+
      							'"shippingNumber": "c123456789",'+
      							'"sku": "M41415",'+
      							'"quantity": 22'+
    					      '}' +
 							 '],'+
                            '"shippings": ['+
                                '{'+
                                    '"shippingNumber": "c123456789",'+
                                    '"type": "standard",'+
                                    '"status": "Received",'+
                                    '"statusDate": "2019-09-20T10:00:00.000Z"'+
                                '}'+
            				']'+
						// '}'+
						'}';
        req.requestBody = Blob.valueof(JsonMsg);

        // Test
        Test.startTest();
        WS_Orders.createOrders();
        Test.stopTest();

        // Check
        System.assertEquals(200, RestContext.response.statusCode);

        // Existing Account, no creation
        List<Account> accList = [SELECT Id FROM Account LIMIT 200];
        System.assertEquals(1, accList.size());

        List<Order__c> orderList = [SELECT Id, Account__c, Store__c, OrderDate__c, Source__c FROM Order__c WHERe OrderNumber__c = :orderNumber];
        System.assertEquals(1, orderList.size());
        System.assertEquals(acc.Id, orderList.get(0).Account__c);
    }

    @isTest
    public static void createOrders_ClientWithoutEmailWithPhone() {
        Test.setMock(HttpCalloutMock.class, new WS_Orders_TEST.OrderHttpCalloutMock());
                
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/orders'; //Request URL
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;

        String firstname = 'sarah';
        String lastname = 'test';
        String orderNumber=  '2201002000228';
        String email = 'sarah.test@test.com';
        String phone = '+33611223785';

        Account acc = createAccount(firstname, lastname, phone, email);
        insert acc;

        Store__c store1 = new Store__c(RetailStoreId__c = 'A06');
        insert store1;

        // With email, no phone
        String JsonMsg ='{'+
						//'"order":{'+
  							'"orderNumber": ' + orderNumber + ',' +
   							'"orderDate": "2019-09-18T00:00:00.000Z",'+
                         	'"storeCode": "A06",'+
  							'"source": "KBRW",'+
  							'"client": {'+
    							'"firstName": "' + firstname + '",'+
    							'"lastName": "' + lastname + '",'+
    							'"phone": "' + phone + '"' +
  							  '},'+
  							'"lines": ['+
            				  '{'+
      							'"shippingNumber": "c123456789",'+
      							'"sku": "M41415",'+
      							'"quantity": 22'+
    					      '}' +
 							 '],'+
                            '"shippings": ['+
                                '{'+
                                    '"shippingNumber": "c123456789",'+
                                    '"type": "standard",'+
                                    '"status": "Received",'+
                                    '"statusDate": "2019-09-20T10:00:00.000Z"'+
                                '}'+
            				']'+
						 //'}'+
						'}';
        req.requestBody = Blob.valueof(JsonMsg);

        // Test
        Test.startTest();
        WS_Orders.createOrders();
        Test.stopTest();

        // Check
        System.assertEquals(200, RestContext.response.statusCode);

        // Existing Account, no creation
        List<Account> accList = [SELECT Id FROM Account LIMIT 200];
        System.assertEquals(1, accList.size());

        List<Order__c> orderList = [SELECT Id, Account__c, Store__c, OrderDate__c, Source__c FROM Order__c WHERe OrderNumber__c = :orderNumber];
        System.assertEquals(1, orderList.size());
        System.assertEquals(acc.Id, orderList.get(0).Account__c);
    }

    @isTest
    public static void createOrders_NoExistingClient() {
        Test.setMock(HttpCalloutMock.class, new WS_Orders_TEST.OrderHttpCalloutMock());

        Store__c store1 = new Store__c(RetailStoreId__c = 'A06');
        insert store1;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/orders'; //Request URL
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;

        String firstname = 'sarah';
        String lastname = 'test';
        String orderNumber=  '2201002000228';
        String email = 'sarah.test@test.com';
        String phone = '+33611223785';

        // With email, no phone
        String JsonMsg ='{'+
						//'"order":{'+
  							'"orderNumber": ' + orderNumber + ',' +
   							'"orderDate": "2019-09-18T00:00:00.000Z",'+
                         	'"storeCode": "A06",'+
  							'"source": "KBRW",'+
  							'"client": {'+
    							'"firstName": "' + firstname + '",'+
    							'"lastName": "' + lastname + '",'+
    							'"email": "' + email + '",'+
    							'"phone": "' + phone + '"' +
  							  '},'+
  							'"lines": ['+
            				  '{'+
      							'"shippingNumber": "c123456789",'+
      							'"sku": "M41415",'+
      							'"quantity": 22'+
    					      '}' +
 							 '],'+
                            '"shippings": ['+
                                '{'+
                                    '"shippingNumber": "c123456789",'+
                                    '"type": "standard",'+
                                    '"status": "Received",'+
                                    '"statusDate": "2019-09-20T10:00:00.000Z"'+
                                '}'+
            				']'+
						 //'}'+
						'}';
        req.requestBody = Blob.valueof(JsonMsg);

        // Test
        Test.startTest();
        WS_Orders.createOrders();
        Test.stopTest();

        // Check
        System.assertEquals(200, RestContext.response.statusCode);

        List<Order__c> orderList = [SELECT Id, Account__c, Store__c, OrderDate__c, Source__c FROM Order__c WHERe OrderNumber__c = :orderNumber];
        system.debug(orderList);
        System.assertEquals(1, orderList.size());
    }

    @isTest 
    public static void testOrderCreation_ExistingClientWithEmailWithoutPhone() {
        Test.setMock(HttpCalloutMock.class, new WS_Orders_TEST.OrderHttpCalloutMock());

        Store__c store1 = new Store__c(RetailStoreId__c = 'A06');
        insert store1;

        String firstname = 'sarah';
        String lastname = 'test';
        String orderNumber=  '2201002000228';
        String email = 'sarah.test@test.com';
        String phone = '+33611223785';

        // No Phone
        Account acc = createAccount(firstname, lastname, null, email);
        insert acc;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/orders'; //Request URL
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;

        String JsonMsg ='{'+
                            '"orderNumber": ' + orderNumber + ',' +
                            '"orderDate": "2019-09-18T00:00:00.000Z",'+
                            '"storeCode": "A06",'+
                            '"source": "KBRW",'+
                            '"client": {'+
                                '"firstName": "' + firstname + '",'+
                                '"lastName": "' + lastname + '",'+
                                '"phone": "' + phone + '",' +
                                '"email": "' + email + '"' +
  							  '},'+
  							'"lines": ['+
            				  '{'+
      							'"shippingNumber": "c123456789",'+
      							'"sku": "M41415",'+
      							'"quantity": 22'+
    					      '}' +
 							 '],'+
                            '"shippings": ['+
                                '{'+
                                    '"shippingNumber": "c123456789",'+
                                    '"type": "standard",'+
                                    '"status": "Received",'+
                                    '"statusDate": "2019-09-20T10:00:00.000Z"'+
                                '}'+
            				']'+
						 //'}'+
						'}';
        req.requestBody = Blob.valueof(JsonMsg);

        // Test
        Test.startTest();
        WS_Orders.createOrders();
        Test.stopTest();

        // Check
        System.assertEquals(200, RestContext.response.statusCode);

        String jsonResult = RestContext.response.responseBody.toString();
        System.debug('jsonResult=' + jsonResult);
        WS_Orders.ResponseHandler resultObject = (WS_Orders.ResponseHandler) JSON.deserialize(jsonResult, WS_Orders.ResponseHandler.class);
        System.assertEquals(true, resultObject.success);
        System.assertEquals(true, resultObject.created);
        System.assert(String.isBlank(resultObject.message));

        List<Order__c> orderList = [SELECT Id, Account__c, Store__c, OrderDate__c, Source__c FROM Order__c WHERe OrderNumber__c = :orderNumber];
        System.assertEquals(1, orderList.size());
        System.assertEquals(acc.Id, orderList.get(0).Account__c); // Existing Account, no creation
    }
        
    @isTest 
    public static void testOrderCreation_LocalPhone_ExistingClientWithoutEmailWithPhone() {
        Test.setMock(HttpCalloutMock.class, new WS_Orders_TEST.OrderHttpCalloutMock());

        Store__c store1 = new Store__c(RetailStoreId__c = 'A06');
        insert store1;

        String firstname = 'sarah';
        String lastname = 'test';
        String orderNumber=  '2201002000228';
        String email = 'sarah.test@test.com';
        String phone = '0611223785';

        // No Email, with existing local phone
        Account acc = createAccount(firstname, lastname, null, null);
        acc.LocalHomePhone__pc = phone;
        insert acc;

        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/orders'; //Request URL
        req.httpMethod = 'POST';
        
        RestContext.request = req;
        RestContext.response= res;

        String JsonMsg ='{'+
                            '"orderNumber": ' + orderNumber + ',' +
                            '"orderDate": "2019-09-18T00:00:00.000Z",'+
                            '"storeCode": "A06",'+
                            '"source": "KBRW",'+
                            '"client": {'+
                                '"firstName": "' + firstname + '",'+
                                '"lastName": "' + lastname + '",'+
                                '"phone": "' + phone + '",' +
                                '"email": "' + email + '"' +
  							  '},'+
  							'"lines": ['+
            				  '{'+
      							'"shippingNumber": "c123456789",'+
      							'"sku": "M41415",'+
      							'"quantity": 22'+
    					      '}' +
 							 '],'+
                            '"shippings": ['+
                                '{'+
                                    '"shippingNumber": "c123456789",'+
                                    '"type": "standard",'+
                                    '"status": "Received",'+
                                    '"statusDate": "2019-09-20T10:00:00.000Z"'+
                                '}'+
            				']'+
						 //'}'+
						'}';
        req.requestBody = Blob.valueof(JsonMsg);

        // Test
        Test.startTest();
        WS_Orders.createOrders();
        Test.stopTest();

        // Check
        System.assertEquals(200, RestContext.response.statusCode);

        String jsonResult = RestContext.response.responseBody.toString();
        System.debug('jsonResult=' + jsonResult);
        WS_Orders.ResponseHandler resultObject = (WS_Orders.ResponseHandler) JSON.deserialize(jsonResult, WS_Orders.ResponseHandler.class);
        System.assertEquals(true, resultObject.success);
        System.assertEquals(true, resultObject.created);
        System.assert(String.isBlank(resultObject.message));

        List<Order__c> orderList = [SELECT Id, Account__c, Store__c, OrderDate__c, Source__c FROM Order__c WHERe OrderNumber__c = :orderNumber];
        System.assertEquals(1, orderList.size());
        System.assertEquals(acc.Id, orderList.get(0).Account__c); // Existing Account, no creation
    }


    global class OrderHttpCalloutMock implements HttpCalloutMock {
        // Implement this interface method
        global HTTPResponse respond(HTTPRequest request) {
            // Create a fake response
            HttpResponse response = new HttpResponse();
            response.setHeader('Content-Type', 'application/json');
            response.setBody(null);
            response.setStatusCode(200);
            return response; 
        }
    }

    private static ProductReferential__c createProductReferential(String sku) {
        ProductReferential__c prod = new ProductReferential__c();
        prod.SKUCode__c = sku;
        prod.Name = 'DEMO PRODUCT';
        return prod;
    }

    private static Account createAccount(String firstname, String lastname, String phone, String email) {
        Account acc = new Account();
        acc.Firstname = firstname;
        acc.LastName = lastname;
        acc.PersonMobilePhone = phone;
        acc.PersonEmail = email;
        return acc;
    }

    // private static Order_note__c createOrderNote(String orderNumber, String shippingNumber, String orderType, String description, String reasonCode) {
    //     Order_note__c orderNote = new Order_note__c();
    //     orderNote.Tech_OrderNumber__c = orderNumber;
    //     orderNote.Tech_shippingNumber__c = shippingNumber;
    //     orderNote.Type__c            = orderType;
    //     orderNote.Description__c     = description;
    //     orderNote.Reason__c          = reasonCode;
    //     return orderNote;
    // }
}