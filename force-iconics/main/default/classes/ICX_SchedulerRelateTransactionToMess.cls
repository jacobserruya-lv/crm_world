/**
* @description: Schedulable  class used to schedule ICX_BatchRelateTransactionToMessaging
*/
global class ICX_SchedulerRelateTransactionToMess implements Schedulable {
	global void execute(SchedulableContext sc) {
		ICX_BatchRelateTransactionToMessaging b = new ICX_BatchRelateTransactionToMessaging();
		database.executebatch(b);
	}
}