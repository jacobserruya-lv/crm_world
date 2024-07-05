global class IC_BatchTaskLastContactDate implements Database.Batchable<sObject>{

    public String query;
    
    global IC_BatchTaskLastContactDate (){ 
        //RAF : put the number of days in parameter
        String withoutDream = ' and RecordTypeId != \'' + IC_UTILS.getTaskDreamRT() +'\' ';
        Integer lastContactTimeRange = Integer.valueOf(ICONSettings__c.getOrgDefaults().get('AccLastContactTimeRange__c'));
        //query = 'Select Id, AccountId, ActivityDate, WhatId, Account.LastContactDate__pc from Task Where (ActivityDate = TODAY or ActivityDate = LAST_N_DAYS:30) and (ActionType__c IN (\'Email\',\'Phone\',\'SMS\',\'Mobile Chat\',\'Postal Mail\')) ' + withoutDream;
        query = 'Select Id, AccountId, ActivityDate, WhatId, Account.LastContactDate__pc from Task Where (ActivityDate = TODAY or ActivityDate = LAST_N_DAYS:'+lastContactTimeRange+') and (ActionType__c IN (\'Email\',\'Phone\',\'SMS\',\'Mobile Chat\',\'Postal Mail\')) ' + withoutDream;

    }
     
    global database.querylocator start(Database.BatchableContext CD){
        System.debug('#### START - IC_BatchTaskLastContactDate ');
        System.debug('#### query : ' + query);
        return Database.getQueryLocator(query);   
    }
    
    
    global void execute(Database.BatchableContext CD, List<sObject> scope){
        System.debug('### Execute');
        System.debug('### Scope : '+scope);
        try{
            IC_Task_TRG.taskSetAccLastContactDate(scope);
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext CD){
        System.debug('#### END --- IC_BatchTaskLastContactDate ');
        System.debug('Launch Batch on Events');
        
        IC_BatchEventLastContactDate bat = new IC_BatchEventLastContactDate();
        ID batchprocessid = Database.executeBatch(bat,1000);           
        
    }

}