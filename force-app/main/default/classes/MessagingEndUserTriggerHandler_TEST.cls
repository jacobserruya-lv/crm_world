@isTest
public class MessagingEndUserTriggerHandler_TEST {
     @testSetup static void methodName() {
        
        MessagingChannel chan = createMessaging();
        system.debug(chan);
    }
    @isTest static void insertMessagingUser() {
        Test.startTest();
            MessagingSession mess = createMessagingSession();
            insert mess;
                system.debug(mess);

        Test.stopTest();
        MessagingSession mess1 = [SELECT id, EndUserAccountId FROM MessagingSession limit 1];
        System.assertNotEquals(null,mess1.EndUserAccountId);
        
    }
    private static MessagingEndUser createMessagingEndUser(Id messagingChannelId) {
        Account con = new Account(LastName = 'test', PersonMobilePhone ='+393515159759');
        insert con;
        MessagingEndUser enduser = new MessagingEndUser();
        endUser.Name = '+393515159759';
        endUser.messagingChannelId = messagingChannelId;
        endUser.MessageType = 'Text';
        endUser.MessagingPlatformKey = '+393515159759';
        insert endUser;
        system.debug(endUser);
        return endUser;
    }
    private static MessagingSession createMessagingSession () {
        MessagingChannel chan =  [SELECT Id ,MessageType FROM MessagingChannel  where MessageType ='Text' limit 1];
        MessagingEndUser enduser =  createMessagingEndUser(chan.Id); 
        MessagingSession mess = new MessagingSession();
        mess.Status = 'New';
        mess.MessagingChannelId = chan.Id;
        mess.MessagingEndUserId = endUser.Id; 
       
        return mess;
    }
    
    private static MessagingChannel createMessaging() {
        MessagingChannel channel = new MessagingChannel();
        channel.MessageType = 'Text' ; 
        channel.MasterLabel = 'Text';
        channel.DeveloperName = 'Text' ; 
        channel.MessagingPlatformKey= 'Text' ; 
        insert channel;
            
        return channel;
       
        
    }
}