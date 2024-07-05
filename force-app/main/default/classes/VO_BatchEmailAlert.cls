// class VO_Batch_SurveyScoring
// Recalcul du scoring des enqu?tes
// Author : Bernard Wach
// Version initiale : 05/10/2015

global without sharing class VO_BatchEmailAlert implements Database.Batchable<sObject> {

private List<ID> userIds = new List<ID>();
private final ID templateId;
private final String d;
private final string query;
	
// Constructor
global VO_BatchEmailAlert() {
	Date dte = Date.today().addDays(-1);
	d = dte.year() + (dte.month() < 10 ? '-0' : '-') + dte.month() + (dte.day() < 10 ? '-0' : '-') + dte.day();
	VO_Config__c cfg = VO_Config__c.getInstance('EmailAlertUserGroup');
	if (cfg==null) return;
	String grp = cfg.Value__c;

	if (!String.isBlank(grp)) {
		if (!Test.isRunningTest()) {
			for(GroupMember gm : [select Id, UserOrGroupId FROM GroupMember where group.name=: grp]) {
				userIds.add(gm.UserOrGroupId) ;
			}
		}
		else {
			List<User> lusers = [select id from User where Username = 'batchEmailAlert@lvtest.com'];
			if (!lusers.isEmpty()) userIds.add(lUsers[0].Id);
		}
		query = 'SELECT id, DefaultStore__c from User where id in :userIds AND DefaultStore__c !=NULL' ;
		//added by MY (DefaultStore__c !="" OR  DefaultStore__c !=NULL)
	}
	else return;
	
	EmailTemplate mail = [select id from EmailTemplate where DeveloperName = 'VO_Email_to_store_manager' limit 1];
	if (mail != null) templateId = mail.Id;
}

global Database.querylocator start(Database.BatchableContext BC){
	return Database.getQueryLocator(query);
}

global void finish(Database.BatchableContext info){
}

global void execute(Database.BatchableContext info, List<sObject> scope){
	List<Id> attendees = new List<Id>();
	Map<String, ID> storeIds = new Map<String, ID>();
	List<String> ls = new List<String>();
	List<User> lUsers = new List<User>();	

	for (sObject s : scope) {
		User u = (User) s;
		ls.add(u.DefaultStore__c);
		lUsers.add(u);
	}
	
	for (Store__c st : [select Id, RetailStoreId__c from Store__c where RetailStoreId__c in :ls])
		storeIds.put(st.RetailStoreId__c, st.Id);

	for (User u : lUsers) {	
		ID storeId = storeIds.get(u.DefaultStore__c);
		if (storeId != null) {			
			List<VO_Survey__c> lsrv = database.query('select id from VO_Survey__c where (Scoring__c = \'Recovery act\' or Scoring__c = \'Delighted client\') and Status__c = \'New\' and AnswerDate__c>=' + d + ' and Store__c = \'' + storeId + '\' limit 1');
			if (lsrv.size()>0) attendees.add(u.Id);
		}	
	}

	for (ID uId : attendees) {	
		Try {		
    	Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
     	mail.setTemplateID(templateId);
    	mail.setTemplateID(templateId);
    	mail.setSenderDisplayName('VOICE');
    	mail.setTargetObjectId(uId);
    	mail.saveAsActivity = false;
    	Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
		}
		catch (Exception e){
			system.debug(e);
		}
	}
}	
}