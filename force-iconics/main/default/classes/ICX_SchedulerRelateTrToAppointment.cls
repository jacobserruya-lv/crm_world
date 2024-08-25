global class ICX_SchedulerRelateTrToAppointment implements Schedulable {
    global void execute(SchedulableContext sc) {
		ICX_BatchRelateTransactionToAppointment b = new ICX_BatchRelateTransactionToAppointment();
		database.executebatch(b);
	}
}