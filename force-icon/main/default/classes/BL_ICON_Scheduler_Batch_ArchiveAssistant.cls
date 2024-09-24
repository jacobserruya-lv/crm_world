public with sharing class BL_ICON_Scheduler_Batch_ArchiveAssistant implements Schedulable {
    public void execute(SchedulableContext sc){
        Database.executeBatch(new BL_ICON_Batch_Archive_TaskAssistant(),200);
    }
}