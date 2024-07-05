// Order Shipping webservice from KBRW system to Salesforce with Apex REST JSON (via WebMethods)
// Description : update a shipping order status
@RestResource(urlMapping='/shippings/*')
global class WS_OrderShippings {

    public static final String EXCEPTION_SHIPPING_EMPTY = 'shipping number not found';

    @HttpPut
    global static void updateShipping() {
        RestRequest request = RestContext.request;
        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        try {
            OrderShipping__c orderShipping ;
            if (request.requestBody != null) {
                //Parse the Json to apex
                JSONParser parser = JSON.createParser(request.requestBody.toString());
                WS_OrderShippingJson js = (WS_OrderShippingJson) parser.readValueAs(WS_OrderShippingJson.class);
                system.debug(js.shippingNumber);
                system.debug(js.status);
                system.debug(js.sourceLocation);
                orderShipping = shippingToUpdate(js.shippingNumber);
                system.debug(orderShipping);
                if(String.isNotEmpty(js.status) && orderShipping != null) {
               	 	updateStatus(orderShipping,js.status, js.sourceLocation);
              		res.responseBody = Blob.valueOf(JSON.serialize('OK'));
              		res.statusCode = 200;
           		 }else if(orderShipping == null) {
                	throw new ShippingException(EXCEPTION_SHIPPING_EMPTY);
           		 }
            } 
        } catch (Exception ex) {
            res.responseBody = Blob.valueOf(JSON.serialize(ex.getMessage()));
            res.statusCode = 400;
        }
    }

    private static OrderShipping__c shippingToUpdate(String shippingNumber) {
        List<OrderShipping__c> listOrderShipping = [SELECT ID, Status__c, ShippingNumber__c, StatusDate__c ,Order__c
                       ,DeliveryType__c ,Order__r.Account__r.PersonContactId  ,Order__r.Store__c  ,Order__r.OwnerId__c , Order__r.Store__r.ISO3_Code__c , Order__r.Store__r.StoreType__c 
                       FROM OrderShipping__c
                       WHERE ShippingNumber__c = :shippingNumber];
        
       OrderShipping__c OrderShipping = (listOrderShipping.isEmpty() ? null : listOrderShipping.get(0));
       return OrderShipping;
    }

    private static void updateStatus(OrderShipping__c orderShipping, String status, String sourceLocation) {
        orderShipping.Status__c = status;
        orderShipping.Source_Location__c = sourceLocation;
        orderShipping.StatusDate__c = System.now();
        orderShipping.IsXstoreOrder__c = updateOrderStoreType(orderShipping);

        update orderShipping;
        List<String> statusList = new List<String> {'unfulfilled'};
       
        // To_Do_Assistant Creation for ICON

        if((statusList.contains(status.toLowerCase()) || (status.toLowerCase() == 'received' && orderShipping.DeliveryType__c == 'shipforpickup')) && orderShipping.Order__r.Store__r.StoreType__c != 'CSC'){
            Map<String,String>  TechnicalUsers = ICON_Todos_Helper.getTechnicalUsers();
            String subject = statusList.contains(status.toLowerCase()) ? 'Product unavailable'  : 'Product ready for collection' ;
            string toDoCode = ''; 
            switch on subject {
                when 'Product unavailable'  {
                    toDoCode = 'TD_XSTO_01';
                }
                when  'Product ready for collection'  {
                    toDoCode = 'TD_XSTO_02';
                }
            }
            
            Task t = ICON_Todos_Helper.createToDoTaskXstore(orderShipping,TechnicalUsers,subject,toDoCode); 
            Database.insert(t  ,false);
        }
        
    }
    
    private static Boolean updateOrderStoreType(OrderShipping__c orderShipping){
        String storeType = [SELECT Id, Store__c, Store__r.StoreType__c FROM Order__c where id = :orderShipping.Order__c].Store__r.StoreType__c;

        return storeType == 'Store';
    }

    public class ShippingException extends Exception {}
    
    public class WS_OrderShippingJson{
        public String status {get;set;} 
		public String shippingNumber {get;set;} 
		public String sourceLocation {get;set;} 

    }
}