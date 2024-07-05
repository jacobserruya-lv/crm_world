global class IC_BatchInactiveInterests implements Database.Batchable<sObject> {
	
	String query;
	
	global IC_BatchInactiveInterests() {
		query = 'select Id,isActive__c,Client__c,Categories__c,TECH_ExtId__c,Priority__c FROM Interests__c Where (isActive__c = false AND Priority__c != \'\')';
		if(!Test.isRunningTest()){
			query += 'OR (isActive__c = true and LastModifiedDate < TODAY)';
		}
		system.debug('###query = '+ query);
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		List<sObject> interestsToUpload = new List<sObject>();
		for(sObject i : scope){
			i.put('isActive__c',false);
			i.put('Priority__c','');
			interestsToUpload.add(i);
		}

		if(interestsToUpload.size()>0){
			update interestsToUpload;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}