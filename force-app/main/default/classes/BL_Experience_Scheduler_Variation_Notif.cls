global with sharing class BL_Experience_Scheduler_Variation_Notif implements Schedulable {

    global void execute(SchedulableContext SC) {
        BL_Experience_Batch_Variation_Notif bscl = new BL_Experience_Batch_Variation_Notif();
        ID batchprocessid = Database.executeBatch(bscl, 2000);
    }
}