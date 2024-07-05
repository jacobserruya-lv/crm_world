trigger Task_BeforeInsert on Task (before insert) {

    // fill whoId
    IC_Task_TRG.setWhoId(Trigger.New);
    
    If (IC_Utils.canTrigger('TASK')) {
        IC_Task_TRG.taskSetDreamIds(Trigger.new);
        //This trigger is fired only when the task comes from worflow after client list insertion
        if(IC_Utils.canTrigger('TSK_AUTOSAVE'))
            IC_Task_TRG.taskSetAutoSaveField(Trigger.new);
    }

    for(Task task : trigger.new){
        task.AppointmentType__c = null;
    }

    //IC_Task_TRG.updateActionTypeAsEmail(Trigger.new);
    IC_Task_TRG.updateTypeAsCall(Trigger.New);
    IC_Task_TRG.relatedCaseTaskToAccount(Trigger.new);
    
    If (IC_Utils.canTrigger('BANNEDWORDS')&& !IC_utils.isIconicsProfile()){
        //
        List<String> bannedWords = IC_BannedWords.checkWords(Trigger.new, 'Task');
        if(!bannedWords.isEmpty())
            Trigger.new[0].addError(String.format(Label.IC_Banned_Words_Message, new String[] {String.join(bannedWords,',')}));
    }
        
}