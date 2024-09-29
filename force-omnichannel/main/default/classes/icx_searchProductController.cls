public with sharing class icx_searchProductController {


    @AuraEnabled(cacheable=false)
    public static List<ProductCatalogue__c>  searchProduct(String searchKey){
        try {

            String searchKeyAPI = '%'+searchKey +'%';
            List<ProductCatalogue__c> listProductCatalog =  [SELECT ID,Name, SKU__c,Image1Url__c,SPO_Category__c FROM ProductCatalogue__c WHERE NAME LIKE: searchKeyAPI OR SKU__c LIKE: searchKeyAPI LIMIT 5];
            return listProductCatalog;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}