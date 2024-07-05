public with sharing class IC_CADreamIDSearch_VFCx {
	
	public UserDreamId__c searchCriterias {get; set;}
	public List<UserDreamId__c> results {get; set;}
	public String message  {get; set;}
	
	
	
	public IC_CADreamIDSearch_VFCx(){
		searchCriterias = new UserDreamId__c();
		results = new List<UserDreamId__c>();
	}
	
	
	public PageReference searchCADreamIDs(){
		results = new List<UserDreamId__c>();
		String reqSOQL = 'Select Id, CA_DREAM_ID__c, CA_Name__c, CA_Retail_Store_Code__c, CA_Retail_Store_Name__c, CA_RMS_ID__c From UserDreamId__c ';
		
		//CA RMS ID
		String rmsID = searchCriterias.CA_RMS_ID__c;				
		List<String> listRMS = formatInputField(rmsID);
		
		//RETAIL CODE
		String retailCode = searchCriterias.CA_Retail_Store_Code__c;		
		List<String> listCode = formatInputField(retailCode);
		
		// Requete SOQL finale
		if (listRMS.isEmpty() && listCode.isEmpty()) {
			// Aucune valeur de recherche => Message Erreur
			message = System.Label.IC_CADreamIdNoSearchCriteria;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, message)); 
            return null;          	
			
		} else if (listRMS.isEmpty() && !listCode.isEmpty()) {			
			reqSOQL += 'where CA_Retail_Store_Code__c in :listCode limit 100';
			
		} else if (!listRMS.isEmpty() && listCode.isEmpty()) {			
			reqSOQL += 'where CA_RMS_ID__c in :listRMS limit 100';
			
		} else {
			reqSOQL += 'where CA_RMS_ID__c in :listRMS AND CA_Retail_Store_Code__c in :listCode limit 100';
			
		}
		results = Database.query(reqSOQL);		
		
		return manageResult (results);
					
		
		
	}
	
	private List <String> formatInputField (String inputValue) {
		List<String> formattedField = new List <String>();
		// Si champ en entree non vide => splitter les valeurs et ajout dans la liste formattedField
		if (inputValue != null) {
			//Split
			formattedField = inputValue.split(',');
				//Retrait des espaces
				for(integer i=0; i<formattedField.size(); i++){
          		  formattedField[i] = formattedField[i].trim();
        		}        
			}		
		// Retour de la liste des valeurs de recherche
		return formattedField;
		
	}
	
	private PageReference manageResult (List<UserDreamId__c> results) {
		
		if (results == null || results.size () == 0) {
			// Message pas de resultat trouv�
			message = System.Label.IC_CADreamIdNoResultFound;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));           				
			return null;
			
		} else if (results.size() == 100) {
			// Message Please populate both fields to perform search
			message = System.Label.IC_CADreamIdSearchTooManyResult;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));            
            return null;
			
		} else {
			// On affiche le resultat
			return null;
			
			
		}
		
		
	}
	
	
	

}