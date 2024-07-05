@isTest 
global with sharing class IC_SchedulerClientMerge_TEST {

@testSetup 
    static void TestIC_SchedulerClientMerge() {
        //#### custom settings
        ICONSettings__c stt = new ICONSettings__c();
        stt.clientMergeLimit__c = 2;
        stt.AccLastContactTimeRange__c = 30;
        insert stt;
                
        List<Account> accounts = new List<Account>();        

        // ####### MASTER ACCOUNTS ########
        // ##### MASTER #1
        Account accMaster1;
        accMaster1 = IC_TestFactory.createAccount();
        accMaster1.Dreamid__c = 'TEST894M0';
        accMaster1.lastName = 'MasterClient #0';
        accMaster1.PersonEmail = 'master@master.com';
        accMaster1.Unsubscribe__pc = false;
        accMaster1.UnsubscribeDate__pc = null;
        accMaster1.PersonHasOptedOutOfEmail = false;
        accMaster1.DoNotSMS__pc = false;
        accMaster1.DoNotContactbyPost__pc = false;
        accounts.add(accMaster1);
        // ##### MASTER #2
        Account accMaster2;
        accMaster2 = IC_TestFactory.createAccount();
        accMaster2.Dreamid__c = 'TEST895M0';
        accMaster2.PersonEmail = null;
        accMaster2.lastName = 'MasterClient #1';
        accMaster2.Unsubscribe__pc = false;
        accMaster2.UnsubscribeDate__pc = null;
        accMaster2.PersonHasOptedOutOfEmail = false;
        accMaster2.DoNotSMS__pc = false;
        accMaster2.DoNotContactbyPost__pc = false;
        accounts.add(accMaster2);
        // ####### MASTER ACCOUNTS ########
        // ####### SLAVE ACCOUNTS ########
        // ##### SLAVE #1
        Account account1;
        account1 = IC_TestFactory.createAccount();
        account1.Dreamid__c = 'TEST893S0';
        account1.DreamIdMasterClient__c = 'TEST894M0';
        account1.ToDelete__c = '1';
        account1.lastName = 'SlaveClient #0';
        account1.PersonEmail = 'slave@slave.com';
        account1.Unsubscribe__pc = true;
        account1.UnsubscribeDate__pc = Date.today();
        account1.PersonHasOptedOutOfEmail = true;
        account1.DoNotSMS__pc = true;
        account1.DoNotContactbyPost__pc = true;
        accounts.add(account1);
        // ##### SLAVE #2
        Account account2;
        account2 = IC_TestFactory.createAccount();
        account2.Dreamid__c = 'TEST892S0';
        account2.DreamIdMasterClient__c = 'TEST894M0';
        account2.ToDelete__c = '1';
        account2.lastName = 'SlaveClient #1';
        account2.PersonEmail = 'master@master.com';
        account2.Unsubscribe__pc = true;
        account2.UnsubscribeDate__pc = Date.today();
        account2.PersonHasOptedOutOfEmail = true;
        account2.DoNotSMS__pc = true;
        account2.DoNotContactbyPost__pc = true;
        accounts.add(account2);
        // ##### SLAVE #3
        Account account3;
        account3 = IC_TestFactory.createAccount();
        account3.Dreamid__c = 'TEST891S0';
        account3.DreamIdMasterClient__c = 'TEST895M0';
        account3.ToDelete__c = '1';
        account3.lastName = 'SlaveClient #1';
        account3.PersonEmail = 'slave3@master.com';
        account3.Unsubscribe__pc = true;
        account3.UnsubscribeDate__pc = Date.today();
        account3.PersonHasOptedOutOfEmail = true;
        account3.DoNotSMS__pc = true;
        account3.DoNotContactbyPost__pc = true;
        accounts.add(account3);
        // ####### SLAVE ACCOUNTS ########

        insert accounts;

        // Create new ActionPlan    
        ActionPlan__c actionPlan = new ActionPlan__c();  
        actionPlan.Comments__c = 'Comments';
        actionPlan.IsClosed__c = false;
        actionPlan.AccountId__c = account1.Id;
        actionPlan.Subject__c =  'subject'  ;            
        insert actionPlan;
        
        // Create new IndividualEmailResult 
        et4ae5__IndividualEmailResult__c em;   
        em = new et4ae5__IndividualEmailResult__c();
        em.et4ae5__Contact__c = [Select Id From Contact WHERE AccountId = :account1.Id].id;       
        et4ae5__SendDefinition__c sd = new et4ae5__SendDefinition__c  ();
        insert sd;

        em.et4ae5__SendDefinition__c = sd.id;
        insert em;
        
        // Create new SMSDefinition    
        et4ae5__SMSDefinition__c sms = new et4ae5__SMSDefinition__c();
        sms.et4ae5__Contact__c = [Select Id From Contact WHERE AccountId = :account1.Id].id;             
        insert sms;
        
        //Create new STAR Event ('Event__c' Object ). It will be used when STAR Program is created
        Event__c evt = new Event__c();
        evt.Name='EventTest';
        evt.Start_Date__c =Date.today();
        evt.End_Date__c = Date.today();      
        evt.Location__c='PariSelecs';
        evt.Level__c='International';
        evt.Theme__c='Art & Culture';
        evt.Type__c='Exhibition';
        
        insert evt;
        
        //Create new Program
        Program__c prg;
        prg = New Program__c();
        prg.name='ProgramTest';
        prg.AccountId__c = account1.Id;
        prg.EventId__c = evt.id;
        
        insert prg;
        /*        
        // Create new Event 
        Event event;        
        event = IC_TestFactory.createEvent(account1);
        //event.whoID = account.PersonContactId;
        event.whoID = [Select Id From Contact WHERE AccountId = :account1.Id].id;
        insert event;*/
        
        // Create new Task
        Task task;
        task = IC_TestFactory.createTask(account1);
        //task.whoID = account.PersonContactId;
        task.whoID = [Select Id From Contact WHERE AccountId = :account1.Id].id;
        insert task;
              
        // Create new Task related to an ActionPlan 
        task = IC_TestFactory.createTask(account1);
        task.whoID = [Select Id From Contact WHERE AccountId = :account1.Id].id;
        task.whatID= [SELECT Id FROM ActionPlan__c WHERE AccountId__c = :account1.Id].id;
        insert task;
        
        // Create new Event related to an ActionPlan 
        /*event = IC_TestFactory.createEvent(account1);
        event.whoID = [Select Id From Contact WHERE AccountId = :account1.Id].id;
        event.whatID= [SELECT Id FROM ActionPlan__c WHERE AccountId__c = :account1.Id].id;
        insert event;*/

        CLI_CliList__c cl = IC_TestFactory.clientlistMembers();
        insert cl;
        
        CLM_CliListMember__c Clm = new CLM_CliListMember__c();
        Clm.Client__c = [Select Id From Contact WHERE AccountId = :account1.Id].id;
        Clm.ClientList__c = Cl.Id;
        insert Clm; 
        
        // Create a case attached to the slave account
        Group g = new Group (Name = 'Queue-France', Type = 'Queue');
        insert g;

        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueueSObject q = new QueueSobject(QueueID = g.id, SobjectType = 'case');
            insert q;
        }
       
        Case ca = new Case (Type = 'Product Information',
                            Origin = 'Email',
                            Status = 'New',
                            Subject = 'test case subject ' + Datetime.now(),
                            Description = 'test case description ' + Datetime.now(),
                            Accountid = account1.id,
                            ContactID = account1.PersonContactId,
                            Ownerid = g.id);
        insert ca;

        String id = [Select Id From Contact WHERE AccountId = :accMaster1.Id].id;
    }
	
        @isTest static void test_method_three() {

            Test.startTest();
            IC_SchedulerClientMerge bat = new IC_SchedulerClientMerge();
            String sch = '20 30 8 10 2 ?';
			System.schedule('TEST1', sch, bat);
            Test.stopTest();
        }
    }