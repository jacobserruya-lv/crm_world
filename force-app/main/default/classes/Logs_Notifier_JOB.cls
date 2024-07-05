global class Logs_Notifier_JOB implements Schedulable {
	global void execute(SchedulableContext sc) {
		Logs_Notifier_BATCH job = new Logs_Notifier_BATCH();
        ID batchprocessid = Database.executeBatch(job, 2000);
	}
}