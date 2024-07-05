/**
* @File Name          : TR_CleanParallelMarket_Scheduler
* @Description        : 
* @Author             : Imad.alsidchikh.ext@louisvuitton.com
* @Group              : 
* @Last Modified By   : Imad.alsidchikh.ext@louisvuitton.com
* @Last Modified On   : 20-09-2022
* @Modification Log   : 
* Ver       Date            Author      		                     Modification
* 1.0       20-09-2022      Imad.alsidchikh.ext@louisvuitton.com     Initial Version
**/
global class TR_CleanParallelMarket_Scheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        TR_CleanParallelMarket_Batch bscl = new TR_CleanParallelMarket_Batch();
        ID batchprocessid = Database.executeBatch(bscl, 2000);
    }
}