global class LogsCleaner_Batch_Scheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
		LogsCleaner_Batch b = new LogsCleaner_Batch();
		database.executebatch(b);
	}
}