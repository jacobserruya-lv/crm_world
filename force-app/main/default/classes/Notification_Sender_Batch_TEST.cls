@isTest
private class Notification_Sender_Batch_TEST {
    
    static testMethod void testBatch() {

        Test.startTest();  
    
        Identity_TestFactory.createSettings();
        Account acc1 = Identity_TestFactory.createAccount('gege', 'test1', 'gege@test1.com', '+972549876543', '', true);
        Account acc2 = Identity_TestFactory.createAccount('gogo', 'test2', 'gogo@test2.com', '+972549876544', '', true);               
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
        List<Notification__c> listBefore = [SELECT Id, Application__c, Message_Id__c, CreatedDate, Status__c, Relay_Datetime__c FROM Notification__c];
        //System.assertequals(listBefore.size(), 4); 
        System.debug(listBefore.size()+' notifications have been created');      
                

        Notification_Sender_BATCH myBatch = new Notification_Sender_BATCH();      
        ID batchprocessid = Database.executeBatch(myBatch,2000);        
        myBatch.execute(null, listBefore);//bug known on the net, execute is not called --> had to add this.


        Integer counter = 0;
        List<Notification__c> listAfter = [SELECT Id,Status__c FROM Notification__c];
        for(Notification__c note: listAfter){
            if (note.Status__c == 'READY TO SEND'){
                counter +=1;
            }
        }
        System.debug(counter+' notifications are ready to send');

        Test.stopTest();
                
    }    
}
 /************** for class coverage increase and real testing!!!: 
 add a custom metadata with DelayTime 0
 ********************************************************/