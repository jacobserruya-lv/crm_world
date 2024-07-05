public with sharing class IC_MassCreateClientLists_VFCx {
	

public User user {get; set;}
public List<String> lvl2List {get; set;}
public List<String> lvl3List {get; set;}
public List<String> storeList {get; set;}
public String clientListName {get; set;}

public List<String> defaultList {get; set;}
public List<String> defaultListSave {get; set;}
public String defaultListText {get; set;}
public boolean isEmpty {get; set;}
public Map<String,String> mapLvl2 {get;set;}
public Map<String,String> mapLvl3 {get;set;}
public Map<String,String> mapStore {get;set;}

	
	public IC_MassCreateClientLists_VFCx () {
				
		user = new User ();
		User currentUser = [Select Id, MANAGEMENT_ZONE_LEVEL__c, MGMT_ZONE_SUB_LEVEL1__c, MGMT_ZONE_SUB_LEVEL2__c from User where Id=:UserInfo.getUserId() limit 1];		
		user.MANAGEMENT_ZONE_LEVEL__c = currentUser.MANAGEMENT_ZONE_LEVEL__c;
		user.MGMT_ZONE_SUB_LEVEL1__c = currentUser.MGMT_ZONE_SUB_LEVEL1__c;
		user.MGMT_ZONE_SUB_LEVEL2__c = currentUser.MGMT_ZONE_SUB_LEVEL2__c;
		initVar ();

        List<Schema.PicklistEntry> lstLvl2 = IC_UTILS.getFieldDescribe('User', 'MGMT_ZONE_SUB_LEVEL2__c').getPicklistValues();
		//List<Schema.PicklistEntry> lstLvl2 = User.MGMT_ZONE_SUB_LEVEL2__c.getDescribe().getPicklistValues();
		mapLvl2 = new Map<String,String>();
		for(Schema.PicklistEntry lvl2 : lstLvl2){
			mapLvl2.put(lvl2.getValue(),lvl2.getLabel());
		}
		
		List<Schema.PicklistEntry> lstLvl3 = IC_UTILS.getFieldDescribe('User', 'MGMT_ZONE_SUB_LEVEL3__c').getPicklistValues();
		mapLvl3 = new Map<String,String>();
		for(Schema.PicklistEntry lvl3 : lstLvl3){
			mapLvl3.put(lvl3.getValue(),lvl3.getLabel());
		}
		
		List<Schema.PicklistEntry> lstStore = IC_UTILS.getFieldDescribe('User', 'DefaultStore__c').getPicklistValues();
		mapStore = new Map<String,String>();
		for(Schema.PicklistEntry store : lstStore){
			mapStore.put(store.getValue(),store.getLabel());
		}


	}
	
	
	// =======================================================================
	// Selectionne/Deselectionne un lvl2
	// =======================================================================
	
	public PageReference selectLevel2(){
				
		onClick (user.MGMT_ZONE_SUB_LEVEL2__c, lvl2List, 'LEVEL2');	
		return null;
		
	}
	
	// =======================================================================
	// Selectionne/Deselectionne un lvl3
	// =======================================================================
	
	public PageReference selectLevel3(){
		
		onClick (user.MGMT_ZONE_SUB_LEVEL3__c, lvl3List, 'LEVEL3');	
		return null;
		
	}
	
	// =======================================================================
	// Selectionne/Deselectionne un store
	// =======================================================================
	
	public PageReference selectStore(){		
		
		onClick (user.DefaultStore__c, storeList, 'STORE');
		return null;
		
	}

	// =======================================================================
	// Lance la creation des clients Lients selecionnes
	// =======================================================================
	public PageReference validate(){
		
	//		defaultListSave = new List<String>();
	//		defaultListSave.addAll(defaultList);
				
			String query = 'SELECT Id FROM User WHERE user.IsActive = true AND (User.MGMT_ZONE_SUB_LEVEL2__c IN :lvl2List';
			
			if (!lvl3List.isEmpty()) {
				query +=' OR User.MGMT_ZONE_SUB_LEVEL3__c IN :lvL3List';
			}
			
			if (!storeList.isEmpty()) {
				query +=' OR User.DefaultStore__c IN :storeList';
			}
			query+=')';

		  	List<User> lstUsers = Database.query(query);
			List<Id> lstUsersId = new List<Id>();			
			for(User u : lstUsers){
                   lstUsersId.add(u.Id); 
			}
			List<String> cltListName = new List<String>();
			if (clientListName == null || clientListName.equals('')) {
				String message = System.Label.IC_Client_List_Name_Empty;
            	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
            	return null;
			}
			cltListName.add(clientListName);
			
			BatchClientListsCreation myBatch = new BatchClientListsCreation(lstUsersId, cltListName);
			Database.executeBatch(myBatch,50);

            String message = System.Label.IC_Mass_Client_List_Created;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, message));
         //   clientListName = '';
       		//clear ();
       		isEmpty = true;
            return null;
			
	}
	
	
	// =======================================================================
	// Retourne l'index d'un element d'une liste
	// =======================================================================
	
    private Integer getIndex (List<String> myList, String element){
    	
    	Integer index = 0;
    	
    	if (!myList.isEmpty()) {
    		for (String c : myList){
    			if (c.equals (element)) {
    				return index;
    				}
    			index ++;
    		}
    	}    	
    	return -1;

    }
    
    
    // =======================================================================
	// Convertis le contenu d'une liste en une chaine de caratere pour 
	//   affichage dans la page visual force
	// =======================================================================
	
    private String listToString (List<String> myList) {
    	
    	String myString = '';
    	for (String c : myList){
    		if (c == null) {
    			c='';
    		}
    		myString += c + '\n';
    	}
    	return myString;
    	
    }
    
   
   	// =======================================================================
	// Initialise les 3 listes qui contiendront les differents elements 
	//   selectionnes depuis les picklists 
	// =======================================================================
	 
   private void initVar () {
   	
   		if (lvl2List == null){
			lvl2List = new List<String>();
			String entete = 'Selected Levels 2:';			
			lvl2List.add (entete);
		}
		if (lvl3List == null){
			lvl3List = new List<String>();			
			String entete = 'Selected Levels 3:';			
			lvl3List.add (entete);
		}
		if (storeList == null){
			storeList = new List<String>();			
			String entete = 'Selected Stores:';			
			storeList.add (entete);
		}
		if (defaultList == null){
			defaultList = new List<String>();
			
		}
		//Desactive 'Client Liste Name' et 'Go!'
		isEmpty = true;
		

   }
    

 	// =======================================================================
	// Retourne la derniere liste finale de tous les elements selectionnes
	// Liste Level 2 + Liste Level3 + Liste Store
	// =======================================================================
	
      	private List<String> concatenate () {
   		
   		List<String> myList = new List<String>();
   		
   		// Is displayed only if at least one element is selected
   		String libelle = 'The client lists will be created to store users for the following scope: \n\n';
   		
   		if(lvl2List.size() > 1 || lvl3List.size() > 1 || storeList.size() > 1){
   			myList.add(libelle);
   		}
   		
   		
   		if (lvl2List.size() > 1) {
   			  for (String c : lvl2List){
   				myList.add(mapLvl2.get(c));
   			}
   		}
   		
		// Affichage seulement si contient au moins 2 elements: Element 1 = Entete = Selected level 3
		if (lvl3List.size() > 1) {
			// On affiche 'and' que si la liste precedente contient au moins un element a afficher
			if (lvl2List.size() > 1){
				myList.add('\nand\n');
				}
			for (String c : lvl3List){
   			myList.add(mapLvl3.get(c));
   			}
		}
   		   		
   		if (storeList.size() > 1) {
   			if (lvl2List.size() > 1 || lvl3List.size() > 1){
				myList.add('\nand\n');
				}
   			for (String c : storeList){
   				myList.add(mapStore.get(c));
   			}
   		}
   		
   		return myList;
   		
   	}
    
    
    // =======================================================================
	// Teste si la liste a afficher est vide
	// =======================================================================
	
    private boolean isClientListEmpty () {
    	
    	if (defaultList.isEmpty()) {
    		isEmpty = true;
    	} else {
    		isEmpty = false;
    	}    	
    	return isEmpty;
    }
    
    
 	// =======================================================================
	// Selection ou deselectionne un element d'une picklist
	// =======================================================================
	    
    private void onClick (String userInfo, List<String> clientList, String level) {    	
  
		if (userInfo != null) {
					Integer i = getIndex (clientList, userInfo);		
				if (i == -1) {
					clientList.add (userInfo);
				}
				else {
					clientList.remove(i);
				}
		
				defaultList.clear ();
				defaultList = concatenate ();
				defaultListText = listToString (defaultList);	
				
		} else {
			String message;
			if (level.equals('LEVEL2')) {
				message = System.Label.IC_Client_List_Country_Empty;
				
			} else if (level.equals('LEVEL3')) {
				message = System.Label.IC_Client_List_Region_Empty;
				
			} else {
				message = System.Label.IC_Client_List_Store_Empty;
			}
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
   //      return null;
		
		}
		// Teste si 'Client Liste Name' et 'Go!' doivent etre acitver
		isClientListEmpty();
		// Reinitialise le Client List Nale
		clientListName = '';
		
    }
    
}