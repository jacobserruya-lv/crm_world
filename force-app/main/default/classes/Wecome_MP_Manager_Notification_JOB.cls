global class Wecome_MP_Manager_Notification_JOB implements Schedulable {
    global void execute(SchedulableContext sc) {
        Wecome_MP_Manager_Notification_Batch job;
        if (Test.isRunningTest()){
            job = new Wecome_MP_Manager_Notification_Batch('Id = \''+ UserInfo.getUserId()+'\'');
        }else{
            job = new Wecome_MP_Manager_Notification_Batch();
        }
        ID batchprocessid = Database.executeBatch(job, 10);
    }
}