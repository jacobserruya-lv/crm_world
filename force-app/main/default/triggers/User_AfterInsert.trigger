/**
* ALL triggers centralized in TR_User_Trigger.trigger
* @Author             : hamza.bouzid.ext@louisvuitton.com
* @Last Modified By   : hamza.bouzid.ext@louisvuitton.com
* @Last Modified On   : 19-09-2023  
**/

trigger User_AfterInsert on User (after insert) {
	/*PASS_TR01_ContactCreateDateID.ContactCreateDateID(Trigger.new);
	Map<String,Profile> profileMap = new Map<String,Profile>([Select Id From Profile Where Name Like '%ICON_%']);
	List<String> usersToCG = new List<String>();
	for(User u : trigger.new){
		if(profileMap.keySet().contains(u.ProfileId)){
			usersToCG.add(u.Id);
		}
	}
	if(usersToCG.size()>0){
		IM_UserToChatterGroup.AddUsertoCG(usersToCG);
	}*/
}