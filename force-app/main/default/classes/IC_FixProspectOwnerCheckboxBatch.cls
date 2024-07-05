global class IC_FixProspectOwnerCheckboxBatch implements Database.Batchable<sObject> {
	
	String query;
	
	global IC_FixProspectOwnerCheckboxBatch() {
		query = 'SELECT Id, TECH_OwnerManuallyChangedForProspect__c FROM Account WHERE IsProspect__pc = TRUE AND Owner.IsTechnicalUser__c = FALSE AND CreatedDate < 2019-04-03T00:00:00.000+0000';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Account> scope) {
		for(Account account: scope) {
			account.TECH_OwnerManuallyChangedForProspect__c = true;
		}
		update scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}