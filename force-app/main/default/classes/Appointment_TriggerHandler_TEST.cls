@isTest
public class Appointment_TriggerHandler_TEST {
    @IsTest static void Appointment_TriggerHandler_TEST() {

      Appointment_TriggerHandler.runOnce();

      User u = IC_Test_Common.prepareTestUser('System Administrator');
      u.DefaultStore__c = '1234';
      insert u;

      User u2 = IC_Test_Common.prepareTestUser('System Administrator');
      u.DefaultStore__c = '1234';
      insert u2;

      Account acc1 = IC_TestFactory.createAccount();
      acc1.DreamID__c='1233';
      insert acc1;
      
      Account acc2 = IC_TestFactory.createAccount();
      acc2.DreamID__c='12335';
      insert acc2;

      Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c,Time_Zone_Id__c='Europe/Rome',
      Local_Name__c='Louis Vuitton Ogilvy',
      Address__c='1307 Rue Sainte-Catherine OuestH3G 1P7 MONTREAL QUEBEC',
      tech_address__c=  'Louis Vuitton Ogilvy');       
      
      insert store;
      String CareServicerecordTypeId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('StoreCareService').getRecordTypeId();
      CareService__c c1 = new CareService__c(Client__c = acc1.id, store__c = store.id, StoreRetailCode__c = store.RetailStoreId__c,IsToDo__c=true,CA__c=u.id, MyRepairStatus__c = 'repairInProgress' ,RecordTypeId =CareServicerecordTypeId );
      insert c1;
      String onlineRecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();

      List<Event> eventToInsert = new List<Event>(); 

      Event event1 =  createEvent(new Map<String,Object>{
        'RecordTypeId' => onlineRecordTypeId,
        'OwnerId' => u2.id,
        'Subject' =>  'we chat test',
        'AccountId' => acc1,
        'Dispatch_Country__c' => 'FR',
        'SourceType__c' => 'WECHAT',
        'Status__c' => 'Not Assigned'
      });

      Event event2 = createEvent(new Map<String,Object>{
        'RecordTypeId' => onlineRecordTypeId,
        'OwnerId' => u.id,
        'Subject' =>  'we chat test',
        'AccountId' => acc1,
        'Dispatch_Country__c' => 'FR',
        'SourceType__c' => 'LV_COM',
        'Status__c' => 'Not Assigned',
        'Store_Location__c' => store.Id
      });

      Event event3 = createEvent(new Map<String,Object>{
        'RecordTypeId' => onlineRecordTypeId,
        'OwnerId' => u.id,
        'Subject' =>  'we chat test',
        'AccountId' => acc1,
        'Dispatch_Country__c' => 'FR',
        'SourceType__c' => 'WECHAT',
        'Status__c' => 'Not Assigned',
        'Store_Location__c' => store.Id,
        'LastModifiedById' => u2.id
      });

      Event event4 = createEvent(new Map<String,Object>{
        'RecordTypeId' => onlineRecordTypeId,
        'OwnerId' => u.id,
        'Subject' =>  'we chat test',
        'AccountId' => acc1,
        'Dispatch_Country__c' => 'FR',
        'SourceType__c' => 'WECHAT_DIAMOND',
        'Status__c' => 'Not Assigned',
        'Store_Location__c' => store.Id
      });

      Event event5 = createEvent(new Map<String,Object>{
        'RecordTypeId' => onlineRecordTypeId,
        'OwnerId' => u.id,
        'Subject' =>  'we chat test',
        'AccountId' => acc2,
        'Dispatch_Country__c' => 'FR',
        'SourceType__c' => 'LV_COM',
        'Status__c' => 'Pending'
      });
    
      Event event6 = createEvent(new Map<String,Object>{
        'RecordTypeId' => onlineRecordTypeId,
        'OwnerId' => u.id,
        'Subject' =>  'we chat test',
        'AccountId' => acc2,
        'Dispatch_Country__c' => 'FR',
        'SourceType__c' => 'WECHAT',
        'Status__c' => 'Pending'
      });

      Event event7 = createEvent(new Map<String,Object>{
        'RecordTypeId' => onlineRecordTypeId,
        'OwnerId' => u.id,
        'Subject' =>  'we chat test',
        'AccountId' => acc1,
        'Dispatch_Country__c' => 'FR',
        'SourceType__c' => 'WECHAT_DIAMOND',
        'Status__c' => 'Pending',
        'Store_Location__c' => store.Id
      });

      Event event8 = createEvent(new Map<String,Object>{
        'RecordTypeId' => onlineRecordTypeId,
        'OwnerId' => u.id,
        'Subject' =>  'we chat test',
        'AccountId' => acc2,
        'Dispatch_Country__c' => 'FR',
        'SourceType__c' => 'LV_COM',
        'Status__c' => 'Assigned',
        'Store_Location__c' => store.Id,
        'My_Repairs__c' => c1.Id
      });

      insert new List<Event> {
        event1,
        event2,
        event3,
        event4,
        event5,
        event6,
        event7,
        event8
      };


      event2.status__c = 'Cancelled';
      event3.status__c = 'Cancelled';
      event4.status__c = 'Cancelled';
      event5.status__c = 'Not Assigned';
      event6.status__c = 'Not Assigned';
      event7.status__c = 'Not Assigned';
      //event8.Reason__c = 'Product Discovery';

      update new List<Event> {
        event1,
        event2,
        event3,
        event4,
        event5,
        event6,
        event7,
        event8
      };





    }

    @IsTest static void Appointment_TriggerHandler_TEST2() {
        User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.DefaultStore__c = '1234';
        insert u;

        User u2 = IC_Test_Common.prepareTestUser('System Administrator');
        u2.DefaultStore__c = '334';
        insert u2;
        Account acc4 = IC_TestFactory.createAccount();
        acc4.DreamID__c='110592092';
        insert acc4;
        Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c,Time_Zone_Id__c='Europe/Rome',
        Local_Name__c='Louis Vuitton Ogilvy',
        Address__c='1307 Rue Sainte-Catherine OuestH3G 1P7 MONTREAL QUEBEC',
        tech_address__c=  'Louis Vuitton Ogilvy');
        insert store;
        Map<id,  Store__c> stores= new Map<id,Store__c>();
        stores.put(store.id,store);  
        Event ev5= IC_TestFactory.createEvent(acc4);
        ev5.RecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();
        ev5.Subject = 'we chat test';
        ev5.Status__c =  'Cancelled';
        ev5.wechat_openId__c  ='fake';

        ev5.ownerid=u.id;
      //  ev5.Store_Location__c = store.Id;
        ev5.sourceType__c = 'WECHAT';
        ev5.Dispatch_Country__c='FR';
        Map<id,  Account> clients= new Map<id,Account>();
        clients.put(acc4.id,acc4);


        Event ev6= IC_TestFactory.createEvent(acc4);
        ev6.RecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();
        ev6.Subject = 'we chat ersfdfs test';
        ev6.Status__c =  'Assigned';
        ev6.Store_Location__c = store.Id;
        ev6.ownerid=u2.id;
      ev6.sourceType__c = 'WECHAT test';
      ev6.wechat_openId__c  ='fake';

      ev6.Dispatch_Country__c='FR';
        insert ev6;

        Event ev7= IC_TestFactory.createEvent(acc4);
        ev7.RecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();
        ev7.Subject = 'we chat ersfdfs test';
        ev7.Status__c =  'Not Assigned';
        ev7.Store_Location__c = store.Id;
        ev7.ownerid=u.id;
        ev7.sourceType__c = 'WECHAT';
        ev7.Dispatch_Country__c='FR';
        ev7.wechat_openId__c  ='fake';

        insert ev7;
        List<Event> lstEvent12 = new List<Event>(); 
        lstEvent12.add(ev5);
        Map<Id, Event> iEvent2 = new Map<Id,Event>();
        iEvent2.put(ev5.id,ev6);
        Map<Id, Event> iEvent3 = new Map<Id,Event>();
        iEvent3.put(ev7.id,ev7);
        List<Event> lstEvent13 = new List<Event>(); 
        lstEvent13.add(ev7);

        Event evt = IC_TestFactory.createEvent(acc4);
      evt.RecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();
      evt.Dispatch_Country__c='FR';
      insert evt;
       
  
        Event evt2 = IC_TestFactory.createEvent(acc4);
        evt2.RecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();
        evt2.Store_Location__c = store.Id;
        evt2.Dispatch_Country__c='FR';
        evt2.purchased_product__c = null;
        evt2.wechat_openId__c  ='fake';

        insert evt2;
  
      

        Event ev4= IC_TestFactory.createEvent(acc4);
        ev4.RecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();
        ev4.Subject = 'WECHAT';
        ev4.Status__c = 'Assigned';
        ev4.Store_Location__c = store.Id;
        ev4.sourceType__c = 'WECHAT';
        ev4.Dispatch_Country__c='FR';

        insert ev4;
        Test.startTest();
        evt.Status__c = 'Cancelled';
        evt.WhatId = acc4.Id;
        update evt;
        evt2.Status__c = 'Pending';
        update evt2;
  
        evt2.Status__c = 'Not Assigned';
        update evt2;
        ev4.Status__c = 'Cancelled';
        ev4.Dispatch_Country__c='FR';
        ev4.wechat_openId__c  ='fake';

        update ev4;
        Map<Id, Event> iEvent4= new Map<Id,Event>();
      
        ev4.ownerId=u2.ID;
        ev4.Status__c = 'Not Assigned';
        update ev4;

        Event ev8= IC_TestFactory.createEvent(acc4);
        ev8.RecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();
        ev8.Subject = 'WECHAT';
        ev8.Status__c = 'Assigned';
        ev8.Store_Location__c = store.Id;
        ev8.StartDateTime=datetime.newInstance(2022, 3, 14, 13, 30, 0);      
        ev8.ENDDATETIME=datetime.newInstance(2022, 3, 15, 13, 30, 0);      
        ev8.sourceType__c = 'WECHAT';
        ev8.Dispatch_Country__c='FR';
        ev8.wechat_openId__c  ='fake';

        insert ev8;
        ev8.Dispatch_Country__c='FR';

        ev8.Status__c = 'Cancelled';
        update ev8;

        Event ev9= IC_TestFactory.createEvent(acc4);
        ev9.RecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();
        ev9.Subject = 'WECHAT';
        ev9.Status__c = 'Pending';
        ev9.Store_Location__c = store.Id;
        ev9.StartDateTime=datetime.newInstance(2022, 3, 10, 14, 30, 0);       
        ev9.ENDDATETIME=datetime.newInstance(2022, 3, 15, 13, 30, 0);  
        ev9.appointmentType__c= 'inStore';    

        ev9.sourceType__c = 'WECHAT';
        ev9.Dispatch_Country__c='FR';
        ev9.wechat_openId__c  ='fake';

        insert ev9;
        ev9.Dispatch_Country__c='FR';
        ev9.Status__c = 'Not Assigned';
        update ev9;

        Event ev10= IC_TestFactory.createEvent(acc4);
        ev10.RecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Online_Appointment').getRecordTypeId();
        ev10.Subject = 'WECHAT';
        ev10.Status__c = 'Pending';
        ev10.ownerid=u.id;
        ev10.Store_Location__c = store.Id;
        ev10.StartDateTime=datetime.newInstance(2022, 3, 10, 14, 30, 0);       
        ev10.ENDDATETIME=datetime.newInstance(2022, 3, 15, 13, 30, 0);  
        ev10.appointmentType__c= 'inStore';    
        ev10.wechat_openId__c  ='fake';
        ev10.sourceType__c = 'WECHATFRR';
        ev10.Dispatch_Country__c='FR';

        insert ev10;
        ev10.Dispatch_Country__c='FR';
        ev10.Status__c = 'Cancelled';
        update ev10;
        iEvent4.put(ev8.id,ev8);

        Notification__c notifs= new Notification__c();
        notifs.Status__c='CREATED';
        notifs.Real_Time__c = FALSE;
        notifs.WhatId__c=acc4.id;
        notifs.External_Id__c=acc4.id;
        insert notifs;
        List<id> ACCOUNTIDS= new list<id>();
        ACCOUNTIDS.add(acc4.id);
        
        Test.stopTest();
        Appointment_TriggerHandler.beforeUpdate(lstEvent12, iEvent2, lstEvent13, iEvent3);
        Map<String,sobject> others= new Map<String,sobject> { 'CampaignId'=>acc4};
        //Appointment_TriggerHandler.sendNotifs(iEvent2,lstEvent13,ACCOUNTIDS,iEvent2,iEvent4,true);


    }
    
    @IsTest static void Appointment_TriggerHandler_golden() {
        Test.startTest();
        User u = IC_Test_Common.prepareTestUser('System Administrator');
        u.DefaultStore__c = '1234';
        insert u;
        Account acc4 = IC_TestFactory.createAccount();
        acc4.DreamID__c='110592092';
        insert acc4;
        /*Store__c store = new Store__c(Name = 'test', RetailStoreId__c = u.DefaultStore__c,Time_Zone_Id__c='Europe/Rome',
        Local_Name__c='Louis Vuitton Ogilvy',
        Address__c='1307 Rue Sainte-Catherine OuestH3G 1P7 MONTREAL QUEBEC',
        tech_address__c=  'Louis Vuitton Ogilvy');
        insert store;
        Map<id,  Store__c> stores= new Map<id,Store__c>();
        stores.put(store.id,store);*/  
        Event ev5= IC_TestFactory.createEvent(acc4);
        ev5.RecordTypeId = Event.sObjectType.getDescribe().getRecordTypeInfosByDeveloperName().get('Golden').getRecordTypeId();
        ev5.Status__c = 'To Be Approved';
        ev5.ownerid=u.id;
        ev5.sourceType__c = 'WECHAT';
        ev5.manager__c = u.id;
        insert ev5;
		ev5.Status__c = 'Pending';
        update ev5;
        ev5.Status__c = 'Cancelled';
        ev5.CA_Ids__c = u.Id;
        update ev5;
        ev5.CA_Ids__c = null;
        update ev5;
        Test.stopTest();
    }


    public static Event createEvent(Map<String ,Object> info){

      Event event = IC_TestFactory.createEvent((Account)info.get('AccountId'));

      for(String field : info.keySet()){

        if(field != 'AccountId')

          event.put(field, info.get(field));
      }

      return event;
    }
}