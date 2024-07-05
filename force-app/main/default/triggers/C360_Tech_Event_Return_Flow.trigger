/***************************************************************************************************
* @File Name          : C360_Tech_Event_Return_Flow__e.apxt
* @Description        : This Trigger was created for the C360 Event Return Flow
* @Author             : Imad.alsidchikh@vo2-consultant.com
* @Group              : VO2
* @Last Modified By   : Imad.alsidchikh@vo2-consultant.com
* @Last Modified On   : 27-06-2022  
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       27-06-2022         Imad.alsidchikh@vo2-group.com     Initial Version
*****************************************************************************************************/
trigger C360_Tech_Event_Return_Flow on C360_Tech_Event_Return_Flow__e (after Insert) {
    
    for(C360_Tech_Event_Return_Flow__e evt : Trigger.New){
        ID jobID = System.enqueueJob(new TR_C360Flow_Queueable(evt, System.now()));
    }
}