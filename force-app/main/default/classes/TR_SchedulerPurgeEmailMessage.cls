/***************************************************************************************************
* @File Name          : TR_SchedulerPurgeEmailMessage.cls
* @Description        : This class was created for schedule the purge emails messages
* @Author             : frank.peyo.basso.ext@louisvuitton.com
* @Group              : VO2
* @Last Modified By   : frank.peyo.basso.ext@louisvuitton.com
* @Last Modified On   : 01-02-2023  
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       01-02-2023         frank.peyo.basso.ext@louisvuitton.com     Initial Version

*****************************************************************************************************/
global class TR_SchedulerPurgeEmailMessage implements schedulable {
global void execute(SchedulableContext SC) {
        TR_PurgeEmailMessage bscl = new TR_PurgeEmailMessage();
        ID batchprocessid = Database.executeBatch(bscl, 200);
    }
}