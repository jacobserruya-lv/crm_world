public with sharing class IC_SchedulerTCLBatch implements Schedulable {

    public void execute(SchedulableContext sc){
        Database.executeBatch(new IC_BatchCreateListMembers(),1);
    }
    

}