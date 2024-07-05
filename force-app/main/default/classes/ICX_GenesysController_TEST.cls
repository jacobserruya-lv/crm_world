@isTest
class ICX_GenesysController_TEST {
    @isTest
    static void TestGetTaskId(){
        Account acc1 = new Account(
            FirstName='Test',
            LastName='Unit',
            PersonMobilePhone = '+3300112233'
        );
        insert acc1;
        String callJson = '{"callLog":{"subject":"Call 28/03/2022, 11:25:33","LVM_SFDCAccounts_Identify__c":"Single Match","Genesys_Queue__c":"US_Phones_2_Shipments_EN","Genesys_IsInternal__c":"False","Status":"Completed","CallType":"Inbound","CallObject":"216ad111-7526-4075-8d8e-232cbd717c3b","Type":"Call","ActivityDate":"2022-3-28"},"interaction":{"id":"216ad111-7526-4075-8d8e-232cbd717c3b","connectedTime":"2022-03-28T09:25:33.923Z","phone":"tel:+3300000000","name":"Mobile Number, France","isConnected":true,"isDisconnected":false,"isDone":false,"state":"CONNECTED","attributes":{"sf_urlpop":"'+acc1.Id+'","Salesforce.ParticipantId":"028b35f1-e3f5-4aa6-aa22-1105097acd83","Participant.LVM_SFDCAccounts_Identify":"Single Match","Participant.LVM_Destination_Country":"USA"},"isCallback":false,"isDialer":false,"isChat":false,"isEmail":false,"isMessage":false,"isVoicemail":false,"remoteName":"Mobile Number, France","recordingState":"active","displayAddress":"+3300000000","queueName":"US_Phones_2_Shipments_EN","ani":"+33782922643","calledNumber":"+33178414725","totalIvrDurationSeconds":17,"direction":"Inbound","isInternal":false,"startTime":"2022-03-28T09:25:13.594Z"},"eventName":"interactionChanged"}';
        ICX_GenesysExtensionPoint genExt = new ICX_GenesysExtensionPoint();
        Id taskId = genExt.onSaveLog(callJson);
        Id taskRetrieved = ICX_GenesysController.getTaskId('216ad111-7526-4075-8d8e-232cbd717c3b', 1, 0);
        Assert.areEqual(taskId, taskRetrieved);
        
        Id monitoringTask = ICX_GenesysController.getTaskId('216ad111-7526-4075-8d8e-232cbd717c3b', 0, 1);
        Task t = [SELECT Id, WhatId, WhoId FROM Task WHERE Id = :taskId];
        Assert.isNotNull(monitoringTask);
        Assert.isNull(t.WhatId);
        Assert.isNull(t.WhoId);
    }
    
    @isTest
    static void TestUpdateCase(){  
        Account a = new Account(Name='TEST UNIT');
        Case c = new Case(
            Accountid = a.Id,
            Origin = 'Email',
            Status = 'New'
        );
        insert c;
        Test.startTest();
        ICX_GenesysController.updateCase(c.Id, 'conversationId', 'participantId');
        Test.stopTest();
        c = [SELECT Id, ICX_GenesysConversationId__c, ICX_GenesysParticipantID__c FROM Case WHERE Id = :c.Id];
        Assert.areEqual('conversationId', c.ICX_GenesysConversationId__c);
        Assert.areEqual('participantId', c.ICX_GenesysParticipantID__c);
    }
    
    @isTest
    static void TestCaseOwnerToInitialQueue(){  
        Group testGroup = new Group(Name='QUEUE NAME', Type='Queue');
        insert testGroup;
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueuesObject testQueue = new QueueSObject(QueueID = testGroup.id, SObjectType = 'Case');
            insert testQueue;
        }
        
        Case c = new Case(
            ICX_GenesysConversationId__c = 'conversationId',  
            Origin = 'Email',
            OwnerId = UserInfo.getUserId(),
            Status = 'New',
            TECH_Queue_ID__c = testGroup.Id
        );
        insert c;
        
        Test.startTest();
        ICX_GenesysController.setCaseOwnerToInitialQueue('conversationId');
        Test.stopTest();
        
        Case updatedCase = [SELECT Id, OwnerId, TECH_Queue_ID__c FROM Case WHERE Id = :c.Id];
        Assert.areEqual(testGroup.Id, updatedCase.TECH_Queue_ID__c);
        Assert.areEqual(updatedCase.TECH_Queue_ID__c, updatedCase.OwnerId);  
    }

    @isTest
    static void TestGetSettings(){  
        ICX_GenesysSettings__c customSettings = new ICX_GenesysSettings__c(
            ClientelingStatusId__c = 'clientelingID',
            HongKongQueueId__c = 'queueId',
            MonitoringStatusId__c = 'monitoringID',
            MonitoringUserId__c = 'userId', 
            TaskRetryLimit__c = 4
        );
        insert customSettings;
        Map<String, Object> settings = ICX_GenesysController.getSettings();
        Assert.isNotNull(settings);
        Assert.areEqual('clientelingID', settings.get('clientelingStatusId'));
        Assert.areEqual('monitoringID', settings.get('monitoringStatusId'));
        Assert.areEqual(4, settings.get('retryLimit'));
    }
}