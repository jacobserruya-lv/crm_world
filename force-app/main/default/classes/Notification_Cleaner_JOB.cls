global class Notification_Cleaner_JOB implements Schedulable {
    global void execute(SchedulableContext sc) {
        Notification_Cleaner_BATCH job = new Notification_Cleaner_BATCH();
        ID batchprocessid = Database.executeBatch(job, 2000);
    }
}