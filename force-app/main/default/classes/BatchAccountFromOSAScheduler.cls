global class BatchAccountFromOSAScheduler implements Schedulable {

    global void execute(SchedulableContext SC) {
        BatchAccountFromOSA bscl = new BatchAccountFromOSA();
        ID batchprocessid = Database.executeBatch(bscl, 2000);
    }
}