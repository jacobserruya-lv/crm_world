/** * File Name: PurchasedProductsComponentExtension_TEST
* Description : Test class for PurchasedProductsComponentExtension
* @author : RMOU
* Modification Log =============================================================== 
* 
* */
@isTest
public class PurchasedProductsComponentExtension_TEST {
    // Currency rotation test
	@isTest (seeAllData=true)
    public static void testEUR (){
        User u = [SELECT id FROM User WHERE IsActive=true AND Currency__c = 'USD' LIMIT 1];
        
        System.runAs(u){
                
            ID accId = [SELECT Id FROM Account LIMIT 1].id;
            ApexPages.currentPage().getParameters().put('id',accId);

            IC_ClientDetails_VFCx cd = new IC_ClientDetails_VFCx();
            PurchasedProductsComponentExtension extension = new PurchasedProductsComponentExtension(cd);
            
            // From USD
            System.assert(extension.isUSD);
            System.assert(!extension.isEUR);
            
            // To EUR
            extension.chooseEUR();
            System.assert(extension.isEUR);
            System.assert(!extension.isUSD);
            
            // To JPY
            extension.chooseJPY();
            System.assert(!extension.isEUR);
            System.assert(extension.isJPY);
            
            // To RMB
            extension.chooseRMB();
            System.assert(extension.isRMB);
            System.assert(!extension.isJPY);
            
            // To USD
            extension.chooseUSD();
            System.assert(extension.isUSD);
            System.assert(!extension.isRMB);
        }
    }
}