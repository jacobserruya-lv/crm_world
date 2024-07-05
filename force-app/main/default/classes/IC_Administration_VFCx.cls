/*
+-----------------------+------------------------------------------------------------------------------------+
| Author                | Pape Babacar DIOUF                                                                 |
+-----------------------+------------------------------------------------------------------------------------+
| Description           |                                                                                    |
|                       |                                                                                    |
|     - Component       |                                                                                    |
|                       |                                                                                    |
|     - Object(s)       | - Controleur de la page Administration                                             |
|     - Description     | - Il automatise la création des ClientList et l'affectation des SA                 |
|                       | 								                                                     |
|                       | 							                                                         |
|                       |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Delivery Date         | 12/11/2013                                                                         |
+-----------------------+------------------------------------------------------------------------------------+
| Modifications         |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
| Governor informations |                                                                                    |
+-----------------------+------------------------------------------------------------------------------------+
*/
public with sharing class IC_Administration_VFCx {
    
    public String dreamIds{get;set;}
    public List<String> listOfDreamIDs;
    public boolean canDisplayMessage{get;set;}
    public String message{get;set;}
    public String clientList{get;set;}
    public List<String> listOfClientList;
    
    public List<ICON_Default_ClientList__c> listIDCL{get;set;}
    public List<String> languages{get;set;}
    public List<String> defaultValues{get;set;}
    public List<Record> lstRecords{get;set;}
    
    public String param{get;set;}
    
    // =======================================================================
	// Constructeur
	// =======================================================================
    public IC_Administration_VFCx (){
        dreamIds = '';
        listOfDreamIDs = new List<String>();
        canDisplayMessage = false;
        message = '';
        clientList = '';
        listOfClientList = new List<String>();
        this.initializeDefaultClienList();
    }
    
    // =======================================================================
	// Initialise les Client List par pays
	// =======================================================================
    public void initializeDefaultClienList(){
    	languages = new List<String>();
        defaultValues = new List<String>();
        lstRecords = new List<Record>();
    	listIDCL = [Select Name, DefautClientList__c From ICON_Default_ClientList__c ORDER BY Name];
    	for(ICON_Default_ClientList__c dcl : listIDCL){
    		if(!dcl.Name.contains('_')){
    			languages.add(dcl.Name);
    			defaultValues.add(this.getClientsList(dcl.Name));
    			lstRecords.add(new Record(dcl.Name, this.getClientsList(dcl.Name)));
    		}
    	}    
    }
    
    // ===========================================================================
	// Recois l'ensemble des ClientList d'un pays passé en paramétre
	// ===========================================================================
    public String getClientsList(String countryLanguage){
    	String clientLists = '';
    	for(ICON_Default_ClientList__c dcl : listIDCL){
    		if(dcl.Name.equals(countryLanguage) || dcl.Name.startsWith(countryLanguage+'_')){
    			clientLists += dcl.DefautClientList__c;
    		}
    	}
    	return clientLists;
    }
    
    // =======================================================================
	// met à jours le champs contenant les ClientList
	// =======================================================================
    public void updateClientList(){
    	String countrylanguage = param;
    	String text = this.getClientsList(countryLanguage);
    	clientList = text;
    	//return text;
    }
    
    // =======================================================================
	// Vérifie si le formulaire est valide pour pouvoir réaffecter SA
	// =======================================================================
    public boolean form_ReaffectSA_IsValid(){
        if(dreamIds == '' || dreamIds == null){
            canDisplayMessage = true;
            return false;
        } else {
            canDisplayMessage = false;
            return true;
        }
    }
    
    // =======================================================================
	// Vérifie si le formulaire est valide pour pouvoir créer les ClientList
	// =======================================================================
    public boolean form_ClientListCreation_IsValid(){
    	if(dreamIds == '' || dreamIds == null || clientList == '' || clientList == null){
            canDisplayMessage = true;
            return false;
        } else {
            canDisplayMessage = false;
            return true;
        }
    }
    
    
    
    // ========================================================================
	// découpe les dream Ids séparés par des virgules et les met dans une liste
	// ========================================================================
    public void getMyListOfDreamsIDs(){
        listOfDreamIDs = dreamIds.split(',');
        for(integer i=0; i<listOfDreamIDs.size(); i++){
            listOfDreamIDs[i] = listOfDreamIDs[i].trim();
        }
    }
    
    
    // ===============================================================================
	// découpe les dream ClientList séparés par des virgules et les met dans une liste
	// ===============================================================================
    public void getMyListOfClientList(){
        listOfClientList = clientList.split(',');
        for(integer i=0; i<listOfClientList.size(); i++){
            listOfClientList[i] = listOfClientList[i].trim();
        }
    }
    
    
    // ==========================================================================
	// Lance le Script Batch qui éffectu la mis à jours des clients (Reaffect SA)
	// ==========================================================================
    public Pagereference launchSriptBatchClientUpdate(){
        if(form_ReaffectSA_IsValid()){
            this.getMyListOfDreamsIDs();
            BatchClientUpdate myBatch = new BatchClientUpdate(listOfDreamIDs);        
            Database.executeBatch(myBatch,1000);
            this.createTextDocument_BatchClientUpdate();
            message = System.Label.IC_Batch_Launched_Message;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, message));
            return null;
        } else {
            message = System.Label.IC_Batch_Not_Valid_Form;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, message));
            return null;
        }
    }
    
    
    // ==========================================================================
	// Lance le Script Batch qui créé les ClientList
	// ==========================================================================
    public Pagereference launchSriptBatchClientListsCreation(){
        if(form_ClientListCreation_IsValid()){
            this.getMyListOfDreamsIDs();
            this.getMyListOfClientList();
            
            List<User> lstUsers = [SELECT Id FROM User WHERE DREAMId__c IN :listOfDreamIDs];
			List<Id> lstUsersId = new List<Id>();
			for(User u : lstUsers){
                   lstUsersId.add(u.Id); 
			}
			BatchClientListsCreation myBatch = new BatchClientListsCreation(lstUsersId, listOfClientList);
			Database.executeBatch(myBatch,50);

            this.createTextDocument_BatchClientListsCreation();
            message = System.Label.IC_Batch_Launched_Message;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, message));
            return null;
        } else {
            message = System.Label.IC_Batch_Not_Valid_Form_CLC;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, message));
            return null;
        }
    }
    
    
    // =======================================================================
	// Créé un fichier contenant la listes des dream ids saisie et ayant pour
	// nom, non du batch concaténé à la date et à lheure instantanée
	// =======================================================================
    public void createTextDocument_BatchClientUpdate(){
        DateTime currentDate = System.now();
        String fileName = 'BatchClientUpdate_';
                fileName += String.valueOf(currentDate.year());
                
                if(currentDate.month()<10) 
                    fileName += '0';
                fileName += String.valueOf(currentDate.month());
                
                if(currentDate.day()<10) 
                    fileName += '0';
                fileName += String.valueOf(currentDate.day());
                
                fileName += '_';
                
                if(currentDate.hour()<10) 
                    fileName += '0';
                fileName += String.valueOf(currentDate.hour());
                
                if(currentDate.minute()<10) 
                    fileName += '0';
                fileName += String.valueOf(currentDate.minute());
                
                if(currentDate.second()<10) 
                    fileName += '0';
                fileName += String.valueOf(currentDate.second());
                
                fileName += '.txt';
        Document document = new Document();
        document.Name = fileName;
        String myContent = 'Dream Ids (Saisies) : \n' + dreamIds;
        document.Body = Blob.valueOf(myContent);
        document.ContentType = 'text/plain; charset=UTF-8';
        document.Type = 'txt';
        Id FolderId;
        List <Folder> lstFolder = [SELECT Id FROM Folder WHERE DeveloperName = :System.Label.IC_AMS_Folder_Name];
        if(lstFolder.size()>0){ 
            document.FolderId = lstFolder[0].id;
            insert document;
        }
    }
    
    
    // =======================================================================
	// Créé un fichier contenant la listes des ClientList saisie et ayant pour
	// nom, non du batch concaténé à la date et à lheure instantanée
	// =======================================================================
    public void createTextDocument_BatchClientListsCreation(){
        DateTime currentDate = System.now();
        String fileName = 'BatchClientListsCreation_';
                fileName += String.valueOf(currentDate.year());
                
                if(currentDate.month()<10) 
                    fileName += '0';
                fileName += String.valueOf(currentDate.month());
                
                if(currentDate.day()<10) 
                    fileName += '0';
                fileName += String.valueOf(currentDate.day());
                
                fileName += '_';
                
                if(currentDate.hour()<10) 
                    fileName += '0';
                fileName += String.valueOf(currentDate.hour());
                
                if(currentDate.minute()<10) 
                    fileName += '0';
                fileName += String.valueOf(currentDate.minute());
                
                if(currentDate.second()<10) 
                    fileName += '0';
                fileName += String.valueOf(currentDate.second());
                
                fileName += '.txt';
        Document document = new Document();
        document.Name = fileName;
        String myContent = 'Dream Ids (saisies) : \n' + dreamIds + '\n\n' + 'Client List(Saisis ) : \n' + clientList;
        document.Body = Blob.valueOf(myContent);
        document.ContentType = 'text/plain; charset=UTF-8';
        document.Type = 'txt';
        Id FolderId;
        List <Folder> lstFolder = [SELECT Id FROM Folder WHERE DeveloperName = :System.Label.IC_AMS_Folder_Name];
        if(lstFolder.size()>0){ 
            document.FolderId = lstFolder[0].id;
            insert document;
        }
        
    }
    
    
    // =======================================================================
	// Classe Utilitaire
	// =======================================================================
    public class Record{
    	public String recordID{get;set;}
    	public String recordValue{get;set;}
    	
    	public Record(String id, String value){
    		recordID = id;
    		recordValue = value;
    	}
    }
    
}