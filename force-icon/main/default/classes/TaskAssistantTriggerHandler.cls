public with sharing class TaskAssistantTriggerHandler {
    
    public static void handleTrigger(List<TaskAssistant__c> newList, Map<Id, TaskAssistant__c> newMap, List<TaskAssistant__c> oldList, Map<Id, TaskAssistant__c> oldMap, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when AFTER_INSERT {
                handleAfterInsert(newList);
            }
        }
    }

    public static void handleAfterInsert(List<TaskAssistant__c> newList) {
        System.enqueueJob(new TaskAssistantQueueable(newList));
    }
        /*
        
    public static void handleAfterInsert(List<TaskAssistant__c> newList) {{
        List<Account> accounts = [SELECT Id, DREAMID__c FROM Account WHERE DREAMID__c IN: dreamIds ];
        List<User> owners = [SELECT Id, WWEmployeeNumber__c FROM User WHERE WWEmployeeNumber__c IN: wwEmployees ];
        List<Store__c> stores = [SELECT Id, RetailStoreId__c FROM Store__c WHERE RetailStoreId__c IN: storeCodes ];

        Map<String,Id> accountMap = new Map<String,Id>(); 
        Map<String,Id> ownersMap = new Map<String,Id>(); 
        Map<String,Id> storeMap = new Map<String,Id>(); 

        for(Account acc :accounts){
            accountMap.put(acc.DREAMID__c,acc.id);
        }

        for(User user :owners){
            ownersMap.put(user.WWEmployeeNumber__c,user.id);
        }

        for(Store__c store :stores){
            storeMap.put(store.RetailStoreId__c,store.id);
        }

        for(TaskAssistant__c task : newList){
            if(accountMap.containsKey(task.dreamId__c)){
                task.Client__c = accountMap.get(task.dreamId__c);
            }
            if(ownersMap.containsKey(task.WWEmployeeNumber__c)){
                task.OwnerId = ownersMap.get(task.WWEmployeeNumber__c);
            }
            if(storeMap.containsKey(task.StoreCode__c)){
                task.Store__c = storeMap.get(task.StoreCode__c);
            }
        }
    }*/
}