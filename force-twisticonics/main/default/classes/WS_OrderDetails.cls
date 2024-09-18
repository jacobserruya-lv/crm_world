public without sharing class WS_OrderDetails {

    // "system":"SFB2C"

    @AuraEnabled
    public static JSON2KbrwOrderV2 getOrderDetailsTwistV2(string orderId) {
        JSON2KbrwOrderV2 orderDetails = new JSON2KbrwOrderV2();

        try { 
            Http http = new Http();    
            HttpRequest request = new HttpRequest();

            string endPoint = '/spl-eu/cust-orders-oms/v1/api/orders/v2/'+ orderId;
            request.setEndpoint('callout:MULESOFT_KBRW' + endPoint);
            request.setMethod('GET');
            request.setTimeout(120000);
            request.setHeader('Encoding', 'UTF-8');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Content-Type', 'application/json');            
            request.setHeader('client_id', '{!$Credential.UserName}');
            request.setHeader('client_secret', '{!$Credential.Password}');

            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200 ) {
                JSON2KbrwOrderV2 mySerializer = new JSON2KbrwOrderV2();
                System.debug('JGU dto start: '+response.getBody());
                orderDetails = (JSON2KbrwOrderV2) mySerializer.deserialize(response.getBody(), JSON2KbrwOrderV2.class);
                System.debug('JGU dto: '+orderDetails);
                System.debug('JGU dto:requesting_system '+orderDetails.requesting_system);
                System.debug('JGU dto:createdDate '+orderDetails.createdDate);

            } else if (response.getStatusCode() == 404 ){
                system.debug('JGU-orderDetails : 404');
            } else{              
                system.debug('JGU-orderDetails : 500 /'+response.getStatusCode());              
                system.debug('JGU-orderDetails : '+response);
                throw new AuraHandledException(response.getStatus());   
            }

            system.debug('JGU-orderDetails :' + orderDetails);
            return orderDetails;
        } catch (Exception e) {
            system.debug('JGU-Exception :' + e);            
            system.debug('JGU-Exception getMessage:' + e.getMessage());
            throw new AuraHandledException(e.getMessage());  
        } 
    }

    @AuraEnabled
    public static JSON2KbrwOrder getOrderDetailsTwist(string orderId) {
        JSON2KbrwOrder orderDetails = new JSON2KbrwOrder();

        // List<Map<String, Object>> listOrderLines = new List<Map<String, Object>>();
        // List<String> listSku = new List<string>();
        // List<String> listStoreId = new List<String> ();
        // Map<String, List<String>> customizationList = new Map<String, List<String>> ();
        // String samples;
        // String giftMessage;
        // String shoppingBag;
        try { 
            Http http = new Http();    
            HttpRequest request = new HttpRequest();

            string endPoint = '/customer-orders/api/orders/v1/'+ orderId;
            request.setEndpoint('callout:MULESOFT_KBRW' + endPoint);
            request.setMethod('GET');
            request.setTimeout(120000);
            request.setHeader('Encoding', 'UTF-8');
            request.setHeader('Accept', 'application/json');
            request.setHeader('Content-Type', 'application/json');            
            request.setHeader('client_id', '{!$Credential.UserName}');
            request.setHeader('client_secret', '{!$Credential.Password}');

            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200 ) {
                JSON2KbrwOrder mySerializer = new JSON2KbrwOrder();
                System.debug('JGU dto start: '+response.getBody());
                orderDetails = (JSON2KbrwOrder) mySerializer.deserialize(response.getBody(), JSON2KbrwOrder.class);
                System.debug('JGU dto: '+orderDetails);
                System.debug('JGU dto:system_Z '+orderDetails.system_Z);
                System.debug('JGU dto:createdDate '+orderDetails.createdDate);

                // ----------------
                // CA
                // ----------------
                // String WWEmployeeId = orderDetails.CA?.WWEmployeeId;
                // User usr = getUserDetails(WWEmployeeId);
                // if (usr != null) orderDetails.CA.Name = usr.Name;
                // else {
                //     orderDetails.CA.Name = 'CA not found';
                // }

                // orderDetails.put('StatusCode','200');
            } else if (response.getStatusCode() == 404 ){
                system.debug('JGU-orderDetails : 404');
                //orderDetails.put('StatusCode','404');
            } else{
                //orderDetails.put('StatusCode','500');                
                system.debug('JGU-orderDetails : 500 /'+response.getStatusCode());              
                system.debug('JGU-orderDetails : '+response);
                throw new AuraHandledException(response.getStatus());   
            }

            system.debug('JGU-orderDetails :' + orderDetails);
            return orderDetails;
        } catch (Exception e) {
            system.debug('JGU-Exception :' + e);            
            system.debug('JGU-Exception getMessage:' + e.getMessage());
            throw new AuraHandledException(e.getMessage());  
        } 
    }

    public static Map<String,Object> getOrderDetails(string orderId) {
        Map<String,Object> orderDetails = new Map<String,Object> (); 
        List<Map<String, Object>> listOrderLines = new List<Map<String, Object>>();
       // Map<String List<Object>> statusHistoryOrderLine = new Map<String List<Object>> 
        List<String> listSku = new List<string>();
        List<String> listStoreId = new List<String> ();
        try { 
            Http http = new Http();
    
            HttpRequest request = new HttpRequest();
            //string endPoint = '/ws/KBRW_ordersAPI/1.0/api/orders/v1/'+ orderId;\
            // request.setEndpoint('callout:EAI' + endPoint);

            string endPoint = '/customer-orders/api/orders/v1/'+ orderId;
            request.setEndpoint('callout:MULESOFT_KBRW' + endPoint);
            request.setMethod('GET');
            request.setTimeout(120000);
            request.setHeader('Encoding', 'UTF-8');
			request.setHeader('Accept', 'application/json');
			request.setHeader('Content-Type', 'application/json');
            
            request.setHeader('client_id', '{!$Credential.UserName}');
			request.setHeader('client_secret', '{!$Credential.Password}');

            HttpResponse response = http.send(request);
            if (response.getStatusCode() == 200 ) {
                Map<String, Object> results = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                    for(Object orderLine :(List<Object>)results.get('order_lines')){ 
                        Map<String, Object> line = (Map<String, Object>) orderLine;
                        
                        listOrderLines.add(orderLineMap(line));
                        listSku.add(String.ValueOf(line.get('item_id'))); 
                    }
                    // Get product referential for the name of the product and the image,and add them to the Order Line 
                    Map<String,ProductReferential__c> skuProduct = getProductBySKU(listSku); 
                    Map<String,OrderShipping__c> shippings = getShipping(orderId) ;  
                    for(Map<String, Object> orderLine :listOrderLines){
                        if(!skuProduct.isEmpty() && skuProduct.containsKey(String.ValueOf(orderLine.get('SKU')))){
                            orderLine.put('productName',skuProduct.get(String.ValueOf(orderLine.get('SKU'))).Name);  
                            orderLine.put('productImage',skuProduct.get(String.ValueOf(orderLine.get('SKU'))).SPO_ImageLink1FrontView__c);
                        }
                      
                        orderLine.put('reason',shippings.get(String.ValueOf(orderLine.get('requestId'))));

                    }
                    Map<String, Object> storeLocation = (Map<String, Object>) results.get('requesting_location');
                    system.debug(storeLocation);
                    listStoreId.add(String.ValueOf(storeLocation.get('rms_id')));
                    system.debug(listStoreId);

                    Map<String,Store__c> storeMap  = getStoreName(listStoreId);     
                    Map<String, Object> createdDate = (Map<String, Object>) results.get('transaction');
                    
                    orderDetails.put('store',storeMap.get(String.ValueOf(storeLocation.get('rms_id'))));
                    orderDetails.put('date',createdDate.get('date'));
                    orderDetails.put('orderLines',listOrderLines);
                    orderDetails.put('OrderId',results.get('order_id'));
                    orderDetails.put('shipments',results.get('shipments'));
                    orderDetails.put('account',getAccountAsMap(String.ValueOf(results.get('order_id'))));

                    orderDetails.put('StatusCode','200');

            } else if (response.getStatusCode() == 404 ){
                 orderDetails.put('StatusCode','404');
            } else{
                 orderDetails.put('StatusCode','500');
            }
            return orderDetails;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());  
        } 
    }
    //Map only the necessary fields for the OrderLines
    public static Map<String,Object> orderLineMap(Map<String,Object> line){
        Map<String,Object> mapOrderLine = new Map<String,Object> ();
        
        mapOrderLine.put('SKU',line.get('item_id'));
        mapOrderLine.put('priority',line.get('priority'));
        mapOrderLine.put('quantity',line.get('qty'));
        mapOrderLine.put('line',line.get('line_number'));
        mapOrderLine.put('availableActions',line.get('available_actions'));
        mapOrderLine.put('deliveryType',line.get('fulfillment_type'));
        mapOrderLine.put('status',line.get('status'));
        mapOrderLine.put('shipTo',line.get('ship_to'));
        mapOrderLine.put('requestId',line.get('request_id')+'-'+line.get('line_number'));
        mapOrderLine.put('location',line.get('source_location'));
        mapOrderLine.put('statusHistory',line.get('logs'));
        mapOrderLine.put('leadTime',line.get('leadtime'));
        
        return mapOrderLine;
    }

    @AuraEnabled(cacheable=true)
    public static Map<String,ProductReferential__c> getProductBySKU(List<String> listSku){
        // get product referential for the name of the product and the image 
        Map<String,ProductReferential__c> skuProduct = new Map<String,ProductReferential__c>();
        for (ProductReferential__c product :  [SELECT id,Name, SKUCode__c ,SPO_ImageLink1FrontView__c FROM ProductReferential__c WHERE SKUCode__c IN:listSku]) {
            if(!skuProduct.containsKey(product.SKUCode__c)){
                skuProduct.put(product.SKUCode__c,product);
            }
        }
        return skuProduct;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String,OrderShipping__c> getShipping(String orderId){
        // get more details about the shipipng 
        Map<String,OrderShipping__c> shippings = new Map<String,OrderShipping__c>();
        for (OrderShipping__c shipping :  [SELECT Id, ShippingNumber__c,FORMAT(SubmitedDate__c),SubmitedBy__c, SubmitedBy__r.Name, Reason__c, tolabel(Action__c) FROM OrderShipping__c WHERE Order__r.OrderNumber__c =:orderId ]) {
            if(!shippings.containsKey(shipping.ShippingNumber__c)){
                shippings.put(shipping.ShippingNumber__c,shipping);
            }
        }
        system.debug(shippings);
        return shippings;
    }
    @AuraEnabled(cacheable=true)
    public static Map<String,Store__c> getStoreName(List<String> storeID){
        //get name of the store  
        Map<String,Store__c> storeList = new Map<String,Store__c>();
        for (Store__c store :  [SELECT id,Name,RetailStoreId__c,StoreCountry__c, StoreType__c FROM Store__c WHERE RetailStoreId__c IN:storeID]){
            if(!storeList.containsKey(store.RetailStoreId__c)){
                storeList.put(store.RetailStoreId__c,store);
            }
        }
        return storeList;
    }

    // Get Client Id  
    @AuraEnabled(cacheable=true)
    public static Map<String,String> getAccountAsMap(String orderNumber){
        Map<String,String> accountName = new Map<String,String>();
        if(String.isNotBlank(orderNumber)){
            Account acc = getAccount(orderNumber);
            if(acc != null){
                accountName.put('Id',acc.id);
                accountName.put('Name',acc.Name);
            } 
        }
        return accountName;
    }

    @AuraEnabled(cacheable=true)
    public static Account getAccount(String orderNumber){
        //Map<String,String> accountName = new Map<String,String>();
        Account acc = new Account();
        if(String.isNotBlank(orderNumber)){
            List<Order__c> orderRecord = [SELECT Account__c,Account__r.Name  FROM Order__c WHERE OrderNumber__c = :orderNumber  limit 1];
            if(!orderRecord.isEmpty()){
                acc.Id = orderRecord.get(0).Account__c;
                acc.Name = orderRecord.get(0).Account__r.Name;
            } 
        }
        return acc;  
    }


     // Get user CA details  
     @AuraEnabled(cacheable=true)
     public static User getUserDetails(String WWEmployeeNumber){
        User usr;
        if(String.isNotBlank(WWEmployeeNumber)){
            List<User> userRecord = [SELECT Id, Name FROM User WHERE WWEmployeeNumber__c = :WWEmployeeNumber  limit 1];
            if(!userRecord.isEmpty()){
                usr = userRecord.get(0);
            } 
        }
        return usr;
     }
}