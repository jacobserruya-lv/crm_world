public with sharing class BL_IWA_Config_Helper {

    static final string JSONRoot_StoreHierarchy        = 'storeHierarchy';
    static final string JSONRoot_SharingChannels        = 'sharingChannel';
    static final string JSONRoot_AssetCSVParams      = 'assetCsvParams';
    static final string JSONRoot_Locals        = 'locals';


    public static Map<String, Object> getConfigByFeatures(String features, String applicationName){
        Map<String, Object> result = new Map<String, Object>();
        List<String> featuresList = features.split(';');
        for(String f : featuresList){
            switch on f{
                when 'sharing-channels'{ 
                    result.put(JSONRoot_SharingChannels, BL_Config_Helper.getSharingChannels());
                } 
                when 'hierarchy'{ 
                    result.put(JSONRoot_StoreHierarchy, BL_Config_Helper.getStoreHierarchyDictionary());
                }
                when 'storeHierarchy'{ 
                    result.put(JSONRoot_StoreHierarchy, BL_Config_Helper.getStoreHierarchy());
                }
                when 'asset-csv-params'{ 
                    result.put(JSONRoot_AssetCSVParams, getAssetInfoSettings());
                }
                when 'locals' {
                    result.put(JSONRoot_Locals, BL_Config_Helper.getLocals());
                }
            }
        }

        return result;
    }


    public static Object getAssetInfoSettings(){    

        return new BL_EasyQuery()
        .useCase('Asset_CSV_Config')
        .executeQuery()
        .getMappedObjects();
    }
}