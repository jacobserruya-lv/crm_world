global with sharing class BL_EMAIL_Config extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET {
    
    global Object executeGET(){
        Integer pageSize = getQueryParameter('limit') != null ? Integer.valueOf(getQueryParameter('limit')) : null;
        Integer pageIndex = getQueryParameter('offset') != null ? Integer.valueOf(getQueryParameter('offset')) : null;
        String features = (getQueryParameter('features') != null ? getQueryParameter('features') : null);
        String application = (getQueryParameter('application') != null ? getQueryParameter('application') : null);

        if (features == null)
            features = 'settings;senderAddresses;templateImages';

        return BL_EMAIL_Config_Helper.getConfigByFeatures(features, application);
    }
}