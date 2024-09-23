public with sharing class GiftCatalogTriggerHandler {
    public static final String baseDefaultImageUrl = 'https://www.louisvuitton.com/images/is/image/lv/1/PP_VP_L/louisvuitton--';

    public static void handleTrigger(List<GiftCatalog__c> newList, Map<Id, GiftCatalog__c> newMap, List<GiftCatalog__c> oldList, Map<Id, GiftCatalog__c> oldMap, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when BEFORE_INSERT {
                handleBeforeInsert(newList);
            }
            when BEFORE_UPDATE {
                handleBeforeUpdate(newList, oldMap);
            }
            when else {
                //do nothing for AFTER_UNDELETE, BEFORE_DELETE, or BEFORE_UPDATE
            }
        }
    }

    public static void handleBeforeInsert(List<GiftCatalog__c> newList) {
        for (GiftCatalog__c c : newList) {
            if (String.isEmpty(c.GiftImageURL__c) && String.isNotEmpty(c.SKUGift__c)) {
                c.GiftImageURL__c = getImageUrlBySKU(c.SKUGift__c);
            }
        }
    }

    public static void handleBeforeUpdate(List<GiftCatalog__c> newList, Map<Id, GiftCatalog__c> oldMap) {
        for (GiftCatalog__c c : newList) {
            GiftCatalog__c oldCat = oldMap.get(c.Id);
            Boolean skuWasChanged = oldCat.SKUGift__c != c.SKUGift__c;
            Boolean urlIsEmpty = String.isEmpty(c.GiftImageURL__c);
            Boolean urlWasRemoved = urlIsEmpty && String.isNotEmpty(oldCat.GiftImageURL__c);
            Boolean urlWasNotAssigned = oldCat.GiftImageURL__c == c.GiftImageURL__c || urlWasRemoved;
            Boolean isEmptyOrDefaultUrl = urlIsEmpty || isDefaultUrl(c.GiftImageURL__c);
            
            if (urlWasNotAssigned && (
                    (skuWasChanged && isEmptyOrDefaultUrl) ||
                    (urlWasRemoved && String.isNotEmpty(c.SKUGift__c))
                )
            ) {
                c.GiftImageURL__c = getImageUrlBySKU(c.SKUGift__c);
            }
        }
    }

    private static String getImageUrlBySKU(String SKU) {
        return baseDefaultImageUrl + SKU + '_PM2_Front%20view.png';
    }

    private static Boolean isDefaultUrl(String url) {
        return url.startsWith(baseDefaultImageUrl);
    }
}