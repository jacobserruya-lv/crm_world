global class ICX_SchedulerRelateTransactionToCall implements Schedulable {
	global void execute(SchedulableContext sc) {
		ICX_BatchRelateTransactionToCall b = new ICX_BatchRelateTransactionToCall();
		database.executebatch(b);
	}
}