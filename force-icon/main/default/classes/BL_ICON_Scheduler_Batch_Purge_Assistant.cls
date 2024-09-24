public with sharing class BL_ICON_Scheduler_Batch_Purge_Assistant implements Schedulable {

    public void execute(SchedulableContext sc){
        Database.executeBatch(new BL_ICON_Batch_Purge_TaskAssistant(),200);
    }
}