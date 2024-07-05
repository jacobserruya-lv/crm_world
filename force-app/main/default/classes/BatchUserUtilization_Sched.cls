global without sharing class BatchUserUtilization_Sched implements Schedulable {
    global void execute(SchedulableContext sc) {
        // Calculation per country and global WW
        BatchUserUtilization cl = new BatchUserUtilization(null, 28, '', '');
        Id batchInstanceId = Database.executeBatch(cl, 5);
    }
}