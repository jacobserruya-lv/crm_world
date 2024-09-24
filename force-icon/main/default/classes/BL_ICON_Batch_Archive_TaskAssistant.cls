global class BL_ICON_Batch_Archive_TaskAssistant  implements Database.Batchable<sObject>{
    public String query;
    global BL_ICON_Batch_Archive_TaskAssistant(){	
        query = 'SELECT Id, DueDate__c FROM TaskAssistant__c WHERE IsArchieved__c = FALSE AND DueDate__c < TODAY ';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        try{
            if(!scope.isEmpty()){
                for(sObject obj : scope){
                    TaskAssistant__c ta = (TaskAssistant__c) obj;
                    ta.IsArchieved__c = true;
                }
                Database.update(scope,false);
            }
        }catch (DmlException e){
            System.debug('Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
    }

    global void finish(Database.BatchableContext CD){}
}