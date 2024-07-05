@isTest
public class WS_OrderShippings_TEST {
    @testsetup static void setupMethod(){
         Store__c store1 = new Store__c(RetailStoreId__c = 'A06');
         // Add by Johan GUINOT : JIRA-13682 / 13683
         Store__c storeSource = new Store__c(RetailStoreId__c = 'A07');
         Store__c storePickup = new Store__c(RetailStoreId__c = 'A08');
         insert new List<Store__c> {store1, storeSource, storePickup};
         Account acc = new Account (LastName='Test', FirstName='Test',PersonEmail='test@Test.com');
         insert acc;
         Order__c order = new Order__c(Name ='Test',OrderNumber__c='2501002000228',Store__c=store1.id,Account__c=acc.id ,Source__c='KBRW',OrderDate__c=System.now());
         insert order;
         Order__c order2 = new Order__c(Name ='Test New',OrderNumber__c='2501004000228',Store__c=store1.id,Account__c=acc.id ,Source__c='KBRW',OrderDate__c=System.now());
         insert order2;
         OrderShipping__c ordershipping= new OrderShipping__c(Name='Test' ,Order__c=order.id,ShippingNumber__c='a123456789',DeliveryType__c='express',Status__c='New',StatusDate__c=System.now(), Pickup_Location__c='A08');
         insert ordershipping ;
         OrderLine__c orderLine = new OrderLine__c(Name= 'Test',Order__c=order.id,Quantity__c=1,SKU__c='M14141',OrderShipping__c=ordershipping.id );
         insert orderLine; 
         OrderShipping__c ordershipping2= new OrderShipping__c(Name='Test' ,Order__c=order2.id,ShippingNumber__c='a123456782',DeliveryType__c='shipforpickup',Status__c='New',StatusDate__c=System.now(), Pickup_Location__c='A08');
         insert ordershipping2 ;
         OrderLine__c orderLine2 = new OrderLine__c(Name= 'Test',Order__c=order2.id,Quantity__c=1,SKU__c='M14141',OrderShipping__c=ordershipping2.id );
         insert orderLine2; 
    }
    
    @istest static void testUpdateShipping() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/shippings/' ; //Request URL
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response= res;
        string shippingNumber='a123456789';
        String JsonMsg ='{'+
  							'"shippingNumber": "' + shippingNumber + '",' +
                              '"status": "Intransit",'+
                              '"sourceLocation": "A07"'+
            			'}';
            
        req.requestBody = Blob.valueOf(JsonMsg);
        Test.startTest();
            WS_OrderShippings.UpdateShipping();
        Test.stopTest();

        System.assertEquals(200, RestContext.response.statusCode);
        OrderShipping__c o = [Select id, Status__c, Source_Location__c, StatusDate__c from OrderShipping__c where ShippingNumber__c=:shippingNumber limit 1];
        System.assertEquals('Intransit', o.Status__c);
        System.assertEquals('A07', o.Source_Location__c);
        system.assertEquals(system.today(), o.StatusDate__c.date());
    }
    @istest static void testUpdateNonExistingShipping() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/shippings/'; //Request URL
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response= res;          
        string shippingNumber='a123456719';
        String JsonMsg ='{'+
  							'"shippingNumber": "' + shippingNumber + '",' +
                              '"status": "Intransit",'+
                              '"sourceLocation": "A07"'+
            			'}';
            
        req.requestBody = Blob.valueOf(JsonMsg);
        Test.startTest();
            WS_OrderShippings.UpdateShipping();
        Test.stopTest();
        List<OrderShipping__c> o = [Select id, Status__c,StatusDate__c from OrderShipping__c where ShippingNumber__c=:shippingNumber limit 1];
        System.assertEquals(0,o.size());
        System.assertEquals(400, RestContext.response.statusCode);

    }
    @istest static void testUpdateNonExistingShipping3() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/shippings/'; //Request URL
        req.httpMethod = 'PUT';
        RestContext.request = req;
        RestContext.response= res;          
        string shippingNumber='a123456782';
        String JsonMsg ='{'+
  							'"shippingNumber": "' + shippingNumber + '",' +
                              '"status": "received",'+
                              '"sourceLocation": "A07"'+
            			'}';
            
        req.requestBody = Blob.valueOf(JsonMsg);
        Test.startTest();
            WS_OrderShippings.UpdateShipping();
        Test.stopTest();
        List<OrderShipping__c> o = [Select id, Status__c,StatusDate__c from OrderShipping__c where ShippingNumber__c=:shippingNumber limit 1];
        System.assertEquals(1,o.size());
        System.assertEquals(200, RestContext.response.statusCode);

    }
}