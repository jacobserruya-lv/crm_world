global class UpdateMessagingQueueAsync implements Schedulable {
    Set<Id> msgSessionId = new Set<Id>();
    
    public UpdateMessagingQueueAsync (Set<Id> messagingSessionIds){
        if(messagingSessionIds != null){
            msgSessionId = messagingSessionIds;
        }
    }
    public void execute(SchedulableContext ctx) {        
        List<MessagingSession> msgSessionList = [SELECT status ,OwnerId ,Id, Queue_Developper_Name__c,TECH_Queue_Messaging__c,Queue_Name__c,Name,EndUserContactId, 
                                                        MessagingEndUser.Tech_GroupID__c, MessagingEndUser.ContactId,channelType,Country__c,createdDate,ChannelGroup,ChannelLocale ,MessagingEndUserId
                                                  FROM MessagingSession 
                                                  WHERE Id IN :msgSessionId AND channelType = 'AppleBusinessChat'
                                                  ];
        if(!msgSessionList.isEmpty()){  
                      
            handleBeforeInsert(msgSessionList); 
            update msgSessionList;
        }
    }
    
    public static void handleBeforeInsert(List<MessagingSession> newList) {   

        Set<String> channelGroup = new Set<String>();
        Set<String> channelLocale = new Set<String>();
        Set<String> languages = new Set<String>();
        Map<Id,String> groupIdMessagingEndUser = new Map<Id,String>();


        for (MessagingSession mess : newList) {
           
            if (String.isNotEmpty(mess.ChannelGroup)) {
              	channelGroup.add(mess.ChannelGroup);
            }
            if(String.isNotEmpty(mess.MessagingEndUser.Tech_GroupID__c)){
                groupIdMessagingEndUser.put(mess.MessagingEndUserId,mess.MessagingEndUser.Tech_GroupID__c);
            }
            if(String.isNotEmpty(mess.ChannelLocale)){
                languages.add(mess.ChannelLocale.substring(0,2));
                String codeISO2 = mess.ChannelLocale.substringAfter('_');
                if(String.isNotEmpty(codeISO2))
                    channelLocale.add(codeISO2.substring(0,2));
    
            }
        }
        String countriesException =  IconicsSettings__c.getInstance().MessagingCountriesException__c;
        List<String> listCountriesException = String.isNotEmpty(countriesException) ? countriesException.split(';') :new List<String>();

        channelGroup.addall(groupIdMessagingEndUser.values());

        Map<String,String> countryMappingQueue = getCountryMappingQueue(channelGroup,channelLocale);

        Map<String,String> languageMappingQueue = getLanguageMappingQueue(languages);
        
        List<String> QueuesName = new list <String>();
        QueuesName.addAll(countryMappingQueue.values());
        QueuesName.addAll(languageMappingQueue.values());

        Map<String,Group> mapQueue = getQueue(QueuesName);
        
        for (MessagingSession mess : newList) {
            String ownerIdString = String.valueOf(mess.OwnerId);

            String language = String.isNotEmpty(mess.ChannelLocale) ? mess.ChannelLocale.substring(0,2) :'';
            
            String codeISO2 = String.isNotEmpty(mess.ChannelLocale) && String.isNotEmpty(mess.ChannelLocale.substringAfter('_'))? mess.ChannelLocale.substringAfter('_').substring(0,2) : '';

            String chatSuggest = (String.isNotEmpty(mess.ChannelGroup) && countryMappingQueue.containskey(mess.ChannelGroup) ? 
                                  mess.ChannelGroup :
                                  countryMappingQueue.containskey(groupIdMessagingEndUser.get(mess.MessagingEndUserId))?
                                  groupIdMessagingEndUser.get(mess.MessagingEndUserId):'');
                     
            String codeISO3 = String.isNotEmpty(chatSuggest)? chatSuggest:countryMappingQueue.containskey(codeISO2)? countryMappingQueue.get(codeISO2):'';
           
            String queueNameOflanguage = String.isNotEmpty(language) ?languageMappingQueue.get(language) :'';
            
            system.debug('codeISO3 :'+ codeISO3);
             system.debug('mess.channelLocale :'+ mess.channelLocale);
            system.debug('chatSuggest :'+ chatSuggest);

            
            String queueName = (countryMappingQueue.containsKey(codeISO3) || listCountriesException.contains(mess.channelLocale)?
                                codeISO2 =='CA' && String.isEmpty(chatSuggest) && !listCountriesException.contains(mess.channelLocale)? '': countryMappingQueue.get(codeISO3):
                                codeISO2 =='CA'?'' : queueNameOflanguage); 
            system.debug('queueName');
            system.debug(queueName);
                    
            mess.Country__c =  codeISO3;
            String defaultQueue = string.isNotEmpty(IconicsSettings__c.getInstance().MessagingDefaultQueue__c) ?IconicsSettings__c.getInstance().MessagingDefaultQueue__c : mess.ownerId ;
            if(mess.status!='Ended'){
                
                if(String.isNotEmpty(queueName) && mapQueue.containskey(queueName)) {
                    mess.Queue_Name__c = (mapQueue.containsKey(queueName)? mapQueue.get(queueName).Name : 'Messaging US');
                    mess.TECH_Queue_Messaging__c = (mapQueue.containsKey(queueName)? mapQueue.get(queueName).id : defaultQueue);
                    mess.Queue_Developper_Name__c = (mapQueue.containsKey(queueName)? mapQueue.get(queueName).DeveloperName: 'Messaging_US');
                    mess.ownerId =  mapQueue.get(queueName).id;
                }else{
                    mess.ownerId =  defaultQueue ;
                    mess.TECH_Queue_Messaging__c = defaultQueue ; 
                    mess.Queue_Name__c = 'Messaging US' ;
                    mess.Queue_Developper_Name__c = 'Messaging_US';
                }
            }
        }
    }
   
    private static Map<String,Group> getQueue(List<String> QueueName ){
        Map<String,Group> QueueMap = new Map<String,Group>();
        for(Group grp : [SELECT Id,DeveloperName ,Name FROM Group WHERE Type = 'Queue' AND DeveloperName in:QueueName]){
             QueueMap.put(grp.DeveloperName,grp);
        }
        return QueueMap;
    }
    private static Map<String,String> getCountryMappingQueue(Set<String> channelGroup,Set<String> channelLocale){
       Map<String,String> QueueName = new Map<String,String>();
       Map<Id, CountryMapping__mdt> first_query = new Map<Id, CountryMapping__mdt>([SELECT Iso2Code__c,Iso3Code__c,QueueMessaging__c
                                                                                    FROM CountryMapping__mdt 
                                                                                    WHERE Iso3Code__c in: channelGroup and HasOtherValue__c=false]);

       Map<Id, CountryMapping__mdt> second_query = new Map<Id, CountryMapping__mdt>([SELECT Iso2Code__c,Iso3Code__c,QueueMessaging__c
                                                                                    FROM CountryMapping__mdt 
                                                                                    WHERE  Iso2Code__c in:channelLocale and HasOtherValue__c=false]); 
        
       first_query.putAll(second_query);
 
       for(CountryMapping__mdt CountryMapping :first_query.values()){
            if(CountryMapping.QueueMessaging__c != null){
                QueueName.put(CountryMapping.Iso3Code__c,CountryMapping.QueueMessaging__c);
            }
            if(channelLocale.contains(CountryMapping.Iso2Code__c)){
                QueueName.put(CountryMapping.Iso2Code__c,CountryMapping.Iso3Code__c);
            }
        }
       return QueueName; 
    }
    private static Map<String,String> getLanguageMappingQueue(Set<String> languages){
        Map<String,String> QueueName = new Map<String,String>();
        
       for(Language__mdt languagesMapping :[SELECT DeveloperName, QueueMessaging__c 
                                            FROM Language__mdt 
                                            WHERE DeveloperName in: languages and QueueMessaging__c!=null]){
           
        QueueName.put(languagesMapping.DeveloperName,languagesMapping.QueueMessaging__c);
           
       }
       return QueueName; 
        
    }
}