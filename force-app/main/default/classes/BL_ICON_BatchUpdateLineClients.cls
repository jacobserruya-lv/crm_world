global with sharing class BL_ICON_BatchUpdateLineClients implements Database.Batchable<sObject>{
    public String query;
    
    global BL_ICON_BatchUpdateLineClients(){	
      
        query =  'select Client__c from Social_Media_Identifier__c where Social_Media_Type__c IN (\'Line\', \'LineThai\') and Client__r.PrimaryCountry__pc IN (\'JAPAN\', \'THAILAND\')';
        System.debug('query' + query);
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
       System.debug('#### START - BL_ICON_BatchUpdateLineClients');
        System.debug('#### QUERY : ' + query);
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        if (!scope.isEmpty()) {
            List<Id> ids = new List<Id>();
            
            for (sObject client : scope){
                Social_Media_Identifier__c sm = (Social_Media_Identifier__c) client;
                ids.add(sm.Client__c);
            }
            List<Account> accounts = [SELECT Id, BoundToLVLine__c FROM Account WHERE Id IN :ids];
            for(Account acc : accounts) {
                acc.BoundToLVLine__c = true;
            }
            database.update(accounts);
        }
    }
    
    global void finish(Database.BatchableContext CD){}

}