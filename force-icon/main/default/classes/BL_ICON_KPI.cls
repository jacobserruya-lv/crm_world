/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-03-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   05-12-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/
global with sharing class BL_ICON_KPI extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET{
    global Object executeGET(){
        List<Map<String, Object>> myTeamList = new List<Map<String, Object>>();
        String filter = (getQueryParameter('filters') != null ? getQueryParameter('filters') : null);
        List<String> caIds = (getQueryParameter('caIds') != null ? getQueryParameter('caIds').split(';') : new List<String>());
        String period = (getQueryParameter('period') != null ? getQueryParameter('period') : null);
        String storeId = (getQueryParameter('storeId') != null ? getQueryParameter('storeId') : null);
        Boolean myTeam = (getQueryParameter('myTeam') != null && getQueryParameter('myTeam') == 'true' ? true : false);  
        String features;
        List<String> listForUserMe = new List<String>();
      
        Boolean s;
        if(myTeam){
            myTeamList = (List<Map<String, Object>>)BL_ICON_Team.getTeamMembers(true,me);
            for(Map<String, Object> teamMember : myTeamList){
                caIds.add((String)teamMember.get('id'));
            }
        }
        if (isStandardRestApiRequired && BL_WS_Router.clientPlatform == 'WECHAT'){
            s = true;
        }
        else{
            s = false;
        }
        if(getQueryParameter('features') != null){
            features = getQueryParameter('features'); 
            if(String.isNotEmpty(filter) && caIds.size() > 0 && filter == 'teamMembers')
                return BL_ICON_KPI_Helper.getKPIByFeatures(caIds,period, storeId,features,pageSize,pageIndex,queryId,s);
            else{
                listForUserMe.add(me.basicInfos.id);
                return  BL_ICON_KPI_Helper.getKPIByFeatures(listForUserMe,period, storeId,features,pageSize,pageIndex,queryId,s);
            }
        }
        else{
            if(path == '/kpi/count'){
                if(String.isNotEmpty(filter) && caIds.size() > 0 && filter == 'teamMembers'){
                    return BL_ICON_KPI_Helper.GetCountFollowUpObject(caIds,period, storeId,pageSize,pageIndex);
                }
                else{

                    listForUserMe.add(me.basicInfos.id);
                    
                    return  BL_ICON_KPI_Helper.GetCountFollowUpObject(listForUserMe,period, storeId,pageSize,pageIndex);
                }
            }
            else{
                if(String.isNotEmpty(filter) && caIds.size() > 0 && filter == 'teamMembers'){

                    return BL_ICON_KPI_Helper.GetFollowUpObject(caIds,period, storeId,pageSize,pageIndex,queryId,s);
                }
                else{

                    listForUserMe.add(me.basicInfos.id);
                    return BL_ICON_KPI_Helper.GetFollowUpObject(listForUserMe,period, storeId,pageSize,pageIndex,queryId,s);
                } 
            }
        }
    }
}