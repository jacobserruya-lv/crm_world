global class ICX_BatchCleanInternalCallTasks implements Database.Batchable<sObject>{
 
    public String query;
   
    
    global ICX_BatchCleanInternalCallTasks(){
          query = 'SELECT Id FROM Task Where  createdDate < TODAY and Phone_Calling_Number__c = \'Internal\' and ActionType__c =\'Phone\' and createdDate >= last_n_days:2 and Genesys_IsInternal__c=\'True\' ';
     }
        
    global database.querylocator start(Database.BatchableContext CD){
        System.debug('#### START - ICX_BatchCleanInternalCallTasks');
        System.debug('#### query : ' + query);
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