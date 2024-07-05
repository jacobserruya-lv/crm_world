global class ICX_SchedulerRelateTrToOutboundCall implements Schedulable {
	global void execute(SchedulableContext sc) {
		ICX_RelateTransactionToOutboundCall b = new ICX_RelateTransactionToOutboundCall();
		database.executebatch(b);
	}
}