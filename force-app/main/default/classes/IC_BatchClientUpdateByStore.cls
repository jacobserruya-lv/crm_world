/**
	Description: Batch used in the developper console in order to recalculate SA for clients who have been created before their SA in ICON
	Created for: SOW: IC007 ICON project
	Create date: 03/01/2014

	Update History
	--------------
	03/01/2014 / Created by Pape Babacar DIOUF (Pape-Babacar.Diouf@capgemini.com)
	
	Issues / TODOs
	--------------
*/
global class IC_BatchClientUpdateByStore implements Database.Batchable<sObject>{

	public String query;
	
	global IC_BatchClientUpdateByStore(List<String> lstStore){	
		
	 	query = 'SELECT Id FROM Account Where AttachedStore__pc IN (';
	 	for(String Store: lstStore){
	 		query += '\'' + Store + '\','; 
	 	}    
	 	query = query.substring(0,query.length()-1);
	 	query+=')';
	 }
	 	
	global database.querylocator start(Database.BatchableContext CD){
		System.debug('#### START - IC_BatchClientUpdateByStore');
		System.debug('#### query : ' + query);
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
            System.debug('#### '+e.getTypeName()+' Exception : ' + e.getMessage() + ' ' + e.getStackTraceString() );
        }
    }
    
    global void finish(Database.BatchableContext CD){}

}