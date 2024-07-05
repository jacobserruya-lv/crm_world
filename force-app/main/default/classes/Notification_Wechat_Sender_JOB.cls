global class Notification_Wechat_Sender_JOB implements Schedulable {
    global void execute(SchedulableContext sc) {
        Notifcation_BATCH_Wechat_Sender job = new Notifcation_BATCH_Wechat_Sender();
        ID batchprocessid = Database.executeBatch(job, 20);
    }
}