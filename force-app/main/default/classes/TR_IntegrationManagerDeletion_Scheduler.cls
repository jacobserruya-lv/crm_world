/**
* @File Name          : TR_IntegrationManagerDeletion_Scheduler
* @Description        : 
* @Author             : Imad.alsidchikh.ext@louisvuitton.com
* @Group              : 
* @Last Modified By   : Imad.alsidchikh.ext@louisvuitton.com
* @Last Modified On   : 20-11-2022
* @Modification Log   : 
* Ver       Date            Author      		                     Modification
* 1.0       20-11-2022      Imad.alsidchikh.ext@louisvuitton.com     Initial Version
**/
global class TR_IntegrationManagerDeletion_Scheduler implements Schedulable {
    global void execute(SchedulableContext SC) {
        TR_BatchIntegrationManagerDeletion bscl = new TR_BatchIntegrationManagerDeletion();
        Database.executeBatch(bscl, 500);
    }
}