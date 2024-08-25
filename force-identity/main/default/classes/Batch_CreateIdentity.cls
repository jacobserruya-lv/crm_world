global class Batch_CreateIdentity implements Database.Batchable<sObject> {
	
	String query;
	
	global Batch_CreateIdentity() {
		query = 'SELECT TECH_Email__c, Email FROM User WHERE Is_Identity_User__c = true AND IsActive = true AND TECH_Email__c = \'\'';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('#### START - Batch_CreateIdentity');
		System.debug('#### QUERY : ' + query);

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		try{

			for(User u : (List<User>) scope){
				u.TECH_Email__c = u.Email;
			}

			Database.SaveResult[] SRs = Database.update(scope, false);

			for(Database.SaveResult sr : SRs){
				if (!sr.isSuccess()) {
			    	System.debug('FAILED - USER ID: ' + sr.getId());
			        for(Database.Error err : sr.getErrors()) {
			            System.debug('EXCEPTION: ' + err.getMessage());
			        }
			    }
			}
		 }
		 catch(DmlException e) {
            System.debug('#### ' + e.getTypeName() + ' Exception:' + e.getMessage() + ' ' + e.getStackTraceString());
        }
	}
	
	global void finish(Database.BatchableContext BC) {
		System.debug('#### END - Batch_CreateIdentity');
	}
	
}