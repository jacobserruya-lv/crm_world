/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 06-06-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
 * Modifications Log 
 * Ver   Date         Author                               Modification
 * 1.0   06-06-2021   ChangeMeIn@UserSettingsUnder.SFDoc   Initial Version
**/

trigger Task_AfterUpdate on Task (after update) {
 
    List<Task> myTasks = new List<Task>();
    if (IC_Utils.canTrigger('TSK_LASTCONTACTDATE')) {
        myTasks = IC_Task_TRG.toFilterTaskList(trigger.new);
    	if(myTasks !=null){  
            IC_Task_TRG.taskSetAccLastContactDate(myTasks);
    	}            
        //--- Create Notification For Inbound Call ---
        IC_Task_TRG.createNotificationInboundCall(trigger.new,Trigger.oldMap);

        //order approval process
        IC_Task_TRG.taskApprovalRejected(trigger.new,Trigger.newMap,Trigger.oldMap);
        


    }  
}