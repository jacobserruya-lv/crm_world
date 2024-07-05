global with sharing class BL_ICON_Batch_NY_OrdersTodos implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    /* ICON requirement - creation of a todo Assitant task 4 & 9 months after hitting the PRODUCTION IN PROGRESS status */

    public String query;
    public static final Id TaskTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('To_Do_Assistant').getRecordTypeId();
  

    global BL_ICON_Batch_NY_OrdersTodos() {

        String progress9months = DateTime.now().addMonths(-9).format('yyyy-MM-dd');
        String progress4months = DateTime.now().addMonths(-4).format('yyyy-MM-dd');

        query =  'SELECT SPO_BriefName__r.SPO_Store__r.ISO3_Code__c ,SPO_BriefName__r.Owner.Is_Store_User__c  , SPO_FirmOrderStatus__c ,Id ,SPO_BriefName__c,SPO_BriefName__r.ApplicationSource__c, SPO_BriefName__r.OwnerId ,SPO_BriefName__r.Owner.IsTechnicalUser__c, SPO_BriefName__r.SPO_Store__c, SPO_BriefName__r.Account.PersonContactId FROM SPO_FirmOrder__c WHERE  SPO_BriefName__r.ApplicationSource__c =\'SPO\' AND (ProductionInProgressDate__c ='+ progress9months +' OR ProductionInProgressDate__c='+progress4months+')';
      
        system.debug(query);

    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('#### START - BL_ICON_Batch_NY_OrdersTodos');
        System.debug('#### QUERY : ' + query);

        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        try{

            Map<String,String>  TechnicalUsers = ICON_Todos_Helper.getTechnicalUsers();

        
            List<Task> lstTask = new List<Task>();
            for(sObject o : scope){
            	SPO_FirmOrder__c order = (SPO_FirmOrder__c) o;
            	String todoCode = '';
                todoCode = order.ProductionInProgressDate__c == Date.today().addMonths(-9) ? 'TD_NY_06' : 'TD_NY_05';
                lstTask.add(ICON_Todos_Helper.createToDoTaskFirmOrderNowYours(order,TechnicalUsers ,'Production in progress', todoCode));              	
            }               
            database.insert(lstTask,false);
        
        }
        catch(Exception e) {
            
        }
    }
    
    
    global void finish(Database.BatchableContext CD){}
    

}