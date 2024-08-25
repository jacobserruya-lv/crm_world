global class TWIST_BatchVerificationCodeCleaner implements Database.Batchable<sObject> , Schedulable {
    
    String query;
	DateTime dt;
	
	global TWIST_BatchVerificationCodeCleaner() {
        dt = DateTime.now().addDays(-(integer.valueOf(TWIST_Settings__c.getInstance().PurgeVerificationCodeIntervalInDays__c)));
		query = 'SELECT Id FROM Registration_Code_Verification_Request__c WHERE CreatedDate < :dt';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		try{
            if(scope.size() > 0){
            	delete scope;
        	}
        }catch (DmlException e){
            // Process exception here
            System.debug('#### '+e.getTypeName()+' Exception:'+e.getMessage()+' '+e.getStackTraceString());
        }
	}

	global void finish(Database.BatchableContext CD){}

	global void execute(SchedulableContext sc) {
		TWIST_BatchVerificationCodeCleaner b = new TWIST_BatchVerificationCodeCleaner();
		database.executebatch(b, 2000);
	}

}