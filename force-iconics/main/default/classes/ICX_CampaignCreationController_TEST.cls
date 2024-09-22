@isTest
public with sharing class ICX_CampaignCreationController_TEST {
    @testSetup static void setup() {
        ProductCatalogue__c newProductCatalogue = new ProductCatalogue__c();
        newProductCatalogue.SKU__c='M1M1M1';
        newProductCatalogue.Workshop__c = '1798';
        insert newProductCatalogue;

        Campaign__c newCampaign = new Campaign__c();
        newCampaign.Name = 'TEST SETUP';
        newCampaign.Description__c = 'description TEST';
        newCampaign.StartDate__c = Date.newInstance(2024,05,06);
        newCampaign.EndDate__c = Date.newInstance(2024,07,08);
        newCampaign.Country__c = 'FRA';
        newCampaign.Priority__c = '1';
        newCampaign.ToolkitComments__c = 'toolkitComment';
        newCampaign.Status__c='New';
        insert newCampaign;

        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'Penguins';
        contentVersion.PathOnClient = 'Penguins.jpg';
        contentVersion.VersionData = Blob.valueOf('Test Content');
        contentVersion.IsMajorVersion = true;
        contentVersion.origin = 'H';
        insert contentVersion;

    }

    @isTest
    public static void createCampaign_TEST()
    {
        Test.startTest();
        String campaignId = ICX_CampaignCreationController.createCampaign('TEST','description test','2024-06-05','2024-08-07','FRA','1','toolkit comment');
        Test.stopTest();
        System.assertNotEquals(null,campaignId);

    }

    @isTest
    public static void createCampaignContentDocumentLink_TEST()
    {
        
        ContentVersion contentVersion = [SELECT Id,ContentDocumentId FROM ContentVersion WHERE Title=:'Penguins' LIMIT 1];

        Campaign__c currentCampaign = [SELECT Id FROM Campaign__c WHERE Name=:'TEST SETUP' LIMIT 1];
        Test.startTest();
        List<ContentDocumentLink> ContentDocumentLinkList = ICX_CampaignCreationController.createCampaignContentDocumentLink(currentCampaign.Id, new List<String>{contentVersion.ContentDocumentId});
        Test.stopTest();
        System.assertEquals(1,ContentDocumentLinkList.size());

    }

    @isTest
    public static void createCampaignCatalogItem_TEST()
    {

        Campaign__c currentCampaign = [SELECT Id FROM Campaign__c WHERE Name=:'TEST SETUP' LIMIT 1];
        ProductCatalogue__c currentProductCatalog = [SELECT Id FROM ProductCatalogue__c WHERE SKU__c=:'M1M1M1' LIMIT 1];
        Test.startTest();
        List<CampaignCatalogItem__c> CampaignCatalogItemList = ICX_CampaignCreationController.createCampaignCatalogItem(currentCampaign.Id, new List<ProductCatalogue__c>{currentProductCatalog});
        Test.stopTest();
        System.assertEquals(1,CampaignCatalogItemList.size());

    }
}