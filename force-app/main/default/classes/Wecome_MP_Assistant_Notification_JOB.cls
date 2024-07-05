global class Wecome_MP_Assistant_Notification_JOB implements Schedulable {
    global void execute(SchedulableContext sc) {
        // for first tests, just to CHINA TEAM USERS
        //Map<String, User> users = new Map<String, User>([SELECT id FROM USER WHERE name IN ('Esther Wahnon', 'Meir Benchimol','Sarah NIDERKORN','Vanessa Gao','Amine RAHIOUI')]);
        //Set<String> userIds = users.keySet();
        Wecome_MP_Assistant_Notification_Batch job;
        if (Test.isRunningTest()){
            job = new Wecome_MP_Assistant_Notification_Batch('Id = \''+ UserInfo.getUserId()+'\'');
        }else{
            job = new Wecome_MP_Assistant_Notification_Batch();//'Id IN ('+Wecome_MP_Assistant_Notification_Batch.listToString(userIds)+')');
        }
        ID batchprocessid = Database.executeBatch(job, 10);
    }
}