/*
* @Last Modified By   : calevm@balink.net
* @Last Modified On   : 06-20-2023 
*/

trigger PPurchase_AfterInsert on PPR_PurchProduct__c (after insert) {
    PPR_PurchProductTriggerHandler.handleAfterInsert(Trigger.New);
    If (IC_Utils.canTrigger('PPURCHASE_AFTER')) {
   //     IC_PPurchase_TRG.ExcepPurchases(Trigger.new);
    }
}