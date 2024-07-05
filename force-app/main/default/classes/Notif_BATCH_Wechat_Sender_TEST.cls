@isTest
public class Notif_BATCH_Wechat_Sender_TEST {
    @isTest
    static void testBatch() {

        
        //custom metadata test
        Notification_Settings__mdt notifications = new Notification_Settings__mdt();
        Map<String,Object>fields=(Map<String,Object>)JSON.deserializeUntyped(JSON.serializePretty(notifications));
        fields.put(Notification_Settings__mdt.Application__c.getdescribe().getName(),'Application');
        fields.put(Notification_Settings__mdt.Message_Id__c.getdescribe().getName(),13);
        fields.put(Notification_Settings__mdt.Clean_Up_Every__c.getdescribe().getName(),03);
        notifications=(Notification_Settings__mdt)JSON.deserialize(JSON.serialize(fields), Notification_Settings__mdt.class);
   
   
        system.debug('notifications*******' + notifications);
   
           Identity_TestFactory.createSettings();
           Account acc1 = Identity_TestFactory.createAccount('gege', 'test1', 'gege@test1.com', '+972549876543', '', true);
           Account acc2 = Identity_TestFactory.createAccount('gogo', 'test2', 'gogo@test2.com', '+972549876544', '', true);                
           
           Set<Id> clients = new Set<Id>();
           clients.add(acc1.id);
           clients.add(acc2.id);  
           
           Map<String, Map<String,Object>> notifParams = new Map<String, Map<String,Object>>();
           notifParams.put(acc1.id , new Map<string, object>{'what_id'=>'123456'});
           notifParams.put(acc2.id , new Map<string, object>{'what_id'=>'123456'});

           Notification_Sender.send(
                           new Map<String,Object> {
                               'application' => 'WECHAT ONLINE APPOINTMENT',
                               'scenario' => 1,
                               'channel' => null
                           },
                           clients, 
                           notifParams
                       ); 
   
           //for each client x notifications are created, according to x metadata settings for these values (careservice app, scenario 1 (and channel email marketing cloud) )        
           List<Notification__c> listBefore = [SELECT Id, Application__c,CreatedDate, Message_Id__c, LastModifiedDate, Status__c FROM Notification__c];
           System.debug(listBefore.size()+' notifications have been created');
   
           Integer i =0;
           for(Notification__c note : listBefore){
                   note.Status__c = 'READY TO SEND'; 
                   note.Real_Time__c = false;
                   note.Relay_Datetime__c=System.now();
           } 
           update listBefore;
        Test.startTest(); 
           Notifcation_BATCH_Wechat_Sender myBatch = new Notifcation_BATCH_Wechat_Sender();      
           ID batchprocessid = Database.executeBatch(myBatch,500);        
        //    myBatch.execute(null, listBefore);//bug known on the net, execute is not called --> had to add this.
    Test.stopTest();
           List<Notification__c> listAfter = [SELECT Id FROM Notification__c];
           System.debug(listAfter.size()+' notifications remain');
   
          
           //System.assertEquals(4, listBefore.size());
           //System.assertEquals(4,listAfter.size());
           
           
       }    
}