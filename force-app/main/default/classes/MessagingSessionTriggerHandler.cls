public class MessagingSessionTriggerHandler {

    public static void handleTrigger(List<MessagingSession> newList, Map<Id, MessagingSession> newMap, List<MessagingSession> oldList, Map<Id, MessagingSession> oldMap, System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            
            when AFTER_INSERT {       
                
                updateAsyncQueue(newMap);
                handleAfterInsert(newList, newMap);
            }
            when AFTER_UPDATE {
                handleAfterUpdate(oldList, oldMap, newList, newMap);
            }
            when else {
                //do nothing for AFTER_UNDELETE, BEFORE_DELETE, or BEFORE_UPDATE
            }
        }
    }
  
    public static void handleAfterInsert(List<MessagingSession> newList, Map<Id, MessagingSession> newMap) {
        List<Task> tskList = new List<Task>();
        for (MessagingSession mess : [SELECT Id, Name,EndUserContactId, MessagingEndUser.ContactId,channelType,Country__c,createdDate FROM MessagingSession WHERE Id IN :newMap.keyset()]) { 
            if (mess.MessagingEndUserId!=null && String.isNotBlank(mess.MessagingEndUser.ContactId) ) {
               tskList.add(createTask(mess));
               
            }
        }
       if (!tskList.isEmpty()){
            insert tskList;
       }
    }
    
    private static void updateAsyncQueue(Map<Id, MessagingSession> newMap){
       UpdateMessagingQueueAsync up = new UpdateMessagingQueueAsync(newMap.keySet());
       DateTime cTime = system.now().addSeconds(5);
       String sch = cTime.second() +' '+ cTime.minute() +' '+ cTime.hour() + ' '+ cTime.day()+' '+cTime.month()+' ? '+cTime.Year();

       String messagingName =newMap.values()[0].Name;

       system.schedule('AsyncQueueUpdate'+messagingName , sch, up);
    }
    
    public static void handleAfterUpdate(List<MessagingSession> oldList, Map<Id, MessagingSession> oldMap, List<MessagingSession> newList, Map<Id, MessagingSession> newMap) {
        List<String> nature = getPicklistValue('Task','Nature__c');
        List<String> resolution = getPicklistValue('Task','Resolution__c');
        List<Task> tskList = new List<Task>();
        List<Task> tskUpdateList = new List<Task>();
        List<String> messagingName = new List<String>();
        for (MessagingSession mess : newList) { 
            messagingName.add('Messaging ' + mess.Name);
        }
        
        Map<String,Task> listTask = getTaskMap(messagingName);

        for (MessagingSession mess : [SELECT Id, Name,nature__c ,Product_SKU_Unknown__c ,Product_SKU__c ,category__c,Domaine__c ,EndUserContactId, MessagingEndUser.ContactId,channelType,OwnerId ,Resolution__c, Country__c,createdDate FROM MessagingSession WHERE Id IN :newList]) {            
           
           Task t = new task();
            if (String.isNotBlank(mess.MessagingEndUser.ContactId) && !listTask.containsKey('Messaging ' + mess.Name)){
                t= createTask(mess);
                updateTask(t,mess,nature,resolution);
                tskList.add(t);
            }else if(listTask.containsKey('Messaging ' + mess.Name)){
                t = listTask.get('Messaging ' + mess.Name);                
                updateTask(t,mess,nature,resolution);
                tskUpdateList.add(t);
            }
        }
        if (!tskList.isEmpty()) {
            insert tskList;
        }
        if (!tskUpdateList.isEmpty()) {
            update tskUpdateList;
        }
    }

    public static Task createTask(MessagingSession mess){
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('ICONICS_Chat').getRecordTypeId();
        Task tsk = new Task();

        tsk.WhoId = mess.MessagingEndUser.ContactId;  
        tsk.Status = 'Completed';  
        tsk.InOut__c ='In';
        tsk.Subject = 'Messaging ' + mess.Name;  
        tsk.Priority ='Low';  
        tsk.ActivityDate = mess.createdDate.date();
        tsk.ActionType__c =  (mess.channelType =='Text' ? 'SMS' : mess.channelType);
        tsk.ICX_Country__c = mess.Country__c;
        tsk.RecordTypeId = recordTypeId;
        return tsk;
    }    
    
    private static Map<String,Task> getTaskMap(List<String> messagingName){
        Map<String,Task> taskMap = new Map<String,Task>();
        for(Task taskRecord : [SELECT Id,Subject FROM Task WHERE Subject in: messagingName]){
            if(!taskMap.containsKey(taskRecord.Subject)){
                taskMap.put(taskRecord.Subject,taskRecord);
            }
        }
        return taskMap;
    }

    private static Task updateTask(Task task, MessagingSession mess, List<String> nature ,List<String> resolution){
        
        task.nature__c = (nature.contains(mess.nature__c) ? mess.nature__c : '');
        task.category__c = mess.category__c;
        task.resolution__c =(resolution.contains(mess.resolution__c) ? mess.resolution__c : '');
        task.Domaine__c = mess.Domaine__c;
        task.Product_SKU_Unknown__c = mess.Product_SKU_Unknown__c ;
        task.Product_SKU__c = mess.Product_SKU__c ;
        return task;
       
    }
    private static List<String> getPicklistValue(String selectedObject, String selectedField){
        List<String> picklistValue= new List<String>();
        DescribeSObjectResult objResult = Schema.getGlobalDescribe().get(selectedObject).getDescribe();
        DescribeFieldResult fieldResult = objResult.fields.getMap().get(selectedField).getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            picklistValue.add(f.getValue());
        }  
        return  picklistValue;
    }
    
}