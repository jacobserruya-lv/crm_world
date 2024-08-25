global with sharing class BL_ICON_BatchCleanToDoAssistant implements Database.Batchable<sObject>{
    
    public String query;
    public static final Id TaskTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('To_Do_Assistant').getRecordTypeId();
    global BL_ICON_BatchCleanToDoAssistant(){	
      
        query = 'SELECT Id FROM Task WHERE Createddate <=  Today AND RecordTypeId = \'' +  TaskTypeId + '\' AND Store_Location__r.ISO3_Code__c  NOT IN (\'F07\',\'F21\',\'H02\',\'H17\',\'J07\',\'J03\',\'Q71\',\'Q66\',\'URD\',\'UKF\',\'UKP\',\'UVW\',\'UOR\',\'L12\',\'L32\',\'Y03\',\'N64\',\'N74\',\'N02\',\'NVJ\',\'N46\',\'N44\',\'N94\',\'NE1\',\'NN6\',\'N31\',\'NM7\',\'NA6\',\'V18\',\'V25\',\'V74\',\'V02\')';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
       
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        try{
            System.debug( 'SIZE' +scope.size());
            if(!scope.isEmpty())
                database.delete(scope,false) ;
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext CD){}

}