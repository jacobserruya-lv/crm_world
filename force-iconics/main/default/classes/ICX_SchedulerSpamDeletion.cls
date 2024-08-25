/**
* @description: Schedulable  class used to schedule ICX_BatchSpamDeletion
*
* @modification history:
*
*/
global class ICX_SchedulerSpamDeletion implements Schedulable {


    global void execute(SchedulableContext sc) {

        // schedule the spam deletion batch
        ICX_BatchSpamDeletion b = new ICX_BatchSpamDeletion();
        database.executebatch(b);
    }
}