/**
* @File Name          : TR_C360LogPurge_Scheduler
* @Description        : 
* @Author             : Imad.alsidchikh.ext@louisvuitton.com
* @Group              : 
* @Last Modified By   : Imad.alsidchikh.ext@louisvuitton.com
* @Last Modified On   : 20-11-2022
* @Modification Log   : 
* Ver       Date            Author      		                     Modification
* 1.0       20-11-2022      Imad.alsidchikh.ext@louisvuitton.com     Initial Version
**/
global class TR_C360LogPurge_Scheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        TR_BatchC360LogPurge bscl = new TR_BatchC360LogPurge();
        Database.executeBatch(bscl, 500);
    }
}