public class LiveChatTranscriptTriggerHandler {
    
    public static void matchClientByPhone(List<LiveChatTranscript> liveChatTranscriptList){
        Set<string> phoneNumber = new Set<string>();
        Map<string,string> mapPhone = new Map<string,string>();
       
        for(LiveChatTranscript liveChat : liveChatTranscriptList){
            System.debug(liveChat.MobilePhone__c);
            if(string.IsNotEmpty(liveChat.MobilePhone__c) && liveChat.MobilePhone__c.length()>4){
				phoneNumber.add(liveChat.MobilePhone__c);
            }
        }
        List<Account> listAccount = [select id,PersonMobilePhone ,LastModifiedDate  from Account where PersonMobilePhone in: PhoneNumber ];
        Map<string,Id> mapAccount = new Map<string,Id>();
        for(Account acc :listAccount){
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
        
}