global class ICX_PPR_voicenotif_scheduleUpdate  implements Schedulable {
    global void execute(SchedulableContext sc) {
        Set<Id> clientSet = new Set<Id>();
        Set<String> storeSet = new Set<String>();
        List<PPR_PurchProduct__c> pprToUpdate = new List<PPR_PurchProduct__c>();
        for (CareService__c cs : [SELECT client__c, Store__r.RetailStoreId__c FROM CareService__c WHERE ICONiCS_Status_Detail__c = 'Delivered to Client']) {
            clientSet.add(cs.client__c);
            storeSet.add(cs.Store__r.RetailStoreId__c);
        }
    
        for(PPR_PurchProduct__c ppr : [SELECT DCS_Voice_notif__c ,Client__c, Store__c FROM PPR_PurchProduct__c WHERE DCS_Voice_notif__c = false AND TransactionType__c = '8' and client__c in:clientSet and store__c in:storeSet])
        {            
                ppr.DCS_Voice_notif__c = true;
                pprToUpdate.add(ppr);
            
        }
        update pprToUpdate;
    }
}