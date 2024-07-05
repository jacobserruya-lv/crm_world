/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 07-06-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   07-06-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/

global with sharing class BL_ICON_EventTest  extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET{

    global Object executeGET(){
        
        Boolean withCategory = (queryParams.get('withCategory') != null ? Boolean.valueof(queryParams.get('withCategory')) : false);
        Boolean withMapping = (queryParams.get('withMapping') != null ? Boolean.valueof(queryParams.get('withMapping')) : false);
        if(withCategory == false){
                if(withMapping){
                    return new BL_WS_Response( new BL_EasyQuery()
                    .useCase(BL_ICON_Constants.USE_CASE_EVENT)
                    .pagination(null, 1000)
                    .executeQuery()
                    .getMappedObjects()); 
                }
                else{ 
                    return new BL_WS_Response( new BL_EasyQuery()
                    .useCase(BL_ICON_Constants.USE_CASE_EVENT)
                    .pagination(null, 1000)
                    .executeQuery()
                    .getSObjects()); 

                }
        }
        else{
            Map<String,Object> result = new Map<String,Object>();
            List<Map<String,Object>> eventList = new BL_EasyQuery()
            .useCase(BL_ICON_Constants.USE_CASE_EVENT)
            .pagination(null, 1000)
            .executeQuery()
            .getMappedObjects();

            List<String> teamIds = getTeam();

            List<Map<String,Object>> assignedToMe = new List<Map<String,Object>>();
            List<Map<String,Object>> notAssigned = new List<Map<String,Object>>();
            List<Map<String,Object>> myTeam = new List<Map<String,Object>>();
            for( Map<String,Object> item : eventList){
                Boolean inMyTeam = teamIds.contains((String)((Map<String,Object>)item.get('assignedTo')).get('id'));
                if(item.containsKey('assignedTo') && (String)((Map<String,Object>)item.get('assignedTo')).get('id') == me.basicInfos.Id && item.containsKey('status') && item.get('status') == 'Assigned'){
                    assignedToMe.add(item);
                }
                if(item.containsKey('status') && item.get('status') == 'Not Assigned'){
                    notAssigned.add(item);
                }
                if(item.containsKey('assignedTo') &&  inMyTeam == true && item.containsKey('status') && item.get('status') == 'Assigned'){
                    myTeam.add(item);
                }
            }
            result.put('not assigned', new BL_WS_Response(notAssigned));
            result.put('assigned to me', new BL_WS_Response(assignedToMe));
            result.put('myTeam', new BL_WS_Response(myTeam));
            result.put('stores', new BL_WS_Response(eventList));
            return result;
        }
    }


    public List<String> getTeam(){
        List<String> teamIds = new List<String>();
        List<Map<String, Object>> result = new BL_EasyQuery()
        .useCase(BL_ICON_Constants.USE_CASE_TEAM)
        .conditionValues( new Map<String, String> {'userId' => me.basicInfos.Id})
        .condition('DefaultStore__c = \'' + me.basicInfos.DefaultStore__c +  '\' AND DefaultStore__c != null AND DefaultStore__c != \'\' AND IsActive = true AND IsTechnicalUser__c = false AND (NOT Email LIKE \'store_%\')')
        .executeQuery()
        .getMappedObjects();

        for(Map<String, Object> item: result){
            if(item.containsKey('teamMembers'))
                teamIds.add((String)item.get('id'));
        }
        return teamIds;
    }
}