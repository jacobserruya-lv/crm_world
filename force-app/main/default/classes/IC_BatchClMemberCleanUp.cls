/**
    Description: Batch used in the developper console in order to delete CLM_CliListMember__c records without account
    Created for: SOW: IC007 ICON project
    Create date: 03/06/2014

    Update History
    --------------
    Create date: Juin 2014  HCH
    
    
    Issues / TODOs
    --------------
*/

global class IC_BatchClMemberCleanUp implements Database.Batchable<sObject> {
	
	public String query;
    global IC_BatchClMemberCleanUp(){
        query = 'SELECT Id FROM CLM_CliListMember__c Where Client__c = null';
        
     }
        
    global database.querylocator start(Database.BatchableContext CD){
        System.debug('#### START - BatchLogInsert');
        System.debug('#### query : '+query);
        return Database.getQueryLocator(query);   
    } 
    
    global void execute(Database.BatchableContext CD, List<sObject> scope){
        
        List<CLM_CliListMember__c> ClMemberToDelete = new List<CLM_CliListMember__c>();
        try{
            for(sObject o:scope){
                CLM_CliListMember__c clm = (CLM_CliListMember__c)o;
                ClMemberToDelete.add(clm);  
                
            }  
                         
            delete ClMemberToDelete;
    
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }       
    }
    
    global void finish(Database.BatchableContext CD){}
    
}