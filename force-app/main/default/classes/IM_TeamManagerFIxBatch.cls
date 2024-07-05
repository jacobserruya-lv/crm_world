global class IM_TeamManagerFIxBatch implements Database.Batchable<sObject> {
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		String query = 'Select Id,TECH_TeamUsersIds__c From User Where TECH_IsManager__c = true AND isActive=TRUE';
		return  Database.getQueryLocator(query);
		
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<TeamMember__c> teamMembers = new List<TeamMember__c>();
		for (User manager: (List<User>)scope){
		    if(manager.TECH_TeamUsersIds__c != null && manager.TECH_TeamUsersIds__c!= ''){
		       for(String userId : manager.TECH_TeamUsersIds__c.split(';')){
		            TeamMember__c tm = new TeamMember__c(Manager__c = manager.Id,User__c = userId, TECH_UniqueKey__c = manager.Id+userId);
		            teamMembers.add(tm);
		        } 
		    } 
		}

		if (teamMembers.size()>0){
		    system.debug(teamMembers.size());
		    Schema.SObjectField f = TeamMember__c.Fields.TECH_UniqueKey__c;
		    database.upsert(teamMembers,f,false);
		}
	
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}