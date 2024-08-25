global with sharing class BL_ICON_ClientList  extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET,BL_WS_Interfaces.DispatchablePOST,BL_WS_Interfaces.DispatchableDELETE,BL_WS_Interfaces.DispatchablePUT{ 
    global Object executeGET(){
        List<Map<String, Object>> myTeamList = new List<Map<String, Object>>();
        List<String> caIdsList = new List<String>();
        List<String> employeNumbersList = new List<String>();
        String features; 
        String caIds = '';
        String employeNumbers = '';
        
        String clientListId = (getPathParameter('id') != null ? (String)getPathParameter('id') : null);
        String storeCode = (getQueryParameter('storeCode') != null ? getQueryParameter('storeCode') : null);
        Integer tab = (getQueryParameter('tab') != null ? Integer.valueOf(getQueryParameter('tab')) : null);
        String filter = (this.queryParams.get('filter') != null ? this.queryParams.get('filter') : null);
        String param10k = (getQueryParameter('param10k') != null ? getQueryParameter('param10k') : null);
        String paramRank10k = (getQueryParameter('paramRank10k') != null ? getQueryParameter('paramRank10k') : null);
        String filterDecode = (filter != null? EncodingUtil.urlDecode(filter,'UTF-8'):null);
        String sortBy = (getQueryParameter('sortBy') != null ? getQueryParameter('sortBy') : null);
        Boolean myTeam = (getQueryParameter('myTeam') != null && getQueryParameter('myTeam') == 'true' ? true : false);
        Integer purchasesYear = (getQueryParameter('purchasesYear') != null ? Integer.valueOf(getQueryParameter('purchasesYear')) : null);
        String retentionType = (getQueryParameter('retentionType') != null ? getQueryParameter('retentionType') : null);

        caIdsList = (getQueryParameter('caIds') != null ? (getQueryParameter('caIds')).split(';') : caIdsList);
        if(getQueryParameter('employeNumbers') != null && getQueryParameter('employeNumbers') != '') {
          employeNumbersList = (getQueryParameter('employeNumbers')).split(';');
        } 
        if(myTeam == true){
            myTeamList = (List<Map<String, Object>>)BL_ICON_Team.getTeamMembers(true,me);
            for(Map<String, Object> teamMember : myTeamList){
                caIdsList.add((String) teamMember.get('id'));
                employeNumbersList.add((String) teamMember.get('wwEmployeeNumber'));
            }
        }
        if(retentionType == 'potential' && sortBy == null){
            sortBy = 'PropensityScore__pc DESC NULLS LAST';
        }
        if(getQueryParameter('features') != null){
            features = getQueryParameter('features'); 
        }
        if(caIdsList != null && !caIdsList.isEmpty()){
             caIds = '\'' + String.join((caIdsList), '\',\'') + '\'';
        }
        if(employeNumbersList != null && !employeNumbersList.isEmpty()){
             employeNumbers = '\'' + String.join((employeNumbersList), '\',\'') + '\'';
        }
        if(clientListId == null && features == null){
            return BL_ICON_ClientList_Helper.getAll();
        } 
        if(clientListId == null && features != null){
            return BL_ICON_ClientList_Helper.getClientListByFeatures(features);
        }
        else {
                switch on resource {
                    when  'members'{
                        if(clientListId.startsWith('m0')){
                            return new BL_WS_Response(BL_ICON_ClientList_Helper.getPermanentListClients(clientListId, pageIndex,pageSize,caIds,storeCode,filterDecode,tab,sortBy,employeNumbersList,param10k,paramRank10k, queryId, isStandardRestApiRequired,purchasesYear,retentionType, null)); 
                        }
                        else{
                            return new BL_WS_Response(BL_ICON_ClientList_Helper.getCutomListClients(clientListId,pageIndex,pageSize,queryId,isStandardRestApiRequired,storeCode,caIds));
                        }
                    }
                    when 'count'{
                        return BL_ICON_ClientList_Helper.getCountOfListClient(clientListId,pageIndex,pageSize,caIds,storeCode,filterDecode,tab,sortBy,employeNumbersList,retentionType);     
                    }
                    when else{
                        return BL_ICON_ClientList_Helper.getSpecificClientListMapped(clientListId);     
                    } 
                }
            }
    }
    global Object executePOST() {
        Object record = getRequestRecord();
        Object res;
        String clientListId = (getPathParameter('id') != null ? getPathParameter('id') : null);
        //////END WECHAT / WECOME NEW FILTER IMPLEMENTATION //////
        Map<String, Object> body  = (Map<String, Object>) record;

        if((BL_WS_Router.clientPlatform == 'WECHAT' ||Test.isRunningTest()) && clientListId != null && body.get('filter') != null) {
            String filterDecode = EncodingUtil.urlDecode((string)body.get('filter'),'UTF-8');
            string wecomeFriendList = (string)body.get('myFriends');
            List<Map<String, Object>> myTeamList = new List<Map<String, Object>>();
            List<String> caIdsList = new List<String>();
            List<String> employeNumbersList = new List<String>();
            // String features; 
            String caIds = '';
            String employeNumbers = '';
            String storeCode = (body.get('storeCode') != null ? (string)body.get('storeCode') : null);
            Integer tab = (body.get('tab') != null ? Integer.valueOf(body.get('tab')) : null);
            String param10k = (body.get('param10k') != null ? (string)body.get('param10k') : null);
            String paramRank10k = (body.get('paramRank10k') != null ? (string)body.get('paramRank10k') : null);
            String sortBy = (body.get('sortBy') != null ? (string)body.get('sortBy') : null);
            Boolean myTeam = (body.get('myTeam') != null ? (Boolean)body.get('myTeam') : false);
            Integer purchasesYear = (body.get('purchasesYear') != null ? Integer.valueOf(body.get('purchasesYear')) : null);
            String retentionType = (body.get('retentionType') != null ? (string)body.get('retentionType') : null);

            caIdsList = (body.get('caIds') != null ? ((string)body.get('caIds')).split(';') : caIdsList);
            if(body.get('employeNumbers') != null && body.get('employeNumbers') != '') {
            employeNumbersList = ((string)body.get('employeNumbers')).split(';');
            } 
            if(myTeam == true){
                myTeamList = (List<Map<String, Object>>)BL_ICON_Team.getTeamMembers(true,me);
                for(Map<String, Object> teamMember : myTeamList){
                    caIdsList.add((String) teamMember.get('id'));
                    employeNumbersList.add((String) teamMember.get('wwEmployeeNumber'));
                }
            }
            
            // if(getQueryParameter('features') != null){
            //     features = getQueryParameter('features'); 
            // }
            if(caIdsList != null && !caIdsList.isEmpty()){
                caIds = '\'' + String.join((caIdsList), '\',\'') + '\'';
            }
            if(employeNumbersList != null && !employeNumbersList.isEmpty()){
                employeNumbers = '\'' + String.join((employeNumbersList), '\',\'') + '\'';
            }
            return new BL_WS_Response(BL_ICON_ClientList_Helper.getPermanentListClients(clientListId, pageIndex,pageSize,caIds,storeCode,filterDecode,tab,sortBy,employeNumbersList,param10k,paramRank10k, queryId, isStandardRestApiRequired,purchasesYear,retentionType,wecomeFriendList)); 
        }
        
        //////END WECHAT / WECOME NEW FILTER IMPLEMENTATION //////
        else if(clientListId != null){ 
           ((Map<String,Object>)record).put('id', clientListId);
            res =  BL_ICON_ClientList_Helper.addClientListMembers(record);
        }
        else {
        	res =  BL_ICON_ClientList_Helper.createClientList(record);
        }
        return new BL_WS_Response(res);
    }
      global Object executePUT() {
        Object record = getRequestRecord();
        String clientListId = (getPathParameter('id') != null ? getPathParameter('id') : null);
        return new BL_WS_Response(BL_ICON_ClientList_Helper.updateClientList(clientListId, record));
    }
    global Object executeDelete() {
        String clientListId = (getPathParameter('id') != null ? getPathParameter('id') : null);
        return new BL_WS_Response(BL_ICON_ClientList_Helper.deleteClientList(clientListId));
    }
    
}