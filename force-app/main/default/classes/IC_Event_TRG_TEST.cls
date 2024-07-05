@isTest
public class IC_Event_TRG_TEST {

    static testMethod void toFilterEventListTest(){
        
        Test.startTest();
        
        //Integer lastContactTimeRange = Integer.valueOf(ICONSettings__c.getOrgDefaults().get('AccLastContactTimeRange__c'));
        
        Event evt = IC_TestFactory.createEvent(System.today().addDays(-10));
        List<Event> listevt = new List<Event>();
        listevt.add(evt);
        List<Event> result = IC_Event_TRG.toFilterEventList(listevt);
   //     System.assertEquals(result.size(), listevt.size());
        
        Event evt2 = IC_TestFactory.createEvent(System.today().addDays(4));
        List<Event> listevt2 = new List<Event>();
        listevt2.add(evt2);
        List<Event> result2 = IC_Event_TRG.toFilterEventList(listevt2);
        System.assertNotEquals(result2.size(), listevt2.size());
        
        Event evt3 = IC_TestFactory.createEvent(System.today().addDays(-40));
        List<Event> listevt3 = new List<Event>();
        listevt3.add(evt3);
        List<Event> result3 = IC_Event_TRG.toFilterEventList(listevt3);
        System.assertNotEquals(result3.size(), listevt3.size());
        
        Test.stopTest();
        
    }
    
    Static testMethod void eventSetAccLastContactDateTest(){
        
        Test.startTest();
            
        Account acc = IC_TestFactory.createAccount();
        acc.LastContactDate__pc = System.today()-10;
        insert acc;
        
        Event evt = IC_TestFactory.createEvent(acc);
        evt.ActivityDate = System.today().addDays(-3);
        List<Event> myLst = new List<Event>{evt};
        IC_Event_TRG.eventSetAccLastContactDate(myLst);
  //    System.assertEquals(evt.ActivityDate, acc.LastActivityDate);
        
        
        Event evt2 = IC_TestFactory.createEvent(acc);
        evt2.ActivityDate = System.today().addDays(-12);
        List<Event> myLst2 = new List<Event>{evt2};
        IC_Event_TRG.eventSetAccLastContactDate(myLst2);
        System.assertNotEquals(evt2.ActivityDate, acc.LastActivityDate);
        
        Test.stopTest();
       
    }
    
  Static testMethod void PopulateTransAppointementTest(){

      Store__c store = ICX_TestFactory.createStore('storeName', 'TESTCODE');
        insert store;

            Account acc = IC_TestFactory.createAccount();
            insert acc;

            User user = IC_TestFactory.createUser('TestUser@test.com');
            user.profileId = IC_UTILS.getSAProfile();
            insert user;
            
            PPR_PurchProduct__c PP = IC_TestFactory.createPurchaseProduct(acc.id);
            insert PP;
            PP =[select id, TechTransactionId__c,TransactionTotalAmount__c from PPR_PurchProduct__c where id =: PP.id limit 1];

            RecordType recordType = [Select Id, DeveloperName From RecordType where DeveloperName IN ('Online_Appointment')];
            System.debug('HHHHHHHHHHHHHHH recordType: ' + recordType);
            Event evt = IC_TestFactory.createEvent(acc);
            evt.RecordTypeId = recordType.Id;
            //evt.Store_Location__c = store.Id;
            insert evt;

            Test.startTest();

            evt.purchased_product__c = pp.id; 
            update evt;

            evt.OwnerId = user.Id;
            update evt;

            evt.Status__c = 'Cancelled';
            evt.WhatId = acc.Id;
            update evt;

            Event evt2 = IC_TestFactory.createEvent(acc);
            evt2.RecordTypeId = recordType.Id;
            evt2.Store_Location__c = store.Id;
            evt2.purchased_product__c = null;
            insert evt2;

            evt2.Status__c = 'Pending';
            update evt2;

            evt2.Status__c = 'Not Assigned';
            update evt2;
            
            event e = [select SaleAmount__c,RelatedTicketNumber__c, purchased_product__c from event where Id =: evt.id limit 1];
            
            //System.assertEquals(e.RelatedTicketNumber__c, PP.TechTransactionId__c );
           // System.assertEquals(e.SaleAmount__c, PP.TransactionTotalAmount__c);
            System.assertEquals(e.purchased_product__c, PP.id );

            Appointment_TriggerHandler.runOnce();
            
            Test.stopTest();
        }
   
    
}