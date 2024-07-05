/**
	Description: Batch used in the developper console in order to recalculate SA for clients who have been created before their SA in ICON
	Created for: SOW: IC007 ICON project
	Create date: 27/08/2013

	Update History
	--------------
	27/08/2013 / IC007/ Created by Laurent Loiseau
	
	Issues / TODOs
	--------------
*/
global class BatchClientUpdate implements Database.Batchable<sObject>{

	public String query;
	
	global BatchClientUpdate(List<String> lstSADreamId){	
		
	 	query = 'SELECT Id FROM Account Where TECH_DreamIdSA__pc IN (';
	 	for(String SADreamId: lstSADreamId){
	 		query += '\'' + SADreamId+'\','; 
	 	}    
	 	query = query.substring(0,query.length()-1);
	 	query+=')';
	 }
	 	
	global database.querylocator start(Database.BatchableContext CD){
		System.debug('#### START - BatchClientUpdate');
		System.debug('#### query : '+query);
        return Database.getQueryLocator(query);   
	} 
    
	global void execute(Database.BatchableContext CD, List<sObject> scope){
        
		try{
			List<Account> lstAcc = new List<Account>();
            for(sObject o:scope){
            	Account myAccount = (Account)o;
            	lstAcc.add(myAccount);              	
            }               
            update lstAcc;
    
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext CD){}

}