@isTest
private class Notification_Cleaner_Batch_TEST {
    
    static testMethod void testBatch() {

        
    
        Identity_TestFactory.createSettings();
        Account acc1 = Identity_TestFactory.createAccount('gege', 'test1', 'gege@test1.com', '+972549876543', '', true);
        Account acc2 = Identity_TestFactory.createAccount('gogo', 'test2', 'gogo@test2.com', '+972549876544', '', true);                
         Notification_Settings__mdt notifications = new Notification_Settings__mdt();
     Map<String,Object>fields=(Map<String,Object>)JSON.deserializeUntyped(JSON.serializePretty(notifications));
     fields.put(Notification_Settings__mdt.Application__c.getdescribe().getName(),'CARE SERVICE');
             fields.put(Notification_Settings__mdt.CHANNEL__c.getdescribe().getName(),'EMail MARKETING CLOUD');
                     fields.put(Notification_Settings__mdt.message_id__c.getdescribe().getName(),'OSAE2');

     fields.put(Notification_Settings__mdt.scenario__c.getdescribe().getName(),1);
     fields.put(Notification_Settings__mdt.Delay_Time__c.getdescribe().getName(),0);
     fields.put(Notification_Settings__mdt.is_active__c.getdescribe().getName(),true);

     fields.put(Notification_Settings__mdt.Message_Id__c.getdescribe().getName(),13);
     fields.put(Notification_Settings__mdt.Clean_Up_Every__c.getdescribe().getName(),0);
             fields.put(Notification_Settings__mdt.Clean_Up_Every__c.getdescribe().getName(),03);

     notifications=(Notification_Settings__mdt)JSON.deserialize(JSON.serialize(fields), Notification_Settings__mdt.class);
        List<Account> clients = new list<Account>();
        clients.add(acc1);
        clients.add(acc2);  
        
         Map<Id,CareService__c> client_ids = new Map<Id,CareService__c>();
        client_ids.put(acc1.id, null);
        client_ids.put(acc2.id, null);
        
        Notification_Sender.send(
                        new Map<String,Object> {
                            'application' => 'CARE SERVICE',
                            'scenario' => 1,
                            'channel' => null
                        },
                        client_ids.keySet(), 
                        new Map<String, Map<String,Object>>()
                    ); 

        //for each client x notifications are created, according to x metadata settings for these values (careservice app, scenario 1 (and channel email marketing cloud) )        
        List<Notification__c> listBefore = [SELECT Id, Application__c,CreatedDate, Message_Id__c, LastModifiedDate, Status__c FROM Notification__c];
        System.debug(listBefore.size()+' notifications have been created');

        Integer i =0;
        for(Notification__c note : listBefore){
            if(math.mod(i, 2) == 0){
                note.Status__c = 'READY TO SEND'; 
            }
            else{
                note.Status__c = 'CANCELLED';  
                system.debug('note created date before ****'+note.CreatedDate);
                Test.setCreatedDate(note.id, System.now().addDays(-20));
                system.debug('note created date after ****'+note.CreatedDate);
                note.Message_Id__c = NULL;
            }
            i++;
        } 
        update listBefore;
     Test.startTest(); 
        Notification_Cleaner_BATCH myBatch = new Notification_Cleaner_BATCH();      
        ID batchprocessid = Database.executeBatch(myBatch,2000);        
        myBatch.execute(null, listBefore);//bug known on the net, execute is not called --> had to add this.
 Test.stopTest();
        List<Notification__c> listAfter = [SELECT Id FROM Notification__c];
        System.debug(listAfter.size()+' notifications remain');

       
        //System.assertEquals(4, listBefore.size());
        //System.assertEquals(4,listAfter.size());
        
        
    }    
}
 /************** for class coverage increase and real testing!!!: 
 add a custom metadata with cleanUpEvery 0
 and Update_Statut_Every__c 0
 ********************************************************/