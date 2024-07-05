/***************************************************************************************************
* @File Name          : TR_SchedulerIndividualEmailResultPurge.cls
* @Description        : This class was created for the C360 DELETE TechRecords
* @Author             : hamza.bouzid.ext@louisvuitton.com
* @Group              : VO2
* @Last Modified By   : hamza.bouzid.ext@louisvuitton.com
* @Last Modified On   : 06-10-2022  
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       06-10-2022         hamza.bouzid.ext@louisvuitton.com     Initial Version

*****************************************************************************************************/
global class TR_SchedulerIndividualEmailResultPurge implements Schedulable {
    global void execute(SchedulableContext SC) {
        TR_IndividualEmailResultPurge bscl = new TR_IndividualEmailResultPurge();
        ID batchprocessid = Database.executeBatch(bscl, 2000);
    }
}