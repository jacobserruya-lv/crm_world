global class IC_SchedulerBatchDeleteOldInterestFiles implements Schedulable {
	global void execute(SchedulableContext sc) {
    	IC_BatchDeleteOldInterestFiles toRun = new IC_BatchDeleteOldInterestFiles();
		Database.executebatch(toRun); 
	}
}