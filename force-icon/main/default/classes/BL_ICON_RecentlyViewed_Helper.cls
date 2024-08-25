/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-16-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   03-16-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
public with sharing class BL_ICON_RecentlyViewed_Helper {
    public static Object getRecentlyViewedClient() {
        String condition = '';
        Integer i = 0;
        List<Map<String,Object>> client = new    List<Map<String,Object>>();
        List<Map<String,Object>> recentlyViewed = (List<Map<String,Object>>)new BL_EasyQuery()
            .usecase(BL_ICON_Constants.USE_CASE_RECENTLY_VIEWED)
            .condition(' Type IN (\'Account\') AND (LastReferencedDate !=null OR LastViewedDate != null)')
            .orderBy('LastReferencedDate DESC, LastViewedDate DESC')
            .limitCount(5)
            .executeQuery()
            .getMappedObjects();

            if(recentlyViewed.size() > 0){
                condition = 'Id '+BL_ICON_Utils.buildMultiChoiceFilterFromObjectList(recentlyViewed,'id');
                client = (List<Map<String,Object>>) new BL_EasyQuery()
                .usecase(BL_ICON_Constants.USE_CASE_RECENTLY_VIEWED_CLIENT)
                .condition(condition)
                .orderBy('LastReferencedDate DESC, LastViewedDate DESC')
                .executeQuery()
                .getMappedObjects();
            } 
            return client;

    }


    public static Object getRecentlyViewedLookShare() {
        return new BL_EasyQuery()
        .usecase(BL_ICON_Constants.USE_CASE_RECENTLY_VIEWED)
        .condition(' Type IN (\'Look_Share__c\') AND (LastReferencedDate !=null OR LastViewedDate != null)')
        .orderBy('LastViewedDate ,LastReferencedDate DESC')
        .limitCount(5)
        .executeQuery()
        .getResponseMappedObjects()
        .get('records');
    }

    public static Object getRecentlyViewedPurchaseProduct() {
        return  new BL_EasyQuery()
        .usecase(BL_ICON_Constants.USE_CASE_RECENTLY_VIEWED)
        .condition(' Type IN (\'PPR_PurchProduct__c\') AND (LastReferencedDate !=null OR LastViewedDate != null)')
        .orderBy('LastViewedDate ,LastReferencedDate DESC')
        .limitCount(15)
        .executeQuery()
        .getResponseMappedObjects()
        .get('records');
    }

    public static Object getRecentlyViewedCareService() {
        return  new BL_EasyQuery()
        .usecase(BL_ICON_Constants.USE_CASE_RECENTLY_VIEWED)
        .condition(' Type IN (\'CareService__c\') AND (LastReferencedDate !=null OR LastViewedDate != null)')
        .orderBy('LastViewedDate ,LastReferencedDate DESC')
        .limitCount(5)
        .executeQuery()
        .getResponseMappedObjects()
        .get('records');
    }

    public static Object getRecentlyViewedEvents() {
        return  new BL_EasyQuery()
        .usecase(BL_ICON_Constants.USE_CASE_RECENTLY_VIEWED)
        .condition(' Type IN (\'Event\') AND (LastReferencedDate !=null OR LastViewedDate != null)')
        .orderBy('LastViewedDate ,LastReferencedDate DESC')
        .limitCount(5)
        .executeQuery()
        .getResponseMappedObjects()
        .get('records');
    }

    public static Object getRecentlyViewedAll() {
        return new BL_EasyQuery()
        .usecase(BL_ICON_Constants.USE_CASE_RECENTLY_VIEWED)
        .condition(' Type IN (\'Account\', \'Look_Share__c\', \'PPR_PurchProduct__c\', \'CareService__c\', \'Event\' ) AND (LastReferencedDate !=null OR LastViewedDate != null)')
        .orderBy('LastViewedDate ,LastReferencedDate DESC')
        .limitCount(5)
        .executeQuery()
        .getResponseMappedObjects()
        .get('records');
    }
}