/***************************************************************************************************
* @File Name          : TR_SchedulerPurgeDeletedRecordLog.cls
* @Description        : This class was created for schedule the pruge of record logs
* @Author             : frank.peyo.basso.ext@louisvuitton.com
* @Group              : VO2
* @Last Modified By   : frank.peyo.basso.ext@louisvuitton.com
* @Last Modified On   : 02-11-2022  
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       02-11-2022         frank.peyo.basso.ext@louisvuitton.com     Initial Version

*****************************************************************************************************/

global class TR_SchedulerPurgeDeletedRecordLog implements Schedulable{
  global void execute(SchedulableContext SC) {
        TR_PurgeDeletedRecordLog bscl = new TR_PurgeDeletedRecordLog();
        ID batchprocessid = Database.executeBatch(bscl, 2000);
    }
}