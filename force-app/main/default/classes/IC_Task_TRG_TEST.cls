@isTest
public class IC_Task_TRG_TEST { 
    public static Account acc; 
    public static Task tsk;
    public static Date lstContactedate;
    public static List<Account> accountList = new List<Account>();
    
    public static List<Task> result;
    //public static Integer lastContactTimeRange = Integer.valueOf(ICONSettings__c.getOrgDefaults().get('AccLastContactTimeRange__c'));
  
    static void init(){
        acc = IC_TestFactory.createAccount();
        insert acc;
        tsk = IC_TestFactory.createTask(IC_Task_TRG_TEST.acc);
        tsk.RecordTypeId = IC_UTILS.getTaskRT();
        insert new ICONSettings__c(AccLastContactTimeRange__c=30);
        insert tsk;  
    }   

    static testMethod void setWhoIdTaskInsert(){    
        Test.startTest();  
        List<Task> taskList =  new List<Task>();
        
        Account acc = IC_TestFactory.createAccount();
        insert acc;
        Contact contact = [SELECT Id FROM Contact WHERE IsPersonAccount = true AND AccountId = :acc.Id];
        Task tsk = IC_TestFactory.createTask(acc);
        taskList.add(tsk);
        System.assertEquals(null, tsk.WhoId);
        IC_Task_TRG.setWhoId(taskList);
        System.assertEquals(contact.Id, tsk.WhoId);

        Test.stopTest();
    }

    static testMethod void setWhoIdTaskUpdate(){    
        Test.startTest();  
        List<Task> taskList = new List<Task>();
        Map<Id, Task> oldData = new Map<Id, Task>();

        Account acc1 = IC_TestFactory.createAccount();
        insert acc1;
        Contact contact1 = [SELECT Id FROM Contact WHERE IsPersonAccount = true AND AccountId = :acc1.Id];

        Account acc2 = IC_TestFactory.createAccount();
        insert acc2;
        Contact contact2 = [SELECT Id FROM Contact WHERE IsPersonAccount = true AND AccountId = :acc2.Id];

        Task task = IC_TestFactory.createTask(acc1);
        Task task2 = IC_TestFactory.createTask(acc2);
        insert task2;
        // old data
        oldData.put(task2.Id, task);
        // new data
        taskList.add(task2);

        // System.assert(task.WhatId == acc2.Id);
        IC_Task_TRG.setWhoId(taskList, oldData);
        System.assertEquals(contact2.Id, task2.WhoId);

        Test.stopTest();
    }

    static testMethod void toFilterTaskListTest(){  
        //Integer lastContactTimeRange = Integer.valueOf(ICONSettings__c.getOrgDefaults().get('AccLastContactTimeRange__c'));
        insert new ICONSettings__c(AccLastContactTimeRange__c=30);
        
        Test.startTest();  

        List<Task> taskList =  new List<Task>();
        List<RecordType> listrecord = [SELECT Id FROM RecordType WHERE Name = 'To Do'];
        Task tsk= IC_TestFactory.createTask('Email',listrecord.get(0).id,System.today().addDays(-10));
        taskList.add(tsk);
        result = IC_Task_TRG.toFilterTaskList(taskList);
        System.assertEquals(result.size(),taskList.size());
        
        Task tsk2 = IC_TestFactory.createTask('Email',listrecord.get(0).id,System.today().addDays(6));
        List<Task> taskList2 = new List<Task>();
        taskList2.add(tsk2);
        result = IC_Task_TRG.toFilterTaskList(taskList2);
        System.assertNotEquals(result.size(),taskList2.size());
        
        Task tsk22 = IC_TestFactory.createTask('Email',listrecord.get(0).id,System.today().addDays(-40));
        List<Task> taskList22 = new List<Task>();
        taskList22.add(tsk22);
        result = IC_Task_TRG.toFilterTaskList(taskList22);
        System.assertNotEquals(result.size(),taskList22.size());
        
        Task tsk3 = IC_TestFactory.createTask('Other',listrecord.get(0).id,System.today().addDays(-10));
        List<Task> taskList3 = new List<Task>();
        taskList3.add(tsk3);
        result = IC_Task_TRG.toFilterTaskList(taskList3);
        //System.assertNotEquals(result.size(),taskList3.size());
        
        List<RecordType> listrecord2 = [SELECT Id FROM RecordType WHERE Name = 'DREAM Contact'];
        Task tsk4 = IC_TestFactory.createTask('Email',listrecord2.get(0).id,System.today().addDays(6));
        List<Task> taskList4 = new List<Task>();
        taskList4.add(tsk4);
        result = IC_Task_TRG.toFilterTaskList(taskList4);
        System.assertNotEquals(result.size(),taskList4.size());
        
        Test.stopTest();
    }
    
    Static testMethod void taskSetAccLastContactDateTest(){
        Test.startTest();
            
        Account acc = IC_TestFactory.createAccount();
        acc.LastContactDate__pc = System.today()-10;
        insert acc;
        
        Task tsk = IC_TestFactory.createTask(acc);
        tsk.ActivityDate = System.today().addDays(-3);
        List<Task> myLst = new List<Task>{tsk};
        IC_Task_TRG.taskSetAccLastContactDate(myLst);
        System.debug ('tsk.ActivityDate' + tsk.ActivityDate);
        System.debug ('acc.LastActivityDate' + acc.LastActivityDate);
        System.debug ('acc.LastContactDate__pc' + acc.LastContactDate__pc);
        // System.assertEquals(tsk.ActivityDate, acc.LastContactDate__pc);
        
        Task task2 = IC_TestFactory.createTask(acc);
        task2.ActivityDate = System.today().addDays(-12);
        List<Task> myLst2 = new List<Task>{task2};
        IC_Task_TRG.taskSetAccLastContactDate(myLst2);
        // IC_Task_TRG.taskSetAccLastContactDate(new List<Task>{task2});
        System.assertNotEquals(task2.ActivityDate, acc.LastActivityDate);
        
        Test.stopTest();    
    }

    @isTest
    static void relatedCaseTaskToAccount_CaseTest()
    {
        // create an client
        Account client = ICX_TestFactory.createAccount();
        insert client;

        // create a case for the above client
        Case ca = ICX_TestFactory.createCase(client.id);
        Id contactId = [Select id from Contact where Accountid =: client.id LIMIT 1].id;
        ca.contactid = contactid;
        insert ca;

        // create an inbound email task on that case
        Task t = ICX_TestFactory.createEmailTaskOnCase(ca.id);
        Test.startTest();
        insert t;
        Test.stopTest();

        t = [SELECT whoid from Task where id =: t.id];
        System.assertEquals(contactId, t.whoid);
    }

    @isTest
    static void relatedCaseTaskToAccount_ReplaceAccountIdByWhoIdTest() {
        // Init
        Account client = ICX_TestFactory.createAccount();
        insert client;
        
        Calling_Campaign__c campaign = new Calling_Campaign__c(Client__c = client.Id);
        insert campaign;
        System.debug('relatedCaseTaskToAccount_ReplaceAccountIdByWhoIdTest,campaign ' + campaign);        

        
        // Outbound call from the CTI Connector
        Task t = new Task(Subject = 'Call 2018-04-17 17:16:15',
                          CallObject = 'VOICE.83917129.1523978169173.0050H000009JXM6QAO',
                          cnx__CTIInfo__c = 'ANI: +33664309999, DNIS: 19112224, DialedNumber: 19101099',
                          cnx__UniqueId__c = 'VOICE.83917129.1523978169173.0050H000009JXM6QAO',
                          Description = 'Call: Here goes the task description',
                          Status = 'Completed',
                          CallType = 'Outbound',
                          WhatId = campaign.Id);

        // Test
        Test.startTest();
        insert t;
        Test.stopTest();

        // Check
        t = [SELECT AccountId, WhoId from Task where id =: t.id];
        System.debug('relatedCaseTaskToAccount_ReplaceAccountIdByWhoIdTest, t.AccountId ' + t.AccountId);        
        System.debug('relatedCaseTaskToAccount_ReplaceAccountIdByWhoIdTest,client.Id ' + client.Id);        
        System.assertEquals(client.Id, t.AccountId);

        Id contactId = [Select id from Contact where Accountid =: client.id LIMIT 1].id;
        System.debug('relatedCaseTaskToAccount_ReplaceAccountIdByWhoIdTest, t.WhoId '  + t.WhoId);        
        System.debug('relatedCaseTaskToAccount_ReplaceAccountIdByWhoIdTest, contactId ' + contactId);        
        System.assertEquals(contactId, t.WhoId);
    }

    @isTest
    static void relatedCaseTaskToAccount_ReplaceWhatIdByWhoIdTest() {
        // create an client
        Account client = ICX_TestFactory.createAccount();
        insert client;

        // create an incoming call task on that account
        Task t = ICX_TestFactory.creatCallTaskOnAccount(client.Id);

        Test.startTest();
        insert t;
        Test.stopTest();
        
        // Check
        t = [SELECT whoid, whatId from Task where id = :t.id];
        Account accResult = [SELECT PersonContactId FROM Account WHERE Id = :client.Id];
        System.assertEquals(accResult.PersonContactId, t.whoid);
        System.assert(t.whatId == null);
    } //*/

    @isTest
    static void setInOutOnTask()
    {
        // create an client
        Account client = ICX_TestFactory.createAccount();
        insert client;

        // create a case
        Case ca = ICX_TestFactory.createCase(client.id);
        insert ca;

        // create tasks
        Task inTask = ICX_TestFactory.createEmailTaskOnCase(ca.id);
        Task outTask = ICX_TestFactory.createEmailTaskOnCase(ca.id);
        insert inTask;
        insert outTask;

        // create an inbound email on the above case
        EmailMessage inEmail = ICX_TestFactory.createEmailOnCase(ca.id, 'client@clientmail.com', 'agent@agentmail.com', true);
        inEmail.activityId = inTask.id;
        // create an outbound email on the above case
        EmailMessage outEmail = ICX_TestFactory.createEmailOnCase(ca.id, 'agent@agentmail.com', 'client@clientmail.com', false);
        outEmail.activityId = outTask.id;

        Test.startTest();
        insert inEmail;
        insert outEmail;
        Test.stopTest();

        inTask = [Select id, inout__c from Task where id =: inEmail.activityid];
        outTask = [Select id, inout__c from Task where id =: outEmail.activityid];
        System.assertEquals('In', inTask.inout__c);
        System.assertEquals('Out', outTask.inout__c);
    }
    
    @isTest
    public static void updateTypeAsCall_TEST() {
        // Init data
        Task t = ICX_TestFactory.creatCallTaskOnAccount(null);

        // Test
        Test.startTest();
        insert t;
        Test.stopTest();

        // Check
        t = [SELECT TaskSubtype, RecordTypeId from Task where id = :t.id];
        System.assertEquals('Call', t.TaskSubtype);
    }


    @isTest
    public static void updateActionTypeAsEmail_TEST() {
        // Init data
        
        // Case mandatory to force "ICONICS Email" record type
        Case cas = ICX_TestFactory.createCase(null);
        insert cas;
        EmailMessage email = ICX_TestFactory.createEmailOnCase(cas.Id, 'fromAdd@email.com', 'toAdd@email.com', false);

        //Task t = ICX_TestFactory.createEmailTaskOnCase(cas.Id);

        // Test
        Test.startTest();
        //insert t;
        // Outbound Email created => Task created auto by Salesforce
        insert email;
        Test.stopTest();

        EmailMessage emailResult = [SELECT ActivityId from EmailMessage WHERE Id = :email.Id];
        Task taskResult = [SELECT TaskSubtype, RecordTypeId from Task WHERE Id = :emailResult.ActivityId];
        System.assertEquals('Email', taskResult.TaskSubtype);

        Id iconicsEmailRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSC_Email').getRecordTypeId();
        System.assertEquals(iconicsEmailRecordTypeId, taskResult.RecordTypeId);

        // Check
/*        t = [SELECT TaskSubtype, RecordTypeId from Task where id = :t.id];
        System.assertEquals('Email', t.TaskSubtype);

        Id iconicsEmailRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSC_Email').getRecordTypeId();
        System.assertEquals(iconicsEmailRecordTypeId, t.RecordTypeId);
*/
    }
/*
    @isTest
    public static void updateFlagOneClient_onDelete_Test() {
        // Init data

        Task tsk = ICX_TestFactory.creatCallTaskOnAccount(null);
        insert tsk;
        
        // Update program by a Datastage profile
        User u2 = createDatastageUser();
        System.runAs(u2) {
            tsk.SendToOneClient__c = false;
            update tsk;
        }
        
        List<Task> taskList = [SELECT SendToOneClient__c FROM Task];
        System.assertEquals(1, taskList.size());
        System.assertEquals(false, taskList[0].SendToOneClient__c);
        
        // Test
        Test.startTest();
        delete tsk;
        Test.stopTest();
        
        // Check
        List<Task> resultList = [SELECT SendToOneClient__c FROM Task ALL ROWS];
        System.assertEquals(1, resultList.size());
        System.assertEquals(true, resultList[0].SendToOneClient__c);
    }

    private static User createDatastageUser() {
        Profile p = [SELECT Id FROM Profile WHERE Name='LV_Interface_Datastage'];
        User u2 = new User(Alias = 'newUser', Email='newuser@testorg.com',
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                           LocaleSidKey='en_US', ProfileId = p.Id,
                           TimeZoneSidKey='America/Los_Angeles', UserName='newuser@testorg' + Integer.valueOf(math.rint(math.random()*1000000)) + '.com');
        return u2;
    }
*/
    @isTest
    static void updateRecordTypeToEmailBeforeUpdateTest() {

        Id iconicsEmailRecordTypeId;
        try {
            iconicsEmailRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSC_Email').getRecordTypeId();
        } catch (Exception e) {}
        

        Case ca = ICX_TestFactory.createCase(null);
        insert ca;
    
        Task newTask = new Task(Whatid = ca.id);

        List<Profile> profileId = [Select Id From Profile Where Name='System Administrator'];
        User newUser = ICX_TestFactory.createUser(profileId[0].id);
        insert newUser;

        // Test
        Test.startTest();
        System.runAs(newUser) {
            insert newTask;
            newTask.ActionType__c = 'Email';
            update newTask;
        }
        Test.stopTest();

        // Check
        newTask = [SELECT RecordTypeId from Task where id = :newTask.id];
        System.assertEquals(iconicsEmailRecordTypeId, newTask.RecordTypeId);

    } 

    @isTest
    static void updateRecordTypeToEmailBeforeInsertTest() {

        Id iconicsEmailRecordTypeId;
        try {
            iconicsEmailRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSC_Email').getRecordTypeId();
        } catch (Exception e) {}

        Case ca = ICX_TestFactory.createCase(null);
        insert ca;
    
        Task newTask = new Task(ActionType__c = 'Email',
                                Whatid = ca.id);

        List<Profile> profileId = [Select Id From Profile Where Name='System Administrator'];
        User newUser = ICX_TestFactory.createUser(profileId[0].id);
        insert newUser;

        // Test
        Test.startTest();
        System.runAs(newUser) {
            insert newTask;
        }
        Test.stopTest();

        // Check
        newTask = [SELECT RecordTypeId from Task where id = :newTask.id];
        System.assertEquals(iconicsEmailRecordTypeId, newTask.RecordTypeId);
    }

    
    @isTest
    static void updateRecordTypeIdToIcxCallTest() {

        Id iconicsCallRecordTypeId;
        try {
            iconicsCallRecordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSC_Call').getRecordTypeId();        
        } catch (Exception e) {
            System.debug('error ' + e);
        }

        Task newTask = new Task(Subject = 'To Test Class updateRecordTypeIdToIcxCall',
                            CallObject = 'VOICE.83917123.1523978169173.0050H000009JXM6QAO',
                            RecordTypeId = iconicsCallRecordTypeId);

        // Test
        Test.startTest();
        insert newTask;
        Test.stopTest();

        // Check
        newTask = [SELECT RecordTypeId FROM Task WHERE id = :newTask.id];
        System.assertEquals(iconicsCallRecordTypeId, newTask.RecordTypeId);
    }
    
   static testMethod void CreateNotification() {
        // Init data
        Id recordTypeId = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('CSC_Call').getRecordTypeId();
        init();
        Task t = ICX_TestFactory.creatCallTaskOnAccount(acc.Id);
        // Test
       
        t.recordTypeId = recordTypeId;
        t.CallType = 'Inbound';
        t.ICX_Country__c='USA';
        insert t;

        Test.startTest();
        t.Resolution__c='Immediate Response';
        update t;
        Test.stopTest();       
        
        // Check
        //     
             
        List<Notification_Settings__mdt> notificationSettings = [select id,DeveloperName ,Is_Active__c from Notification_Settings__mdt where DeveloperName ='VOICE_AFTER_CALL_SURVEY'  and Is_Active__c=true];
        integer numOfNotif= 0;
        List<Notification__c> notif = [select id from notification__c];
        if(!notificationSettings.isEmpty()){
           numOfNotif= 1;
        }
        System.assertEquals(numOfNotif, notif.size());
    }


	  @isTest
    static void taskApprovalCompleted() {
        	  Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
          
        Id profileId = [SELECT Id FROM Profile WHERE Name='ICONiCS_SA' LIMIT 1].Id;

        User CAUser = ICX_TestFactory.createUser(profileId);
        CAUser.Country__c='SAUDI ARABIA';
        insert CAUser;
        
  
        
        Order__c order = ICX_TestFactory.createOrder(acc) ;
        order.OwnerId__c = CAUser.Id;
        insert order;

  		    List<OrderShipping__c> orderShippingInsert = new List<OrderShipping__c>();
  		OrderShipping__c orderShipping = ICX_TestFactory.createOrderShipping(order);
        orderShippingInsert.add(orderShipping);
        
        OrderShipping__c orderShipping2 = ICX_TestFactory.createOrderShipping(order);
        orderShipping2.ShippingNumber__c ='0123456789-2';
        orderShippingInsert.add(orderShipping2);
  
        insert orderShippingInsert;
 
       
        List<OrderLine__c> OrderLineInsert = new List<OrderLine__c>();

  		OrderLine__c orderLine = ICX_TestFactory.createOrderLine(order);
        orderLine.OrderShipping__c =orderShipping.Id;
        OrderLineInsert.add(orderLine);
        
        OrderLine__c orderLine2 = ICX_TestFactory.createOrderLine(order);
        orderLine2.OrderShipping__c =orderShipping2.Id;
        OrderLineInsert.add(orderLine2);
        
        insert OrderLineInsert;        

        
        Id taskRecordIdApproval = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Approval').getRecordTypeId();    
         Task newTask = new Task(); 
         newTask.OwnerId = CAUser.Id;
         newTask.ActivityDate = Date.today();
         newTask.recordTypeId = taskRecordIdApproval;
         newTask.WhoId = acc.PersonContactId;
        newTask.WhatId = orderShipping.Id;
        newTask.Subject = String.valueOF(orderShipping.Id)+' PRICE_ADJUSTMENT Rejected';
		newTask.Priority = 'High';
        newTask.Status = 'New';
        newTask.Description ='test task approval';
        insert newTask;
        
         Test.startTest();       

             StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
  		mock.setStaticResource('KBRWUpdateOrderShipping');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;');
        Test.setMock(HttpCalloutMock.class, mock);
        
        List<Task> taskApproval = [SELECT Id FROM Task WHERE RecordTypeId=: taskRecordIdApproval AND Status ='New'];
        taskApproval[0].Status ='Completed';
        update taskApproval;
         Test.stopTest();

        

        
    }

      @isTest
    static void taskApprovalCompletedBankTransfer() {
        	  Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
          
        Id profileId = [SELECT Id FROM Profile WHERE Name='ICONiCS_SA' LIMIT 1].Id;

        User CAUser = ICX_TestFactory.createUser(profileId);
        CAUser.Country__c='SAUDI ARABIA';
        insert CAUser;
        
  
        
        Order__c order = ICX_TestFactory.createOrder(acc) ;
        order.OwnerId__c = CAUser.Id;
        insert order;

  		    List<OrderShipping__c> orderShippingInsert = new List<OrderShipping__c>();
  		OrderShipping__c orderShipping = ICX_TestFactory.createOrderShipping(order);
        orderShippingInsert.add(orderShipping);
        
        OrderShipping__c orderShipping2 = ICX_TestFactory.createOrderShipping(order);
        orderShipping2.ShippingNumber__c ='0123456789-2';
        orderShippingInsert.add(orderShipping2);
  
        insert orderShippingInsert;
 
       
        List<OrderLine__c> OrderLineInsert = new List<OrderLine__c>();

  		OrderLine__c orderLine = ICX_TestFactory.createOrderLine(order);
        orderLine.OrderShipping__c =orderShipping.Id;
        OrderLineInsert.add(orderLine);
        
        OrderLine__c orderLine2 = ICX_TestFactory.createOrderLine(order);
        orderLine2.OrderShipping__c =orderShipping2.Id;
        OrderLineInsert.add(orderLine2);
        
        insert OrderLineInsert;        

        
        Id taskRecordIdApproval = Schema.SObjectType.Task.getRecordTypeInfosByDeveloperName().get('Approval').getRecordTypeId();    
         Task newTask = new Task(); 
         newTask.OwnerId = CAUser.Id;
         newTask.ActivityDate = Date.today();
         newTask.recordTypeId = taskRecordIdApproval;
         newTask.WhoId = acc.PersonContactId;
        newTask.WhatId = order.Id;
        newTask.Subject = String.valueOF(order.Id)+' BANK_TRANSFER Rejected';
		newTask.Priority = 'High';
        newTask.Status = 'New';
        newTask.Description ='test task approval';
        insert newTask;
        
         Test.startTest();       

             StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
  		mock.setStaticResource('KBRWUpdateOrderShipping');
        mock.setStatusCode(200);
        mock.setHeader('Content-Type', 'application/json;');
        Test.setMock(HttpCalloutMock.class, mock);
        
        List<Task> taskApproval = [SELECT Id FROM Task WHERE RecordTypeId=: taskRecordIdApproval AND Status ='New'];
        taskApproval[0].Status ='Completed';
        update taskApproval;
         Test.stopTest();

        

        
    }

}