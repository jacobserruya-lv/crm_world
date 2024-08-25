global with sharing class BL_ICON_Wardrobing_Encryption implements Database.Batchable<sObject>{
    
    
    public String query;
    global BL_ICON_Wardrobing_Encryption(){	
      
        query = 'SELECT Id ,TECH_EnCrypted_LookId__c FROM Look__c WHERE Createddate =  LAST_N_DAYS:90' ;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
       
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope) {
        try{

            List<Look__c> looks = (List<Look__c>) scope ;
            System.debug( 'SIZE' +scope.size());
            if(!scope.isEmpty())
            for(Look__c lk : looks){
                lk.TECH_EnCrypted_LookId__c = WRDB_WS_Look.getEncryptedId(lk.Id);

            }

            database.update(looks,false) ;
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext CD){}
}