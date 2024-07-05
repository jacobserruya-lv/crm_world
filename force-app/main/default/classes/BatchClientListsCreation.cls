/**
	Description: Batch used in the developper console in order to create generic client list for new users
	Created for: SOW: IC007 ICON project
	Create date: 27/08/2013

	Update History
	--------------
	27/08/2013 / IC007/ Created by Laurent Loiseau
	
	Issues / TODOs
	--------------
*/

global class BatchClientListsCreation implements Database.Batchable<sObject>{
	public String query;
	public List<String> lstCLName;
	
	global BatchClientListsCreation(List<Id> lstUsersId, List<String> lstCLName){
	 	this.lstCLName = lstCLName;
	 	query = 'SELECT Id FROM User Where Id IN (';
	 	for(Id currentId: lstUsersId){
	 		query += '\'' + currentId+'\','; 
	 	}    
	 	query = query.substring(0,query.length()-1);
	 	query+=')';
	 }
	 	
	global database.querylocator start(Database.BatchableContext CD){
		System.debug('#### START - BatchClientListsCreation');
		System.debug('#### query : '+query);
        return Database.getQueryLocator(query);   
	} 
    
	global void execute(Database.BatchableContext CD, List<sObject> scope){
        
		
		List<CLI_CliList__c> lstCL = new List<CLI_CliList__c>();
		try{
            for(sObject o:scope){
            	User myUser = (User)o;
            	for(String clName:lstCLName){
            		CLI_CliList__c CL= new CLI_CliList__c(Name=clName, OwnerId=myUser.Id, Active__c=true);
            		lstCL.add(CL);  
            	}
            }               
            insert lstCL;
    
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext CD){}
}