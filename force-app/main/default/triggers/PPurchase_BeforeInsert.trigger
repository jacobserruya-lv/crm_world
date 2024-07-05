trigger PPurchase_BeforeInsert on PPR_PurchProduct__c (before insert) {
    If (IC_Utils.canTrigger('PPURCHASE')) {
        IC_PPurchase_TRG.deleteDuplicatePurchProduct(Trigger.new);
        IC_PPurchase_TRG.checkIfActifSA(Trigger.new);
    }
}