@isTest
public with sharing class ICX_CampaignNewProductController_TEST {
    @testSetup static void setup() {
        ProductCatalogue__c newProductCatalogue = new ProductCatalogue__c();
        newProductCatalogue.SKU__c='M1M1M1';
        newProductCatalogue.Workshop__c = '1798';
        insert newProductCatalogue;

    }
    @isTest
    public static void getProductCatalog_TEST()
    {
        
        Test.startTest();
        List<ProductCatalogue__c> productsId = ICX_CampaignNewProductController.getProductCatalog(new List<String>{'M1M1M1'});
        Test.stopTest();
        System.assertEquals(1,productsId.size());
    }

    @isTest
    public static void getProductCatalogFromFile_TEST()
    {
        string str = 'SKU\r\n' + 'M1M1M1\r\n';
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'product';
        contentVersion.PathOnClient = 'product.csv';
        contentVersion.VersionData = Blob.valueOf(str);
        contentVersion.IsMajorVersion = true;
        contentVersion.origin = 'H';
        insert contentVersion;


        Test.startTest();
        List<ProductCatalogue__c> productsId = ICX_CampaignNewProductController.getProductCatalogFromFile(contentVersion.Id);
        Test.stopTest();
        System.assertEquals(1,productsId.size());

    }
    
    
      @isTest
    public static void getProductCatalogFromFileERROR_TEST()
    {
        string str = 'M1M1M1\r\n';
        ContentVersion contentVersion = new ContentVersion();
        contentVersion.Title = 'product';
        contentVersion.PathOnClient = 'product.csv';
        contentVersion.VersionData = Blob.valueOf(str);
        contentVersion.IsMajorVersion = true;
        contentVersion.origin = 'H';
        insert contentVersion;


        Test.startTest();
         try
        {
        List<ProductCatalogue__c> productsId = ICX_CampaignNewProductController.getProductCatalogFromFile(contentVersion.Id);
        }
        catch(Exception e)
        {
            system.debug(e.getMessage());
        }
        Test.stopTest();

    }

   
}