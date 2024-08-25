global with sharing class BL_ICON_Retention extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET{

    global Object executeGET(){
        if(path == '/retention/store-ranking' ){ 
            system.debug('storecode:'+getQueryParameter('storeCode'));
            system.debug('storecode2:'+me.basicInfos.DefaultStore__c);
            String storeCode = getQueryParameter('storeCode') != null ? getQueryParameter('storeCode') :  me.basicInfos.DefaultStore__c;
            return  BL_ICON_Retention_Helper.getStoreRanking(me.basicInfos.Id, storeCode);
        }

        String filter = getQueryParameter('filter');
        String storeCode = getQueryParameter('storeCode');
        String lvmId = getQueryParameter('lvmid');
        String type = getQueryParameter('type');

        if((filter == 'store' && storeCode == null) || (filter == 'ca' && lvmId == null)){
            throw new BL_Exceptions.RouterException('Invalid Retention REST Method - Parameter is missing'); 
        }
        
        if(type == 'Dashboard'){
            return BL_ICON_Retention_Helper.getRetentionDashboard(filter, storeCode, lvmId);
        }
        else if (type == 'Pyramid'){
            return BL_ICON_Retention_Helper.getRetentionPyramid(filter, storeCode, lvmId);
        }
    return null;         
    }

}