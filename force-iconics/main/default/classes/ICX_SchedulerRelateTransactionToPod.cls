/**
* @description: Schedulable  class used to schedule ICX_BatchRelateTransactionToPod
*/
global class ICX_SchedulerRelateTransactionToPod implements Schedulable {
	global void execute(SchedulableContext sc) {
		ICX_BatchRelateTransactionToPod b = new ICX_BatchRelateTransactionToPod();
		database.executebatch(b);
	}
}