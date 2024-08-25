@isTest
public class PDFPageControllerTest {
    
    @isTest
    public static void test_PDFPageController(){

        Test.startTest();
        
        Account acc = IC_TestFactory.createAccount();
        Insert acc;
        
         ProductCatalogue__c productCatalogue = new ProductCatalogue__c(sku__c='123');
				insert productCatalogue;
        
        ProductReferential__c product = new ProductReferential__c(SKUCode__c='123',
                                                                  name='product');
        insert product;
        
        SPO_Colors__c color = new SPO_Colors__c(Name='TestCouleur');
        insert color;
        
        
        Opportunity opp = new Opportunity(Name='OppTest',AccountId=acc.Id, 
                            SPO_SizeUnit__c='Cm',
                            SPO_Patch__c='Ptach',
                            SPO_ExteriorMaterial1__c='TestCouleur',
                            SPO_ExteriorMaterialColor1__c='TestCouleur',
                            SPO_ExteriorMaterial2__c='TestCouleur',
                            SPO_ExteriorMaterialColor2__c='TestCouleur',
                            SPO_ExteriorMaterial3__c='TestCouleur',
                            SPO_ExteriorMaterialColor3__c='TestCouleur',
                            SPO_LiningInteriorMaterial1__c='TestCouleur',
                            SPO_LiningInteriorColor1__c='TestCouleur',
                            SPO_LiningInteriorMaterial2__c='TestCouleur',
                            SPO_LiningInteriorColor2__c='TestCouleur',
                            SPO_BaseSKURefmodelSKU__c=product.Id,
                                         stageName='okok',
                                         closeDate= date.newInstance(2017, 1, 30));
        Insert opp;
        
       ApexPages.CurrentPage().getParameters().put('id',opp.id);
       Apexpages.StandardController sc = new Apexpages.StandardController(opp);
       PDFPageController ext = new PDFPageController(sc);
       System.assertNotEquals(null, ext);
       Test.stopTest();
    }

}