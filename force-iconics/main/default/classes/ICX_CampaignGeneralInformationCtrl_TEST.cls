@isTest
public class ICX_CampaignGeneralInformationCtrl_TEST {

    @TestSetup
    static void makeData(){
        Campaign__c newCampaign = ICX_TestFactory.createCampaign();
        insert newCampaign;
    
        ContentVersion contentVersion = ICX_TestFactory.createSingleContentVersion();
        insert contentVersion;

        ContentVersion currentContentVersion = [SELECT ID, ContentDocumentId FROM ContentVersion LIMIT 1];
        
        ContentDocumentLink currentContentLink = new ContentDocumentLink(
            ContentDocumentId = currentContentVersion.ContentDocumentId,
            LinkedEntityId = newCampaign.Id
        );
        insert currentContentLink;

        ProductCatalogue__c prodCatalog = ICX_TestFactory.createProductCatalogue('Alma', 'M41414');
        insert prodCatalog;
        ProductCatalogue__c prodCatalog2 = ICX_TestFactory.createProductCatalogue('Alma2', 'M41415');
        insert prodCatalog2;

        String CampaignCatalogItemRT = Schema.SObjectType.CampaignCatalogItem__c.getRecordTypeInfosByName().get('Campaign Product').getRecordTypeId();

        CampaignCatalogItem__c producSKU = new CampaignCatalogItem__c(
            Campaign__c = newCampaign.Id,
            CampaignProduct__c = prodCatalog.Id,
            RecordTypeId = CampaignCatalogItemRT
        );
        insert producSKU;
        CampaignCatalogItem__c producSKU2 = new CampaignCatalogItem__c(
            Campaign__c = newCampaign.Id,
            CampaignProduct__c = prodCatalog2.Id,
            RecordTypeId = CampaignCatalogItemRT
        );
        insert producSKU2;
    }


    @isTest 
    public static void getContentVersion_TEST() {

        Campaign__c currentCampaign = [SELECT id FROM Campaign__c LIMIT 1];

        ContentVersion currentContentVersion = [SELECT ID, ContentDocumentId FROM ContentVersion LIMIT 1];

        Test.startTest();
        List<ContentVersion> contentVersionList = ICX_CampaignGeneralInformationController.getContentVersion(new List<String>{currentContentVersion.ContentDocumentId});
        Test.stopTest();

    }

    @isTest
    public static void getProductSKUList_TEST() {
        String campaignId = [SELECT id FROM Campaign__c LIMIT 1].Id;
        Integer pageSize = 5; 
        Integer pageIndex = 0;
        Test.startTest();
        List<CampaignCatalogItem__c> productSKUList = ICX_CampaignGeneralInformationController.getProductSKUList(campaignId, pageSize, pageIndex);
        Test.stopTest();

    }

    @isTest 
    public static void updateCampaignCatalogItem_TEST() {
        String campaignId = [SELECT id FROM Campaign__c LIMIT 1].Id;

        ProductCatalogue__c prodCatalog = ICX_TestFactory.createProductCatalogue('Alma3', 'M41416');
        insert prodCatalog;

        List<ProductCatalogue__c> prodCatalogList = new List<ProductCatalogue__c>();
        prodCatalogList.add(prodCatalog);

        Test.startTest();
        ICX_CampaignGeneralInformationController.updateCampaignCatalogItem(campaignId,prodCatalogList);
        Test.stopTest();
    }

}