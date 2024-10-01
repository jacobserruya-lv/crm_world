/**
	Description: Batch + Scheduler used to delete lines in TwistCacheManager__c object: object used to block user for age restriction
	Created for: TWIST project
	Create date: 26/Fev/2024
	--------------
	26/Fev/2024 / Twist / Created by Mohamed SACKO
*/
global class TWIST_BatchDeleteTwistCacheManager implements Database.Batchable<sObject>, Schedulable {
    String query;
    
    global TWIST_BatchDeleteTwistCacheManager() {
        query = 'SELECT Key__c, LangCountry__c, TTL__c, Value__c, Type__c, CreatedDate, isblocked__c FROM TwistCacheManager__c WHERE isblocked__c = false';
    }
	
    global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext bc, List<sObject> scope){
        try{
            if(scope.size() > 0){
            	delete scope;
        	}
        }catch (DmlException e){
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
    }
    
    global void finish(Database.BatchableContext bc){}
    
    global void execute(SchedulableContext sc) {
		TWIST_BatchDeleteTwistCacheManager b = new TWIST_BatchDeleteTwistCacheManager();
		database.executebatch(b, 200);
	}
}