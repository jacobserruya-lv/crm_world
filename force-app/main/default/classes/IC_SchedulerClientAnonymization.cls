global class IC_SchedulerClientAnonymization implements Schedulable{

    global void execute(SchedulableContext sc) {    

    	IC_BatchClientAnonymization bat = new IC_BatchClientAnonymization();	
    	Integer scope = Integer.valueOf((Decimal)ICONSettings__c.getOrgDefaults().get('batchAnonymizationScope__c'));
        ID batchprocessid = Database.executeBatch(bat,!IC_UTILS.empty(scope) ? scope : 100);    
               
    }
}