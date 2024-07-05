public class PurchasedProductControllerLC {

    @AuraEnabled
    public static PagedResult getPurchasedProductList(Id accountId, Decimal pageSize, Decimal pageNumber) {

        Integer pSize = (Integer)pageSize;
        Integer offset = ((Integer)pageNumber - 1) * pSize;

        PagedResult r =  new PagedResult();
        r.pageSize = pSize;
        r.page = (Integer) pageNumber;

        r.total = [SELECT count() FROM PPR_PurchProduct__c WHERE Client__c = :accountId]; 
		r.purchasedProductList = [SELECT id, PurchasedDate__c, Name, SKU__c, ProductLine__c, Quantity__c, Amount__c, CurrencyCode__c, PurchaseCountry__c, Store__c, Image_Url__c 
                                  FROM PPR_PurchProduct__c WHERE Client__c = :accountId 
                                  ORDER BY PurchasedDate__c DESC
                                  LIMIT :pSize OFFSET :offset];
    
    	return r;
    }

    public class PagedResult {
        
        @AuraEnabled
        public Integer pageSize { get;set; }
        
        @AuraEnabled
        public Integer page { get;set; }
        
        @AuraEnabled
        public Integer total { get;set; }
        
        @AuraEnabled
        public List<PPR_PurchProduct__c> purchasedProductList { get;set; }
        
    }

}