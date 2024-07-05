/*--------------------------------------------------------------------------------------------------------------------------
Author:         Visal OU
Company:        CGI
Description:Class used to retrive the purchased histories on client to show on event page
Test Class:     IC_PurchasedProducts_TEST
History
<Date>          <Authors Name> <Brief Description of Change>
13-06-2017      VOU             Develop the first version
--------------------------------------------------------------------------------------------------------------------------*/

global class IC_PurchasedProducts {
    
    @AuraEnabled
    public static List<TransactionWrapper> findPurchasedProductDB(String Id){
        System.debug('Id received from component for searching :' + Id);

        // Event searching using passed id
        //Event   event = [Select Id, WhatId, WhoId, AccountId, OwnerId, Client_List__c FROM Event Where Id =:Id Limit 1];
        Id accountId = getAccount(Id);

        // List of purchased products
        List<PPR_PurchProduct__c> purchasedProducts = [ SELECT Id, TechTransactionId__c, Name, Client__c, Client__r.Name,TransactionTotalAmount__c, Amount__c, Quantity__c, CurrencyCode__c, toLabel(Store__c), PurchaseCountry__c, StoreCountry__c, 
                                                        PurchasedDate__c,StoreRetailCode__c, DREAMID__c, ICX_ContactChannel__c, ICX_ContactChannel_RecordId__c FROM PPR_PurchProduct__c
                                                       Where Client__c = :accountid   and TransactionStoreType__c in ('Web','CSC') and PurchasedDate__c >= LAST_N_DAYS:30 ];
        System.debug('There are : ' + purchasedProducts.size()+ ' purchasedProducts');

        // Map TransactionIds with purchased product (The field TechTransactionId__c is a formula field and cannot be used in Group by where clause in SOQL)
        Map<String,List<PPR_PurchProduct__c>> TransactionIds = new  Map<String,List<PPR_PurchProduct__c>>();
        
        for(PPR_PurchProduct__c p:purchasedProducts){
            System.debug('This is/are the product:' + p);
            if(TransactionIds.containsKey(p.TechTransactionId__c)){
                TransactionIds.get(p.TechTransactionId__c).add(p);
            }
            else{
                TransactionIds.put(p.TechTransactionId__c, new List<PPR_PurchProduct__c>{p});
            }
        }
        
    
        //List of product to return to the method call
        List<TransactionWrapper> ppToReturn = new List<TransactionWrapper>();

        for(String tid: TransactionIds.keySet()){
            ppToReturn.add(new TransactionWrapper(tid, TransactionIds.get(tid)[0]?.PurchasedDate__c, 0, TransactionIds.get(tid)));
            System.debug('TechTransactionId__c : ' + TransactionIds.get(tid));
        }

        for(TransactionWrapper pp:ppToReturn){
            System.debug('ppToReturn : ' + pp);
        } 
        ppToReturn.sort();
        system.debug(ppToReturn);
        

        return ppToReturn;
    }

    private static Id getAccount(Id recordId) {
        Id accountId;

        String objectType = (String.isNotBlank(recordId) ? recordId.getSObjectType().getDescribe().getName() : null);
        if ('Event'.equals(objectType)) {
            /*old version
            accountId = [Select Id, WhatId, WhoId, AccountId, OwnerId, Client_List__c FROM Event Where Id = :recordId Limit 1].WhatId;
			*/
            // EGZ: Possible correction 
            Id caseId = [Select Id, WhatId, WhoId, AccountId, OwnerId, Client_List__c, DREAMID__c FROM Event Where Id = :recordId Limit 1]?.WhatId;
            accountId = [SELECT AccountId FROM Case WHERE Id = :caseId]?.AccountId;
			
        } else if ('Case'.equals(objectType)) {
            accountId = [SELECT AccountId FROM Case WHERE Id = :recordId]?.AccountId;
        }
        System.debug('### getAccountID:'+accountID);
        return accountId;
    }

    global class TransactionWrapper implements Comparable{
        @AuraEnabled 
        public String transactionid {get;private set;}
        @AuraEnabled
        public Date purchaseDate {get; private set;}
        @AuraEnabled
        public String totalAmount {get;private set;}
        @AuraEnabled 
        public String contactChannelType {get;private set;}
        @AuraEnabled 
        public Boolean isGrey {get;private set;}
        @AuraEnabled
        public List<PPR_PurchProduct__c> pps {get;private set;}

        public TransactionWrapper(String id, Date d, Double amount, List<PPR_PurchProduct__c> l){
            pps = l;
            transactionid = id;
            purchaseDate = d;
            totalAmount = (l.get(0).TransactionTotalAmount__c != null ? l.get(0).TransactionTotalAmount__c?.format() + ' ' + l.get(0).CurrencyCode__c : null);
            contactChannelType = l.get(0)?.ICX_ContactChannel__c;
            isGrey = String.isNotEmpty(l.get(0)?.ICX_ContactChannel_RecordId__c) || (l.get(0)?.PurchasedDate__c!=null) && l.get(0)?.PurchasedDate__c < Date.today().addDays(-30)? true : false;
           
        }
        
        global Integer compareTo(Object compareTo){
            TransactionWrapper transactionToCompare = (TransactionWrapper)compareTo;
            
            if(purchaseDate > transactionToCompare.purchaseDate) return -1;
            if(purchaseDate < transactionToCompare.purchaseDate) return 1;
            else return 0;
        }
    }

    @AuraEnabled
    public static void updatePurchasedProductOnEvent(String eventId, String ppId){
        System.debug('Event Id received from component for searching :' + eventId);
        System.debug('Purchased Product Id received from component for searching :' + ppId);
        
        PPR_PurchProduct__c ppr = [ SELECT Id, TechTransactionId__c, Name, Client__c, Client__r.Name,TransactionTotalAmount__c, Amount__c, Quantity__c, CurrencyCode__c, toLabel(Store__c), PurchaseCountry__c, StoreCountry__c, 
                                                        PurchasedDate__c,StoreRetailCode__c, DREAMID__c, ICX_ContactChannel__c,ICX_ContactChannel_RecordId__c,ICX_CSCContactDate__c,
                                   TicketNumber__c,ConvertedAmountEUR__c FROM PPR_PurchProduct__c where Id =: ppid];

        String objectType = (String.isNotBlank(eventId) ? Id.valueOf(eventId).getSObjectType().getDescribe().getName() : null);
        if ('Event'.equals(objectType)) {
            // Event searching using passed idInitial term of field expression must be a concrete SObject
            Event   event = [Select Id, WhatId, WhoId, AccountId, RecordTypeId, OwnerId, Client_List__c,Purchased_Product__c, RelatedTicketNumber__c,SaleAmount__c,Currency__c,
                             Transaction_Total_Converted_Amount_EUR__c, Channel__c, ActivityDate
                             FROM Event Where Id =:eventId Limit 1];
            
            // Update fields on Appointment record 
            event.Purchased_Product__c = ppId;
            event.RelatedTicketNumber__c = ppr.TicketNumber__c;
            event.SaleAmount__c = ppr.Amount__c ;
            event.Currency__c = ppr.CurrencyCode__c;
            event.Transaction_Total_Converted_Amount_EUR__c = ppr.ConvertedAmountEUR__c;
            System.debug('Event before update :' + event);
            update event;
            System.debug('Event after update :' + event);   
            
            // Update fields on transaction record
            ppr.ICX_ContactChannel__c = event.Channel__c;
            ppr.ICX_ContactChannel_RecordId__c = event.Id;
            ppr.ICX_CSCContactDate__c =  event.ActivityDate;
            ppr.ICX_CSCUser__c = event.OwnerId ;
            System.debug('Purchased Product before update :' + ppr);
            update ppr;
            System.debug('Purchased Product after update :' + ppr);
            
        } else if ('Case'.equals(objectType)) {
            Case cas = new Case(Id = eventId);
            cas.PurchasedProduct__c = ppId;
            update cas;
        }
    }
}