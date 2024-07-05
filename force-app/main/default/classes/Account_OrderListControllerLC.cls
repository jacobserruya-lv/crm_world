public with sharing class Account_OrderListControllerLC {

    @AuraEnabled
    public static PagedResult getOrderLineList(Id accountId, Integer pageSize, Integer pageNumber) {
        System.debug('getOrderLineList accountId, pageSize, pageNumber=' + accountId + '-' + pageSize + '-' + pageNumber);
        Integer pSize = (Integer) pageSize;
        Integer offset = ((Integer) pageNumber - 1) * pSize;

        PagedResult r =  new PagedResult();
        r.pageSize = pSize;
        r.page = (Integer) pageNumber;

        r.total = [SELECT count() FROM OrderLine__c WHERE Order__r.Account__c = :accountId AND ( (OrderShipping__r.status__c='Fulfilled' AND  OrderShipping__r.StatusDate__c<= THIS_WEEK AND OrderShipping__r.StatusDate__c >=LAST_WEEK) OR OrderShipping__r.status__c!='Fulfilled')]; 
        r.orderLineList = [SELECT Quantity__c, SKU__c, Order__c, Order__r.OrderDate__c, Order__r.OrderNumber__c, Order__r.Store__r.ShortName__c, 
                           Order__r.Store__r.StoreType__c, Order__r.Store__r.RetailStoreId__c, Order__r.Source__c,
                           ProductReferential__r.SKUCode__c, ProductReferential__r.Name, ProductReferential__r.SPO_ImageLink1FrontView__c, 
                           tolabel(OrderShipping__r.Status__c), OrderShipping__r.StatusDate__c, tolabel(OrderShipping__r.DeliveryType__c)
                                  FROM OrderLine__c WHERE Order__r.Account__c = :accountId AND ((OrderShipping__r.status__c='Fulfilled' AND  OrderShipping__r.StatusDate__c<= THIS_WEEK AND OrderShipping__r.StatusDate__c >=LAST_WEEK) OR OrderShipping__r.status__c!='Fulfilled')
                                  ORDER BY Order__r.OrderDate__c DESC
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
        public List<OrderLine__c> orderLineList { get;set; }
        
    }
}