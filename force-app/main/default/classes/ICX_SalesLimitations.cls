public class ICX_SalesLimitations {
   public static List<Sales> salesList = new List<Sales>() ;
   public static set<String> OrderToPurchased = new set<String>() ;


    @AuraEnabled
    public static List<Sales> getRelatedAccounts(String recordId){
        Set <String> setAccount =  new Set<String> ();     
        
         for(Alias_Member__c am : [SELECT Client__c FROM Alias_Member__c  WHERE Alias__c  =:recordId] ){
         setAccount.add(am.Client__c);
        }
        getPurchasedProduct(setAccount);
        getOrder(setAccount);
       return salesList;
        
    }
    
    public static void getPurchasedProduct(Set <String> setAccount){
        date currentDate = date.newinstance(System.now().year(), System.now().month(), System.now().day());
        date dateBefore = currentDate.addMonths(-12);

        for(PPR_PurchProduct__c  pp:[SELECT Id,Client__r.DREAMID__c, RMSSKUCode__c,PurchasedDate__c ,Name,TechTransactionId__c, TicketNumber__c,Quantity__c,ProductLine__c,Store__c  
                                     FROM PPR_PurchProduct__c 
                                     WHERE PurchasedDate__c <=: currentDate  AND PurchasedDate__c >=: dateBefore AND  Client__c in :setAccount AND ProductLine__c!=null  AND Amount__c != 0
                                     ORDER BY  PurchasedDate__c DESC]){
			
             salesList.add(new Sales(pp.Client__r.DREAMID__c,pp.RMSSKUCode__c,pp.PurchasedDate__c,pp.Name ,pp.TechTransactionId__c,pp.Quantity__c,pp.ProductLine__c,pp.Store__c,'','Purchased Product'));
             OrderToPurchased.add(pp.RMSSKUCode__c+' '+pp.PurchasedDate__c+' '+pp.Store__c);                       
            
        }
    }
    
    public static void getOrder(Set <String> setAccount){
        date currentDate = date.newinstance(System.now().year(), System.now().month(), System.now().day());
        date dateBefore = currentDate.addMonths(-12);
       
        for(OrderLine__c  ord: [SELECT  Id ,Order__r.Account__r.DREAMID__c, ProductReferential__r.SKUCode__c,Order__r.OrderDate__c,ProductReferential__r.Name, Order__r.OrderNumber__c, Quantity__c,  ProductReferential__r.ProductCategory__c, Order__r.Store__r.RetailStoreId__c,tolabel(OrderShipping__r.Status__c),OrderShipping__r.StatusDate__c
							FROM OrderLine__c 
                            WHERE /*OrderShipping__r.Status__c!='unfulfilled' and*/ Order__r.Account__c in :setAccount AND Order__r.OrderDate__c <=: currentDate  AND Order__r.OrderDate__c >=: dateBefore
							ORDER BY Order__r.OrderDate__c DESC] ){
            if((!OrderToPurchased.contains(ord.ProductReferential__r.SKUCode__c+' '+ord.OrderShipping__r.StatusDate__c.date()+' '+ord.Order__r.Store__r.RetailStoreId__c) && ord.OrderShipping__r.Status__c =='Fulfilled' )|| ord.OrderShipping__r.Status__c !='Fulfilled'){
                     salesList.add(new Sales(ord.Order__r.Account__r.DREAMID__c,ord.ProductReferential__r.SKUCode__c,ord.Order__r.OrderDate__c.date(),ord.ProductReferential__r.Name,ord.Order__r.OrderNumber__c,ord.Quantity__c,ord.ProductReferential__r.ProductCategory__c,ord.Order__r.Store__r.RetailStoreId__c,ord.OrderShipping__r.Status__c,'Store Order'));

            }
            
        }
    } 
    
    
    public Class Sales{
       
        @AuraEnabled
        public String dreamId {get;set;} 
        @AuraEnabled
        public String SKU {get;set;} 
        @AuraEnabled
        public Date purchasedDate {get;set;}
        @AuraEnabled
        public String productName {get;set;}
        @AuraEnabled
        public String transactionId {get;set;} 
        @AuraEnabled
        public Decimal quantity {get;set;} 
        @AuraEnabled
        public String category {get;set;} 
        @AuraEnabled
        public String storeCode {get;set;} 
        @AuraEnabled
        public String status {get;set;} 
        @AuraEnabled
        public String nameObject {get;set;} 
        
        public Sales (String dreamId, String SKU,Date purchasedDate,String productName ,String transactionId,Decimal quantity,String category,String storeCode,String status,String nameObject){
            this.dreamId = dreamId ;
            this.SKU = SKU ;
            this.purchasedDate = purchasedDate ;
            this.productName = productName ;
            this.transactionId = transactionId ;
            this.quantity = quantity ;
            this.category = category ;
            this.storeCode = storeCode ;
            this.status = status ;
            this.nameObject = nameObject;

        }
        
    }


}