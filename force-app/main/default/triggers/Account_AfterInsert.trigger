trigger Account_AfterInsert on Account (after insert) {
    If (IC_Utils.canTrigger('ACCOUNT')) {
        // If (IC_Utils.canTrigger('PROSPECT'))
        //  IC_PersonAccount_TRG.manageProspect(Trigger.new);
    }
}