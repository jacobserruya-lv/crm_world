global class WRDB_Look_URL_Shorterner_Batch_Scheduler implements Schedulable{

    global void execute(SchedulableContext sc) {
        WRDB_Look_URL_Shorterner_Batch bat = new WRDB_Look_URL_Shorterner_Batch();
        ID batchprocessid = Database.executeBatch(bat,10);           
    }
}