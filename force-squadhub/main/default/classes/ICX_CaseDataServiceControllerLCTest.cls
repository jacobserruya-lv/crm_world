@isTest
public class ICX_CaseDataServiceControllerLCTest {
/*
    // // Avoid : System.DmlException: Insert failed. First exception on row 0; 
    // // first error: MIXED_DML_OPERATION, DML operation on setup object is not permitted after you have updated a non-setup object (or vice versa): MessagingChannel, original object: Account: []
    // //@testSetup
    // //public static void init() {
    //     //MessagingChannel chan = createMessagingChannel();//[SELECT Id FROM MessagingChannel WHERE MessageType='Text' LIMIT 1];
    //     //insert chan;
    // //}
    
    // // test getAccountId()
    @isTest
    public static void getAccountId_CaseTest() {
        // test case empty
        System.assertEquals(null, ICX_CaseDataServiceControllerLC.getAccountId(null));
        
        // test 2
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        Case cas = ICX_TestFactory.createCase(acc.Id);
        insert cas;
        
        Test.startTest();
        Id accId = ICX_CaseDataServiceControllerLC.getAccountId(cas.Id);
        Id accId2 = ICX_CaseDataServiceControllerLC.getAccountIdByField(cas.Id, 'AccountId');
        Test.stopTest();

        System.assertEquals(acc.Id, accId);
        System.assertEquals(acc.Id, accId2);
    }

    @isTest
    public static void getAccountId_TaskTest() {
        // test case empty
        System.assertEquals(null, ICX_CaseDataServiceControllerLC.getAccountId(null));
        
        // test 2
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        Case cas = ICX_TestFactory.createCase(acc.Id);
        insert cas;
        
        Task task = ICX_TestFactory.createEmailTaskOnCase(cas.Id);
        // task.accountId = acc.Id; // field not writeable
        task.WhatId = acc.id;
        insert task;
        
        Test.startTest();
        Id accId = ICX_CaseDataServiceControllerLC.getAccountId(task.Id);
        Id accId2 = ICX_CaseDataServiceControllerLC.getAccountIdByField(task.Id, null);
        Test.stopTest();

        System.assertEquals(acc.Id, accId);
         System.assertEquals(acc.Id, accId2);
    }
    
    @isTest
    public static void getAccountId_CallingCampaignTest() {

        // Init
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        Calling_Campaign__c campaign = new Calling_Campaign__c(Client__c = acc.Id);
        insert campaign;
        
        // Test
        Test.startTest();
        Id accId = ICX_CaseDataServiceControllerLC.getAccountId(campaign.Id);
         Id accId2 = ICX_CaseDataServiceControllerLC.getAccountIdByField(campaign.Id, 'Client__c');
        Test.stopTest();

        // Check
        System.assertEquals(acc.Id, accId);
        System.assertEquals(acc.Id, accId2);
    }

    @isTest
    public static void getAccountId_LiveChatTranscriptTest() {
        
        // test 2
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        LiveChatVisitor lcv = new LiveChatVisitor();
        insert lcv;

        LiveChatTranscript chat = new LiveChatTranscript();//ICX_TestFactory.createCase(acc.Id);
        //cas.Name = 'TestLiveChat' + Math.random();
        chat.AccountId = acc.id;
        chat.LiveChatVisitorid = lcv.Id;
        insert chat;
        
        Test.startTest();
        Id accId = ICX_CaseDataServiceControllerLC.getAccountId(chat.Id);
        Test.stopTest();

        System.assertEquals(acc.Id, accId);
    }

    @isTest
    public static void getAccountId_MessagingSessionTest() {
        // Prepare
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
        MessagingSession mess = createMessagingSession();
        insert mess;

        MessagingSession mess2 = [SELECT MessagingEndUserId FROM MessagingSession WHERE Id = :mess.Id LIMIT 1];
        MessagingEndUser endUser = new MessagingEndUser(Id = mess2.MessagingEndUserId);
        endUser.AccountId = acc.Id;
        update endUser;

        // Test
        Test.startTest();
        Id accIdResult = ICX_CaseDataServiceControllerLC.getAccountId(mess.Id);
        Test.stopTest();

        // Check
        //MessagingSession result = [SELECT EndUserAccountId FROM MessagingSession WHERE Id = :mess.Id];
        System.assertEquals(acc.Id, accIdResult);
    }
    
    //  TODO
    // @isTest
    // public static void getAccountId_Task_NoAccountIdTest() {
    //     // test case empty
    //     System.assertEquals(null, ICX_CaseDataServiceControllerLC.getAccountId(null));
        
    //     // test 2
    //     Account acc = ICX_TestFactory.createAccount();
    //     insert acc;
        
    //     Task task = ICX_TestFactory.createEmailTaskOnCase(null);
    //     // task.accountId = acc.Id; // field not writeable
    //     //task.WhatId = acc.id;
    //     insert task;
        
    //     Case cas = ICX_TestFactory.createCase(acc.Id);
    //     insert cas;
        
    //     // should changed AccountId in empty
    //     task.WhatId = cas.Id;
    //     update task;
        
    //     Test.startTest();
    //     Id accId = ICX_CaseDataServiceControllerLC.getAccountId(task.Id);
    //     Test.stopTest();

    //     System.assertEquals(acc.Id, accId);
    // }

    @isTest
    public static void getCareServiceList_Test() {
        // Init Data
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
        // Care Services should be filtered
        Id StoreCareRTId = Schema.SObjectType.CareService__c.getRecordTypeInfosByDeveloperName().get('StoreCareService').getRecordTypeId(); 	 
       
        CareService__c careDelivered = ICX_TestFactory.createCareService(acc.Id);
        careDelivered.RecordTypeId = StoreCareRTId;
        careDelivered.MyRepairStatus__c = 'productDeliveredToClient';
        careDelivered.Shipping_Address_Line_1__c = 'address1';
        careDelivered.Shipping_City__c = 'Paris';
        careDelivered.Shipping_Country__c = 'FR';
        careDelivered.Shipping_State_Province__c = 'France';
        careDelivered.Shipping_Zip_Postal_Code__c = '123456';

        CareService__c careCancelled = ICX_TestFactory.createCareService(acc.Id);
        careCancelled.RecordTypeId = StoreCareRTId;
        careCancelled.MyRepairStatus__c = 'cancelled';
        careCancelled.Shipping_Address_Line_1__c = 'address1';
        careCancelled.Shipping_City__c = 'Paris';
        careCancelled.Shipping_Country__c = 'FR';
        careCancelled.Shipping_State_Province__c = 'France';
        careCancelled.Shipping_Zip_Postal_Code__c = '123456';

        CareService__c careOtherAccount = ICX_TestFactory.createCareService(acc.Id);
        careOtherAccount.RecordTypeId = StoreCareRTId;
        careOtherAccount.MyRepairStatus__c = 'draft';
        careOtherAccount.Shipping_Address_Line_1__c = 'address1';
        careOtherAccount.Shipping_City__c = 'Paris';
        careOtherAccount.Shipping_Country__c = 'FR';
        careOtherAccount.Shipping_State_Province__c = 'France';
        careOtherAccount.Shipping_Zip_Postal_Code__c = '123456';

        // Care Service should be ok
        CareService__c careAccepted = ICX_TestFactory.createCareService(acc.Id);
        careAccepted.RecordTypeId = StoreCareRTId;
        careAccepted.MyRepairStatus__c = 'orderAccepted';
        careAccepted.Shipping_Address_Line_1__c = 'address1';
        careAccepted.Shipping_City__c = 'Paris';
        careAccepted.Shipping_Country__c = 'FR';
        careAccepted.Shipping_State_Province__c = 'France';
        careAccepted.Shipping_Zip_Postal_Code__c = '123456';

        List<CareService__c> careList = new List<CareService__c>{careDelivered, careCancelled, careOtherAccount, careAccepted};
        insert careList;
        
		// Test
        Test.startTest();
        List<CareService__c> resultList = ICX_CaseDataServiceControllerLC.getCareServiceList(acc.Id);
        Test.stopTest();
        
        // Check
        System.assertEquals(2, resultList.size());
        //System.assertEquals(1, resultList.size());
        System.assertEquals(careAccepted.Id, resultList[1].Id);
        //System.assertEquals(careAccepted.Id, resultList[0].Id);
    }

    @isTest
    public static void updateRecord_Task_Test() {
        
        // Prepare
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
        Task task = ICX_TestFactory.creatCallTaskOnAccount(null);
        insert task;
        
        // Test
        Test.startTest();
        ICX_CaseDataServiceControllerLC.updateRecord(task.Id, acc.Id);
        Test.stopTest();

        // Check
        Task taskResult = [SELECT WhoId FROM Task WHERE Id = :task.Id];
        Account accResult = [SELECT PersonContactId FROM Account WHERE Id = :acc.Id];
        System.assertEquals(accResult.PersonContactId, taskResult.WhoId);
    }

    @isTest
    public static void updateRecord_Case_Test() {
        
        // Prepare
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
        Case cas = ICX_TestFactory.createCase(null);
        insert cas;
        
        // Test
        Test.startTest();
        ICX_CaseDataServiceControllerLC.updateRecord(cas.Id, acc.Id);
        Test.stopTest();

        // Check
        Case result = [SELECT ContactId FROM Case WHERE Id = :cas.Id];
        Account accResult = [SELECT PersonContactId FROM Account WHERE Id = :acc.Id];
        System.assertEquals(accResult.PersonContactId, result.ContactId);
    }

    @isTest
    public static void updateRecord_LiveChatTranscript_Test() {
        
        // Prepare
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
        LiveChatTranscript chat = ICX_TestFactory.createLiveChatTranscript();
        insert chat;

        // Test
        Test.startTest();
        ICX_CaseDataServiceControllerLC.updateRecord(chat.Id, acc.Id);
        Test.stopTest();

        // Check
        LiveChatTranscript result = [SELECT AccountId, ContactId FROM LiveChatTranscript WHERE Id = :chat.Id];
        Account accResult = [SELECT PersonContactId FROM Account WHERE Id = :acc.Id];
        System.assertEquals(accResult.PersonContactId, result.ContactId);
        System.assertEquals(acc.Id, result.AccountId);
    }

    @isTest
    public static void updateRecord_MessagingSession_Test() {
        
        // Prepare
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
        MessagingSession mess = createMessagingSession();
        insert mess;

        // Test
        Test.startTest();
        ICX_CaseDataServiceControllerLC.updateRecord(mess.Id, acc.Id);
        Test.stopTest();

        // Check
        MessagingSession result = [SELECT EndUserAccountId, EndUserContactId, MessagingEndUser.AccountId, MessagingEndUser.ContactId FROM MessagingSession WHERE Id = :mess.Id];
        Account accResult = [SELECT PersonContactId FROM Account WHERE Id = :acc.Id];
        System.assertEquals(accResult.PersonContactId, result.EndUserContactId);
        System.assertEquals(acc.Id, result.EndUserAccountId);

        System.assertEquals(accResult.PersonContactId, result.MessagingEndUser.ContactId);
        System.assertEquals(acc.Id, result.MessagingEndUser.AccountId);
    }

    private static MessagingSession createMessagingSession() {
        MessagingSession mess = new MessagingSession();
        mess.Status = 'New';

        MessagingChannel channel = createMessagingChannel();
        //insert channel;
        mess.MessagingChannelId = channel.Id;

        MessagingEndUser endUser = createMessagingEndUser(channel.Id);
        insert endUser;
        mess.MessagingEndUserId = endUser.Id;

        return mess;
    }

    private static MessagingChannel createMessagingChannel() {
        MessagingChannel chan = [SELECT Id FROM MessagingChannel WHERE IsActive = true LIMIT 1];
        return chan;
        //MessagingChannel channel = new MessagingChannel();
        //channel.MasterLabel = 'createMessagingChannel';
        //return channel;
    }

    private static MessagingEndUser createMessagingEndUser(Id messagingChannelId) {
        MessagingEndUser enduser = new MessagingEndUser();
        //enduser.MasterLabel = 'createMessagingChannel';
        endUser.Name = 'urn:mbid:AQAAYxyLnIW+0xi5lAsNUgJTkm8BWQtdk/vcCJZq/iKSznk0dXEHAU+/DmOnpjfhGglQtuONEci0tS4K+OvSWTMNIuEdENJ3QsDeVg4zt82V7DJKKPSTDB/...';
        endUser.messagingChannelId = messagingChannelId;
        endUser.MessageType = 'Text';//AppleBusinessChat'; // Apple doesn't work (error: UNKNOWN_EXCEPTION, To use this value, enable Messaging for Apple Business Chat)
        endUser.MessagingPlatformKey = 'urn:mbid:AQAAYxyLnIW+0xi5lAsNUgJTkm8BWQtdk/vcCJZq/iKSznk0dXEHAU+/DmOnpjfhGglQtuONEci0tS4K+OvSWTMNIuEdENJ3QsDeVg4zt82V7DJKKPSTDB/...';
        return enduser;
    }

    @isTest
    public static void updateRecord_CasesWithEmailMatching_Test() {
        // init
        String email = 'mytest@open.com';
        Case cas1 = ICX_TestFactory.createCase(null);
        cas1.SuppliedEmail = email;

        Case cas2 = ICX_TestFactory.createCase(null);
        cas2.SuppliedEmail = email;

        Case cas3 = ICX_TestFactory.createCase(null);
        cas3.SuppliedEmail = 'fake@mail.com';

        // Closed case
        Case closedCase = ICX_TestFactory.createCase(null);
        closedCase.SuppliedEmail = email;
        closedCase.Resolution__c = 'Immediate Response';
        closedCase.Type = ICX_CaseDataServiceControllerLC.CASE_TYPE_COMPLAINTS;
        closedCase.Category__c = 'Process';

        List<Case> caseList = new List<Case> {cas1, cas2, cas3, closedCase};
        insert caseList;

        // Create account
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        Test.startTest();
        ICX_CaseDataServiceControllerLC.updateRecord(cas1.Id, acc.Id);
        Test.stopTest();

        // Check
        Account accResult = [SELECT PersonContactId FROM Account WHERE Id = :acc.Id];
        List<Case> resultList = [SELECT Id, ContactId FROM Case WHERE ContactId = :accResult.PersonContactId];
        // cas1, cas2 and closedCase should be linked to ContactID
        System.assertEquals(3, resultList.size());
    }

    @isTest
    public static void getOpenCaseList_Account_Test() {
        // test case empty
        System.assertEquals(new List<Case>(), ICX_CaseDataServiceControllerLC.getOpenCaseList(null));
        
        // test 2
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        List<Case> caseList = new List<Case>();
        caseList.add(ICX_TestFactory.createCase(acc.Id));
        caseList.add(ICX_TestFactory.createCase(acc.Id));

        // test with a closed case
        Case closedCase = ICX_TestFactory.createCase(acc.Id);
        closedCase.Resolution__c = 'Immediate Response';
        closedCase.Type = ICX_CaseDataServiceControllerLC.CASE_TYPE_COMPLAINTS;
        closedCase.Category__c = 'Process';
        caseList.add(closedCase);

        insert caseList;
        
        Test.startTest();
        List<Case> resultList = ICX_CaseDataServiceControllerLC.getOpenCaseList(acc.Id);
        Test.stopTest();

        System.assertEquals(2, resultList.size());        
    }

    @isTest
    public static void getOpenCaseList_Case_Test() {
        // init
        String email = 'mytest@open.com';


        Case cas1 = ICX_TestFactory.createCase(null);
        cas1.SuppliedEmail = email;

        Case cas2 = ICX_TestFactory.createCase(null);
        cas2.SuppliedEmail = email;

        Case cas3 = ICX_TestFactory.createCase(null);
        cas3.SuppliedEmail = 'fake@mail.com';

        // test with a closed case
        Case closedCase = ICX_TestFactory.createCase(null);
        closedCase.SuppliedEmail = email;
        closedCase.Resolution__c = 'Immediate Response';
        closedCase.Type = ICX_CaseDataServiceControllerLC.CASE_TYPE_COMPLAINTS;
        closedCase.Category__c = 'Process';

        List<Case> caseList = new List<Case> {cas1, cas2, cas3, closedCase};
        insert caseList;
        
        Test.startTest();
        List<Case> resultList = ICX_CaseDataServiceControllerLC.getOpenCaseList(cas1.Id);
        Test.stopTest();

        // only cas1, cas2 should be retrieved
        System.assertEquals(2, resultList.size());        
    }

    @isTest
    public static void getComplaintIndicator_CaseTest() {

        // test
        Account acc = ICX_TestFactory.createAccount();
        insert acc;

        List<Case> caseList = new List<Case>();
        // test with a case NOT COMPLAINTS (should be not in getRecentComplaintCaseList() and getComplaintCaseList())
        caseList.add(ICX_TestFactory.createCase(acc.Id));

        // test with a complaint case not closed (should be in getRecentComplaintCaseList() and getComplaintCaseList())
        Case recentComplaintCase = ICX_TestFactory.createCase(acc.Id);
        //recentComplaintCase.Resolution__c = 'Immediate Response';
        recentComplaintCase.Type = ICX_CaseDataServiceControllerLC.CASE_TYPE_COMPLAINTS;
        recentComplaintCase.Category__c = 'Process';
        recentComplaintCase.Subject = 'subject';
        caseList.add(recentComplaintCase);

        // test with a complaint case CLOSED (should not be in getRecentComplaintCaseList() but ok for getComplaintCaseList())
        Case recentComplaintCase2 = ICX_TestFactory.createCase(acc.Id);
        recentComplaintCase2.Type = ICX_CaseDataServiceControllerLC.CASE_TYPE_COMPLAINTS;
        recentComplaintCase2.Category__c = 'Process';
        recentComplaintCase2.Resolution__c = 'Immediate Response';
        recentComplaintCase2.Subject = 'subject';
        caseList.add(recentComplaintCase2);

        insert caseList;
        
        Test.startTest();
        String result = ICX_CaseDataServiceControllerLC.getComplaintIndicator(acc.Id);
        Test.stopTest();
        
        ICX_CaseDataServiceControllerLC.ComplaintCaseWrapper resultWrapper = (ICX_CaseDataServiceControllerLC.ComplaintCaseWrapper) JSON.deserialize(result, ICX_CaseDataServiceControllerLC.ComplaintCaseWrapper.class);
        System.assertEquals(2, resultWrapper.complaintList.size());
        for (Case cas : resultWrapper.complaintList) {
            System.assertEquals('subject', cas.Subject);
        }

        System.assertEquals(1, resultWrapper.recentComplaintList.size());
        System.assertEquals(recentComplaintCase.Id, resultWrapper.recentComplaintList.get(0).Id);     
    }

	@isTest
    public static void getComplaintIndicator_CaseWithEmailMatchingTest() {
        // init
        String email = 'mytest@open.com';

        Case cas1 = ICX_TestFactory.createCase(null);
        cas1.SuppliedEmail = email;
        cas1.Type = ICX_CaseDataServiceControllerLC.CASE_TYPE_COMPLAINTS;
        cas1.Category__c = 'Process';
        cas1.Subject = 'subject';

        Case cas2 = ICX_TestFactory.createCase(null);
        cas2.SuppliedEmail = email;
        cas2.Type = ICX_CaseDataServiceControllerLC.CASE_TYPE_COMPLAINTS;
        cas2.Category__c = 'Process';
        cas2.Subject = 'subject';

        // test without email matching
        Case cas3 = ICX_TestFactory.createCase(null);
        cas3.SuppliedEmail = 'fake@mail.com';
        cas3.Type = ICX_CaseDataServiceControllerLC.CASE_TYPE_COMPLAINTS;
        cas3.Category__c = 'Process';
        cas3.Subject = 'subject';

        // test with a closed case
        Case closedCase = ICX_TestFactory.createCase(null);
        closedCase.SuppliedEmail = email;
        closedCase.Resolution__c = 'Immediate Response';
        closedCase.Type = ICX_CaseDataServiceControllerLC.CASE_TYPE_COMPLAINTS;
        closedCase.Category__c = 'Process';
        closedCase.Subject = 'subject';

        List<Case> caseList = new List<Case> {cas1, cas2, cas3, closedCase};
        insert caseList;
        
        Test.startTest();
        String result = ICX_CaseDataServiceControllerLC.getComplaintIndicator(cas1.Id);
        Test.stopTest();
        
        ICX_CaseDataServiceControllerLC.ComplaintCaseWrapper resultWrapper = (ICX_CaseDataServiceControllerLC.ComplaintCaseWrapper) JSON.deserialize(result, ICX_CaseDataServiceControllerLC.ComplaintCaseWrapper.class);
        // only cas1, cas2, closedCase should be retrieved
        System.assertEquals(3, resultWrapper.complaintList.size());
        for (Case cas : resultWrapper.complaintList) {
            System.assertEquals('subject', cas.Subject);
        }

        // code commented (recentComplaintList is not used, maybe comment this method)
        //System.assertEquals(0, resultWrapper.recentComplaintList.size());
        //System.assertEquals(recentComplaintCase.Id, resultWrapper.recentComplaintList.get(0).Id);           
    }

    @isTest
    public static void getIndicatorList_Test() {
        // Init
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
        MessagingSession mess = createMessagingSession();
        insert mess;

        MessagingSession mess2 = [SELECT MessagingEndUserId FROM MessagingSession WHERE Id = :mess.Id LIMIT 1];
        MessagingEndUser endUser = new MessagingEndUser(Id = mess2.MessagingEndUserId);
        endUser.AccountId = acc.Id;
        update endUser;

        Case cas = ICX_TestFactory.createCase(acc.Id);
        insert cas;

        //Test
        ICX_CaseDataServiceControllerLC.IndicatorWrapper result;
        //System.runAs(iconicsUser) {
        Test.startTest();
        result = (ICX_CaseDataServiceControllerLC.IndicatorWrapper) ICX_CaseDataServiceControllerLC.getIndicatorList(acc.Id);
        Test.stopTest();
        //}

        // Check
        System.assertEquals(1, result.openCaseList.size());
        System.assertEquals(cas.Id, result.openCaseList[0].id);
        System.assertEquals(0, result.complaintList.size());
        System.assertEquals(0, result.careList.size());
        System.assertEquals(1, result.openMessagingList.size());
        System.assertEquals(mess.Id, result.openMessagingList[0].id);
    }
    
    @isTest
    public static void updateRecord_Alias_Test() {
        
        // Prepare
        Account acc = ICX_TestFactory.createAccount();
        insert acc;
        
        Alias__c a = new Alias__c(Name='test',Country__c='USA');
        insert a;

        // Test
        Test.startTest();
        ICX_CaseDataServiceControllerLC.updateRecord(a.Id, acc.Id);
        Test.stopTest();

        // Check
        Alias_Member__c result = [SELECT Client__c,Alias__c FROM Alias_Member__c WHERE Alias__c = :a.Id];
        Account accResult = [SELECT PersonContactId FROM Account WHERE Id = :acc.Id];
       

        System.assertEquals(a.Id, result.Alias__c);
        System.assertEquals(acc.Id, result.Client__c);
    }
        */
}