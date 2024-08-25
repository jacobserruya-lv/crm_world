@RestResource(urlMapping='/identity/purchaseHistory/*')
global with sharing class IDENTITY_WS_PurchaseHistory {

    @HttpGet
    global static void get() {

        RestResponse res = RestContext.response;
        res.addHeader('Content-Type', 'application/json');

        Pattern pattern = Pattern.compile('/identity/purchaseHistory/([a-zA-Z0-9]{18})');
        Matcher matcher = pattern.matcher(RestContext.request.requestUri);
        System.debug(RestContext.request.requestUri);

        if (matcher.matches()) {
            String id = matcher.group(1);

            // GET Excluded IDS
            String[] ids = new List<String>();
            if(RestContext.request.params.get('exclude') != null){
                ids = RestContext.request.params.get('exclude').split(',');
            }

            // GET Excluded SKUS
            String[] skus = new List<String>();
            if(String.isNotEmpty(IDENTITY_Settings__c.getInstance().Excluded_SKU_for_Purchase_History_API__c)){
                skus = IDENTITY_Settings__c.getInstance().Excluded_SKU_for_Purchase_History_API__c.split(';');
            }

            // GET Excluded orderTypes
            String[] orderTypes = new List<String>();
            String[] orderTypesForQuery = new List<String>();
            if(RestContext.request.params.get('orderType') != null){
                orderTypes = RestContext.request.params.get('orderType').split(',');
                for(String ot : orderTypes){
                    if(ot.toLowerCase() == 'digital'){
                        orderTypesForQuery.add('Web');
                    }
                    else if(ot.toLowerCase() == 'retail'){


                        
                        orderTypesForQuery.add('Store');
                    }
                    else{
                        orderTypesForQuery.add(ot.substring(0,1).toUpperCase() + ot.substring(1).toLowerCase());   
                    }
                }
            }
            else{
                orderTypesForQuery = new List<String>{'Store', 'Web', 'CSC', 'Other'};
            }
            
            PPR_PurchProduct__c[] purchases = [
                SELECT Id, TECH_TransactionIdConso__c, OrderATGId__c, RMSSKUCode__c, StoreRetailCode__c, Store__c, PurchasedDate__c, Quantity__c,
                    Amount__c, TransactionTotalAmount__c, CurrencyCode__c,
                    MacroMaterial__c, Model__c, ProductLine__c, Image_Url__c, Name,
                    TransactionCCFlag__c, TransactionStHFlag__c, TransactionEAFlag__c, TransactionStSFlag__c, TransactionStoreType__c
                FROM PPR_PurchProduct__c
                WHERE Client__c = :id
                AND RMSSKUCode__c NOT IN :skus
                AND TECH_TransactionIdConso__c NOT IN :ids
                AND TransactionStoreType__c IN :orderTypesForQuery
                ORDER BY TECH_TransactionIdConso__c, PurchasedDate__c ASC
            ];

            // GROUP BY TECH_TransactionIdConso__c
            Map<String,List<PPR_PurchProduct__c>> groupByTransactionId = new Map<String,List<PPR_PurchProduct__c>>();
            for(PPR_PurchProduct__c purchase : purchases){
                if(groupByTransactionId.get(purchase.TECH_TransactionIdConso__c) == null){
                    groupByTransactionId.put(purchase.TECH_TransactionIdConso__c, new List<PPR_PurchProduct__c>());
                }
                groupByTransactionId.get(purchase.TECH_TransactionIdConso__c).add(purchase);
            }

            // BUILD WRAPPER
            Purchase[] body = new List<Purchase>();
            for(String key : groupByTransactionId.keySet()){
                body.add(new Purchase(groupByTransactionId.get(key)));
            }

            res.statusCode = 200;
            res.responseBody = Blob.valueOf(JSON.serialize(new RestResource_Utils.Response(body), true));
        }
        else {

            res.statusCode = 400;
            res.responseBody = Blob.valueOf(JSON.serialize(new RestResource_Utils.Error(Label.MALFORMED_ID,'400')));
        }
    }

    private class Purchase {
        String orderId;
        String orderType;
        String transactionId;
        Date purchasedDate;
        String currencyCode;
        Decimal totalPriceWithVAT;
        Decimal totalItems;
        Decimal totalPurchased;
        Decimal totalReturned;
        Decimal totalCancelled;
        String shippingMethod;
        String storeCode;
        Item[] items;
        

        public Purchase(PPR_PurchProduct__c[] purchases){
            initiate(purchases);
            calculate(purchases);
        }

        public void initiate(PPR_PurchProduct__c[] purchases){
            this.totalItems = 0;
            this.totalPurchased = 0;
            this.totalReturned = 0;
            this.totalCancelled = 0;

            if(!purchases.isEmpty()){
                this.purchasedDate = purchases[0].PurchasedDate__c;
                this.transactionId = purchases[0].TECH_TransactionIdConso__c;
                this.orderId = purchases[0].OrderATGId__c;
                this.currencyCode = purchases[0].CurrencyCode__c;
                this.totalPriceWithVAT = purchases[0].TransactionTotalAmount__c;
                this.storeCode = purchases[0].StoreRetailCode__c;
                this.orderType = purchases[0].TransactionStoreType__c;
                
                if(this.orderType == 'Web'){
                    this.orderType = 'Digital';
                }
                if(this.orderType == 'Store'){
                    this.orderType = 'Retail';
                }

                if(purchases[0].TransactionCCFlag__c){
                    this.shippingMethod = 'CLICK_COLLECT';
                }
                else if(purchases[0].TransactionStHFlag__c){
                    this.shippingMethod = 'STORE_TO_HOME';
                }
                else if(purchases[0].TransactionEAFlag__c){
                    this.shippingMethod = 'ENDLESS_AISLES';
                }
                else if(purchases[0].TransactionStSFlag__c){
                    this.shippingMethod = 'STORE_TO_STORE';
                }
            }

            this.items = new List<Item>();
        }

        public void calculate(PPR_PurchProduct__c[] purchases){

            Map<String,Item> itemsMap = new Map<String,Item>();
            for(PPR_PurchProduct__c purchase : purchases){

                //CALCULATE TOTALS
                if(purchase.Quantity__c != null){
                    if(purchase.Amount__c > 0){
                        if(itemsMap.get(purchase.RMSSKUCode__c) != null && itemsMap.get(purchase.RMSSKUCode__c).priceWithVAT < 0){
                            this.totalReturned -= Math.abs(purchase.Quantity__c);
                            this.totalCancelled += Math.abs(purchase.Quantity__c);
                        }
                        else {
                            this.totalPurchased += Math.abs(purchase.Quantity__c);
                            this.totalItems += Math.abs(purchase.Quantity__c);
                        }
                        
                    }
                    else{
                        if(itemsMap.get(purchase.RMSSKUCode__c) != null && itemsMap.get(purchase.RMSSKUCode__c).priceWithVAT > 0){
                            this.totalPurchased -= Math.abs(purchase.Quantity__c);
                            this.totalCancelled += Math.abs(purchase.Quantity__c);
                        }
                        else {
                            this.totalReturned += Math.abs(purchase.Quantity__c);
                            this.totalItems += Math.abs(purchase.Quantity__c);
                        }

                    }
                }    


                // IS RETURNED PRODUCT
                if(itemsMap.get(purchase.RMSSKUCode__c) != null && (
                        (itemsMap.get(purchase.RMSSKUCode__c).priceWithVAT < 0 && purchase.Amount__c > 0) ||
                        (itemsMap.get(purchase.RMSSKUCode__c).priceWithVAT > 0 && purchase.Amount__c < 0))){
                    itemsMap.get(purchase.RMSSKUCode__c).isCancelled = true;
                    itemsMap.get(purchase.RMSSKUCode__c).isReturned = false;
                }
                else {
                    itemsMap.put(purchase.RMSSKUCode__c, new Item(purchase));
                }
            }

            this.items = itemsMap.values();
        }
    }

    private class Item {
        String sku;
        String name;
        String material;
        String image;
        Boolean isReturned;
        Boolean isCancelled;
        Decimal priceWithVAT;
        Decimal quantity;
        
        public Item(PPR_PurchProduct__c purchase){
            this.sku = purchase.RMSSKUCode__c;
            this.name = purchase.Name;
            this.material = purchase.MacroMaterial__c;
            this.image = purchase.Image_Url__c;
            this.isReturned = (purchase.Amount__c < 0 ? true : false);
            this.isCancelled = false;
            this.priceWithVAT = purchase.Amount__c;
            this.quantity = purchase.Quantity__c;                        
        }
    }
}