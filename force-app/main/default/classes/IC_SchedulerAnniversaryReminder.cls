global class IC_SchedulerAnniversaryReminder implements Schedulable{

    global void execute(SchedulableContext sc) {

        IC_BatchAnniversaryReminder bat = new IC_BatchAnniversaryReminder();
        Integer scope = Integer.valueOf((Decimal)ICONSettings__c.getOrgDefaults().get('batchAnniversaryScope__c'));
        ID batchprocessid = Database.executeBatch(bat,!IC_UTILS.empty(scope) ? scope : 1000);
    }
}