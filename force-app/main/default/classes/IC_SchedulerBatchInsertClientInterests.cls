global class IC_SchedulerBatchInsertClientInterests implements Schedulable {
    global void execute(SchedulableContext sc) {
    	IC_BatchInsertClientInterests toRun = new IC_BatchInsertClientInterests();
		Database.executebatch(toRun,200); 
	}
}