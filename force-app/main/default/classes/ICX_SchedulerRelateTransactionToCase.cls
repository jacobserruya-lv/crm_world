global class ICX_SchedulerRelateTransactionToCase implements Schedulable {
	global void execute(SchedulableContext sc) {
		ICX_BatchRelateTransactionToCase b = new ICX_BatchRelateTransactionToCase();
		database.executebatch(b);
	}
}