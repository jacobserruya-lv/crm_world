global class Notification_Sender_JOB implements Schedulable {

    global void execute(SchedulableContext sc) {
        Notification_Sender_BATCH job = new Notification_Sender_BATCH();
        ID batchprocessid = Database.executeBatch(job, 2000);
    }
    
}