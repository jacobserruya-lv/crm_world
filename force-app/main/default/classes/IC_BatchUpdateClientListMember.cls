global class IC_BatchUpdateClientListMember implements Database.Batchable<sObject> {
	
	String query;
	
	global IC_BatchUpdateClientListMember() {
		query = 'SELECT Id FROM CLM_CliListMember__c WHERE TECH_External_Id__c = null';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Database.SaveResult> resultList = Database.update(scope, false);
		System.debug('resultList: ' + resultList);
	}
	
	global void finish(Database.BatchableContext BC) {
		IC_BatchClientListMemberDuplicateDelete bat = new IC_BatchClientListMemberDuplicateDelete();
        ID batchprocessid = Database.executeBatch(bat);           
	}
	
}