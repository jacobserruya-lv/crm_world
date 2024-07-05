global class IC_SchedulerExceptionalPurchase implements Schedulable {
	
	    global void execute(SchedulableContext sc) {

        IC_BatchExceptionalPurchase bat = new IC_BatchExceptionalPurchase();
        ID batchprocessid = Database.executeBatch(bat,1000);           
    }

}