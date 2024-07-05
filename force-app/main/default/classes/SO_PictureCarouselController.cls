global with sharing class SO_PictureCarouselController {

    // Custom Settings ProductSettings to get different picture size
    @AuraEnabled
    public static Integer getProductCarouselWidth() {
        return (Integer) ProductSettings__c.getInstance().ProductCarouselWidth__c;
    }
}