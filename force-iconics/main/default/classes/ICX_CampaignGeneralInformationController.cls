public with sharing class ICX_CampaignGeneralInformationController {

    @AuraEnabled
    public static List<ContentVersion> getContentVersion(List<String> ContentDocumentId){
        try {

            List<ContentVersion> contentVersionList = [SELECT Id, VersionData, FileType, Title, FileExtension,
            ContentDocument.CreatedBy.Name, ContentDocument.ContentSize,
            CreatedDate, ContentDocumentId, ContentDocument.FileType
            FROM   ContentVersion 
            WHERE  ContentDocumentId IN : ContentDocumentId];
            return contentVersionList;

        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled (cacheable=true)
    public static List<CampaignCatalogItem__c> getProductSKUList(String campaignId, Integer pageSize, Integer pageIndex){
        system.debug('getProductSKUList : ' +campaignId);
        try {

            return [SELECT ID,SKU__c,CampaignProduct__r.Id,CampaignProduct__r.Name FROM CampaignCatalogItem__c WHERE Campaign__c=:campaignId  LIMIT:pageSize OFFSET:pageIndex];
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<CampaignCatalogItem__c>  updateCampaignCatalogItem(String campaignId,List<ProductCatalogue__c> productSKUList){
        try {
            String CampaignCatalogItemRT = Schema.SObjectType.CampaignCatalogItem__c.getRecordTypeInfosByName().get('Campaign Product').getRecordTypeId();
            Set<Id> skuList = new Set<Id>();                                                                                        
            for (CampaignCatalogItem__c product : [SELECT ID, sku__c, CampaignProduct__c, Campaign__c FROM CampaignCatalogItem__c WHERE Campaign__c =: campaignId]) {
                skuList.add(product.CampaignProduct__c);
            }                                                                
     
            List<CampaignCatalogItem__c> productsToInsert = new List<CampaignCatalogItem__c>();
            for(ProductCatalogue__c currentProductSku : productSKUList)
            {
                 if(!skuList.contains(currentProductSku.Id)){//to check which field need to be ???
                    CampaignCatalogItem__c currentCampaignCatalogItem = new CampaignCatalogItem__c();
                    currentCampaignCatalogItem.CampaignProduct__c = currentProductSku.Id;
                    currentCampaignCatalogItem.RecordTypeId = CampaignCatalogItemRT;
                    currentCampaignCatalogItem.Campaign__c = campaignId;
                    productsToInsert.add(currentCampaignCatalogItem);
                }
                
            }
            Database.insert(productsToInsert, true);
            return productsToInsert;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}