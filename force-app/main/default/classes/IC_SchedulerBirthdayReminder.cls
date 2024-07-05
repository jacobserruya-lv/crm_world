global class IC_SchedulerBirthdayReminder implements Schedulable{

    global void execute(SchedulableContext sc) {
    	
    	Integer scope = Integer.valueOf((Decimal)ICONSettings__c.getOrgDefaults().get('batchBirthdayReminderScope__c'));
        IC_BatchBirthdayReminder bat = new  IC_BatchBirthdayReminder();
        ID batchprocessid = Database.executeBatch(bat,!IC_UTILS.empty(scope) ? scope : 1000);           
        
    }
}