global class Logs_Notifier_BATCH implements Database.Batchable<sObject>, Database.Stateful {
	
	String query;
	DateTime dt = System.now().addDays(-3);
	Set<String> apexClasses;
	Map<String,Map<String,LogsSetting__mdt>> settings;
	Global List<String> email_addresses;
	Global List<Blob> bloblist;
	
	global Logs_Notifier_BATCH() {
		bloblist=new List<Blob>();
		// GET SUPPORT ADDRESS
		email_addresses = new List<String>();
		List<Global_Settings__mdt> global_settings = [
            SELECT Value__c
            FROM Global_Settings__mdt 
            WHERE MasterLabel = 'Support Factory Email'
        ];

        if(!global_settings.isEmpty() && !String.isEmpty(global_settings[0].Value__c)){
        	email_addresses.addAll(global_settings[0].Value__c.split(','));
        }

		// GET SETTINGS 
		List<LogsSetting__mdt> settings_list = [
            SELECT Apex_Class__c, Level__c
            FROM LogsSetting__mdt 
            WHERE IsActive__c = true AND Notification_to_Support__c = true AND (Level__c = null OR Level__c = 'ALL' OR Level__c = 'ERROR')
        ];

        apexClasses = new Set<String>();
        for(LogsSetting__mdt setting : settings_list){
			apexClasses.add(setting.Apex_Class__c);
        }

        query = 'SELECT Name, CreatedDate, CreatedBy.Name, Apex_Class__c, Category__c, Type__c, Message__c, Trace__c, Remote_Address__c, API_Endpoint__c, API_Request__c, API_Response__c, Other_Details__c FROM Logs__c WHERE CreatedDate >=: dt AND Level__c = \'ERROR\' AND Apex_Class__c IN: apexClasses ORDER BY Apex_Class__c, Level__c, CreatedDate';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		
   		// CONVERT LOGS AS BLOB
   		String logs_as_strings = 'Name,CreatedDate,CreatedBy Name,ApexClass,Category__c,Type__c,Message__c,Trace__c,Remote_Address__c,API_Endpoint__c,API_Request__c,API_Response__c,Other_Details__c\n';
   		for(Logs__c log : (List<Logs__c>)scope){
			logs_as_strings += format(log.Name);
			logs_as_strings += format(log.CreatedDate.format());
			logs_as_strings += format(log.CreatedBy.Name);
			logs_as_strings += format(log.Apex_Class__c);
			logs_as_strings += format(log.Category__c);
			logs_as_strings += format(log.Type__c);
			logs_as_strings += format(log.Message__c);
			logs_as_strings += format(log.Trace__c);
			logs_as_strings += format(log.Remote_Address__c);
			logs_as_strings += format(log.API_Endpoint__c);
			logs_as_strings += format(log.API_Request__c);
			logs_as_strings += format(log.API_Response__c);
			logs_as_strings += format(log.Other_Details__c);
			logs_as_strings += '\n';
		}
		Blob excel = Blob.valueOf(logs_as_strings);
		bloblist.Add(excel);
		// CREATE ATTACH FILE
		
		 
	
	}
	
	global void finish(Database.BatchableContext BC) {
		List<Messaging.EmailFileAttachment> attachlist = new List<Messaging.EmailFileAttachment>();
		for (Blob c : bloblist){
			Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
			attach.setBody(c);
			attach.setFileName('Logs ' + System.now() + '.xls');
			attachlist.Add(attach);
		}
		//Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
		//attach.setBody(bloblist);
		//attach.setFileName('Logs ' + System.now() + '.xls');
	// SEND EMAIL
	Messaging.singleEmailMessage email = new Messaging.singleEmailMessage();
	email.setSubject('[SUPPORT] - Weekly Report, Custom Logs');
	email.setToaddresses(email_addresses);
	email.setPlainTextBody('You can find here the error log of the last three days.');
	email.setFileAttachments(attachlist);
	Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});


	}
	
	private String format(String field){
		if(!String.isEmpty(field)){
			field = field.replace(',', ';');
			field = field.replace('\n', ' ');
		}
		else{
			field = '';
		}

		return field + ',';
	}
}