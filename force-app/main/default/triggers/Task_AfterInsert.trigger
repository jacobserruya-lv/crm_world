trigger Task_AfterInsert on Task (after insert) {
    List<Task> myTasks = new List<Task>();
    
    if (IC_Utils.canTrigger('TSK_LASTCONTACTDATE')) {
        myTasks = IC_Task_TRG.toFilterTaskList(trigger.new);
        if(myTasks!=null){
          IC_Task_TRG.taskSetAccLastContactDate(myTasks);
        }
    }
    IC_Task_TRG.updateActionTypeAsEmail(Trigger.new);

    Task_TriggerHandler.afterInsert(trigger.new, trigger.newMap);
    
}