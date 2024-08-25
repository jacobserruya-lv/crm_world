global class ICX_SchedulerRelateTransactionToLiveChat implements Schedulable {
	global void execute(SchedulableContext sc) {
		ICX_BatchRelateTransactionToLiveChat b = new ICX_BatchRelateTransactionToLiveChat();
		database.executebatch(b);
	}
}