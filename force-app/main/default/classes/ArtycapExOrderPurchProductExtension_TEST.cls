@isTest
public class ArtycapExOrderPurchProductExtension_TEST {
    // Currency rotation test
	@isTest (seeAllData=true)
    public static void testEUR (){
        User u = [SELECT id FROM User WHERE IsActive=true AND Currency__c = 'USD' LIMIT 1];
        
        System.runAs(u){
                
            ID orderId = [SELECT Id FROM Exclusive_Campaign_Order__c LIMIT 1].id;
            ApexPages.currentPage().getParameters().put('id',orderId);

            Artycap_ExOrder_ClientDetails_VFC cd = new Artycap_ExOrder_ClientDetails_VFC();
            ArtycapExOrderPurchasedProductsExtension extension = new ArtycapExOrderPurchasedProductsExtension(cd);
            
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