/**
    Description: Batch used in the developper console in order to delete the Task
    Created for: SOW: IC007 ICON project
    Create date: 26/06/2014

    Update History
    --------------
    Create date: Juin 2014  Pape Babacar DIOUF (Pape-Babacar.Diouf@capgemini.com)
    Modifications:
    	STI 01/10/14 : outreach criteria is deleted from query
    	STI 19/03/15 : correction on date parameters in query
    
    Issues / TODOs
    --------------
*/

global class IC_BatchCleanUpTask implements Database.Batchable<sObject>{
      
    public String query;
    
    Integer MaxLimit = Integer.valueOf((Decimal)ICONSettings__c.getOrgDefaults().get('taskPurgeMaxLimit__c'));
    Integer MinLimit = Integer.valueOf((Decimal)ICONSettings__c.getOrgDefaults().get('taskPurgeMinLimit__c'));
    
    String MaxLimitDate = String.valueOf(Date.today().addMonths(-MaxLimit));
    String MinLimitDate = String.valueOf(Date.today().addMonths(-MinLimit));
    
    //List<String> actionTypesCriterias = new String[]{ 'Email', 'Phone', 'SMS', 'Mobile Chat'};
    //String dreamProfile;
    
    global IC_BatchCleanUpTask(){
        //dreamProfile = [Select Id from Profile where Name='ICON_Interface DREAM'].Id;
        // STI 01/10/14 : outreach criteria is deleted from query
        //query = 'SELECT Id FROM Task Where ( (DREAMID__c Like \'CRM_%\' AND ((Channel__c = \'Emailing\' AND ActivityDate < :MinLimitDate)OR(Channel__c = \'Mailing\' AND ActivityDate < :MaxLimitDate))) OR (CreatedBy.ProfileId != :dreamProfile  AND ActionType__c IN :actionTypesCriterias AND ActivityDate < :MaxLimitDate) ) ';
        query = 'SELECT Id FROM Task Where ( DREAMID__c Like \'CRM_%\' AND ((Channel__c = \'Emailing\' AND ActivityDate < ' + MinLimitDate + ') OR (Channel__c = \'Mailing\' AND ActivityDate < '+ MaxLimitDate + '))) ';
     }
        
    global database.querylocator start(Database.BatchableContext CD){
        System.debug('#### START - BatchCleanUpTask');
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