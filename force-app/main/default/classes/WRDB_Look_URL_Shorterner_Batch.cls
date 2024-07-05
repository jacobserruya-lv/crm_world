global  class WRDB_Look_URL_Shorterner_Batch implements Database.Batchable<sObject>,Database.AllowsCallouts {

       
    public String query;
    
    global WRDB_Look_URL_Shorterner_Batch(){
        query = ' Select SHORT_LV_URL_Sharing__c, LV_URL_Sharing__c, SHORT_Picture_URL__c, Picture_URL__c '+
        '  From Look__c where SHORT_LV_URL_Sharing__c = null  OR SHORT_Picture_URL__c = null ';
    }
        
    global database.querylocator start(Database.BatchableContext CD){
        System.debug('#### START - WRDB_Look_URL_Shorterner_Batch');
        System.debug('#### query : ' + query);
        return Database.getQueryLocator(query);   
    } 
    
    global void execute(Database.BatchableContext CD, List<sObject> scope){
        try{
            
            if(scope.size() > 0){
                this.setShortUrl((List<Look__c>) scope);
            }
            
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }       
    }
    
    global void finish(Database.BatchableContext CD){
    }

    private void setShortUrl(List<Look__c> looks){
        system.debug(looks.size());
        for(Look__c l : looks){
            if(String.isEmpty(l.SHORT_LV_URL_Sharing__c) && String.isNotEmpty(l.LV_URL_Sharing__c)){
                l.SHORT_LV_URL_Sharing__c = WRDB_WS_Look.getShortenedLookLVURL(l.LV_URL_Sharing__c);
            }

            if(String.isEmpty(l.SHORT_Picture_URL__c) && String.isNotEmpty(l.Picture_URL__c)){
                l.SHORT_Picture_URL__c = WRDB_WS_Look.getShortenedLookLVURL(l.Picture_URL__c);
            }
        }

        Database.update(looks, false);
    }
}