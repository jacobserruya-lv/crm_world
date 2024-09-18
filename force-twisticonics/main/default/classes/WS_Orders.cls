// Order webservice from KBRW system to Salesforce with Apex REST JSON (via WebMethods)
// Description : create an order with lines and shippings
@RestResource(urlMapping='/orders/*')
global with sharing class WS_Orders {

    //HTTP Request POST called From KBRW or ATG 
    @HttpPost
    global static void createOrders() {
        RestRequest req = RestContext.request;
        String service = req.requestURI.substring(req.requestURI.lastIndexOf('/') + 1);

        RestResponse res = RestContext.response;
        res.addHeader('Content-Type','application/json');
        res.statusCode = 200;
        String response;
        Logs resultLog;

        try {
            if (req.requestBody != null) {
                //Parse the Json to apex
                JSONParser parser = JSON.createParser(req.requestBody.toString());
                WS_OrdersJson js = (WS_OrdersJson) parser.readValueAs(WS_OrdersJson.class);
                //JsonOrderToApex js = JsonOrderToApex.parse(req.requestBody.toString());
                //createOrder(js.Order);
                createOrder(js);
                OrderNoteService.syncWithOrder(new List<String>{js.orderNumber}, new List<String>());
            }
            ResponseHandler responseOrder = new ResponseHandler(true,'',true);
            res.responseBody = Blob.valueOf(JSON.serialize(responseOrder));
            resultLog = ICX_Utils.createLogsObject(true,'ICONICS', 'WS_Orders',service,JSON.serialize(responseOrder), req.requestBody.toString(),'INFO',String.valueOF(res.statusCode));
            resultLog.insertLog();

        } catch (Exception ex) {
            System.debug('Exception=' + ex);
            ResponseHandler errorObject = new ResponseHandler(false,ex.getMessage(),false);
            res.responseBody = Blob.valueOf(JSON.serialize(errorObject));
            res.statusCode = 400;
            resultLog = ICX_Utils.createLogsObject(true,'ICONICS', 'WS_Orders',service,JSON.serialize(errorObject), req.requestBody.toString(),'ERROR',String.valueOF(res.statusCode));
            resultLog.insertLog();
        }
    }

    // order creation
    private static Order__c createOrder(WS_OrdersJson o){
        // JsonOrderToApex.Order o = (JsonOrderToApex.Order) order;
        //get the id of the client
        Account clientOrder = new Account ();
        Account updatedClientOrder = new Account();
        String anonymousClientId= System.Label.China_Anonymous_Client_Id;
        system.debug('China Anonymous Client Id: ' +anonymousClientId);
        system.debug('JSON Client Id: ' + o.Client.customer_no);
        if(o.Client.customer_no != anonymousClientId)
        {
            clientOrder = getClient(o.Client,O);

            updatedClientOrder = updateAddress(clientOrder,o);
        }
        else 
        clientOrder=null;


        // check if the order already exists 
        List<Order__c> listOrder = [SELECT id, OrderNumber__c FROM Order__c WHERE OrderNumber__c = :o.orderNumber LIMIT 1];

        Order__c ord = (listOrder.isEmpty() ? null : listOrder.get(0));
        if (ord == null) {
            ord = new Order__c();
            ord.Name = o.orderNumber;
            ord.OrderNumber__c = o.orderNumber;
            if(updatedClientOrder != null)
            ord.Account__c = updatedClientOrder.id;             
            ord.OrderDate__c = (DateTime) JSON.deserialize('"'+o.orderDate+'"', DateTime.class); 
            ord.Source__c = o.source;
            ord.WWEmployeeNumber__c = o.WWEmployeeId;
            ord.WWClientID__c = o.Client.customer_no;
            List<Store__c> storeList = [SELECT id FROM Store__c WHERE RetailStoreId__c = :o.storeCode LIMIT 1]; 
            List<User> userId = [SELECT id FROM User WHERE WWEmployeeNumber__c = :o.WWEmployeeId LIMIT 1]; 
            
            ord.Store__c = (!storeList.isEmpty() ? storeList[0].id : null);
            ord.OwnerId__c = (!userId.isEmpty() ? userId[0].id : UserInfo.getUserId());



            insert ord;
            system.debug(ord);
        }


        createOrderShipping(o.Shippings,ord,o.Comissioned_CA);
        createOrderLines(o.Lines,ord);

        return ord;
    }
    
    // create orders shippings
    private static void createOrderShipping(List<WS_OrdersJson.Shippings> os, Order__c order, String Commissioned_CA){
        system.debug('ordershippingapex '+ os);
        List<OrderShipping__c> listOrdersShippings = [SELECT id, Order__c,ShippingNumber__c FROM OrderShipping__c WHERE Order__c = :order.id];
        List<String> listOrdersShippingsNumber = new List<String>();
        for(OrderShipping__c shipping :listOrdersShippings ){
            listOrdersShippingsNumber.add(shipping.ShippingNumber__c);
        }

        if (os != null) {
            List<OrderShipping__c> OrderShippingToInsert = new List<OrderShipping__c>();
            for (WS_OrdersJson.Shippings o : os ) {
                if(!listOrdersShippingsNumber.contains(o.shippingNumber)){
                    OrderShipping__c orderShipping = new OrderShipping__c();
                    orderShipping.Name = o.shippingNumber;
                    orderShipping.ShippingNumber__c = o.shippingNumber;
                    orderShipping.DeliveryType__c = o.type;
                    orderShipping.Order__c = order.id;
                    orderShipping.Status__c = o.status;
                    orderShipping.StatusDate__c = (DateTime) JSON.deserialize('"'+o.statusDate+'"', DateTime.class);
                    orderShipping.IsXstoreOrder__c = updateOrderStoreType(orderShipping);
                    // Add by Johan GUINOT : JIRA-13682 / 13683
                    orderShipping.Source_Location__c = o.sourceLocation;
                    orderShipping.Pickup_Location__c = o.pickupLocation;
                    
                    OrderShippingToInsert.add(orderShipping);



                }
                
            }

            if (!OrderShippingToInsert.isEmpty()){
                insert OrderShippingToInsert;
                system.debug(OrderShippingToInsert);


                //naomi 10/2023 Commissioned CA
                //IMPORTANT : the OMS is using one api call per shipping group.
                //If there is more than on shipping group in the order creation request body, we cannot know to which shipping group the Commissioned is related to.
                if(OrderShippingToInsert.size()<2) 
                {
                    OrderShipping__c currentOrderShipping = OrderShippingToInsert[0];

                if(!String.isBlank(Commissioned_CA))
                    {
                        List<String> CommissionedCAEmployeeIdList = Commissioned_CA.split(';');
                        List<User> CommissionedCAUser = [SELECT Id FROM User WHERE WWEmployeeNumber__c IN:CommissionedCAEmployeeIdList ];


                        if(!CommissionedCAUser.isEmpty())
                        {
                            List<CommissionedCA__c> CommissionedCAToInsert = new List<CommissionedCA__c>();
                            for(User currentCommissionedCA : CommissionedCAUser)
                            {

                                CommissionedCA__c CommissionedCA = new CommissionedCA__c();
                                CommissionedCA.Commissioned_CA__c = currentCommissionedCA.Id;
                                CommissionedCA.Order_Shipping__c = currentOrderShipping.Id;
                                CommissionedCAToInsert.add(CommissionedCA);


                            }
                            if(!CommissionedCAToInsert.isEmpty())
                            {
                                insert CommissionedCAToInsert;
                            }

                        }

                    }
                
                }
                    else
                    {
                        System.debug('You should have only one shipping group to associated Commissioned CA');
                    }

            }

            

           

        }

        // linkOrderNotes(order, listOrdersShippingsNumber);
    }

    

    

    
    // insert OrderLines 
    private static void createOrderLines(List<WS_OrdersJson.Lines> ol, Order__c order){
        system.debug(ol);
        system.debug(order);
                                                                                       
        //List <JsonOrderToApex.Lines> ol =  (List <JsonOrderToApex.Lines>) orderLines;
        List<String> skuNumbers = new List<String>();
        List<String> shippingNumbers = new List<String>();

        for (WS_OrdersJson.Lines o : ol) {
            skuNumbers.add(o.sku);
            shippingNumbers.add(o.shippingNumber);
        }
       // Get the product referential
       Map<String, ProductReferential__c> mapProduct= new Map<String, ProductReferential__c>();
       for (ProductReferential__c product : [SELECT id, SKUCode__c FROM ProductReferential__c WHERE SKUCode__c in :skuNumbers]) {
            mapProduct.put(product.SKUCode__c, product);
       }
       // Get the Order Shipping
       Map<String, OrderShipping__c> mapShipping = new Map<String, OrderShipping__c>();
       for (OrderShipping__c orderShipping : [SELECT id, ShippingNumber__c FROM OrderShipping__c WHERE ShippingNumber__c in :shippingNumbers]) {
            mapShipping.put(orderShipping.ShippingNumber__c, orderShipping);
       } 

        //check if already exists  
        List<OrderLine__c> ListOrderLines = [SELECT id, Order__c,OrderShipping__r.ShippingNumber__c FROM OrderLine__c WHERE Order__c = :order.id];
        List<String> listOrdersShippingsNumber = new List<String>();
        for(OrderLine__c shipping :ListOrderLines ){
            listOrdersShippingsNumber.add(shipping.OrderShipping__r.ShippingNumber__c);
        }
        
        if (ol != null ) {
            List<OrderLine__c> orderLinesToInsert = new List<OrderLine__c>();
            Integer indexLine = ListOrderLines.size();
            for (WS_OrdersJson.Lines o : ol) {
                if(!listOrdersShippingsNumber.contains(o.shippingNumber)){
                    OrderLine__c orderline = new OrderLine__c();
                    orderline.Name = order.OrderNumber__c + '-' + ++indexLine;
                    orderline.Order__c = order.id;
                    orderline.Quantity__c= o.quantity;
                    orderline.ProductReferential__c = (mapProduct.get(o.sku) != null ? mapProduct.get(o.sku).id : null); 
                    orderline.SKU__c=o.sku;
                    orderline.OrderShipping__c = (mapShipping.get(o.shippingNumber) != null ? mapShipping.get(o.shippingNumber).id : null);
                    orderline.Line_Number__c = o.lineNumber != null ? o.lineNumber : null;
                    orderline.Initial_Eta_Min__c = o.initial_eta_min!=null? date.newInstance(Integer.ValueOF(o.initial_eta_min.replaceAll('\\s+', '').split('-')[0]),Integer.ValueOF(o.initial_eta_min.replaceAll('\\s+', '').split('-')[1]),Integer.ValueOF(o.initial_eta_min.replaceAll('\\s+', '').split('-')[2])):null;
                    orderline.Initial_Eta_Max__c = o.initial_eta_max!=null? date.newInstance(Integer.ValueOF(o.initial_eta_max.replaceAll('\\s+', '').split('-')[0]),Integer.ValueOF(o.initial_eta_max.replaceAll('\\s+', '').split('-')[1]),Integer.ValueOF(o.initial_eta_max.replaceAll('\\s+', '').split('-')[2])):null;

                    orderLinesToInsert.add(orderline);
                }
            }

            if (!orderLinesToInsert.isEmpty()) {
                insert orderLinesToInsert;
            } 
        }
    }
    
    //Get the client according to the Name and Email or phone 
    private static Account getClient(WS_OrdersJson.Client c, WS_OrdersJson Oc){
        List<Account> listAccount = new List<Account>();
        Account exactAccount;
        List<Account> exactAccountList = new List<Account>();
        if(c.customer_no != null) {

            //exact match between WWClientID__c (Order) vs WW_RMSId__c (Account)
            if(c.customer_no.length()==10)
            {

                exactAccountList = [SELECT Id,PrimaryAddressLine1__pc FROM Account WHERE WW_RMSId__c=: c.customer_no limit 1];
            }
            else if(c.customer_no.length()==36)
            {
                exactAccountList = [SELECT Id,PrimaryAddressLine1__pc FROM Account WHERE C360GoldenID__c=: c.customer_no limit 1];

            }
        }

        if(exactAccountList?.size() > 0){ 
            return exactAccountList.get(0); // we can do that because the WW_RMSID is a unique ID => no risk to have 2 records or more.
        }else{ //if no same id then match/create account using phone number /email 
        
        // Replace international phone starting by 00 by +
        String phone;
        if (c != null && String.isNotBlank(c.phone)) {
            //System.debug('ws phone=' + c.phone);
            if (c.phone.startsWith('00')) {
                phone = '+' + c.phone.removeStart('00');
            //} else if (c.phone.length() <= 3) { // don't take "+32" only into account
            //    phone = null;
            } else {
                phone = c.phone;
            }
        } else {
            phone = c.phone;
        }
        //System.debug('phone=' + phone);

        if (c == null || String.isEmpty(c.lastName) || String.isEmpty(c.firstName)) {// Phone or email not mandatory in MyCC } || (String.isEmpty(c.email) && String.isEmpty(phone))) {
            throw new OrderException(Label.WS_Orders_Client_Empty);
        } else if (String.isNotEmpty(c.email) && String.isNotEmpty(phone)) {
           
            for (Account acc : [SELECT id, LastName, PersonEmail, LocalMobilePhone__pc, LocalWorkPhone__pc, PrimaryAddressCompacted__pc,  PrimaryAddress__pc, PrimaryAddressLine1__pc ,LocalHomePhone__pc, PersonMobilePhone, PersonHomePhone, Phone,LastModifiedDate FROM Account 
                                  WHERE LastName = :c.lastName AND FirstName = :c.firstName AND IsPersonAccount=True
                                  AND (PersonEmail = :c.email OR (PersonMobilePhone = :phone OR PersonHomePhone = :phone OR Phone = :phone OR LocalMobilePhone__pc = :phone OR LocalWorkPhone__pc = :phone OR LocalHomePhone__pc = :phone)) 
                                  ORDER BY LastTrans__pc, LastModifiedDate DESC]) {
                if (acc.PersonEmail == c.email && (acc.PersonMobilePhone == phone || acc.PersonHomePhone == phone || acc.Phone == phone || acc.LocalMobilePhone__pc == phone || acc.LocalWorkPhone__pc == phone || acc.LocalHomePhone__pc == phone)) {
                     // exact matching -> get the account
                    exactAccount = acc;
                    System.debug('In the first check=========>>>>>>' + exactAccount.PrimaryAddress__pc );
                    break;
                } else if (acc.PersonEmail == c.email) {
                    exactAccount = acc;
                } else if (acc.PersonMobilePhone == phone || acc.PersonHomePhone == phone || acc.Phone == phone || acc.LocalMobilePhone__pc == phone || acc.LocalWorkPhone__pc == phone || acc.LocalHomePhone__pc == phone) {
                    exactAccount = acc;
                }
            }
            if (exactAccount != null) {
                listAccount.add(exactAccount);
            }
        } else if (String.isNotEmpty(c.email)) {
            listAccount = [SELECT id  ,LastName,LastModifiedDate,PrimaryAddressLine1__pc FROM Account 
                           WHERE LastName = :c.lastName AND FirstName = :c.firstName AND PersonEmail = :c.email
                           ORDER BY LastTrans__pc, LastModifiedDate DESC LIMIT 1];
        } else if (String.isNotEmpty(phone)) {
            listAccount = [SELECT id  ,LastName,LastModifiedDate,PrimaryAddressLine1__pc FROM Account 
                           WHERE LastName = :c.lastName AND FirstName = :c.firstName AND (PersonMobilePhone = :phone OR PersonHomePhone = :phone OR Phone = :phone)
                           ORDER BY LastTrans__pc, LastModifiedDate DESC LIMIT 1];
        }

        Account acc = (listAccount.isEmpty() ? null : listAccount.get(0));
            System.debug('*****value cys :oc*****'+oc);
                        List<Store__c> storeList = [SELECT id,Store_CountryCode__c,StoreCountry__c,RetailStoreId__c,	ISO3_Code__c  FROM Store__c WHERE RetailStoreId__c = :oc.storeCode LIMIT 1]; 

        if (acc == null) {
               acc = new Account(FirstName = c.firstName, LastName =  c.lastName, PersonEmail = c.email, PersonMobilePhone = phone, ProspectForDream__c = true, IsProspect__pc = true, Source__c = 'KBRW',WW_RMSId__c= c.customer_no);
            if(!storelist.isEmpty()){
                acc.AttachedStoreCode__pc=storeList[0].RetailStoreId__c;
                acc.PrimaryCountry__pc=storeList[0].StoreCountry__c;
                    acc.AttachedStoreCountry__pc=storeList[0].ISO3_Code__c;

            }
            insert acc;
        }            
    
        return acc;
    }
     }

     public static Account updateAddress(Account act ,WS_OrdersJson ac)
    {
            System.debug('Inside the update address method'+ act);

        if(act.PrimaryAddressLine1__pc == null && ac.address !=null)
        {
            act.PrimaryAddressLine1__pc = ac.address.address1;

            act.PrimaryCity__pc = ac.address.city;

            act.PrimaryZipCode__pc = ac.address.postal_code;

            act.PrimaryCountry__pc = ac.address.country;

            update act;

        }

        return act;
    }
    
     private static Boolean updateOrderStoreType(OrderShipping__c orderShipping){
        String storeType = [SELECT Id, Store__c, Store__r.StoreType__c FROM Order__c where id = :orderShipping.Order__c].Store__r.StoreType__c;
        return storeType == 'Store';
    }
    
    // Check if related records to orderNumber or ShippingNumber are pending in "Order_Note__c"
    // public static void linkOrderNotes(Order__c order, List<String> shippingNumbers){
    //     if (order.OrderNumber__c != null) {
    //         List<Order_Note__c> orderNotes = [SELECT Id, Tech_OrderNumber__c, Tech_shippingNumber__c FROM Order_Note__c WHERE Tech_OrderNumber__c = :order.OrderNumber__c OR Tech_shippingNumber__c in :shippingNumbers];
            
    //         Order_Note__c orderNoteUpd = new Order_Note__c();
    //         List<Order_Note__c> orderNotesUpd = new  List<Order_Note__c>();
            
    //         for (Order_Note__c orderNote: orderNotes) {
    //             orderNoteUpd.Id = orderNote.Id;
    //             orderNoteUpd.OwnerId = order.OwnerId;
    //             orderNoteUpd.order__r = new Order__c(orderNumber__c = orderNote.Tech_OrderNumber__c);
    //             if (orderNote.Tech_shippingNumber__c != null) {
    //                 orderNoteUpd.order_shipping__r = new OrderShipping__c(shippingNumber__c = orderNote.Tech_shippingNumber__c);
    //             }
    //             orderNotesUpd.add(orderNoteUpd);
    //         }

    //         Database.SaveResult[] srList = Database.update(orderNotesUpd);
    //     }
    // }

    global class ResponseHandler{
        
        public Boolean success {get; set;}
        public string message {get;set;}
        public Boolean created {get;set;}

        public ResponseHandler(Boolean success,string message,Boolean created){
            this.success = success;
            this.message = message;
            this.created = created;
        }
    }
    
    public class OrderException extends Exception {}
    
}