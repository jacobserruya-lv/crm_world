public with sharing class IM_SchedulerDeactivateExpiredClisBatch implements Schedulable {
    
    public void execute(SchedulableContext sc){
        Database.executeBatch(new IM_DeactivateExpiredClientListsBatch(),1);
    }

}

// Should run once a day. need to put this code in Developer Console.
// IM_SchedulerDeactivateExpiredClisBatch sch = new IM_SchedulerDeactivateExpiredClisBatch();
// System.schedule('IM_DeactivateExpiredClientListsBatch', '0 0 0 * * ?', sch);