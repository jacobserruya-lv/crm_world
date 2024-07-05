public with sharing class LookTriggerHandler {
       // avoid the recursion https://help.salesforce.com/articleView?id=000133752
	private static boolean run = true;

    //===================================================//
    // Here go the handler methods
    public static boolean runOnce() {
        System.debug('runOnce=' + run);
        if (run) {
            run = false;
            return true;
        } else {
            return run;
        }
    }

    public static Map<String, WRDB_Locale__mdt> getLocalesMap(){
        List<WRDB_Locale__mdt> localeSettings = [SELECT LV_COM_Locale__c, DeveloperName, Page_Name__c,DispatchCountry__c FROM WRDB_Locale__mdt];
        Map<String, WRDB_Locale__mdt> localesMap = new  Map<String, WRDB_Locale__mdt>();
        for (WRDB_Locale__mdt localeSetting : localeSettings){
            localesMap.put(localeSetting.DeveloperName, localeSetting);
        }
        return localesMap;
    }

    public static void beforeInsert(List<Look__c> newLookList, Map<id, Look__c> newLookMap) {
        Map<String, WRDB_Locale__mdt> localesMap = getLocalesMap();
        Long refDateTime = DateTime.now().getTime();
         for(Look__c lookRecord : newLookList){
            lookRecord.TECH_LV_LOCALE__c = localesMap.get(lookRecord.Locale__c) != null ? localesMap.get(lookRecord.Locale__c).LV_COM_Locale__c : localesMap.get('en_E1').LV_COM_Locale__c;
            lookRecord.TECH_LV_PAGE_NAME__c = localesMap.get(lookRecord.Locale__c) != null ? localesMap.get(lookRecord.Locale__c).Page_Name__c : localesMap.get('en_E1').Page_Name__c;
            lookRecord.TECH_LV_DISPATCH_COUNTRY__c = localesMap.get(lookRecord.Locale__c) != null ? localesMap.get(lookRecord.Locale__c).DispatchCountry__c : null;
            Integer skusCount = lookRecord.SKUs__c.split(';').size();
            lookRecord.layoutId__c = String.isEmpty(lookRecord.LayoutId__c) ?  skusCount + '_0' : lookRecord.layoutId__c;

            lookRecord.Reference_Id__c = String.isEmpty(lookRecord.Reference_Id__c)  ?
            lookRecord.OwnerId + lookRecord.skus__c + refDateTime :
            lookRecord.Reference_Id__c;
         }
    }

    public static void beforeUpdate(List<Look__c> newLookList, Map<id, Look__c> newLookMap,
        List<Look__c> oldLookList, Map<id, Look__c> oldLookMap) {
        List<Look__c> toSetPicture = new List<Look__c>();
        Map<String, WRDB_Locale__mdt> localesMap = getLocalesMap();
        Long refDateTime = DateTime.now().getTime();
        for(Look__c lookRecord : newLookList){
            lookRecord.TECH_LV_LOCALE__c = localesMap.get(lookRecord.Locale__c) != null ? localesMap.get(lookRecord.Locale__c).LV_COM_Locale__c : localesMap.get('en_E1').LV_COM_Locale__c;
            lookRecord.TECH_LV_PAGE_NAME__c = localesMap.get(lookRecord.Locale__c) != null ? localesMap.get(lookRecord.Locale__c).Page_Name__c : localesMap.get('en_E1').Page_Name__c;
            lookRecord.TECH_LV_DISPATCH_COUNTRY__c = localesMap.get(lookRecord.Locale__c) != null ? localesMap.get(lookRecord.Locale__c).DispatchCountry__c : null;
            if(lookRecord.MasterSKU__c != oldLookMap.get(lookRecord.Id).MasterSKU__c ||
            lookRecord.SKUs__c != oldLookMap.get(lookRecord.Id).SKUs__c){
                Integer skusCount = lookRecord.SKUs__c.split(';').size();
                lookRecord.layoutId__c = String.isEmpty(lookRecord.LayoutId__c) ?  skusCount + '_0' : lookRecord.layoutId__c;
            }

            lookRecord.Reference_Id__c = String.isEmpty(lookRecord.Reference_Id__c)  ?
            lookRecord.OwnerId + lookRecord.skus__c + refDateTime :
            lookRecord.Reference_Id__c;
        }
    }
    
    public static void afterUpdate(List<Look__c> newLookList, Map<id, Look__c> newLookMap,
     List<Look__c> oldLookList, Map<id, Look__c> oldLookMap)
    {
        // if was executed during the same context / avoid recursion
        // if(runOnce()) {

        //     for(Look__c lookRecord : newLookList){}
        // }
    }

    public static void afterInsert(List<Look__c> newLookList, Map<id, Look__c> newLookMap) {

            // for(Look__c lookRecord : newLookList){
            // }
    }

    // static void setPictureUrl(List<Look__c> newLookList){
    //     Map<String, String> productsMap = new Map<String, String>();
    //     for(Look__c lookRecord : newLookList){
    //         for(String sku : lookRecord.SKUs__c.split(';')){
    //             productsMap.put(sku,'');
    //         }
    //     }

    //     List<ProductCatalogue__c> prList = [Select Id,sku__c, Tech_Wardrobing_ImageUrl__c from ProductCatalogue__c
    //      where Sku__c IN :productsMap.keySet()];
    //     for(ProductCatalogue__c prd : prList){
    //         if (prd.Tech_Wardrobing_ImageUrl__c != null){
    //             productsMap.put(prd.SKU__c, prd.Tech_Wardrobing_ImageUrl__c.substringBetween('louisvuitton--', '.jpg'));
    //         }
    //     }

    //     List<WRDB_Layout__mdt> layoutSettings = [Select Image_Path__c,DeveloperName, Number_of_Items__c, Variation__c 
    //     FROM WRDB_Layout__mdt WHERE Is_Active__c = TRUE ORDER BY Number_of_Items__c, Variation__c];

    //     Map<String, WRDB_Layout__mdt> layoutsMapSetting = new Map<String, WRDB_Layout__mdt>();

    //     for (WRDB_Layout__mdt layout : layoutSettings){
    //         layoutsMapSetting.put(layout.DeveloperName, layout);
    //     }

    //     system.debug(layoutsMapSetting);

    //     for(Look__c lookRecord : newLookList){
    //         List<String> fillers = new List<String>();
                
    //         for(String sku : lookRecord.SKUs__c.split(';')){
    //             if (productsMap.get(sku) != null){ fillers.add(productsMap.get(sku)); }
                    
    //         }
    //         lookRecord.layoutId__c = String.isEmpty(lookRecord.LayoutId__c) ?  fillers.size() + '_0' : lookRecord.layoutId__c;
    //         // String placeholderWeb = getPlaceholder(lookRecord.layoutId__c, layoutsMapSetting, 1200);
    //         // lookRecord.Picture_URL__c = String.format(placeholderWeb, fillers);

    //         // String placeholderMobile = getPlaceholder(lookRecord.layoutId__c, layoutsMapSetting, 300);
    //         // lookRecord.Picture_URL_Mobile__c = String.format(placeholderMobile, fillers);
    //     }
    // }

    // static String getPlaceholder(String layoutId, Map<String, WRDB_Layout__mdt> layoutsMapSetting, Integer size){
    //     String urlHost = 'https://mosaic-prp.louisvuitton.com/composition/';
    //     system.debug('X' + layoutId);
    //     String path = 
    //     layoutsMapSetting.get('X' + layoutId).Image_Path__c
    //     .replaceAll('\\{\\!size\\}',String.valueOf(size))
    //     .replaceAll('\\{\\!size/2\\}',String.valueOf(size/2))
    //     .replaceAll('\\{\\!size1/3\\}',String.valueOf(size/3))
    //     .replaceAll('\\{\\!size2/3\\}',String.valueOf(size*2/3));

    //     return urlHost + path;
    // }
    
}