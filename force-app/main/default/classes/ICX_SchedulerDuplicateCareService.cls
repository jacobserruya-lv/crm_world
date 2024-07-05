/**
* @author Keman WU
* @date Creation 14/12/2021
* @description scheduler batch to cancel duplicate distant careservice
*/
public class ICX_SchedulerDuplicateCareService implements Schedulable{

    public void execute(SchedulableContext SC) {
        ICX_BatchDuplicateCareService batch = new ICX_BatchDuplicateCareService();
        Database.executeBatch(batch,200);
    }

}