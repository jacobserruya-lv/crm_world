/*
* User Trigger handler for multiStore
* @createdBy   Romain Mouchel-Vallon 31/01/17
*/

public with sharing class User_MultiStore_TRG {

    // Map holding store code translations
	private static final Map<String, String> picklistTranslationsMap = new Map<String, String>();

	// Copies Default Store to the User stores list on insert
	public static void multiStoreInsert (User[] newUsers){	
		init();	
		Map<String, List<User>> mapStoreCodeUsers = new Map<String, List<User>>();
		for (User u : newUsers){
			if (u.DefaultStore__c != null){
				Set<String> userStores = u.TECH_User_Stores__c == null ? new Set<String>() : new Set<String>(u.TECH_User_Stores__c.split(','));
				if (!userStores.contains(u.DefaultStore__c)){
					userStores.add(u.DefaultStore__c);
					u.TECH_User_Stores__c = String.join(new List<String>(userStores), ',');
				}
			}
			updateStoreNames (u);

			if(u.Is_Identity_User__c == false && u.DefaultStore__c != null){
				if (mapStoreCodeUsers.get(u.DefaultStore__c) == null){
					mapStoreCodeUsers.put(u.DefaultStore__c, new List<User>());
				}
				mapStoreCodeUsers.get(u.DefaultStore__c).add(u);
			}
		}

		// setUserTimeZone(mapStoreCodeUsers);
	}

	// Removes old Default Store and add the new one to the user stores list on update
	public static void multiStoreUpdate (Map<Id, User> oldMap, User[] newUsers){
		init();
		Map<String, List<User>> mapStoreCodeUsers = new Map<String, List<User>>();

		for (User u : newUsers){
			User oldUser = oldMap.get(u.id);

			Set<String> userStores = u.TECH_User_Stores__c == null ? new Set<String>() : new Set<String>(u.TECH_User_Stores__c.split(','));
			userStores.remove(oldUser.DefaultStore__c);
			if (u.DefaultStore__c != null)
				userStores.add(u.DefaultStore__c);

			u.TECH_User_Stores__c = String.join(new List<String>(userStores), ',');

			updateStoreNames (u);

			if(u.Is_Identity_User__c == false && u.DefaultStore__c != null){
				if (mapStoreCodeUsers.get(u.DefaultStore__c) == null){
					mapStoreCodeUsers.put(u.DefaultStore__c, new List<User>());
				}
				mapStoreCodeUsers.get(u.DefaultStore__c).add(u);
			}
		}

		// setUserTimeZone(mapStoreCodeUsers);
	}

	// Updates store names list based on store codes list
	private static void updateStoreNames (User u){
			List<String> storeNames = new List<String>();
			if (u.TECH_User_Stores__c != null){
				for (String s : u.TECH_User_Stores__c.split(',')){
					storeNames.add(picklistTranslationsMap.get(s));
				}
			}
			u.User_Stores__c = String.join(storeNames, ', ');
	}

	// private static void setUserTimeZone(Map<String, List<User>> mapStoreCodeUsers){
	// 	List<Store__c> stores = [Select Id, Time_Zone_Id__c, RetailStoreId__c 
    //     	From Store__c where Time_Zone_Id__c != null AND RetailStoreId__c IN : mapStoreCodeUsers.keySet()];
	// 	for(Store__c s : stores){
	// 		for(User u: mapStoreCodeUsers.get(s.RetailStoreId__c)){
	// 			u.TimeZoneSidKey = s.Time_Zone_Id__c;
	// 		}
	// 	}
	// }

	// init
	public static void init (){
	    // Initializing translation map
	    List<Schema.PicklistEntry> picklistValues = User.DefaultStore__c.getDescribe().getPicklistValues();
	    for (Schema.PicklistEntry pe : picklistValues){
	        picklistTranslationsMap.put(pe.getValue(), pe.getLabel());
	    }
	}
}