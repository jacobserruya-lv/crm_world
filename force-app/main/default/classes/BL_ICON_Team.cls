global with sharing class BL_ICON_Team  extends BL_WS_Request implements BL_WS_Interfaces.DispatchableGET{

    global Object executeGET(){
        Boolean myTeam = false;
        if(getQueryParameter('myTeam') != null){
            myTeam = true; 
        }
		return new BL_WS_Response(getTeamMembers(myTeam,me));   
    }
    public static Object getTeamMembers(Boolean myTeam,BL_UserInfo me) { 
         if(myTeam) {
            List<Map<String, Object>> result = new BL_EasyQuery()
                                            .useCase(BL_ICON_Constants.USE_CASE_TEAM)
                                            .conditionValues( new Map<String, String> {'userId' => me.basicInfos.Id})
                                            .condition(
                                                'DefaultStore__c = \'' + me.basicInfos.DefaultStore__c +  '\' AND DefaultStore__c != null AND DefaultStore__c != \'\' AND IsActive = true AND IsTechnicalUser__c = false AND (NOT Email LIKE \'store_%\') ' + 
                                                'AND ID IN (Select User__c From TeamMember__c Where Manager__c = \'{userId}\' )')
                                            .orderBy('FirstName ASC,Lastname ASC')
                                            .executeQuery()
                                            .getMappedObjects();
            return result;
        } else {
            List<Map<String, Object>> result = new BL_EasyQuery()
                                            .useCase(BL_ICON_Constants.USE_CASE_TEAM)
                                            .conditionValues( new Map<String, String> {'userId' => me.basicInfos.Id})
                                            .condition('DefaultStore__c = \'' + me.basicInfos.DefaultStore__c +  '\' AND DefaultStore__c != null AND DefaultStore__c != \'\' AND IsActive = true AND IsTechnicalUser__c = false AND (NOT Email LIKE \'store_%\')')
                                            .orderBy('FirstName ASC,Lastname ASC')
                                            .executeQuery()
                                            .getMappedObjects();

            return result;
        }
    }
}