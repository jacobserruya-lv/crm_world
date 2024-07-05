/**
    Description: Batch used in the developper console in order to delete all cleanUplog records
    Created for: SOW: IC007 ICON project
    Create date: 03/06/2014

    Update History
    --------------
    Create date: Juin 2014  HCH
    
    
    Issues / TODOs
    --------------
*/

global class IC_BatchClUpLogCleanUp implements Database.Batchable<sObject> {
	
	public String query;
    global IC_BatchClUpLogCleanUp(){
        query = 'SELECT Id FROM CleanUpLog__c';
        
     }
        
    global database.querylocator start(Database.BatchableContext CD){
        System.debug('#### START - BatchLogInsert');
        System.debug('#### query : '+query);
        return Database.getQueryLocator(query);   
    } 
    
    global void execute(Database.BatchableContext CD, List<sObject> scope){
        
        List<CleanUpLog__c> CleanUpLogToDelete = new List<CleanUpLog__c>();
        try{
            for(sObject o:scope){
                CleanUpLog__c cul = (CleanUpLog__c)o;
                CleanUpLogToDelete.add(cul);  
                
            }  
                         
            delete CleanUpLogToDelete;
    
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }       
    }
    
    global void finish(Database.BatchableContext CD){}
    
}