/**
* @author Keman WU
* @date Creation 25/03/2021
* @description schedule auto cancellation for distant careservice
*/
public class ICX_SchedulerCareServiceAutoCancel implements Schedulable{

    public void execute(SchedulableContext SC) {
        ICX_BatchCareServiceAutoCancel batch = new ICX_BatchCareServiceAutoCancel();
        Database.executeBatch(batch,100);
    }

}