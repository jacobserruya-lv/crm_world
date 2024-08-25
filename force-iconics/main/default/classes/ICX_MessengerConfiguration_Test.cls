@Istest
public with sharing class ICX_MessengerConfiguration_Test {

    
    @testSetup  
    static void makeData(){

        MessagingChannel chan = [SELECT Id FROM MessagingChannel LIMIT 1]; 
        MessagingEndUser enduser =  createMessagingEndUser(chan.Id);
        insert enduser;
    }
     @isTest static void testMethod1() {


        MessagingEndUser endUser = [select Id from MessagingEndUser LIMIT 1 ];

        ICX_MessengerConfiguration.BotInput botInputs = New ICX_MessengerConfiguration.BotInput ();
        botInputs.varCountry = 'USA';
        botInputs.varMessagingEndUserId = endUser.Id;

        Messenger_Configuration__mdt messengerConfiguration = [SELECT Label ,ISO3_Code__c , Messaging_Queue_Id__c ,Confirmation_Message__c FROM Messenger_Configuration__mdt WHERE  Label = 'USA'];

        Test.startTest();
        ICX_MessengerConfiguration.BotOutput botOutput = new ICX_MessengerConfiguration.BotOutput();
        List<ICX_MessengerConfiguration.BotOutput> botOutputs = ICX_MessengerConfiguration.UpdateMessagingEndUser(new List<ICX_MessengerConfiguration.BotInput>{botInputs});
        Test.stopTest();
        system.assertequals(botOutputs.get(0).varMessengerQueue,messengerConfiguration.Messaging_Queue_Id__c);




        
    }

    private static MessagingEndUser createMessagingEndUser(Id messagingChannelId) {
    
        MessagingEndUser enduser = new MessagingEndUser();
        endUser.Name = 'test';
        endUser.messagingChannelId = messagingChannelId;
        endUser.MessageType = 'Text';
        endUser.MessagingPlatformKey = 'test';
  
        return endUser;
    }
    
    /*private static MessagingSession createMessagingSession() {
       
        
        MessagingSession mess = new MessagingSession();
        mess.Status = 'Active';
        mess.MessagingChannelId = chan.Id;
        mess.MessagingEndUserId = enduser.id; 
        mess.OwnerId = userinfo.getuserid();
        
        return mess;
    }*/


}