global class IM_BatchDeleteOldPushNotificationItems implements Database.Batchable<sObject> {
	
	
	Datetime dateT;
	public String query;
    
    global IM_BatchDeleteOldPushNotificationItems(){
		dateT = System.now().addDays(-7);
        query = ' SELECT Id FROM Push_Notification_Item__c WHERE CreatedDate < : dateT OR Is_Silent_Push__c = TRUE'  ;
     }

	global database.querylocator start(Database.BatchableContext CD){
        System.debug('#### START - IM_BatchDeleteOldPushNotificationItems');
        System.debug('#### query : ' + query);
        return Database.getQueryLocator(query);   
    }

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		if(scope.size()>0){
			Database.emptyRecycleBin(scope);
		}

	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}