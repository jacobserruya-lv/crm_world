@istest
public class MessagingSessionTriggerHandler_TEST {
    @testSetup
    public static void init() {
        MessagingChannel chan = createMessagingChannelText();//[SELECT Id FROM MessagingChannel WHERE MessageType='Text' LIMIT 1];
        insert chan;
    }
    
    @isTest static void insertMessagingSession() {
        Test.startTest();
        MessagingSession mess = createMessagingSession();
        insert mess;
        Test.stopTest();
        
        MessagingSession mess1 = [SELECT id, TECH_Queue_Messaging__c, OwnerId FROM MessagingSession limit 1];
        System.assertEquals(mess1.OwnerId, mess1.TECH_Queue_Messaging__c);        
    }
    
    @isTest static void updateMessagingSession() {
        Test.startTest();
        MessagingSession mess = createMessagingSession();
        insert mess;

        mess.Resolution__c ='Immediate Response';
        update mess;
        Test.stopTest();
        
        List<Task> tasks = [select id ,RecordTypeId ,RecordType.Name from Task LIMIT 10];
        system.debug(tasks);
      //  System.assertEquals(1, tasks.size());
    }
    
    private static MessagingEndUser createMessagingEndUser(Id messagingChannelId) {
        Contact con = new contact(LastName = 'test');
        insert con;

        MessagingEndUser enduser = new MessagingEndUser();
        endUser.Name = '+33699999999';
        endUser.messagingChannelId = messagingChannelId;
        endUser.MessageType = 'AppleBusinessChat';
        endUser.MessagingPlatformKey = '+33699999999';
        endUser.ContactId = con.id;
        endUser.Tech_GroupID__c='USA';

        return endUser;
    }
    
    private static MessagingSession createMessagingSession() {
        MessagingSession mess = new MessagingSession();
        mess.Status = 'New';
        
        MessagingChannel chan = [SELECT Id FROM MessagingChannel WHERE MessageType='AppleBusinessChat' LIMIT 1]; // createMessagingChannelText();//
        //insert chan;
        mess.MessagingChannelId = chan.Id;
        
        MessagingEndUser enduser =  createMessagingEndUser(chan.Id);
        insert enduser;
        system.debug(enduser);
        mess.MessagingEndUserId = endUser.Id; 
        
        QueueSobject queue =  [select Id, QueueId ,SobjectType from QueueSobject where SobjectType = 'MessagingSession' limit 1];
        mess.OwnerId = queue.QueueId;
        
        return mess;
    }

    private static MessagingChannel createMessagingChannelText() {
        MessagingChannel channel = new MessagingChannel();
        channel.MessageType='AppleBusinessChat';
        channel.DeveloperName = 'MessagingSessionTriggerHandlerTESTcreateMessagingChannel';
        channel.MasterLabel = 'MessagingSessionTriggerHandlerTESTcreateMessagingChannel';
        channel.MessagingPlatformKey = '+3933999999';
        return channel;
    }
}