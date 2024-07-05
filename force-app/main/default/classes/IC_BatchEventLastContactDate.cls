global class IC_BatchEventLastContactDate implements Database.Batchable<sObject>{

    public String query;
    
    global IC_BatchEventLastContactDate (){ 
      //RAF : put the number of days in parameter
      Integer lastContactTimeRange = Integer.valueOf(ICONSettings__c.getOrgDefaults().get('AccLastContactTimeRange__c'));
        //query = 'Select Id, AccountId, ActivityDate, Account.LastContactDate__pc, Account.LastAppointmentDate__pc from Event Where ActivityDate = TODAY or ActivityDate = LAST_N_DAYS:30';
        query = 'Select Id, AccountId, ActivityDate, Account.LastContactDate__pc, Account.LastAppointmentDate__pc from Event Where ActivityDate = TODAY or ActivityDate = LAST_N_DAYS:'+lastContactTimeRange;
    }
     
    global database.querylocator start(Database.BatchableContext CD){
        System.debug('#### START - IC_BatchEventLastContactDate ');
        System.debug('#### query : ' + query);
        return Database.getQueryLocator(query);   
    }
    
    
    global void execute(Database.BatchableContext CD, List<sObject> scope){
        System.debug('### Execute');
        System.debug('### Scope : '+scope);
        try{
            IC_Event_TRG.eventSetAccLastContactDate(scope);
                    
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext CD){
        System.debug('#### END --- IC_BatchEventLastContactDate ');
    }

}