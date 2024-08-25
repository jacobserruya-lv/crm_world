public class TracabilityRecordTriggerHandler {

    public static void handleTrigger(List<Export_Purchases_Tracability__c> newList, Map<Id,Export_Purchases_Tracability__c> newMap, List<Export_Purchases_Tracability__c> oldList, Map<Id,Export_Purchases_Tracability__c> oldMap, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when AFTER_INSERT{
                handleAfterInsert(newList);
            }
            //when AFTER_UPDATE{
            //    handleAfterUpdate(oldMap, newList);
            //}
        }

    }

    public static void handleAfterInsert(List<Export_Purchases_Tracability__c> newList){
        for(Export_Purchases_Tracability__c tracabilityRecord : newList){
            if(tracabilityRecord.Status__c != 'Ready To Download') {
                Queueable job = new ICX_PurchasesExportQueueable(tracabilityRecord.DreamId__c, tracabilityRecord.Id); //cannot enqueue more than 5 jobs due to SF limitation --> cannot do more than 4 retry
                System.enqueueJob(job);
            }

        }
    }

}