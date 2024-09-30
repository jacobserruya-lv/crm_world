global with sharing class OrderNoteService {

    //public Enum OrderNoteType {ATTACHED_NOTE, CLIENTELING_EXCEPTION, PRICE_ADJUSTMENT}
    
    // Type__c : picklist Values
    public static final string ATTACHED_NOTE = 'ATTACHED_NOTE';
    public static final string CLIENTELING_EXCEPTION = 'CLIENTELING_EXCEPTION';
    public static final string PRICE_ADJUSTMENT = 'PRICE_ADJUSTMENT';
    public static final string BANK_TRANSFER = 'BANK_TRANSFER';
    public static final string STOCK_ON_HOLD = 'STOCK_ON_HOLD';
    public static final string FREE_SHIPPING = 'FREE_SHIPPING';
    public static final string PAYMENT_LINK = 'PAYMENT_LINK';
    public static final string EXTENDED_PAYMENT_LINK = 'EXTENDED_PAYMENT_LINK';
    public static final string PAY_AFTER_AGREEMENT = 'PAY_AFTER_AGREEMENT';
    public static final string PERSO_PRODUCT_ACC = 'PERSO_PRODUCT_ACC';
    public static final string PERSO_PRODUCT_REF = 'PERSO_PRODUCT_REF';


    // Contact con = [SELECT Id, Status__c FROM Contact WHERE Id = ‘1234567890’];
    // //To get picklist entries
    // List<Schema.PicklistEntry> values = Contact. Status__c.getDescribe().getPicklistValues();
    // Map<String,String> statusApiToLabelMap = new Map<String,String>();
    // For(Schema.PicklistEntry sp : values){
    //     //Map to hold Picklist API as Key and Picklist Label as Value
    //     statusApiToLabelMap.put(sp. getValue(), sp. values.getLabel());
    // }
    // System.debug(‘Label value of picklist>>’+ statusApiToLabelMap .get(con.Status__c));

    

    @auraEnabled(cacheable=true)
    public static List<Order_Note__c> getOrderNoteByOrders(List<String> orderNumbers, List<String> types) {        
        List<Order_Note__c> orderNotes = [SELECT Id, Type__c, 
                                            Tech_OrderNumber__c, Order__c, Order__r.OrderNumber__c, 
                                            Tech_ShippingNumber__c, Tech_ShippingNumberV2__c, Order_Shipping__c, Order_Shipping__r.ShippingNumber__c ,ClientAdvisor__c, 
                                            Reason__c, toLabel(Reason__c) ReasonLabel, Description__c,CreatedDate
                                        FROM Order_Note__c
                                        WHERE Tech_OrderNumber__c in :orderNumbers
                                          and Type__c in :types];
                                        
        system.debug(orderNotes);

        return orderNotes;
    }

    // List of Attached Note related to order or shipping
    // Param
    // - recordId : could be "order id" or "shipping id"
    @auraEnabled(cacheable=true)
    public static List<Order_Note__c> getAttachedNote(String recordId) {        
        List<Order_Note__c> orderNotes = [SELECT Id, Description__c, 
                                            ClientAdvisor__c, ClientAdvisor__r.Name, ClientAdvisor__r.RMS_ID__c,
                                            CreatedDate, Type__c
                                        FROM Order_Note__c
                                        WHERE ((Order__c = :recordId and Order_Shipping__c = null)
                                          OR (Order_Shipping__c = :recordId))
                                          AND Type__c = 'ATTACHED_NOTE'
                                        ORDER BY CreatedDate];
        system.debug(orderNotes);

        return orderNotes;
    }

    // Map<Order__c or Order_Shipping__c, 
    //  Map<Case.Approval_Type__c, Case>>
    @auraEnabled(cacheable=true)
    public static List<Case> getRelatedApprovalCases(List<String> orderNumbers) { 
        Id caseRecordIdApproval = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Approval').getRecordTypeId();

        List<Case> ApprovalCases = [SELECT Id, Status, CaseNumber,
                                            Approval_Submitter__c, Approval_Type__c, toLabel(Approval_Type__c) ApprovalTypeLabel, 
                                            Order__c, Order__r.OrderNumber__c, 
                                            Order_Shipping__c, Order_Shipping__r.ShippingNumber__c, Order_Shipping__r.ShippingNumberV2__c,
                                            OwnerId, recordTypeId, AccountId, CreatedDate
                                        FROM Case
                                        WHERE recordTypeId = :caseRecordIdApproval
                                            AND (Order__r.orderNumber__c in :orderNumbers
                                                OR Order_Shipping__r.Order__r.orderNumber__c in :orderNumbers)];
                                        
        system.debug(ApprovalCases);

        return ApprovalCases;
    }


    // Sync Order_Note__c records pending with order__c and/or order_shipping__c
    @future
    public static void syncWithOrder(List<String> orderNumbers, List<String> shippingNumbers){
        
        Map<String, OrderShipping__c> orderMap = new Map<String, OrderShipping__c>();
        Map<String, OrderShipping__c> orderShippingMap = new Map<String, OrderShipping__c>();

        List<String> shippingNumbersV2 = new List<String>();

        // ---------- //
        // JIRA-25028 //
        // ---------- //
        // List<Order__c> orders = [SELECT id, orderNumber__c, ownerId__c, 
        //                             (SELECT Id, ShippingNumber__c FROM Orders_Shippings__r WHERE ShippingNumber__c in :shippingNumbers) 
        //                         FROM order__c WHERE orderNumber__c in :orderNumbers];        
        // for (Order__c order: orders) {
        //     orderMap.put(order.orderNumber__c, order);
        //     // orderNumberSet.add(order.orderNumber__c);
        //     for(OrderShipping__c orderShipping: order.Orders_Shippings__r) {
        //         orderShippingMap.put(orderShipping.ShippingNumber__c, orderShipping);
        //         // shippingNumberSet.add(orderShipping.ShippingNumber__c);
        //     }
        // }

        // Kitting -> convert shippingNumber V1 format (xxxxxx-y) to shippingNumber V2 format (xxxxxxx)
        for(String shippingNumber: shippingNumbers) {
            shippingNumbersV2.add(shippingNumber.split('-')[0]);
            if(shippingNumber.contains('-')) {
                shippingNumbersV2.add(shippingNumber);
            }
        }


        List<OrderShipping__c> orderShippings = [SELECT Order__r.Id, Order__r.orderNumber__c, Order__r.ownerId__c, Id, ShippingNumber__c, ShippingNumberV2__c 
                                            FROM OrderShipping__c 
                                            WHERE ShippingNumber__c in :shippingNumbersV2 OR Order__r.orderNumber__c in :orderNumbers];       

        for (OrderShipping__c orderShipping: orderShippings) {
            orderMap.put(orderShipping.order__r.orderNumber__c, orderShipping);
            orderShippingMap.put(orderShipping.ShippingNumberV2__c, orderShipping);
        }

        Integer nbOfTry = 0;
        Boolean hasRetry = false;

        List<Order_Note__c> orderNotes;

        do {
            try {
                hasRetry = false;
                // Does it exist pending : Attached Note, Clienteling Exception or Price adjustment 
                orderNotes = [SELECT Id, Tech_OrderNumber__c, Order__c, 
                                Tech_ShippingNumber__c, Tech_ShippingNumberV2__c, Order_Shipping__c, ClientAdvisor__c,Type__c,Order__r.Account__c,Order_Shipping__r.Order__r.Account__c
                            FROM Order_Note__c
                            WHERE (Order__c = null and Order_Shipping__c = null)
                            and (Tech_OrderNumber__c in :orderNumbers OR Tech_ShippingNumberV2__c in :shippingNumbersV2)
                            FOR UPDATE];
            }
            catch(QueryException e) {
                nbOfTry++;
                if (nbOfTry <= 3) {
                    hasRetry = true;
                }
                else {
                    throw e;
                }
            }
        } while (hasRetry);

        List<Order_Note__c> orderNotesToUpdate = new List<Order_Note__c>();                               
        for (Order_Note__c orderNote: orderNotes) {
            orderNote.Order__c = null;
            orderNote.Order_Shipping__c = null;
            orderNote.ClientAdvisor__c = orderMap.get(orderNote.Tech_OrderNumber__c)?.Order__r.OwnerId__c;

            if (orderNote.Tech_ShippingNumberV2__c != null) {                
                // On Map "Order_Note" avec "Order_Shipping" 
                orderNote.Order_Shipping__c = orderShippingMap.get(orderNote.Tech_ShippingNumberV2__c)?.Id;
            }
            if (orderNote.Tech_OrderNumber__c != null) { 
                // On Map "Order_Note" avec "Order"
                orderNote.Order__c = orderMap.get(orderNote.Tech_OrderNumber__c)?.order__r.Id;
            }
            // IF the order exists and the mapping is a success
            if (orderNote.Order__c != null || orderNote.Order_Shipping__c != null) {
                orderNotesToUpdate.add(orderNote);
            }
        }

        if (!orderNotesToUpdate.isEmpty()) {
            update orderNotesToUpdate;
            approvalCaseCreation(orderNotesToUpdate);
        }
    }


    public static void approvalCaseCreation(List<Order_Note__c> orderNotesList)
    {
        List<Order_Note__c> orderNodeToCreateCase = new List<Order_Note__c>();
        Map<String, Order_Note__c> orderNodeToCreateCaseMap = new Map<String, Order_Note__c>();
        Map<Id, Id> orderAccountMap = new Map<Id, Id>();
        Map<Id, Id> orderContactMap = new Map<Id, Id>();
        Map<Id, String> orderCountryMap = new Map<Id, String>();

        Map<Id, Id> ShipppingOrderMap = new Map<Id, Id>();

        Map<Id, String> CACountryMap = new Map<Id, String>();

        Map<String, String> countryQueueMap = new Map<String, String>();
        Map<String, Id> QueueNameIdMap = new Map<String, Id>();
        Map<String, Id> countryQueueIdMap = new Map<String, Id>();

        Set<Id> CAList = new Set<Id>();
        Set<Id> OrderId = new Set<Id>();
        Set<Id> ShippingId = new Set<Id>();

      

        try{
            List<String> caseApprovalType = new List<String>();
            Schema.DescribeFieldResult fieldDescription = Case.Approval_Type__c.getDescribe();
        List<Schema.PicklistEntry> entries = fieldDescription.getPicklistValues();
        for (Schema.PicklistEntry entry : entries) {
            caseApprovalType.add(entry.getValue());
            }

            System.debug('nao caseApprovalType'+caseApprovalType);
        for(Order_Note__c currentOrderNote : orderNotesList)
        {

            if(caseApprovalType.contains(currentOrderNote.Type__c))
            {

                orderNodeToCreateCaseMap.put(currentOrderNote.Id,currentOrderNote);
                orderNodeToCreateCase.add(currentOrderNote);
                CAList.add(currentOrderNote.ClientAdvisor__c);
                OrderId.add(currentOrderNote.Order__c);
                ShippingId.add(currentOrderNote.Order_Shipping__c);
            }

        }
        if(orderNodeToCreateCase.size()>0)
        {

            
            //List<OrderLine__c> orderAccount = [SELECT Id, Order__c, Order__r.Account__c,Order__r.Account__r.PersonContactId, OrderShipping__c FROM OrderLine__c WHERE (Order__c IN: OrderId OR OrderShipping__c IN: ShippingId)];
            Set<OrderShipping__c> orderAccount = new Set<OrderShipping__c>();
            //need to do 2 query for performance issue
            if(!ShippingId.isEmpty())
            {
                orderAccount.addAll([SELECT Id, Order__c, Order__r.Account__c,Order__r.Account__r.PersonContactId, Order__r.Store__r.StoreCountry__c FROM OrderShipping__c WHERE Id IN: ShippingId ]);
            }
            if(!OrderId.isEmpty())
            {
                orderAccount.addAll ([SELECT Id, Order__c, Order__r.Account__c,Order__r.Account__r.PersonContactId, Order__r.Store__r.StoreCountry__c FROM OrderShipping__c WHERE Order__c IN: OrderId]);
            }

        //List<User> userCA = [SELECT Id, Country__c FROM User WHERE Id IN: CAList];
        

        
        if(orderAccount.size()>0)
        {
            // for(OrderLine__c currentOrder : orderAccount)
            // {
            //     ShipppingOrderMap.put(currentOrder.OrderShipping__c, currentOrder.Order__c);
            //     if(ShippingId.contains(currentOrder.OrderShipping__c) && orderAccountMap.get(currentOrder.OrderShipping__c)==null)
            //     {
            //         orderAccountMap.put(currentOrder.OrderShipping__c,currentOrder.Order__r.Account__c);
            //         orderContactMap.put(currentOrder.OrderShipping__c,currentOrder.Order__r.Account__r.PersonContactId);
            //     }
            //     else if(orderAccountMap.get(currentOrder.Order__c)==null)
            //     {
            //         orderAccountMap.put(currentOrder.Order__c,currentOrder.Order__r.Account__c);
            //         orderContactMap.put(currentOrder.Order__c,currentOrder.Order__r.Account__r.PersonContactId);

            //     }
            // }

            //if country is not in the metadata, we need to map it
            Map<String,String> countryMap = new Map<String,String> {
                'USA' => 'UNITED STATES',
                'MACAU' => 'MACAO'
            };

            String storeCountry;

            for(OrderShipping__c currentOrder : orderAccount)
            {
                storeCountry = currentOrder.Order__r.Store__r.StoreCountry__c;
                if(countryMap.get(storeCountry) != null) {
                    storeCountry = countryMap.get(storeCountry);
                }

                ShipppingOrderMap.put(currentOrder.Id, currentOrder.Order__c);
                if(ShippingId.contains(currentOrder.Id) && orderAccountMap.get(currentOrder.Id)==null)
                {
                    orderAccountMap.put(currentOrder.Id,currentOrder.Order__r.Account__c);
                    orderContactMap.put(currentOrder.Id,currentOrder.Order__r.Account__r.PersonContactId);
                }
                else if(orderAccountMap.get(currentOrder.Order__c)==null)
                {
                    orderAccountMap.put(currentOrder.Order__c,currentOrder.Order__r.Account__c);
                    orderContactMap.put(currentOrder.Order__c,currentOrder.Order__r.Account__r.PersonContactId);
                }
                orderCountryMap.put(currentOrder.Order__c,storeCountry);
            }
        }
        // System.debug('orderAccountMap ' +orderAccountMap);
        // if(userCA.size()>0)
        // {
        //     //if country is not in the metadata, we need to map it
        //     Map<String,String> countryMap = new Map<String,String> {
        //         'USA' => 'UNITED STATES',
        //         'MACAU' => 'MACAO'
        //     };
        //     for(User currentUser : userCA)
        //     {
                
        //         if(CACountryMap.get(currentUser.Id)==null)
        //         {
        //             String userCountry =currentUser.Country__c;
        //             if(countryMap.get(userCountry) != null) {
        //                 userCountry = countryMap.get(userCountry);
        //             }
     
        
        //             CACountryMap.put(currentUser.Id, userCountry);
        //         }
                
        //     }
        // }

        List<CountryMapping__mdt> countryMapping = [SELECT Id, QueueApproval__c, Picklist__c FROM CountryMapping__mdt WHERE Picklist__c IN:  orderCountryMap.values() AND HasOtherValue__c=false];

        for(CountryMapping__mdt countryMap : countryMapping)
        {
            if(countryQueueMap.get(countryMap.Picklist__c)==null)
            {
                countryQueueMap.put(countryMap.Picklist__c, countryMap.QueueApproval__c);
            }
        }


        List<Group> queueApproval = [SELECT Id,Name FROM Group WHERE Type=:'Queue' AND Name IN:countryQueueMap.values()];
        
        for(Group currentQueue : queueApproval)
        {
            QueueNameIdMap.put(currentQueue.Name,currentQueue.Id);
        }

        for(String currentCountry : countryQueueMap.keySet())
        {
            
            countryQueueIdMap.put(currentCountry,QueueNameIdMap.get(countryQueueMap.get(currentCountry)));
        }
        

        List<Case> caseToInsert = new List<Case>();
        for(Order_Note__c currentOrderNote : orderNodeToCreateCase)
        {
            //System.debug(' OwnerId CACountryMap ' + CACountryMap.get(currentOrderNote.ClientAdvisor__c));
            System.debug('countryQueueIdMap: '+countryQueueIdMap);
            System.debug('orderCountryMap: '+orderCountryMap);
            System.debug('currentOrderNote.Order__c: '+currentOrderNote.Order__c);
            
            System.debug(' OwnerId countryQueueIdMap ' + countryQueueIdMap.get(orderCountryMap.get(currentOrderNote.Order__c)));
            
            
            Id caseRecordIdApproval = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Approval').getRecordTypeId();
            
            Case currentCase = new Case();
            currentCase.Approval_Submitter__c = currentOrderNote.ClientAdvisor__c;
            currentCase.Approval_Type__c = currentOrderNote.Type__c;
            currentCase.Subject = 'Approval '+ currentCase.Approval_Type__c;
            currentCase.Order__c = currentOrderNote.Order__c!=null? currentOrderNote.Order__c:ShipppingOrderMap.get(currentOrderNote.Order_Shipping__c);
            currentCase.Order_Shipping__c = currentOrderNote.Order_Shipping__c;
            
            currentCase.OwnerId = countryQueueIdMap.get(OrderCountryMap.get(currentOrderNote.Order__c))!=null?
                                            countryQueueIdMap.get(OrderCountryMap.get(currentOrderNote.Order__c))
                                            :currentOrderNote.ClientAdvisor__c!=null?currentOrderNote.ClientAdvisor__c:UserInfo.getUserId();
            

            currentCase.recordTypeId = caseRecordIdApproval;
            currentCase.AccountId = orderAccountMap.get(currentOrderNote.Order__c)!=null?orderAccountMap.get(currentOrderNote.Order__c):orderAccountMap.get(currentOrderNote.Order_Shipping__C);
            currentCase.ContactId = orderContactMap.get(currentOrderNote.Order__c)!=null?orderContactMap.get(currentOrderNote.Order__c):orderContactMap.get(currentOrderNote.Order_Shipping__C);            
            caseToInsert.add(currentCase);
            
        }
        
        insert caseToInsert;
    }
        
    }
    catch(Exception e)
    {
        System.debug('Case Approval Creation ERROR : ' +e.getMessage());
    }
    
}


}