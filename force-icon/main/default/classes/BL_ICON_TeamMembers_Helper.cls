global class BL_ICON_TeamMembers_Helper {
    public static List<Object> setTeamMembers(Map<String,Object>body) { 
        List<TeamMember__c> tmToUpsert = new List<TeamMember__c>();
        List<String> teamIds = new List<String>(); 
        for(Object o : (List<Object>)body.get('teamIds')){
           teamIds.add((String)o) ;
        }
        String teamIdsToString =  '\'' + String.join((teamIds), '\',\'') + '\'';
        Set<String> teamMemberIds = new Set<String>();
       
        List<User> teamUsers = new BL_EasyQuery()
                               .useCase(BL_ICON_Constants.USE_CASE_USER)     
                               .condition('Id in (' + teamIdsToString  + ')')
                               .executeQuery()
                               .getSObjects();
            
        List<TeamMember__c> tmToDelete = new BL_EasyQuery()
                               .useCase(BL_ICON_Constants.USE_CASE_TEAM_MEMBER)     
                               .condition('Manager__c = \'' + UserInfo.getUserId() + '\' AND User__c NOT in (' + teamIdsToString  + ')')
                               .executeQuery()
                               .getSObjects();
        if (tmToDelete.size() > 0) {
            delete tmToDelete;
        }

        for(User user : teamUsers) {
            TeamMember__c tm = new TeamMember__c(User__c = user.Id, Manager__c = UserInfo.getUserId(), TECH_UniqueKey__c = UserInfo.getUserId()+user.Id);
            tmToUpsert.add(tm);
        } 

        if (tmToUpsert.size()>0) {
           upsert tmToUpsert TECH_UniqueKey__c;
        }
        
        for(TeamMember__c tm : tmToUpsert) {
            teamMemberIds.add(tm.id); 
        } 
        String teamMemberIdsToString = '\'' + String.join(BL_Utils.toList(teamMemberIds), '\',\'') + '\'';
         return  new BL_EasyQuery()
                 .useCase(BL_ICON_Constants.USE_CASE_TEAM_MEMBER)  
                 .condition('Id in (' + teamMemberIdsToString  + ')')
                 .executeQuery()
                 .getMappedObjects();

    }

}