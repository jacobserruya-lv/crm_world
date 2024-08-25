/***************************************************************************************************
* @File Name          : TR_C360Flow_Queueable.cls
* @Description        : This Queueable class was created for the C360 Event Return Flow
* @Author             : Imad.alsidchikh@vo2-consultant.com
* @Group              : VO2
* @Last Modified By   : Imad.alsidchikh@vo2-consultant.com
* @Last Modified On   : 09-05-2022  
* @Modification Log   :
* Ver       Date               Author                            Modification
* 1.0       09-05-2022         Imad.alsidchikh@vo2-group.com     Initial Version
*****************************************************************************************************/
public class TR_C360Flow_Queueable implements Queueable {
    @testVisible
    public static Boolean isChainFirstJob = true;
    public C360_Tech_Event_Return_Flow__e cterf;
    public DateTime startTime;
    
    public TR_C360Flow_Queueable(C360_Tech_Event_Return_Flow__e cterf ,DateTime startTime) {
        this.cterf = cterf;
        this.startTime = startTime;
    }
    
    public void execute(QueueableContext context) { 
        if(cterf != null){
            TR_C360_IntegrationManager_Utils.setAccountEventBus(cterf,startTime); 
        }
    }
    
}