/**
    Description: Batch used in the developper console in order to correct Product_Family field format
                  in all CareService objects
    Created for: ICON project
    Create date: 22/05/2019
    
    Issues / TODOs
    --------------
*/
global class IC_UpdateCareService_Batch implements Database.Batchable<sObject>{

public String query;
    
    global IC_UpdateCareService_Batch(){
        
        query = 'SELECT id, Product_family__c FROM CareService__c where Product_family__c != null';
             
     }
        
    global database.querylocator start(Database.BatchableContext CD){
        System.debug('#### START - IC_UpdateCareService_Batch');
        System.debug('#### query : '+query);
        return Database.getQueryLocator(query);   
    } 
    
    global void execute(Database.BatchableContext CD, List<sObject> scope){
        
        try{        
            //care service trigger will do the job
            update scope;
    
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext CD){}


}