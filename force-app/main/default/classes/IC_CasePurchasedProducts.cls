global class IC_CasePurchasedProducts {
	@AuraEnabled
    public static List<TransactionWrapper> FindPurchasedProductDB(String Id){
        System.debug('Id received from component for searching :' + Id);

        // Event searching using passed id
        Case  cse = new Case();
        cse = [Select Id, AccountId FROM Case Where Id =:Id Limit 1];
		System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$' + cse.AccountId);
        // List of purchased products
        List<PPR_PurchProduct__c> purchasedProducts	= [	SELECT Id, TechTransactionId__c, Name, Client__c, Client__r.Name,TransactionTotalAmount__c, Amount__c, Quantity__c, CurrencyCode__c, toLabel(Store__c), PurchaseCountry__c, StoreCountry__c, 
        												PurchasedDate__c,StoreRetailCode__c FROM PPR_PurchProduct__c Where Client__c = :cse.AccountId];
        System.debug('There are : ' + purchasedProducts.size());

        // Map TransactionIds with purchased product (The field TechTransactionId__c is a formula field and cannot be used in Group by where clause in SOQL)
        Map<String,List<PPR_PurchProduct__c>> TransactionIds = new  Map<String,List<PPR_PurchProduct__c>>();
        
        for(PPR_PurchProduct__c p:purchasedProducts){
        	System.debug('This is/are the product:' + p);
             System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$' + p.TechTransactionId__c);
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
            ppToReturn.add(new TransactionWrapper(tid, TransactionIds.get(tid)[0].PurchasedDate__c, 0, TransactionIds.get(tid)));
            System.debug('TechTransactionId__c : ' + TransactionIds.get(tid));
        }

        for(TransactionWrapper pp:ppToReturn){
            System.debug('ppToReturn : ' + pp);
        } 
        ppToReturn.sort();

        return ppToReturn;
    }

    global class TransactionWrapper implements Comparable{
        @AuraEnabled 
        String transactionid {get;private set;}
        @AuraEnabled
        Date purchaseDate {get; private set;}
        @AuraEnabled
        String totalAmount {get;private set;}
        @AuraEnabled
        List<PPR_PurchProduct__c> pps {get;private set;}

        public TransactionWrapper(String id, Date d, Double amount, List<PPR_PurchProduct__c> l){
            System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'+id);
            System.debug('$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$'+d);
            
			
             
            pps = l;
            transactionid = id;
            purchaseDate = d;
           
            if(l.get(0).TransactionTotalAmount__c !=null){
                
                totalAmount = l.get(0).TransactionTotalAmount__c.format() + ' ' + l.get(0).CurrencyCode__c;
            }
            else 
                totalAmount = 'Missing Values';
            
        }
        
        global Integer compareTo(Object compareTo){
            TransactionWrapper transactionToCompare = (TransactionWrapper)compareTo;
            
            if(purchaseDate > transactionToCompare.purchaseDate) return -1;
            if(purchaseDate < transactionToCompare.purchaseDate) return 1;
            else return 0;
        }
    }

    @AuraEnabled
    public static void updatePurchasedProductOnEvent(String caseId, String tId, String ppId){
        System.debug('Case Id received from component for searching :' + caseId);
        System.debug('Purchased Product Id received from component for searching :' + tId);

        // Event searching using passed idInitial term of field expression must be a concrete SObject
        Case   c = new Case();
        c = [Select Id, AccountId, OwnerId FROM Case Where Id =:caseId Limit 1];
        c.Transaction_Id__c = tId;
        c.PprLinked__c = ppId;
        System.debug('Purchased Product on event before update :' + c.Transaction_Id__c);
        update c;
        System.debug('Purchased Product on event before update :' + c.Transaction_Id__c);
    }
}