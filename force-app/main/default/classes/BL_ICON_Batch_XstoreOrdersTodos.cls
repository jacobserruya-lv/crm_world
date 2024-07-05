global with sharing class BL_ICON_Batch_XstoreOrdersTodos implements Database.Batchable<sObject>, Database.AllowsCallouts{

    public String query;
    public static final Id TaskTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('To_Do_Assistant').getRecordTypeId();
   // public static Map<String,String> TechnicalUsers = new Map<String,String>();

    
    global BL_ICON_Batch_XstoreOrdersTodos() {

        String homeDeliveryDate = DateTime.now().addDays(-15).format('yyyy-MM-dd');
        String pickInStoreDate = DateTime.now().addDays(-7).format('yyyy-MM-dd');
        query =  'SELECT id ,Order__c, DeliveryType__c ,Order__r.Account__r.PersonContactId  ,Order__r.Store__c  ,Order__r.OwnerId__c , Order__r.Store__r.ISO3_Code__c FROM OrderShipping__c WHERE  Order__r.Store__r.StoreType__c IN (\'Store\' , \'POP UP - OON\') AND  Status__c = \'Fulfilled\' AND ((DAY_ONLY(StatusDate__c) ='+ homeDeliveryDate + ' AND DeliveryType__c = \'DELIVERY\')  OR (DAY_ONLY(StatusDate__c) ='+ pickInStoreDate + ' AND DeliveryType__c = \'shipforpickup\') )';
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
       
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        try{

            Map<String,String>  TechnicalUsers = ICON_Todos_Helper.getTechnicalUsers();

        
            List<Task> lstTask = new List<Task>();
            for(sObject o : scope){
            	OrderShipping__c order = (OrderShipping__c) o;
            	
                lstTask.add(ICON_Todos_Helper.createToDoTaskXstore(order,TechnicalUsers,'Follow-up after purchase', 'TD_XSTO_03'));              	
            }               
            database.insert(lstTask,false);
        
        }
        catch(Exception e) {
            
        }
    }
    
    
    global void finish(Database.BatchableContext CD){}
    

}