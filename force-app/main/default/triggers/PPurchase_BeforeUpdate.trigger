trigger PPurchase_BeforeUpdate on PPR_PurchProduct__c (before update) {
    If (IC_Utils.canTrigger('PPURCHASE')) {
        IC_PPurchase_TRG.checkIfActifSA(Trigger.new);
    }
}