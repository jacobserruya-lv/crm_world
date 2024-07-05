public with sharing class IM_UserToChatterGroup {
	@future
	static public Void AddUsertoCG(List<String> userIds){
		List<User> users =[select Id,TimeZoneSidKey,LanguageLocaleKey From User where Id IN : userIds];
		List<ChatterGroupConfig__c> cgcList = [Select TimeZone__c,Language__c,ChatterGroup_Name__c From ChatterGroupConfig__c];
		if(cgcList.size()>0){
			List<CollaborationGroup> cGroups  = [Select Id,Name From CollaborationGroup Where Name IN :getChatterGroupNames()];
			if(cGroups.size()>0){
				List<CollaborationGroupMember> cgmToInsert = new List<CollaborationGroupMember>();
				Set<String> usersAssigned = new Set<String>();

				Map<String,CollaborationGroup> cGroupsMap = new Map<String,CollaborationGroup>();
				for(CollaborationGroup cg:cGroups){
					cGroupsMap.put(cg.Name,cg);
				} 

				//Map<String,ChatterGroupConfig__c> cgcMap = new Map<String,ChatterGroupConfig__c>(); 
				//for(ChatterGroupConfig__c cgc :cgcList){
				//	cgcMap.put(cgc.TimeZone__c+cgc.Language__c,cgc);
				//}

				//for(User u:users){
				//	String cgName = cgcMap.get(u.TimeZoneSidKey+u.LanguageLocaleKey)!=null ? cgcMap.get(u.TimeZoneSidKey+u.LanguageLocaleKey).ChatterGroup_Name__c : ChatterGroupConfig__c.getInstance('Default').ChatterGroup_Name__c;
				//	CollaborationGroupMember cgm = new CollaborationGroupMember(CollaborationGroupId = cGroupsMap.get(cgName).Id,
				//		MemberId = u.Id);
				//	cgmToInsert.add(cgm);
				//}

				//if(cgmToInsert.size()>0){
				//	insert cgmToInsert;
				//}
				for(User u:users){
					for(ChatterGroupConfig__c cgc : cgcList){
						if(cgc.TimeZone__c.contains(u.TimeZoneSidKey) && cgc.Language__c.contains(u.LanguageLocaleKey)){
							CollaborationGroupMember cgm = new CollaborationGroupMember(CollaborationGroupId = cGroupsMap.get(cgc.ChatterGroup_Name__c).Id,
								MemberId = u.Id);
							cgmToInsert.add(cgm);
							usersAssigned.add(u.Id);
						}
					}
					if(!usersAssigned.contains(u.Id)){
						CollaborationGroupMember cgm = new CollaborationGroupMember(CollaborationGroupId = cGroupsMap.get(ChatterGroupConfig__c.getInstance('Default').ChatterGroup_Name__c).Id,
								MemberId = u.Id);
							cgmToInsert.add(cgm);
							usersAssigned.add(u.Id);
					}
				}

				if(cgmToInsert.size()>0){
					insert cgmToInsert;
				}
			}
				
		}
	}
	@future
	static public Void RemoveUserFromALLCG(List<String> userIds){
		List<User> users =[select Id,TimeZoneSidKey,LanguageLocaleKey From User where Id IN : userIds];
		List<CollaborationGroupMember> cgmList = [Select Id From CollaborationGroupMember Where MemberId IN :users AND CollaborationGroup.Name IN :getChatterGroupNames()];
		if(cgmList.size()>0){
			delete cgmList;
		}
	}

	static public List<String> getChatterGroupNames(){
		List<ChatterGroupConfig__c> cgcList = [Select ChatterGroup_Name__c From ChatterGroupConfig__c];
		List<String> cgcNames = new List<String>();
		for(ChatterGroupConfig__c cgc : cgcList){
			cgcNames.add(cgc.ChatterGroup_Name__c);
		}
		return cgcNames;
	}

}