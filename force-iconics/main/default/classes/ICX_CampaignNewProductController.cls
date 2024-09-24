public with sharing class ICX_CampaignNewProductController {
    public virtual class CustomException extends Exception {}


    @AuraEnabled
    public static List<ProductCatalogue__c>  getProductCatalog(List<String> skuList){
            List<ProductCatalogue__c> productsId = [SELECT Id,SKU__c FROM ProductCatalogue__c  WHERE SKU__c IN: skuList];

            system.debug('nao productsId '+ productsId);
            return productsId;
           
    }

    @AuraEnabled
    public static List<ProductCatalogue__c>  getProductCatalogFromFile(String ContentVersionId){
        try {
            ContentVersion currentContentVersion = [SELECT Id,VersionData  FROM ContentVersion WHERE Id=:ContentVersionId];
            if(currentContentVersion!=null)
            {
                system.debug('nao currentContentVersion.VersionData.toString()'+ currentContentVersion.VersionData.toString());
                List<String> rowsData = (List<String>) currentContentVersion.VersionData.toString().split('\r\n');
                system.debug(' rowsData '+ rowsData);
                if(!rowsData[0].contains('SKU'))
                {
                    system.debug(' Wrong data format ');

                    throw new CustomException('Wrong data format, the first line should be "SKU"');

                }
                rowsData.remove(0);
                system.debug(' rowsData after remove '+ rowsData);
                return getProductCatalog(rowsData);
            }
            return null;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
  
}