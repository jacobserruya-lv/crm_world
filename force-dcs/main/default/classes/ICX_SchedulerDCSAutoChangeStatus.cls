/**
* @author Keman WU
* @date Creation 27/09/2022
* @description schedule auto change status for distant careservice
*/
public class ICX_SchedulerDCSAutoChangeStatus implements Schedulable{

    public void execute(SchedulableContext SC) {
        ICX_BatchDCSAutoChangeStatus batch = new ICX_BatchDCSAutoChangeStatus();
        Database.executeBatch(batch,10);
    }

}