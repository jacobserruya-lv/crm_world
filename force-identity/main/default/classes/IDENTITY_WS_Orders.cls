@RestResource(urlMapping='/identity/orders/*')
global with sharing class IDENTITY_WS_Orders {

    @HttpGet
    global static void get() {

        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        Pattern pattern = Pattern.compile('/identity/orders/([a-zA-Z0-9]{18})');
        Matcher matcher = pattern.matcher(RestContext.request.requestUri);
        System.debug('myurl: '+RestContext.request.requestUri);

        if (matcher.matches()) {
            String id = matcher.group(1);
            
            // GET only orders not or recently fulfilled
            Decimal fulfilledDaysLimit;
            String fulfilledDaysLimitCondition;
            String fulfilled = 'Fulfilled';
            if(RestContext.request.params.get('fulfilledDaysLimit') != null){
                fulfilledDaysLimit = decimal.valueOf(RestContext.request.params.get('fulfilledDaysLimit'));
                fulfilledDaysLimitCondition = ' AND ((OrderShipping__r.status__c=:fulfilled AND OrderShipping__r.StatusDate__c >=LAST_N_DAYS:'+fulfilledDaysLimit+') OR OrderShipping__r.status__c!=:fulfilled)'; 
            }
            else{
                fulfilledDaysLimitCondition = ' ';
            }

            
            List< OrderLine__c> ol = new List<OrderLine__c>();

            String storeType = 'Store';
            
            String query = 'SELECT Quantity__c, SKU__c, Order__c, Order__r.OrderDate__c,';
            query += ' Order__r.OrderNumber__c, Order__r.Store__r.ShortName__c,Order__r.Store__r.StoreType__c,';
            query += ' Order__r.Store__r.RetailStoreId__c, Order__r.Source__c,ProductReferential__r.SKUCode__c,';  
            query += ' ProductReferential__r.Name, ProductReferential__r.SPO_ImageLink1FrontView__c, ProductReferential__r.MacroColor__c,';  
            query += ' tolabel(OrderShipping__r.Status__c), OrderShipping__r.StatusDate__c, tolabel(OrderShipping__r.DeliveryType__c) ';  
            query += ' FROM OrderLine__c';
            query += ' WHERE Order__r.Account__c =:id AND Order__r.Store__r.StoreType__c =:storeType ';
            query += fulfilledDaysLimitCondition;

            // condition for KBRW orders in the CRM:
            // query+='AND ((OrderShipping__r.status__c=\'Fulfilled\' AND  OrderShipping__r.StatusDate__c<= THIS_WEEK AND OrderShipping__r.StatusDate__c >=LAST_WEEK) OR OrderShipping__r.status__c!=\'Fulfilled\')';

            query += ' ORDER BY Order__r.OrderDate__c DESC';

            System.debug('query=' + query);
            ol = Database.query(String.escapeSingleQuotes(query));
           
            System.debug('MY ORDER LINES: '+ol);

            // GROUP BY Order__c
            Map<String,List<OrderLine__c>> groupByOrderId = new Map<String,List<OrderLine__c>>();
            for(OrderLine__c orderline : ol){
                if(groupByOrderId.get(orderline.Order__c) == null){
                    groupByOrderId.put(orderline.Order__c, new List<OrderLine__c>());
                }
                groupByOrderId.get(orderline.Order__c).add(orderline);
            }
            
            // BUILD WRAPPER
            Order[] body = new List<Order>();
            for(String key : groupByOrderId.keySet()){
                body.add(new Order(groupByOrderId.get(key)));
            }

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(new RestResource_Utils.Response(body), true));
        }
        else {
            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new RestResource_Utils.Error(Label.MALFORMED_ID,'400')));
        }
    }


    
    
    private class Order {
        String orderId;
        String orderExternalId;
        Datetime orderDate;
        String storeShortName;
        String storeType;
        String retailStoreId;
        String source;
        String shippingStatus;
        Datetime shippingStatusDate;
        String deliveryType;
        Decimal totalQuantity;
        Item[] items;
            
        

        public Order(OrderLine__c[] orders){
            initiate(orders);
            calculate(orders);
        }

        public void initiate(OrderLine__c[] orders){
            this.totalQuantity = 0;

            if(!orders.isEmpty()){
                this.orderId = orders[0].Order__c;
                this.orderExternalId = orders[0].Order__r.OrderNumber__c;
                this.orderDate = orders[0].Order__r.OrderDate__c;
                this.storeShortName = orders[0].Order__r.Store__r.ShortName__c;
                this.storeType = orders[0].Order__r.Store__r.StoreType__c;
                this.retailStoreId = orders[0].Order__r.Store__r.RetailStoreId__c;
                this.source = orders[0].Order__r.Source__c;
                this.shippingStatus = orders[0].OrderShipping__r.Status__c;
                this.shippingStatusDate = orders[0].OrderShipping__r.StatusDate__c;
                this.deliveryType = orders[0].OrderShipping__r.DeliveryType__c;
              
            }

            this.items = new List<Item>();
        }
        public void calculate(OrderLine__c[] orders){
            Map<String,Item> itemsMap = new Map<String,Item>();
            for(OrderLine__c order : orders){
                this.totalQuantity += (order.Quantity__c != null ? order.Quantity__c : 0);
                itemsMap.put(order.SKU__c, new Item(order));
            }

            this.items = itemsMap.values();
        }
      
    }

    private class Item {
        String sku;
        String name;
        String color;
        String image;
        Decimal quantity;
        
        public Item(OrderLine__c orderLine){
           this.sku = orderLine.SKU__c;
           this.name = orderLine.ProductReferential__r.Name;
           this.color = orderLine.ProductReferential__r.MacroColor__c;
           this.image = orderLine.ProductReferential__r.SPO_ImageLink1FrontView__c;
           this.quantity = orderLine.Quantity__c;                        
        }
    }
}