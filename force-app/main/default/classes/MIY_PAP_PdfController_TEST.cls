@isTest
public with sharing class MIY_PAP_PdfController_TEST {
    @testSetup
    static void testSetup(){
        Opportunity opp = new Opportunity(
            Name = 'opp',
            StageName = 'Creation in progress',
            CloseDate = Date.today()
        );
        insert opp;

        ProductCatalogue__c productCatalogue = new ProductCatalogue__c(SKU__c = '123', Workshop__c = '1798');
        insert productCatalogue;
    }

    @isTest
    static void test_getBody_1(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'opp'];
        ProductCatalogue__c productCatalogue = [SELECT Id FROM ProductCatalogue__c WHERE Workshop__c = '1798'];
        
        SPO_FirmOrder__c firmOrder = new SPO_FirmOrder__c(
            Name = 'firmOrder',
		    SPO_BriefName__c = opp.Id,
		    LineNumber__c = 1,
		    SPO_TechETLStatus__c = 'V',
		    SPO_FirmOrderStatus__c = 'Creation in progress',
            ProductCatalogue__c = productCatalogue.Id
        );
        insert firmOrder;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MIY_PAP_PdfController_MOCK('200'));

        MIY_PAP_PdfController pdfController = new MIY_PAP_PdfController();
        PageReference pageRef1 = Page.MIY_PAP_Pdf;
        Test.setCurrentPage(pageRef1);

        ApexPages.currentPage().getParameters().put('Id', firmOrder.Id);
        PageReference pageRef2 = pdfController.getBody();
        System.assertEquals(pageRef2.getUrl().startsWith('/sfc/servlet.shepherd/document/download/'), true);

        Test.stopTest();
    }

    @isTest
    static void test_getBody_2(){
        Opportunity opp = [SELECT Id FROM Opportunity WHERE Name = 'opp'];
        ProductCatalogue__c productCatalogue = [SELECT Id FROM ProductCatalogue__c WHERE Workshop__c = '1798'];
        
        SPO_FirmOrder__c firmOrder = new SPO_FirmOrder__c(
            Name = 'firmOrder',
		    SPO_BriefName__c = opp.Id,
		    LineNumber__c = 1,
		    SPO_TechETLStatus__c = 'V',
		    SPO_FirmOrderStatus__c = 'Creation in progress',
            ProductCatalogue__c = productCatalogue.Id
        );
        insert firmOrder;

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MIY_PAP_PdfController_MOCK('201'));

        MIY_PAP_PdfController pdfController = new MIY_PAP_PdfController();
        PageReference pageRef1 = Page.MIY_PAP_Pdf;
        Test.setCurrentPage(pageRef1);

        ApexPages.currentPage().getParameters().put('Id', firmOrder.Id);
        PageReference pageRef2 = pdfController.getBody();
        System.assertEquals(pageRef2, pageRef1);

        Test.stopTest();
    }
}