global class Logs_Cleaner_JOB implements Schedulable {
    global void execute(SchedulableContext sc) {
        Logs_Cleaner_BATCH job = new Logs_Cleaner_BATCH();
        ID batchprocessid = Database.executeBatch(job, 2000);
    }
}