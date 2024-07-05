/**
	Description: Batch used in the developper console in order to delete incorrect transactions
	Created for: SOW: IC007 ICON project
	Create date: 29/11/2013

	Update History
	--------------
	29/11/2013 / IC007/ Created by Laurent Loiseau
	
	Issues / TODOs
	--------------
*/
global class IC_DeleteTransactions_Batch implements Database.Batchable<sObject>{

public String query;
	
	global IC_DeleteTransactions_Batch(){
		String param;
		param = (String)ICONSettings__c.getOrgDefaults().get('Param_DeleteTransaction_batch__c') ;
		if(param != null)
	 		query = 'SELECT Id FROM PPR_PurchProduct__c  where createddate > '+param;
	 }
	 	
	global database.querylocator start(Database.BatchableContext CD){
		System.debug('#### START - IC_DeleteTransactions_Batch');
		System.debug('#### query : '+query);
        return Database.getQueryLocator(query);   
	} 
    
	global void execute(Database.BatchableContext CD, List<sObject> scope){
        
		try{        
            delete scope;
    
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext CD){}


}