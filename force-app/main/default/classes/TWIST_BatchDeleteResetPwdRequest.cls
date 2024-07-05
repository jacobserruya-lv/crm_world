/**
	Description: Batch + Scheduler used to delete lines in Reset_Password_Request__c object: object used to save reset password requests
	Created for: TWIST project
	Create date: 20/Nov/2022
	Update History
	--------------
	20/Nov/2022 / Twist / Created by Hanna Grumbach
*/
//BatchDeletePendingOSA
global class TWIST_BatchDeleteResetPwdRequest implements Database.Batchable<sObject>, Schedulable {
	
	String query;
	DateTime dt;
	
	global TWIST_BatchDeleteResetPwdRequest() {
        dt = DateTime.now().addDays(-(integer.valueOf(TWIST_Settings__c.getInstance().Purge_ResetPwdRequest__c)));
		query = 'SELECT Id FROM Reset_Password_Request__c WHERE CreatedDate < :dt';
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
	
	global void finish(Database.BatchableContext BC) {}

	global void execute(SchedulableContext sc) {
		TWIST_BatchDeleteResetPwdRequest b = new TWIST_BatchDeleteResetPwdRequest();
		database.executebatch(b, 10000);
	}
	
}