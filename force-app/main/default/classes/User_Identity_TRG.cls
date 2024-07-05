/*  
*** Balink October 2018
*** DESCRIPTION: Helper for trigger on User
*/
public without sharing class User_Identity_TRG {

	static String identityProfile = IDENTITY_Settings__c.getInstance().ProfileId__c;

	/*
    *** DESCRIPTION Initialize TECH fields for Identity Users
    */
	public static void setTechFields(List<User> newUsers) {

		for(User u : newUsers) {

			if(identityProfile != null && u.ProfileId == identityProfile && u.Email != null) {
				u.TECH_Email__c = u.Email;
			}
			
			if(identityProfile != null && u.ProfileId == identityProfile && u.MobilePhone != null) {
				u.TECH_MobilePhone__c = u.MobilePhone;
			}
		}
	}
}