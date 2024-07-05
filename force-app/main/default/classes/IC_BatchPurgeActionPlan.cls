global class IC_BatchPurgeActionPlan implements Database.Batchable<sObject>{
	
	public String query;
	global List<ID> lstAcPlanId;
		
	global IC_BatchPurgeActionPlan(){ 

		query = 'SELECT ID, AccountId__c, IsClosed__c FROM ActionPlan__c WHERE AccountId__c = null OR AccountId__c = \'\'';
		
    }
     
    global IC_BatchPurgeActionPlan(List<ID> lstId){    	

     	lstAcPlanId = new List<ID>();
     	lstAcPlanId.addAll (lstId);
     	System.debug('#### lstId : ' + lstId);
     	System.debug('#### lstAcPlanId : ' + lstAcPlanId);
     	query = 'SELECT ID, AccountId__c, IsClosed__c FROM ActionPlan__c WHERE ID IN :lstAcPlanId';
    }
     
    global database.querylocator start(Database.BatchableContext CD){
        System.debug('#### START - IC_BatchPurgeActionPlan');
        System.debug('#### query : ' + query);
        return Database.getQueryLocator(query);   
    }
    
    
    global void execute(Database.BatchableContext CD, List<sObject> scope){
    	System.debug('### try');
        try{
           List<ActionPlan__c> lstToDelete = new List<ActionPlan__c>();
           for(sObject o:scope){
                ActionPlan__c ac = (ActionPlan__c)o;
                lstToDelete.add(ac);
            } 
            
            
        //Supppression   
          if(lstToDelete != null && lstToDelete.size() > 0)
            Database.delete(lstToDelete, false);
                
          
       	  
       }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext CD){
    	System.debug('#### Fin ! ');
    }
	
	
    
}