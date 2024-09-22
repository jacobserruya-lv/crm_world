public with sharing class ICX_CampaignCreationController {
    public virtual class CustomException extends Exception {}

    @AuraEnabled
    public static string createCampaign(String campaignName, String description,String startDate,String endDate,String country, String priority,String toolkitComment){
        try {
            Campaign__c newCampaign = new Campaign__c();
            newCampaign.Name = campaignName;
            newCampaign.Description__c = description;
            newCampaign.StartDate__c = Date.newInstance(Integer.valueOf(startDate.split('-')[0]), Integer.valueOf(startDate.split('-')[1]),Integer.valueOf( startDate.split('-')[2]));
            newCampaign.EndDate__c = Date.newInstance(Integer.valueOf(endDate.split('-')[0]), Integer.valueOf(endDate.split('-')[1]), Integer.valueOf(endDate.split('-')[2]));
            newCampaign.Country__c = country;
            newCampaign.Priority__c = priority;
            newCampaign.ToolkitComments__c = toolkitComment;
            newCampaign.Status__c='New';
            insert newCampaign;

            return newCampaign.Id;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<ContentDocumentLink> createCampaignContentDocumentLink(String campaignId,List<String> contentDocumentList){
        try {

            List<ContentDocumentLink> currentContentDocumentLinkList = new List<ContentDocumentLink>();
            for(String currentContentDocumentId : contentDocumentList)
            {
                ContentDocumentLink currentContentDocumentLink = new ContentDocumentLink();
                currentContentDocumentLink.ContentDocumentId = currentContentDocumentId;
                currentContentDocumentLink.LinkedEntityId = campaignId;
                currentContentDocumentLinkList.add(currentContentDocumentLink);
            }
            Database.insert(currentContentDocumentLinkList,true);

            return currentContentDocumentLinkList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static List<CampaignCatalogItem__c>  createCampaignCatalogItem(String campaignId,List<ProductCatalogue__c> productSKUList){
        try {
            String CampaignCatalogItemRT = Schema.SObjectType.CampaignCatalogItem__c.getRecordTypeInfosByName().get('Campaign Product').getRecordTypeId();

            List<CampaignCatalogItem__c> CampaignCatalogItemList = new List<CampaignCatalogItem__c>();
            for(ProductCatalogue__c currentProductSku : productSKUList)
            {
                CampaignCatalogItem__c currentCampaignCatalogItem = new CampaignCatalogItem__c();
                currentCampaignCatalogItem.CampaignProduct__c = currentProductSku.Id;
                currentCampaignCatalogItem.RecordTypeId = CampaignCatalogItemRT;
                currentCampaignCatalogItem.Campaign__c = campaignId;
                CampaignCatalogItemList.add(currentCampaignCatalogItem);
            }
            Database.insert(CampaignCatalogItemList,true);
            return CampaignCatalogItemList;
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
}