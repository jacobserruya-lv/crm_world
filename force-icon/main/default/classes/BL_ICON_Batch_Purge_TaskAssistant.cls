global without sharing class BL_ICON_Batch_Purge_TaskAssistant implements Database.Batchable<sObject>{
    public String query;
    global BL_ICON_Batch_Purge_TaskAssistant(){	

        String dateToCheck = DateTime.now().addDays(-35).format('yyyy-MM-dd');

        query = 'SELECT Id FROM TaskAssistant__c WHERE IsArchieved__c = TRUE AND DueDate__c <= '+ dateToCheck;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        try{
            if(!scope.isEmpty())
                database.delete(scope,false) ;
        }catch (DmlException e){
            System.debug('Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
    }

    global void finish(Database.BatchableContext CD){}
}