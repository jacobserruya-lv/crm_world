global with sharing class BL_IWA_Config extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET {
    
    global Object executeGET(){

        String features = (getQueryParameter('features') != null ? getQueryParameter('features') : null);
        if (features == null)
            features = 'sharing-channels;storeHierarchy;locals';

        return BL_Config_Helper.getConfigByFeatures(features, BL_AppSettings.currentApplicationName);
    }
}