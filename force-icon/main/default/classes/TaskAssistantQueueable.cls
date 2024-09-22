public with sharing class TaskAssistantQueueable implements Queueable {
    public List<TaskAssistant__c> records;
    
    public TaskAssistantQueueable(List<TaskAssistant__c> records) {
        this.records = records;
    }
    
    public void execute(QueueableContext context) {
        updateTaskAssisant(records);
    }

    public static void updateTaskAssisant(List<TaskAssistant__c> taskAssistants){
        List<TaskAssistant__c> tasksToUpdate = new List<TaskAssistant__c>();
        List<String> wwEmployees =  new List<String>();
        Map<String,Id> ownersMap = new Map<String,Id>(); 

        for(TaskAssistant__c task : taskAssistants){
            if(String.isNotEmpty(task.WWEmployeeNumber__c))
                wwEmployees.add(task.WWEmployeeNumber__c);
        }

        ownersMap = getOwnerMap(wwEmployees);

        for(TaskAssistant__c record : taskAssistants){
            TaskAssistant__c task = record.clone(true,true,true,true);

            if(String.isNotEmpty(task.dreamId__c)){
                task.Client__r = new Account(DreamId__c = task.dreamId__c);

            }
            if(String.isNotEmpty(task.StoreCode__c)){
                task.Store__r = new Store__c(RetailStoreId__c = task.StoreCode__c); 
            }

            if(ownersMap.containsKey(task.WWEmployeeNumber__c)){
                task.OwnerId = ownersMap.get(task.WWEmployeeNumber__c);
            }
            tasksToUpdate.add(task);
        }

        if(!tasksToUpdate.isEmpty()){
            Database.update(tasksToUpdate,false);
        }    
    }



    public static Map<String,Id> getOwnerMap(List<String> wwEmployees){
        Map<String,Id> ownersMap = new Map<String,Id>(); 
        
        if(!wwEmployees.isEmpty()) {
            for(User user : [SELECT Id, WWEmployeeNumber__c FROM User WHERE WWEmployeeNumber__c IN: wwEmployees ]){
                ownersMap.put(user.WWEmployeeNumber__c,user.id);
            }
        }
        return ownersMap;
    }

    /*
    public void execute(QueueableContext context) {
        List<TaskAssistant__c> tasksToUpdate = new List<TaskAssistant__c>();
        List<String> wwEmployees =  new List<String>();
        List<String> dreamIds = new List<String>();
        List<String> storeCodes = new List<String>();

        for(TaskAssistant__c task : records){
            wwEmployees.add(task.WWEmployeeNumber__c);
            dreamIds.add(task.DreamId__c);
            storeCodes.add(task.StoreCode__c);
        }

        Map<String,Id> accountMap = getAccountMap(dreamIds); 
        Map<String,Id> ownersMap = getOwnerMap(wwEmployees);
        Map<String,Id> storeMap = getStoreMap(storeCodes); 
        

        for(TaskAssistant__c record : records){
            TaskAssistant__c task = record.clone(true,true,true,true);

            if(accountMap.containsKey(task.dreamId__c)){
                task.Client__c = accountMap.get(task.dreamId__c);
            }
            if(ownersMap.containsKey(task.WWEmployeeNumber__c)){
                task.OwnerId = ownersMap.get(task.WWEmployeeNumber__c);
            }
            if(storeMap.containsKey(task.StoreCode__c)){
                task.Store__c = storeMap.get(task.StoreCode__c);
            }
            tasksToUpdate.add(task);
        }

        if(!tasksToUpdate.isEmpty()){
            update tasksToUpdate;
        }
    }

    public static Map<String,Id> getAccountMap(List<String> dreamIds){
        Map<String,Id> accountMap = new Map<String,Id>(); 

        for(Account acc : [SELECT Id, DREAMID__c FROM Account WHERE DREAMID__c IN: dreamIds ]){
            accountMap.put(acc.DREAMID__c,acc.id);
        }
        return accountMap;
    }

    public static Map<String,Id> getStoreMap(List<String> storeCodes){
        Map<String,Id> storeMap = new Map<String,Id>(); 

        for(Store__c store : [SELECT Id, RetailStoreId__c FROM Store__c WHERE RetailStoreId__c IN: storeCodes ]){
            storeMap.put(store.RetailStoreId__c,store.id);
        }
        return storeMap;
    }
  	*/
}