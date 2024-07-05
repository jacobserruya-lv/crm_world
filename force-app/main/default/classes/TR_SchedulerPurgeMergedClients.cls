global class TR_SchedulerPurgeMergedClients implements Schedulable{
  global void execute(SchedulableContext SC) {
        TR_PurgeMergedClients bscl = new TR_PurgeMergedClients();
        ID batchprocessid = Database.executeBatch(bscl, 2000);
    }
}