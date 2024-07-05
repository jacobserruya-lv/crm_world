/**
* @description: Schedulable  class used to schedule SPO_BatchPendingBriefNotification
*
* @modification history:
*
*/
global class SPO_SchedulerPendingBriefNotification implements Schedulable{

    global void execute(SchedulableContext sc)
    {
        // schedule pending brief notification batch
        SPO_BatchPendingBriefNotification b = new SPO_BatchPendingBriefNotification();
        database.executeBatch(b);
    }
}