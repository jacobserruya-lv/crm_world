public with sharing class ICX_MessengerConfiguration {

    public class BotInput  {
        @InvocableVariable
        public String varCountry;
        @InvocableVariable
        public String varMessagingEndUserId;
    }
     
    public class  BotOutput{
        @InvocableVariable
        public String varMessengerQueue;
        @InvocableVariable
        public String varConfirmationMsg;
    }

  
    public static List<Messenger_Configuration__mdt> getMessengerConfiguration(String fieldName , String varCountry) {
        
        String soql = 'SELECT Label ,ISO3_Code__c , Messaging_Queue_Id__c ,Confirmation_Message__c FROM Messenger_Configuration__mdt WHERE ' + fieldName +' = \''+  + String.escapeSingleQuotes(varCountry) + '\'';
        system.debug(soql);
        return Database.query(soql);
    }
    public static List<MessagingEndUser> getMessagingEndUsers(String messagingEndUserIds) {

        return [SELECT Id ,Tech_GroupID__c  FROM MessagingEndUser WHERE Id =: messagingEndUserIds] ; 
    } 

    @InvocableMethod(label='Messenger Get Queue Id' description='Return Queue Id And Update Messaging User if needed' category='Messenger Configuration')
    public static List<BotOutput> UpdateMessagingEndUser(List<BotInput> botInputs) {

        System.debug('Messenger Configuration');

        List<BotOutput> botOutputs = new List<BotOutput>();
        
        // Get the Country and MessagingEndUser from the input
        String countryNumber = String.isNotBlank(botInputs.get(0).varCountry) ? botInputs.get(0).varCountry : '' ;
        String messagingEndUserIds = botInputs.get(0).varMessagingEndUserId; 

        List<MessagingEndUser> messagingEndUsers = getMessagingEndUsers(messagingEndUserIds);
        MessagingEndUser messagingEndUser = messagingEndUsers.isEmpty() ? null : messagingEndUsers.get(0);

        String groupId = messagingEndUser != null && String.isNotBlank(messagingEndUser.Tech_GroupID__c) ? messagingEndUser.Tech_GroupID__c : '' ;

        String varIsoCode = String.isNotBlank(groupId) ? groupId : countryNumber ;
        String fieldName  = String.isNotBlank(groupId) ? 'ISO3_Code__c' : 'Label' ; 

        List<Messenger_Configuration__mdt> configurations =  getMessengerConfiguration(fieldName ,varIsoCode);

        Messenger_Configuration__mdt configuration = configurations.isEmpty() ? null : configurations.get(0);

        if(configuration != null){

            BotOutput botOutput = new BotOutput();
            botOutput.varMessengerQueue = configuration.Messaging_Queue_Id__c;
            botOutput.varConfirmationMsg = configuration.Confirmation_Message__c;
            botOutputs.add(botOutput);

            if(String.isBlank(groupId) && String.isnotBlank(configuration.ISO3_Code__c)){
                messagingEndUser.Tech_GroupID__c = configuration.ISO3_Code__c;
                Database.update(messagingEndUser, false); 
            } 
        }

        return  botOutputs;
    }
}