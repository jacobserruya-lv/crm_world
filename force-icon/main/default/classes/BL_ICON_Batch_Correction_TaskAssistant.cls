global without sharing class BL_ICON_Batch_Correction_TaskAssistant implements Database.Batchable<sObject>{
    public String query;
    global BL_ICON_Batch_Correction_TaskAssistant(){	
        query = 'SELECT Id,WWEmployeeNumber__c, StoreCode__c, DreamId__c FROM TaskAssistant__c WHERE Client__c = NULL AND DueDate__c >= TODAY';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        try{
            if(!scope.isEmpty()){
                TaskAssistantQueueable.updateTaskAssisant((List<TaskAssistant__c>) scope);
            }
        }catch (DmlException e){
            System.debug('Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
    }

    global void finish(Database.BatchableContext CD){}
}