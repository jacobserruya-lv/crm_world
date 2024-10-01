public class LiveChatTranscriptTriggerHandler {
    
    public static void matchClientByPhone(List<LiveChatTranscript> liveChatTranscriptList){
        Set<string> phoneNumber = new Set<string>();
        Map<string,string> mapPhone = new Map<string,string>();
       
        for(LiveChatTranscript liveChat : liveChatTranscriptList){
            System.debug(liveChat.MobilePhone__c);
            if(string.IsNotEmpty(liveChat.MobilePhone__c) && liveChat.MobilePhone__c.length()>4){
            System.debug('AYOUB TEST - phoneNumber.add');
				phoneNumber.add(liveChat.MobilePhone__c);
            }
        }
            System.debug('AYOUB TEST - before list Account');
        List<Account> listAccount = [select id,PersonMobilePhone ,LastModifiedDate  from Account where PersonMobilePhone in: PhoneNumber ];
        System.debug('AYOUB TEST - list Account: '+listAccount);
        Map<string,Id> mapAccount = new Map<string,Id>();
        for(Account acc :listAccount){
            System.debug('AYOUB TEST - acc.PersonMobilePhone: '+acc.PersonMobilePhone);
            if(!mapAccount.containsKey(acc.PersonMobilePhone)){
                mapAccount.put(acc.PersonMobilePhone,acc.id);
            }
        }
        
        for(LiveChatTranscript liveChat :liveChatTranscriptList) {
             if(mapAccount.containsKey(liveChat.MobilePhone__c)&& liveChat.AccountId==null){
                liveChat.AccountId = mapAccount.get(liveChat.MobilePhone__c);
             }
         }
    }
    public static void createTasksForLiveChat(List<LiveChatTranscript> liveChatTranscriptList) {
        List<Task> tasksToInsert = new List<Task>();
       
       
          // Query accounts to get PersonContactId for all related accounts
          Set<Id> accountIds = new Set<Id>();
          for (LiveChatTranscript chat : liveChatTranscriptList) {
              if (chat.AccountId != null) {
                  accountIds.add(chat.AccountId);
              }
          }
  
          Map<Id, Id> accountToContactMap = new Map<Id, Id>();
          if (!accountIds.isEmpty()) {
              List<Account> accounts = [SELECT Id, PersonContactId FROM Account WHERE Id IN :accountIds];
              for (Account acc : accounts) {
                  accountToContactMap.put(acc.Id, acc.PersonContactId);
              }
          } 

        // Get the Record Type Id for ICONICS_Chat
        Id iconicsChatRecordTypeId = [SELECT Id FROM RecordType WHERE SObjectType = 'Task' AND DeveloperName = 'ICONICS_Chat'].Id;

        for (LiveChatTranscript chat : liveChatTranscriptList) {
            if (chat.InsideConversationId__c != null && (accountToContactMap.get(chat.AccountId)) !=null) {
                
           
            Task newTask = new Task();
            newTask.Subject = 'Chat';
            newTask.Status = 'Completed';
            newTask.Priority = 'Low';
            newTask.OwnerId = chat.OwnerId ;
            newTask.RecordTypeId = iconicsChatRecordTypeId;
            newTask.WhatId = chat.Id; // Associate with live chat
            newTask.WhoId = accountToContactMap.get(chat.AccountId); // Associate with Contact (if available)
            newTask.ActivityDate = Date.today();
            tasksToInsert.add(newTask);
            }
        }
        
        // Insert the new tasks
        if (!tasksToInsert.isEmpty()) {
            insert tasksToInsert;
        }
    }
}