@isTest
class ICX_GenesysTaskStoreTest {

     @testSetup static void setup() {
         Account acc = new Account(
            FirstName='TestTask',
            LastName='Unit',
            PersonMobilePhone = '+3300112233'
        );
        insert acc;       
    }
    
	@isTest 
    static void TestCreateTask(){ 
        Account acc = [SELECT Id FROM Account WHERE FirstName='TestTask'];
        String callJson = '{"callLog":{"subject":"Call 28/03/2022, 11:25:33","LVM_SFDCAccounts_Identify__c":"Single Match","Genesys_Queue__c":"US_Phones_2_Shipments_EN","Genesys_IsInternal__c":"False","Status":"Completed","CallType":"Inbound","CallObject":"216ad111-7526-4075-8d8e-232cbd717c3b","Type":"Call","ActivityDate":"2022-3-28"},"interaction":{"id":"216ad111-7526-4075-8d8e-232cbd717c3b","connectedTime":"2022-03-28T09:25:33.923Z","phone":"tel:+3300000000","name":"Mobile Number, France","isConnected":true,"isDisconnected":false,"isDone":false,"state":"CONNECTED","attributes":{"sf_urlpop":"'+acc.Id+'","Salesforce.ParticipantId":"028b35f1-e3f5-4aa6-aa22-1105097acd83","Participant.LVM_SFDCAccounts_Identify":"Single Match","Participant.LVM_Destination_Country":"USA"},"isCallback":false,"isDialer":false,"isChat":false,"isEmail":false,"isMessage":false,"isVoicemail":false,"remoteName":"Mobile Number, France","recordingState":"active","displayAddress":"+3300000000","queueName":"US_Phones_2_Shipments_EN","ani":"+33782922643","calledNumber":"+33178414725","totalIvrDurationSeconds":17,"direction":"Inbound","isInternal":false,"startTime":"2022-03-28T09:25:13.594Z"},"eventName":"interactionChanged"}';
        ICX_GenesysExtensionPoint genExt = new ICX_GenesysExtensionPoint();
        Id taskId = genExt.onSaveLog(callJson);
        Assert.isNotNull(taskId);
    }
    
   	@isTest
    static void TestCreateTaskWithFalseCountry(){
        Account acc = [SELECT Id FROM Account WHERE FirstName='TestTask'];
        String callJson = '{"callLog":{"subject":"Call 28/03/2022, 11:25:33","LVM_SFDCAccounts_Identify__c":"Single Match","Genesys_Queue__c":"US_Phones_2_Shipments_EN","Genesys_IsInternal__c":"False","Status":"Completed","CallType":"Inbound","CallObject":"216ad111-7526-4075-8d8e-232cbd717c3b","Type":"Call","ActivityDate":"2022-3-28"},"interaction":{"id":"216ad111-7526-4075-8d8e-232cbd717c3b","connectedTime":"2022-03-28T09:25:33.923Z","phone":"tel:+3300000000","name":"Mobile Number, France","isConnected":true,"isDisconnected":false,"isDone":false,"state":"CONNECTED","attributes":{"sf_urlpop":"'+acc.Id+'","Salesforce.ParticipantId":"028b35f1-e3f5-4aa6-aa22-1105097acd83","Participant.LVM_SFDCAccounts_Identify":"Single Match","Participant.LVM_Destination_Country":"FALSE"},"isCallback":false,"isDialer":false,"isChat":false,"isEmail":false,"isMessage":false,"isVoicemail":false,"remoteName":"Mobile Number, France","recordingState":"active","displayAddress":"+3300000000","queueName":"US_Phones_2_Shipments_EN","ani":"+33782922643","calledNumber":"+33178414725","totalIvrDurationSeconds":17,"direction":"Inbound","isInternal":false,"startTime":"2022-03-28T09:25:13.594Z"},"eventName":"interactionChanged"}';
        ICX_GenesysExtensionPoint genExt = new ICX_GenesysExtensionPoint();
        Id taskId = genExt.onSaveLog(callJson);
        Assert.isNotNull(taskId);
    }
    
    @isTest 
    static void TestCreateTaskCallback(){ 
        Account acc = [SELECT Id FROM Account WHERE FirstName='TestTask'];
        String callJson = '{"callLog":{"subject":"Callback 18/07/2023 08:48:31","Status":"Completed","CallType":"Inbound","CallObject":"test-callback","Type":"Call","ActivityDate":"2023-7-18"},"interaction":{"id":"test-callback","connectedTime":"2023-07-18T05:48:31.560Z","name":"Name Not Provided","isConnected":true,"isDisconnected":false,"isDone":false,"state":"CONNECTED","isCallback":true,"isDialer":false,"isChat":false,"isEmail":false,"isMessage":false,"isVoicemail":false,"direction":"Inbound","isInternal":false,"callbackNumbers":["+33122334455"]},"eventName":"interactionChanged"}';        
        ICX_GenesysExtensionPoint genExt = new ICX_GenesysExtensionPoint();
        Id taskId = genExt.onSaveLog(callJson);
        Assert.isNotNull(taskId);
    }
   
    @isTest
    static void TestUpdateTaskDuration(){ 
        Task t = new Task();
        insert t;
        
        ICX_GenesysData.Interaction interaction = new ICX_GenesysData.Interaction();
        ICX_GenesysData dataObj = new ICX_GenesysData();
        dataObj.callLog = new ICX_GenesysData.callLog();
        dataObj.Interaction = new ICX_GenesysData.Interaction();
        dataObj.callLog.id = null;
        dataObj.interaction.interactionDurationSeconds = 120;
        
        Id taskId1 = ICX_GenesysTaskStore.updateTaskDuration(dataObj);
        Assert.isNull(taskId1);
        
        dataObj.callLog.id = t.Id;
        Id taskId2 = ICX_GenesysTaskStore.updateTaskDuration(dataObj);
		Task t2 = [SELECT Id, CallDurationInSeconds FROM Task WHERE Id = :taskId2];
        Assert.isNotNull(taskId2);
        Assert.areEqual(120, t2.CallDurationInSeconds);
    }
    
    @isTest
    static void TestFalseCountryAndStoreCode(){  
        String callJson='{"callLog":{"LVM_SFDCAccounts_Identify__c":"No Match","Genesys_Queue__c":"Europe_Phone_NL","Genesys_IsInternal__c":"False","calldurationinseconds":317,"Status":"Completed","CallObject":"888888-2ffd-49a5-aba4-84e439b1be2f","Type":"Call","ActivityDate":"2022-4-27"},"interaction":{"id":"11111-2222-3333-44444-5555","connectedTime":"2022-04-27T16:03:55.409Z","endTime":"2022-04-27T16:09:12.907Z","phone":"tel:+33782922643","name":"+31655534833","isConnected":true,"isDisconnected":false,"isDone":true,"state":"CONNECTED","attributes":{"Participant.LVM_Destination_Country":"AAABBBB","Participant.StoreCode":"AAABBB","Participant.LVM_SFDCAccounts_Identify":"No Match"},"isCallback":false,"isDialer":false,"isChat":false,"isEmail":false,"isMessage":false,"isVoicemail":false,"remoteName":"+31655534833","recordingState":"none","displayAddress":"+31655534833","queueName":"Europe_Phone_NL","ani":"+31655534833","calledNumber":"+3226220208","interactionDurationSeconds":317,"totalIvrDurationSeconds":24,"totalAcdDurationSeconds":426,"dispositionDurationSeconds":148,"isInternal":false,"startTime":"2022-04-27T15:56:24.825Z"},"eventName":"interactionRemoved"}';
        ICX_GenesysExtensionPoint genExt = new ICX_GenesysExtensionPoint();
        Id taskId = genExt.onSaveLog(callJson);

        List<Task> taskList = [SELECT Id FROM Task WHERE createdDate = TODAY AND CallObject = '11111-2222-3333-44444-5555'];
        Assert.areEqual(1, taskList.size());
        Assert.isNotNull(taskId);
    } 
}