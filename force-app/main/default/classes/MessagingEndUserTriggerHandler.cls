public class MessagingEndUserTriggerHandler {
    public static void handleTrigger(List<MessagingEndUser> newList,System.TriggerOperation triggerEvent) {
        switch on triggerEvent {
            when BEFORE_INSERT {
                handleBeforeInsert(newList);
            }
            when else {
                //do nothing for AFTER_UNDELETE, BEFORE_DELETE, or BEFORE_UPDATE
            }
        }
    }
    public static void handleBeforeInsert(List<MessagingEndUser> newList){
        system.debug('Before Insert');
        Set<String> listPhone = new Set<String> ();
        for (MessagingEndUser mess : newList) {
            if(String.isNotBlank(mess.MessagingPlatformKey) &&(mess.MessageType == 'WhatsApp' || mess.MessageType == 'Text')){
                String phone = mess.MessagingPlatformKey.removeStartIgnoreCase('WhatsApp:').replaceAll( '\\s+', '');
                listPhone.add(phone);
            }
        }
        Map<String,Account> phoneMessagingEndUser = new Map<String,Account>();
        if(!listPhone.isEmpty()){
            for(Account acc :[SELECT id ,PersonContactId, PersonMobilePhone , LastModifiedDate FROM Account WHERE PersonMobilePhone IN: listPhone]){
                if(!phoneMessagingEndUser.containsKey(acc.PersonMobilePhone)){
                    phoneMessagingEndUser.put(acc.PersonMobilePhone,acc);
                }
            }
        }
        
        for (MessagingEndUser mess : newList) {
            if(String.isNotBlank(mess.MessagingPlatformKey) && (mess.MessageType == 'WhatsApp'|| mess.MessageType == 'Text')){
                String phone = mess.MessagingPlatformKey.removeStartIgnoreCase('WhatsApp:').replaceAll( '\\s+', '');
                mess.AccountId = (phoneMessagingEndUser.containsKey(phone) ? phoneMessagingEndUser.get(phone).id : null);
                mess.ContactId = (phoneMessagingEndUser.containsKey(phone) ? phoneMessagingEndUser.get(phone).PersonContactId : null);
            }
        }
    }
}