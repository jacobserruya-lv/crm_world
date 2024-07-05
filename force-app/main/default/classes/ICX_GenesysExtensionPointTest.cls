@isTest
class ICX_GenesysExtensionPointTest {
    
    @isTest
    static void testOnScreenPop(){
        String data = '{"searchValue":"+33000000","interaction":{"id":"815f8e56-74fb-4dfd-a61a-be510925e667","phone":"tel:+33782922643","name":"Mobile Number, France","isConnected":false,"isDisconnected":false,"isDone":false,"state":"ALERTING","attributes":{"sf_urlpop":"","Salesforce.ParticipantId":"ecc0f972-a82d-4dac-8e61-9c72d5b6d8e9","Participant.LVM_SFDCAccounts_Identify":"Single Match","Participant.LVM_Destination_Country":"Belgium"},"isCallback":false,"isDialer":false,"isChat":false,"isEmail":false,"isMessage":false,"isVoicemail":false,"remoteName":"Mobile Number, France","recordingState":"active","displayAddress":"+33000000","queueName":"EMEA_Voice_CSC_FR","ani":"+3300000000","calledNumber":"+33178414729","totalIvrDurationSeconds":10,"direction":"Inbound","isInternal":false}}';
        ICX_GenesysExtensionPoint genExt = new ICX_GenesysExtensionPoint();
        String res = genExt.onScreenPop(data);
        Assert.areEqual('{"defaultScreenPop":false}', res);
    }
    
    @isTest
    static void testOnSaveLogCallConnectedDisconnected(){  
        Account acc1 = new Account(
            FirstName='Test',
            LastName='Unit 2',
            PersonMobilePhone = '+3300112233'
        );
        insert acc1;
        Store__c store = new Store__c(
            CommercialName__c='Test store',
            RetailStoreId__c='TEST'
        );
        insert store;
        String callJson = ' {"callLog":{"subject":"Call 28/03/2022, 11:25:33","LVM_SFDCAccounts_Identify__c":"Single Match","Genesys_Queue__c":"US_Phones_2_Shipments_EN","Genesys_IsInternal__c":"False","Status":"Completed","CallType":"Inbound","CallObject":"216ad111-7526-4075-8d8e-232cbd717c3b","Type":"Call","ActivityDate":"2022-3-28"},"interaction":{"id":"216ad111-7526-4075-8d8e-232cbd717c3b","connectedTime":"2022-03-28T09:25:33.923Z","phone":"tel:+3300000000","name":"Mobile Number, France","isConnected":true,"isDisconnected":false,"isDone":false,"state":"CONNECTED","attributes":{"sf_urlpop":"'+acc1.Id+'","Salesforce.ParticipantId":"028b35f1-e3f5-4aa6-aa22-1105097acd83","Participant.LVM_SFDCAccounts_Identify":"Single Match","Participant.LVM_Destination_Country":"USA","Participant.StoreCode":"'+store.RetailStoreId__c+'"},"isCallback":false,"isDialer":false,"isChat":false,"isEmail":false,"isMessage":false,"isVoicemail":false,"remoteName":"Mobile Number, France","recordingState":"active","displayAddress":"+3300000000","queueName":"US_Phones_2_Shipments_EN","ani":"+33782922643","calledNumber":"+33178414725","totalIvrDurationSeconds":17,"direction":"Inbound","isInternal":false,"startTime":"2022-03-28T09:25:13.594Z"},"eventName":"interactionChanged"}';
        ICX_GenesysExtensionPoint genExt = new ICX_GenesysExtensionPoint();
        Id taskId = genExt.onSaveLog(callJson);
        Assert.isNotNull(taskId);

        Task t = [SELECT Id, Store_Location__c FROM Task WHERE id = :taskId];
        Assert.areEqual(store.Id, t.Store_Location__c);

        String disconnectJSON = '{"callLog":{"id":"'+taskId+'","calldurationinseconds":2},"interaction":{"id":"37510b14-1480-4d7a-990e-78fba94874a0","connectedTime":"2022-03-14T11:40:44.746Z","endTime":"2022-03-14T11:40:46.758Z","phone":"tel:+3300112233","name":"Mobile Number, France","isConnected":false,"isDisconnected":true,"isDone":true,"state":"DISCONNECTED","attributes":{"Salesforce.ParticipantId":"27f173de-332b-4237-ab08-5dfe4834fadf"},"isCallback":false,"isDialer":false,"isChat":false,"isEmail":false,"isMessage":false,"isVoicemail":false,"remoteName":"Mobile Number, France","recordingState":"none","displayAddress":"+3300112233","ani":"Internal","calledNumber":"+3300112233","interactionDurationSeconds":2,"direction":"Outbound","isInternal":false,"startTime":"2022-03-14T11:40:33.842Z"},"eventName":"interactionDisconnected"}';
        Id disconnectTaskId = genExt.onSaveLog(disconnectJSON);
        Assert.isNotNull(disconnectTaskId);
    }

    @isTest
    static void testOnSaveLogInternal(){
        String callJson = '{"callLog":{"subject":"Call 14/03/2022, 12:28:33","LVM_SFDCAccounts_Identify__c":"Single Match","Genesys_Queue__c":"EMEA_Voice_CSC_FR","Genesys_IsInternal__c":"False","Status":"Completed","CallType":"Inbound","CallObject":"ded50a35-0137-450b-bf32-0767f01dcc7a","Type":"Call","ActivityDate":"2022-3-14"},"interaction":{"id":"ded50a35-0137-450b-bf32-0767f01dcc7a","connectedTime":"2022-03-14T11:28:33.067Z","phone":"tel:+33000000000","name":"Mobile Number, France","isConnected":true,"isDisconnected":false,"isDone":false,"state":"CONNECTED","attributes":{"Participant.LVM_Destination_Country":"Belgium","Salesforce.ParticipantId":"5fed62dc-3945-4f16-8482-b05969d8d57f","Participant.LVM_SFDCAccounts_Identify":"Single Match"},"isCallback":false,"isDialer":false,"isChat":false,"isEmail":false,"isMessage":false,"isVoicemail":false,"remoteName":"Mobile Number, France","recordingState":"active","displayAddress":"+33000000000","ani":"+33000000000","calledNumber":"+33178414729","totalIvrDurationSeconds":7,"direction":"Inbound","isInternal":true,"startTime":"2022-03-14T11:28:21.344Z"},"eventName":"interactionChanged"}';
        ICX_GenesysExtensionPoint genExt = new ICX_GenesysExtensionPoint();
        Id taskId = genExt.onSaveLog(callJson);
        Assert.isNull(taskId);
    }
    
    @isTest
    static void testSaveLog(){
        String data = 'Data Message';
        String interactionId = 'InteractionID';
        String recordId = 'RecordId';
        ICX_GenesysExtensionPoint.log(data, interactionId, recordId);
        Logs__c log = [SELECT Id, Message__c, Other_Details__c, Record_Id__c FROM Logs__c 
                       WHERE Apex_Class__c = 'ICX_GenesysExtensionPoint' AND createdDate = TODAY LIMIT 1];
        Assert.isNotNull(log);
        Assert.areEqual(data, log.Message__c);
        Assert.areEqual(interactionId, log.Other_Details__c);
        Assert.areEqual(recordId, log.Record_Id__c);
    }
}