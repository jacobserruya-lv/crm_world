/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 03-08-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   03-07-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global with sharing class BL_ICON_Config extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET {
    
    global Object executeGET(){

        String features = (getQueryParameter('features') != null ? getQueryParameter('features') : null);
        if (features == null)
            return  new BL_WS_Response(BL_Config_Helper.getAllConfig(BL_AppSettings.currentApplicationName));
        else {
            return BL_Config_Helper.getConfigByFeatures(features, BL_AppSettings.currentApplicationName);
        }
    }
}