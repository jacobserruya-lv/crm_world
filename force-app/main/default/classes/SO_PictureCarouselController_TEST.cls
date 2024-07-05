@isTest
public class SO_PictureCarouselController_TEST {
    
    @isTest
    public static void testGetProductCarouselWidth(){
        ProductSettings__c settings = new ProductSettings__c(Name = 'Test', ProductCarouselWidth__c = 123);
        insert settings;

        Test.startTest();
        Integer result = SO_PictureCarouselController.getProductCarouselWidth();
        Test.stopTest();
        
        System.assertNotEquals(null, result);
        System.assertEquals(123, result, 'getProductCarouselWidth() did not return the expected value');
    }
}