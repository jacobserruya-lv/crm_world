public with sharing class BL_ICON_Scheduler_Batch_ToDo_Assistant implements Schedulable {

    public void execute(SchedulableContext sc){
        Database.executeBatch(new BL_ICON_Batch_XstoreOrdersTodos(),200);
        Database.executeBatch(new BL_ICON_Batch_NY_OrdersTodos(),200);
    }
}